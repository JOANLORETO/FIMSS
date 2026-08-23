import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualEntryScreen extends StatefulWidget {
  final String? qrData;

  const ManualEntryScreen({
    super.key,
    this.qrData,
  });

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController nssController =
      TextEditingController();

  bool isLoading = false;
  bool isLoadingServices = false;

  String? unidadNombre;
  int? unidadId;
  int? colaQrId;
  int? servicioQrId;

  List<Map<String, dynamic>> servicios = [];

  int? servicioSeleccionadoId;
  String? servicioSeleccionadoNombre;
  int? colaSeleccionadaId;

  @override
  void initState() {
    super.initState();

    debugPrint(
      'FIMSS QR REAL: ${widget.qrData}',
    );
  }

  @override
  void dispose() {
    nssController.dispose();
    super.dispose();
  }

  // ============================================================
  // LEER DATOS DEL QR
  // ============================================================

  String? _getQrValue(String key) {
    final qr = widget.qrData?.trim();

    if (qr == null || qr.isEmpty) {
      return null;
    }

    final match = RegExp(
      '$key\\s*=\\s*([^|\\]]+)',
      caseSensitive: false,
    ).firstMatch(qr);

    return match?.group(1)?.trim();
  }

  // ============================================================
  // CONSULTAR UNIDAD
  // ============================================================

  Future<void> _consultarUnidad() async {
    final nss = nssController.text.trim();

    if (nss.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El NSS debe contener 11 dígitos.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // 1. LEER EL QR
      // --------------------------------------------------------

      final qrColaId =
          int.tryParse(_getQrValue('cola_id') ?? '');

      final qrUnidadId =
          int.tryParse(_getQrValue('unidad_id') ?? '');

      final qrServicioId =
          int.tryParse(_getQrValue('servicio_id') ?? '');

      debugPrint(
        'FIMSS QR → '
        'cola=$qrColaId '
        'unidad=$qrUnidadId '
        'servicio=$qrServicioId',
      );

      if (qrColaId == null) {
        throw Exception(
          'El QR no contiene un cola_id válido.',
        );
      }

      // --------------------------------------------------------
      // 2. BUSCAR LA COLA
      // --------------------------------------------------------

      final cola = await supabase
          .from('colas')
          .select(
            'id, prefijo, unidad_id, servicio_id',
          )
          .eq('id', qrColaId)
          .maybeSingle();

      debugPrint(
        'FIMSS COLA SUPABASE: $cola',
      );

      if (cola == null) {
        throw Exception(
          'No se encontró la cola $qrColaId en Supabase.',
        );
      }

      final int nuevaColaId =
          cola['id'] as int;

      final int nuevaUnidadId =
          cola['unidad_id'] as int;

      final int nuevoServicioId =
          cola['servicio_id'] as int;

      // --------------------------------------------------------
      // 3. BUSCAR LA UNIDAD
      // --------------------------------------------------------

      String nombreUnidad =
          'Unidad FIMSS';

      try {
        final unidad = await supabase
            .from('unidades')
            .select('id, nombre')
            .eq('id', nuevaUnidadId)
            .maybeSingle();

        debugPrint(
          'FIMSS UNIDAD SUPABASE: $unidad',
        );

        if (unidad != null &&
            unidad['nombre'] != null) {
          nombreUnidad =
              unidad['nombre'].toString();
        }
      } catch (error) {
        debugPrint(
          'FIMSS AVISO UNIDAD: $error',
        );
      }

      // --------------------------------------------------------
      // 4. SI LA TABLA UNIDADES NO DEVUELVE EL NOMBRE,
      //    USAMOS EL NOMBRE QUE VIENE EN EL QR
      // --------------------------------------------------------

      if (nombreUnidad == 'Unidad FIMSS') {
        final qr = widget.qrData ?? '';

        final partes = qr
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split('|');

        if (partes.length >= 5) {
          final posibleNombre =
              partes[4].trim();

          if (posibleNombre.isNotEmpty) {
            nombreUnidad =
                posibleNombre;
          }
        }
      }

      // --------------------------------------------------------
      // 5. ACTUALIZAR PANTALLA
      // --------------------------------------------------------

      if (!mounted) return;

      setState(() {
        colaQrId = nuevaColaId;
        unidadId = nuevaUnidadId;
        servicioQrId = nuevoServicioId;
        unidadNombre = nombreUnidad;
        isLoading = false;
      });

      debugPrint(
        'FIMSS UNIDAD FINAL: '
        '$nuevaUnidadId - $nombreUnidad',
      );

      // --------------------------------------------------------
      // 6. CARGAR SERVICIOS
      // --------------------------------------------------------

      await _cargarServicios(nuevaUnidadId);

    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint(
        'FIMSS ERROR: $error',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible identificar la unidad:\n$error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CARGAR SERVICIOS DE LA UNIDAD
  // ============================================================

  Future<void> _cargarServicios(int unidadId) async {
    if (!mounted) return;

    setState(() {
      isLoadingServices = true;
    });

    try {
      final colas = await supabase
          .from('colas')
          .select(
            'id, prefijo, unidad_id, servicio_id',
          )
          .eq('unidad_id', unidadId)
          .order('id');

      debugPrint(
        'FIMSS COLAS DE UNIDAD: $colas',
      );

      final List<Map<String, dynamic>> resultado = [];

      for (final cola in colas) {
        final int? colaId =
            cola['id'] as int?;

        final int? servicioId =
            cola['servicio_id'] as int?;

        if (colaId == null ||
            servicioId == null) {
          continue;
        }

        try {
          final servicio = await supabase
              .from('servicios')
              .select('id, nombre')
              .eq('id', servicioId)
              .maybeSingle();

          debugPrint(
            'FIMSS SERVICIO $servicioId: $servicio',
          );

          if (servicio != null) {
            resultado.add({
              'cola_id': colaId,
              'servicio_id': servicioId,
              'prefijo': cola['prefijo'],
              'nombre':
                  servicio['nombre']?.toString() ??
                      'Servicio',
            });
          }
        } catch (error) {
          debugPrint(
            'FIMSS ERROR SERVICIO: $error',
          );
        }
      }

      // --------------------------------------------------------
      // SI NO HAY SERVICIOS, USAR EL SERVICIO DEL QR
      // --------------------------------------------------------

      if (resultado.isEmpty &&
          colaQrId != null &&
          servicioQrId != null) {
        String nombreServicio =
            'Consulta médica';

        try {
          final servicio = await supabase
              .from('servicios')
              .select('id, nombre')
              .eq('id', servicioQrId!)
              .maybeSingle();

          if (servicio != null &&
              servicio['nombre'] != null) {
            nombreServicio =
                servicio['nombre'].toString();
          }
        } catch (_) {}

        resultado.add({
          'cola_id': colaQrId,
          'servicio_id': servicioQrId,
          'prefijo': 'A',
          'nombre': nombreServicio,
        });
      }

      if (!mounted) return;

      setState(() {
        servicios = resultado;
        isLoadingServices = false;
      });

      debugPrint(
        'FIMSS SERVICIOS FINALES: $resultado',
      );

    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingServices = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible cargar los servicios:\n$error',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SELECCIONAR SERVICIO
  // ============================================================

  void _seleccionarServicio(
    Map<String, dynamic> servicio,
  ) {
    setState(() {
      servicioSeleccionadoId =
          servicio['servicio_id'] as int?;

      servicioSeleccionadoNombre =
          servicio['nombre']?.toString();

      colaSeleccionadaId =
          servicio['cola_id'] as int?;
    });

    debugPrint(
      'FIMSS SERVICIO SELECCIONADO: '
      '$servicioSeleccionadoNombre '
      'cola=$colaSeleccionadaId',
    );
  }

  // ============================================================
  // CONTINUAR
  // ============================================================

  void _continuar() {
    if (servicioSeleccionadoId == null ||
        colaSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona un servicio para continuar.',
          ),
        ),
      );
      return;
    }

    debugPrint(
      'FIMSS FILA: '
      'NSS=${nssController.text.trim()} '
      'unidad=$unidadId '
      'servicio=$servicioSeleccionadoId '
      'cola=$colaSeleccionadaId',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Servicio seleccionado: '
          '$servicioSeleccionadoNombre',
        ),
      ),
    );
  }

  // ============================================================
  // BOTÓN SERVICIO
  // ============================================================

  Widget _serviceButton(
    Map<String, dynamic> servicio,
  ) {
    final int? servicioId =
        servicio['servicio_id'] as int?;

    final bool seleccionado =
        servicioSeleccionadoId == servicioId;

    final String nombre =
        servicio['nombre']?.toString() ??
            'Servicio';

    IconData icon =
        Icons.medical_services_outlined;

    final String nombreLower =
        nombre.toLowerCase();

    if (nombreLower.contains('laboratorio')) {
      icon = Icons.science_outlined;
    } else if (nombreLower.contains('cirug')) {
      icon = Icons.local_hospital_outlined;
    } else if (nombreLower.contains('farmacia')) {
      icon = Icons.medication_outlined;
    }

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 62,
        child: OutlinedButton.icon(
          onPressed: () {
            _seleccionarServicio(servicio);
          },
          icon: Icon(icon),
          label: Text(
            nombre,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                const Color(0xFF006B54),
            backgroundColor: seleccionado
                ? const Color(0xFFE2F1EC)
                : Colors.white,
            side: BorderSide(
              color:
                  const Color(0xFF006B54),
              width:
                  seleccionado ? 2 : 1,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool unidadEncontrada =
        unidadNombre != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FIMSS'),
        backgroundColor:
            const Color(0xFF006B54),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),

              const Icon(
                Icons.badge_outlined,
                size: 70,
                color:
                    Color(0xFF006B54),
              ),

              const SizedBox(height: 20),

              const Text(
                'Número de Seguridad Social',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Ingresa tu NSS para continuar',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller:
                    nssController,
                keyboardType:
                    TextInputType.number,
                textInputAction:
                    TextInputAction.done,
                maxLength: 11,
                decoration:
                    InputDecoration(
                  labelText: 'NSS',
                  hintText:
                      'Ejemplo: 12345678901',
                  prefixIcon:
                      const Icon(
                    Icons.person_outline,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
                onSubmitted: (_) {
                  _consultarUnidad();
                },
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : _consultarUnidad,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                            0xFF006B54),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'CONTINUAR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (unidadEncontrada) ...[
                const SizedBox(height: 35),

                Container(
                  padding:
                      const EdgeInsets.all(22),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                            0xFFE2F1EC),
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        size: 48,
                        color:
                            Color(0xFF006B54),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'UNIDAD IDENTIFICADA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        unidadNombre!,
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF006B54),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  '¿Qué servicio necesitas?',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Selecciona el servicio que deseas utilizar',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                if (isLoadingServices)
                  const Padding(
                    padding:
                        EdgeInsets.all(25),
                    child: Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            Color(0xFF006B54),
                      ),
                    ),
                  )
                else if (servicios.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.orange.shade50,
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: const Text(
                      'No hay servicios disponibles '
                      'para esta unidad.',
                      textAlign:
                          TextAlign.center,
                    ),
                  )
                else
                  ...servicios.map(
                    _serviceButton,
                  ),

                if (servicioSeleccionadoNombre !=
                    null) ...[
                  const SizedBox(height: 10),

                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                      border: Border.all(
                        color:
                            const Color(
                                0xFF006B54),
                      ),
                    ),
                    child: Text(
                      'Servicio seleccionado:\n'
                      '$servicioSeleccionadoNombre',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF006B54),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 60,
                    child:
                        ElevatedButton(
                      onPressed:
                          _continuar,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF006B54),
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                      ),
                      child: const Text(
                        'CONTINUAR A LA FILA',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 25),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
