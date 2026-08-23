import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/mi_turno_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const FimssApp());
}

class FimssApp extends StatelessWidget {
  const FimssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIMSS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B54),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Text(
                'FIMSS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF006B54),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tu turno, sin hacer fila',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 50),

              // =================================================
              // ESCANEAR QR
              // =================================================

              SizedBox(
                height: 65,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QRScannerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    size: 30,
                  ),
                  label: const Text(
                    'ESCANEAR QR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // MI TURNO
              // =================================================

              SizedBox(
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MiTurnoScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.confirmation_number_outlined,
                  ),
                  label: const Text(
                    'MI TURNO',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF006B54),
                    side: const BorderSide(
                      color: Color(0xFF006B54),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const _InfoCard(
                icon: Icons.access_time,
                title: 'Ahorra tiempo',
                text:
                    'Espera tu turno sin permanecer formado físicamente.',
              ),

              const SizedBox(height: 14),

              const _InfoCard(
                icon: Icons.notifications_active_outlined,
                title: 'Recibe avisos',
                text:
                    'Te avisaremos cuando tu turno esté próximo.',
              ),

              const SizedBox(height: 14),

              const _InfoCard(
                icon: Icons.qr_code_2,
                title: 'Fácil de usar',
                text:
                    'Escanea un QR y entra rápidamente a la fila virtual.',
              ),

              const SizedBox(height: 40),

              const Text(
                'FIMSS • Sistema de fila virtual',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 3),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color(0xFF006B54),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
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
