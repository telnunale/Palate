import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'views/login_view.dart';

Future<void> main() async {
  // Garantiza que los plugins de Flutter esten inicializados antes de
  // realizar llamadas asincronas a paquetes nativos.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de notificaciones de forma defensiva: si fallase
  // por algun motivo, la app continua arrancando con normalidad y los
  // temporizadores funcionarian solo en primer plano.
  try {
    await NotificationService.instancia.init();
  } catch (_) {
    // Inicializacion fallida; la app sigue funcionando sin notificaciones
  }

  runApp(const PalateApp());
}

class PalateApp extends StatelessWidget {
  const PalateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palate',
      debugShowCheckedModeBanner: false,
      // Se aplica el tema centralizado definido en AppTheme
      theme: AppTheme.tema,
      home: const LoginView(),
    );
  }
}
