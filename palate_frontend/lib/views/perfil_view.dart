import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario.dart';
import '../viewmodels/aversiones_viewmodel.dart';
import '../viewmodels/despensa_viewmodel.dart';
import 'aversiones_view.dart';

class PerfilView extends StatefulWidget {
  final Usuario usuario;

  final VoidCallback onLogout;

  const PerfilView({
    super.key,
    required this.usuario,
    required this.onLogout,
  });

  @override
  State<PerfilView> createState() => PerfilViewState();
}

class PerfilViewState extends State<PerfilView> {
  final _aversionesVM = AversionesViewModel();
  final _despensaVM = DespensaViewModel();

  @override
  void initState() {
    super.initState();
    _recargarDatos();
  }

  void _recargarDatos() {
    Future.wait([
      _aversionesVM.cargarAversiones(widget.usuario.id),
      _despensaVM.cargarProductos(widget.usuario.id),
    ]).then((_) {
      if (mounted) setState(() {});
    });
  }

  void recargar() {
    _recargarDatos();
  }

  String get _iniciales {
    final partes = widget.usuario.nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return partes[0].isNotEmpty ? partes[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: const Color(0xFFFFFBF7),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Center(
                  child: Text(
                    'Palate',
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF732b16),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFF91412b),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF732b16).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _iniciales,
                          style: GoogleFonts.newsreader(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.usuario.nombre,
                      style: GoogleFonts.newsreader(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF732b16),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.usuario.email,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF88726d),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Las estadisticas se calculan a partir de los ViewModels
                    // de aversiones y despensa cargados en initState.
                    // El tile "Superadas" refleja las aversiones que el usuario
                    // ha conseguido superar mediante el sistema de feedback.
                    Row(
                      children: [
                        _TileEstadistica(
                          valor: _aversionesVM.totalAversiones.toString(),
                          etiqueta: 'Aversiones',
                        ),
                        const SizedBox(width: 10),
                        _TileEstadistica(
                          valor: _despensaVM.totalProductos.toString(),
                          etiqueta: 'Despensa',
                        ),
                        const SizedBox(width: 10),
                        _TileEstadistica(
                          valor: _aversionesVM.aversionesSuperadas.length
                              .toString(),
                          etiqueta: 'Superadas',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Solo se incluyen las opciones que disponen de pantalla
                    // funcional asociada. Otras opciones tipicas como
                    // editar perfil o ajustes generales se omiten al no
                    // formar parte del alcance del proyecto.
                    _SeccionMenu(
                      titulo: 'CUENTA',
                      items: [
                        // Navegacion directa a la pantalla de aversiones
                        _ItemMenu(
                          icono: Icons.heart_broken_outlined,
                          etiqueta: 'Mis aversiones alimentarias',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AversionesView(
                                  usuarioId: widget.usuario.id,
                                ),
                              ),
                            ).then((_) {
                              _aversionesVM
                                  .cargarAversiones(widget.usuario.id)
                                  .then((_) => setState(() {}));
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    TextButton(
                      onPressed: widget.onLogout,
                      child: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFba1a1a),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileEstadistica extends StatelessWidget {
  final String valor;
  final String etiqueta;

  const _TileEstadistica({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFfaebe7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFdbc1ba).withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: GoogleFonts.newsreader(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF732b16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: const Color(0xFF55433e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeccionMenu extends StatelessWidget {
  final String titulo;
  final List<_ItemMenu> items;

  const _SeccionMenu({required this.titulo, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFF732b16),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFfff0ed),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFfaebe7)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final esUltimo = index == items.length - 1;
              return Column(
                children: [
                  GestureDetector(
                    onTap: item.onTap,
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            item.icono,
                            size: 20,
                            color: const Color(0xFF88726d),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.etiqueta,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: const Color(0xFF211a18),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFdbc1ba),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!esUltimo)
                    Divider(
                      height: 1,
                      color: const Color(0xFFdbc1ba).withOpacity(0.4),
                      indent: 50,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ItemMenu {
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
  });
}
