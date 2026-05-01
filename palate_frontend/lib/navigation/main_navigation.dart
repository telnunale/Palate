import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario.dart';
import '../views/home_view.dart';
import '../views/recetas_view.dart';
import '../views/despensa_view.dart';
import '../views/perfil_view.dart';

/// Pantalla raíz de la aplicación tras el inicio de sesión.
/// Contiene la barra de navegación inferior y gestiona qué
/// sección se muestra en cada momento.
class MainNavigation extends StatefulWidget {
  /// Usuario autenticado, pasado desde la pantalla de login
  final Usuario usuario;

  const MainNavigation({super.key, required this.usuario});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  /// Índice de la pestaña actualmente seleccionada
  int _indiceSeleccionado = 0;

  /// Las cuatro secciones principales de la aplicación.
  /// Se usa [IndexedStack] para mantener el estado de cada pestaña
  /// al cambiar entre ellas.
  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pantallas = [
      HomeView(usuario: widget.usuario),
      const RecetasView(),
      const DespensaView(),
      const PerfilView(),
    ];
  }

  /// Cambia la pestaña visible al tocar un elemento de la barra inferior.
  void _onTabSeleccionado(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene el estado de cada pestaña activa en memoria,
      // evitando recargar datos al volver a una pestaña ya visitada
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: _pantallas,
      ),
      bottomNavigationBar: _BarraNavegacion(
        indiceSeleccionado: _indiceSeleccionado,
        onTabSeleccionado: _onTabSeleccionado,
      ),
    );
  }
}

/// Widget de la barra de navegación inferior personalizada.
/// Replica el diseño del sistema con fondo translúcido, esquinas
/// superiores redondeadas e indicador de pestaña activa.
class _BarraNavegacion extends StatelessWidget {
  final int indiceSeleccionado;
  final ValueChanged<int> onTabSeleccionado;

  const _BarraNavegacion({
    required this.indiceSeleccionado,
    required this.onTabSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7).withOpacity(0.97),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF732b16).withOpacity(0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF91412b).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ItemNavegacion(
                icono: Icons.home_outlined,
                iconoActivo: Icons.home,
                etiqueta: 'Inicio',
                activo: indiceSeleccionado == 0,
                onTap: () => onTabSeleccionado(0),
              ),
              _ItemNavegacion(
                icono: Icons.menu_book_outlined,
                iconoActivo: Icons.menu_book,
                etiqueta: 'Recetas',
                activo: indiceSeleccionado == 1,
                onTap: () => onTabSeleccionado(1),
              ),
              _ItemNavegacion(
                icono: Icons.kitchen,
                iconoActivo: Icons.kitchen,
                etiqueta: 'Despensa',
                activo: indiceSeleccionado == 2,
                onTap: () => onTabSeleccionado(2),
              ),
              _ItemNavegacion(
                icono: Icons.person_outline,
                iconoActivo: Icons.person,
                etiqueta: 'Perfil',
                activo: indiceSeleccionado == 3,
                onTap: () => onTabSeleccionado(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Elemento individual de la barra de navegación.
/// Muestra icono y etiqueta, con fondo destacado cuando está activo.
class _ItemNavegacion extends StatelessWidget {
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _ItemNavegacion({
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFFF4EBE6) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activo ? iconoActivo : icono,
              color: activo
                  ? const Color(0xFF732b16)
                  : const Color(0xFF9E9E9E),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: activo
                    ? const Color(0xFF732b16)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
