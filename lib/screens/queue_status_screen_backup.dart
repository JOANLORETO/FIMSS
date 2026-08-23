import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QueueStatusScreen extends StatefulWidget {
  final String patientId;

  const QueueStatusScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = true;
  bool isTakingTurn = false;

  String clinic = 'Cargando...';
  String service = 'Cargando...';
  String prefix = 'A';

  int colaId = 1;
  int peopleWaiting = 0;

  int? myTurn;
  int? myTurnId;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedTurnId = prefs.getInt('turno_id');

      final cola = await supabase
          .from('colas')
          .select('id, prefijo, unidad_id, servicio_id')
          .eq('id', 1)
          .maybeSingle();

      if (cola == null) {
        throw Exception('No se encontró la cola.');
      }

      final unidad = await supabase
          .from('unidades')
          .select('nombre')
          .eq('id', cola['unidad_id'])
          .maybeSingle();

      final servicio = await supabase
          .from('servicios')
          .select('nombre')
          .eq('id', cola['servicio_id'])
          .maybeSingle();

      final waiting = await supabase
          .from('turnos')
          .select('id')
          .eq('cola_id', cola['id'])
          .eq('estado', 'esperando');

      int? savedNumber;

      // Primero buscamos el turno guardado en este teléfono.
      if (savedTurnId != null) {
        final savedTurn = await supabase
            .from('turnos')
            .select('id, numero, estado, cola_id')
            .eq('id', savedTurnId)
            .maybeSingle();

        if (savedTurn != null &&
            savedTurn['estado'] != 'atendido' &&
            savedTurn['estado'] != 'cancelado') {
          savedNumber = savedTurn['numero'] as int;
          myTurnId = savedTurn['id'] as int;
        }
      }

      // Si no encontramos turno guardado, buscamos por el identificador
      // utilizado al escanear el QR.
      if (savedNumber == null && widget.patientId.isNotEmpty) {
        final patientTurn = await supabase
            .from('turnos')
            .select('id, numero, estado')
            .eq('cola_id', cola['id'])
            .eq('identificador_usuario', widget.patientId)
            .inFilter('estado', ['esperando', 'llamado'])
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle();

        if (patientTurn != null) {
          savedNumber = patientTurn['numero'] as int;
          myTurnId = patientTurn['id'] as int;

          await prefs.setInt(
            'turno_id',
            patientTurn['id'] as int,
          );
        }
      }

      if (!mounted) return;

      setState(() {
        colaId = cola['id'] as int;
        prefix = cola['prefijo'] as String;
        clinic = unidad?['nombre'] ?? 'Unidad FIMSS';
        service = servicio?['nombre'] ?? 'Servicio';
        peopleWaiting = waiting.length;

        myTurn = savedNumber;

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al consultar la fila:\n$error',
          ),
        ),
      );
    }
  }

  Future<void> _takeTurn() async {
    if (isTakingTurn || myTurn != null) return;

    setState(() {
      isTakingTurn = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Revisamos si ya existe un turno activo guardado.
      final existingTurnId = prefs.getInt('turno_id');

      if (existingTurnId != null) {
        final existingTurn = await supabase
            .from('turnos')
            .select('id, numero, estado')
            .eq('id', existingTurnId)
            .maybeSingle();

        if (existingTurn != null &&
            existingTurn['estado'] != 'atendido' &&
            existingTurn['estado'] != 'cancelado') {
          if (!mounted) return;

          setState(() {
            myTurnId = existingTurn['id'] as int;
            myTurn = existingTurn['numero'] as int;
            isTakingTurn = false;
          });

          return;
        }
      }

      // Obtenemos el último número.
      final lastTurn = await supabase
          .from('turnos')
          .select('numero')
          .eq('cola_id', colaId)
          .order('numero', ascending: false)
          .limit(1);

      int nextNumber = 1;

      if (lastTurn.isNotEmpty) {
        nextNumber = (lastTurn.first['numero'] as int) + 1;
      }

      // El QR identifica al usuario.
      final userId = widget.patientId.isNotEmpty
          ? widget.patientId
          : 'demo-${DateTime.now().millisecondsSinceEpoch}';

      // Creamos el turno.
      final inserted = await supabase
          .from('turnos')
          .insert({
            'cola_id': colaId,
            'numero': nextNumber,
            'estado': 'esperando',
            'identificador_usuario': userId,
          })
          .select('id, numero')
          .single();

      final insertedId = inserted['id'] as int;
      final insertedNumber = inserted['numero'] as int;

      // Guardamos el ID REAL del turno en el teléfono.
      await prefs.setInt('turno_id', insertedId);

      // Personas delante.
      final ahead = await supabase
          .from('turnos')
          .select('id')
          .eq('cola_id', colaId)
          .eq('estado', 'esperando')
          .lt('numero', insertedNumber);

      if (!mounted) return;

      setState(() {
        myTurnId = insertedId;
        myTurn = insertedNumber;
        peopleWaiting = ahead.length;
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
          Icons.local_hospital_outlined,
          size: 70,
          color: Color(0xFF006B54),
        ),

        const SizedBox(height: 20),

        Text(
          clinic,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          service,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
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
                '$peopleWaiting',
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
                '$prefix-${myTurn.toString().padLeft(3, '0')}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006B54),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                peopleWaiting == 0
                    ? 'Eres el siguiente en la fila'
                    : 'Personas delante: $peopleWaiting',
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
          clinic,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          service,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
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
