import 'package:flutter/material.dart';
import 'lib/theme/app_theme.dart';
import 'lib/views/login_view.dart';

void main() {
  runApp(const PalateApp());
}

/// Clase raíz de la aplicación Palate.
/// Configura el tema global y establece la pantalla de inicio de sesión
/// como punto de entrada de la navegación.
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
