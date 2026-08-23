import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MiTurnoScreen extends StatefulWidget {
  const MiTurnoScreen({super.key});

  @override
  State<MiTurnoScreen> createState() => _MiTurnoScreenState();
}

class _MiTurnoScreenState extends State<MiTurnoScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nssController = TextEditingController();

  bool isLoading = false;

  String? turno;
  String? estado;
  String? unidad;
  String? servicio;
  String? mensaje;

  @override
  void dispose() {
    nssController.dispose();
    super.dispose();
  }

  Future<void> _buscarTurno() async {
    final nss = nssController.text.trim();

    if (nss.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu Número de Seguridad Social.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      mensaje = null;
      turno = null;
      estado = null;
      unidad = null;
      servicio = null;
    });

    try {
      debugPrint('FIMSS MI TURNO: buscando NSS=$nss');

      final resultado = await supabase
          .from('filas')
          .select()
          .eq('nss', nss)
          .maybeSingle();

      debugPrint('FIMSS MI TURNO RESULTADO: $resultado');

      if (!mounted) return;

      if (resultado == null) {
        setState(() {
          isLoading = false;
          mensaje = 'No encontramos un turno activo para este NSS.';
        });
        return;
      }

      setState(() {
        turno = resultado['turno']?.toString();
        estado = resultado['estado']?.toString() ?? 'En espera';
        unidad = resultado['unidad_nombre']?.toString();
        servicio = resultado['servicio_nombre']?.toString();
        isLoading = false;
      });
    } catch (error) {
      debugPrint('FIMSS MI TURNO ERROR: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        mensaje = 'No fue posible consultar tu turno.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi turno'),
        backgroundColor: const Color(0xFF006B54),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),

              const Icon(
                Icons.confirmation_number_outlined,
                size: 75,
                color: Color(0xFF006B54),
              ),

              const SizedBox(height: 20),

              const Text(
                'Consulta tu turno',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Ingresa tu Número de Seguridad Social para consultar tu fila.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nssController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 11,
                onSubmitted: (_) => _buscarTurno(),
                decoration: InputDecoration(
                  labelText: 'Número de Seguridad Social',
                  hintText: 'Ejemplo: 12345678901',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _buscarTurno,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'CONSULTAR MI TURNO',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (mensaje != null) ...[
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    mensaje!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              if (turno != null) ...[
                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F1EC),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TU TURNO',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        turno!,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B54),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (unidad != null)
                        _dato(
                          Icons.local_hospital_outlined,
                          'Unidad',
                          unidad!,
                        ),

                      if (servicio != null)
                        _dato(
                          Icons.medical_services_outlined,
                          'Servicio',
                          servicio!,
                        ),

                      _dato(
                        Icons.info_outline,
                        'Estado',
                        estado ?? 'En espera',
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

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
          ),
        ),
      ),
    );
  }

  Widget _dato(
    IconData icon,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF006B54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
