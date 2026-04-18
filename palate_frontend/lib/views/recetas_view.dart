import 'package:flutter/material.dart';
import '../viewmodels/recetas_viewmodel.dart';
import '../models/receta.dart';
import 'login_view.dart';
import 'receta_detalle.dart';

class RecetasView extends StatefulWidget {
  final String nombre;
  const RecetasView({super.key, required this.nombre});

  @override
  State<RecetasView> createState() => _RecetasViewState();
}

class _RecetasViewState extends State<RecetasView> {
  final _viewModel = RecetasViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.cargarRecetas().then((_) => setState(() {}));
  }

  String _dificultadTexto(String dificultad) {
    switch (dificultad) {
      case 'FACIL':
        return 'Fácil';
      case 'MEDIA':
        return 'Media';
      case 'DIFICIL':
        return 'Difícil';
      default:
        return dificultad;
    }
  }

  // Imágenes placeholder para las recetas
  String _imagenReceta(int index) {
    final imagenes = [
      'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=400',
      'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
      'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=400',
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
    ];
    return imagenes[index % imagenes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _viewModel.cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB85C38)),
              )
            : CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.restaurant_menu,
                                color: Color(0xFFB85C38),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Palate',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB85C38),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginView(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bienvenida
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECCIONADO PARA TI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB85C38).withOpacity(0.8),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ola, ${widget.nombre}.',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Descobre receitas pensadas para ti e supera os teus rexeitamentos alimentarios.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF8A8A8A),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botón "Comezar a cociñar"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB85C38),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Comezar a cociñar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Buscador
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar receitas...',
                          hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF8A8A8A),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF0EBE3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Lista de recetas
                  _viewModel.recetas.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                'Non hai receitas dispoñibles',
                                style: TextStyle(
                                  color: Color(0xFF8A8A8A),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final receta = _viewModel.recetas[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecetaDetalleView(
                                      recetaId: receta.id,
                                      titulo: receta.titulo,
                                      imagenUrl: _imagenReceta(index),
                                    ),
                                  ),
                                );
                              },
                              child: _RecetaCard(
                                receta: receta,
                                imagenUrl: _imagenReceta(index),
                                dificultadTexto: _dificultadTexto(
                                  receta.dificultad,
                                ),
                              ),
                            );
                          }, childCount: _viewModel.recetas.length),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                label: 'Inicio',
                activo: false,
              ),
              _NavBarItem(
                icon: Icons.restaurant_menu,
                label: 'Receitas',
                activo: true,
              ),
              _NavBarItem(
                icon: Icons.bookmark_outline,
                label: 'Gardadas',
                activo: false,
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                activo: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== RECETA CARD ====================

class _RecetaCard extends StatelessWidget {
  final Receta receta;
  final String imagenUrl;
  final String dificultadTexto;

  const _RecetaCard({
    required this.receta,
    required this.imagenUrl,
    required this.dificultadTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Image.network(
                imagenUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: const Color(0xFFF0EBE3),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Color(0xFFB85C38),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receta.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8A8A8A),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF8A8A8A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${receta.tiempoTotal} min',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Color(0xFF8A8A8A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dificultadTexto,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== NAV BAR ITEM ====================

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool activo;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: activo ? const Color(0xFFB85C38) : const Color(0xFF8A8A8A),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: activo ? const Color(0xFFB85C38) : const Color(0xFF8A8A8A),
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
