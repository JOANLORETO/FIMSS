import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TakeTurnScreen extends StatefulWidget {
  final int colaId;
  final String unidadNombre;
  final String servicioNombre;
  final String prefijo;

  const TakeTurnScreen({
    super.key,
    required this.colaId,
    required this.unidadNombre,
    required this.servicioNombre,
    required this.prefijo,
  });

  @override
  State<TakeTurnScreen> createState() => _TakeTurnScreenState();
}

class _TakeTurnScreenState extends State<TakeTurnScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = false;
  int? myTurn;
  int peopleAhead = 0;

  Future<void> takeTurn() async {
    if (isLoading || myTurn != null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 1. Consultamos el último turno de esta cola.
      final lastTurnResponse = await supabase
          .from('turnos')
          .select('numero')
          .eq('cola_id', widget.colaId)
          .order('numero', ascending: false)
          .limit(1);

      int nextNumber = 1;

      if (lastTurnResponse.isNotEmpty) {
        final lastNumber = lastTurnResponse.first['numero'] as int;
        nextNumber = lastNumber + 1;
      }

      // Identificador temporal para nuestra prueba.
      final userId =
          'demo-${DateTime.now().millisecondsSinceEpoch}';

      // 2. Insertamos el nuevo turno.
      await supabase.from('turnos').insert({
        'cola_id': widget.colaId,
        'numero': nextNumber,
        'estado': 'esperando',
        'identificador_usuario': userId,
      });

      // 3. Calculamos cuántas personas están delante.
      final aheadResponse = await supabase
          .from('turnos')
          .select('id')
          .eq('cola_id', widget.colaId)
          .eq('estado', 'esperando')
          .lt('numero', nextNumber);

      if (!mounted) return;

      setState(() {
        myTurn = nextNumber;
        peopleAhead = aheadResponse.length;
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
            'No fue posible obtener tu turno: $error',
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: myTurn == null
            ? _buildTakeTurn()
            : _buildMyTurn(),
      ),
    );
  }

  Widget _buildTakeTurn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),

        const Icon(
          Icons.confirmation_number_outlined,
          size: 80,
          color: Color(0xFF006B54),
        ),

        const SizedBox(height: 25),

        Text(
          widget.unidadNombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          widget.servicioNombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),

        const Spacer(),

        SizedBox(
          height: 65,
          child: ElevatedButton(
            onPressed: isLoading ? null : takeTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006B54),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isLoading
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
        const SizedBox(height: 25),

        const Text(
          '¡Turno obtenido!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 35),

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
                '${widget.prefijo}-${myTurn!}',
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
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          widget.servicioNombre,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
