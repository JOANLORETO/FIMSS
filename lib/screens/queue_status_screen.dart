import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QueueStatusScreen extends StatefulWidget {
  final String patientId;
  final int colaId;
  final int unidadId;
  final int servicioId;
  final String unidadNombre;
  final String servicioNombre;
  final String prefijo;

  const QueueStatusScreen({
    super.key,
    required this.patientId,
    required this.colaId,
    required this.unidadId,
    required this.servicioId,
    required this.unidadNombre,
    required this.servicioNombre,
    required this.prefijo,
  });

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = true;
  bool isTakingTurn = false;

  int peopleAhead = 0;
  int? myTurn;
  int? myTurnId;

  String get nss => widget.patientId.trim();

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final existingTurn = await supabase
          .from('turnos')
          .select('id, numero, estado')
          .eq('cola_id', widget.colaId)
          .eq('identificador_usuario', nss)
          .inFilter('estado', ['esperando', 'llamado'])
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existingTurn != null) {
        final id = existingTurn['id'] as int;
        final numero = existingTurn['numero'] as int;

        await prefs.setInt('turno_id', id);
        await prefs.setString('turno_nss', nss);

        await _calculatePeopleAhead(numero);

        if (!mounted) return;

        setState(() {
          myTurnId = id;
          myTurn = numero;
          isLoading = false;
        });

        return;
      }

      final waiting = await supabase
          .from('turnos')
          .select('id')
          .eq('cola_id', widget.colaId)
          .eq('estado', 'esperando');

      if (!mounted) return;

      setState(() {
        peopleAhead = waiting.length;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al consultar la fila:\n$error'),
        ),
      );
    }
  }

  Future<void> _calculatePeopleAhead(int number) async {
    final ahead = await supabase
        .from('turnos')
        .select('id')
        .eq('cola_id', widget.colaId)
        .eq('estado', 'esperando')
        .lt('numero', number);

    peopleAhead = ahead.length;
  }

  Future<void> _takeTurn() async {
    if (isTakingTurn || myTurn != null) {
      return;
    }

    if (nss.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se recibió un NSS válido.'),
        ),
      );
      return;
    }

    setState(() {
      isTakingTurn = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // ========================================================
      // 1. VERIFICAR SI ESTE NSS YA TIENE TURNO
      // ========================================================

      final existingTurn = await supabase
          .from('turnos')
          .select('id, numero, estado')
          .eq('cola_id', widget.colaId)
          .eq('identificador_usuario', nss)
          .inFilter('estado', ['esperando', 'llamado'])
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existingTurn != null) {
        final id = existingTurn['id'] as int;
        final numero = existingTurn['numero'] as int;

        await prefs.setInt('turno_id', id);
        await prefs.setString('turno_nss', nss);

        await _calculatePeopleAhead(numero);

        if (!mounted) return;

        setState(() {
          myTurnId = id;
          myTurn = numero;
          isTakingTurn = false;
        });

        return;
      }

      // ========================================================
      // 2. OBTENER EL SIGUIENTE NÚMERO
      // ========================================================

      final lastTurn = await supabase
          .from('turnos')
          .select('numero')
          .eq('cola_id', widget.colaId)
          .order('numero', ascending: false)
          .limit(1);

      int nextNumber = 1;

      if (lastTurn.isNotEmpty) {
        nextNumber = (lastTurn.first['numero'] as int) + 1;
      }

      // ========================================================
      // 3. CREAR TURNO
      // ========================================================

      final inserted = await supabase
          .from('turnos')
          .insert({
            'cola_id': widget.colaId,
            'numero': nextNumber,
            'estado': 'esperando',
            'identificador_usuario': nss,
          })
          .select('id, numero')
          .single();

      final insertedId = inserted['id'] as int;
      final insertedNumber = inserted['numero'] as int;

      // ========================================================
      // 4. GUARDAR EN EL TELÉFONO
      // ========================================================

      await prefs.setInt('turno_id', insertedId);
      await prefs.setString('turno_nss', nss);

      // ========================================================
      // 5. CALCULAR PERSONAS DELANTE
      // ========================================================

      await _calculatePeopleAhead(insertedNumber);

      if (!mounted) return;

      setState(() {
        myTurnId = insertedId;
        myTurn = insertedNumber;
        isTakingTurn = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isTakingTurn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible tomar turno:\n$error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIMSS'),
        backgroundColor: const Color(0xFF006B54),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: myTurn == null
                  ? _buildQueue()
                  : _buildMyTurn(),
            ),
    );
  }

  Widget _buildQueue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 25),

        const Icon(
          Icons.groups_outlined,
          size: 70,
          color: Color(0xFF006B54),
        ),

        const SizedBox(height: 20),

        const Text(
          'Servicio seleccionado',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          widget.servicioNombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B54),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          widget.unidadNombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),

        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F1EC),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const Text(
                'PERSONAS ESPERANDO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '$peopleAhead',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B54),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        SizedBox(
          height: 65,
          child: ElevatedButton(
            onPressed: isTakingTurn ? null : _takeTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B54),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isTakingTurn
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text(
                    'TOMAR TURNO',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildMyTurn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),

        const Text(
          '¡Turno obtenido!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFFE2F1EC),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              const Text(
                'TU TURNO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '${
                  widget.prefijo
                }-${myTurn.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B54),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                peopleAhead == 0
                    ? 'Eres el siguiente en la fila'
                    : 'Personas delante: $peopleAhead',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        Text(
          widget.unidadNombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          widget.servicioNombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'NSS: $nss',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black45,
          ),
        ),

        const Spacer(),

        SizedBox(
          height: 55,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF006B54),
              side: const BorderSide(
                color: Color(0xFF006B54),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'VOLVER',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
