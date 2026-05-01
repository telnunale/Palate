import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario.dart';
import '../models/receta.dart';
import '../viewmodels/home_viewmodel.dart';
import 'receta_detalle.dart';

/// Pantalla principal de la aplicación tras el inicio de sesión.
/// Muestra un banner de acceso a la generación IA, estadísticas del usuario,
/// alertas de productos próximos a caducar y las recetas más recientes.
class HomeView extends StatefulWidget {
  /// Usuario autenticado, necesario para mostrar el saludo personalizado
  final Usuario usuario;

  const HomeView({super.key, required this.usuario});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    // Carga los datos al inicializar la pantalla
    _viewModel.cargarDatos().then((_) => setState(() {}));
  }

  /// Devuelve una URL de imagen de Unsplash según el índice de la receta,
  /// ya que las recetas generadas por IA no tienen imagen propia.
  String _imagenReceta(int index) {
    final imagenes = [
      'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=400',
      'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
      'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=400',
    ];
    return imagenes[index % imagenes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: _viewModel.cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF732b16)),
              )
            : CustomScrollView(
                slivers: [
                  // ── Barra superior con logo y notificaciones ──
                  SliverToBoxAdapter(child: _AppBar()),

                  // ── Saludo personalizado ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${widget.usuario.nombre}',
                            style: GoogleFonts.newsreader(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF732b16),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¿Qué te apetece cocinar hoy?',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF55433e),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Banner de generación con IA ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _BannerIA(),
                    ),
                  ),

                  // ── Estadísticas rápidas en grid bento ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _GridEstadisticas(
                        totalRecetas: _viewModel.totalRecetas,
                      ),
                    ),
                  ),

                  // ── Recetas recientes ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recetas recientes',
                            style: GoogleFonts.newsreader(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF211a18),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Ver todas',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF732b16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lista de las dos recetas más recientes
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final receta = _viewModel.recetasRecientes[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                          child: _TarjetaRecetaCompacta(
                            receta: receta,
                            imagenUrl: _imagenReceta(index),
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
                          ),
                        );
                      },
                      childCount: _viewModel.recetasRecientes.length,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
      ),

      // ── Botón flotante de acceso rápido a la generación IA ──
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Próximamente')),
          );
        },
        backgroundColor: const Color(0xFF732b16),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }
}

/// Barra superior con el logotipo de la aplicación y el icono de notificaciones.
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                color: Color(0xFF732b16),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                'Palate',
                style: GoogleFonts.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF732b16),
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFf4e5e2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF732b16),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner destacado que invita al usuario a generar recetas con IA.
/// Muestra un fondo terracota con imagen superpuesta y un botón de acción.
class _BannerIA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF91412b),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Imagen decorativa en el lado derecho del banner
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: Opacity(
              opacity: 0.4,
              child: Image.network(
                'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          // Gradiente para difuminar la imagen con el fondo
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF91412b), Color(0x6691412b), Colors.transparent],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Contenido textual del banner
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge de IA
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFfdb733),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Color(0xFF6d4a00),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'INTELIGENCIA ARTIFICIAL',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF6d4a00),
                        ),
                      ),
                    ],
                  ),
                ),

                // Texto y botón de acción
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crea una cena perfecta\ncon lo que tienes.',
                      style: GoogleFonts.newsreader(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFffc2b2),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Próximamente')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Generar receta con IA',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF732b16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid de tres estadísticas rápidas del usuario: recetas, despensa y aversiones.
class _GridEstadisticas extends StatelessWidget {
  final int totalRecetas;

  const _GridEstadisticas({required this.totalRecetas});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TileEstadistica(valor: '$totalRecetas', etiqueta: 'Recetas'),
        const SizedBox(width: 12),
        _TileEstadistica(valor: '—', etiqueta: 'Despensa'),
        const SizedBox(width: 12),
        _TileEstadistica(valor: '—', etiqueta: 'Aversiones'),
      ],
    );
  }
}

/// Tile individual de estadística con valor numérico y etiqueta.
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
          color: const Color(0xFFfff0ed),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFdbc1ba).withOpacity(0.4)),
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
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: const Color(0xFF55433e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta compacta para mostrar una receta en el listado de recientes.
/// Muestra una miniatura, el título, tiempo y nivel de dificultad.
class _TarjetaRecetaCompacta extends StatelessWidget {
  final Receta receta;
  final String imagenUrl;
  final VoidCallback onTap;

  const _TarjetaRecetaCompacta({
    required this.receta,
    required this.imagenUrl,
    required this.onTap,
  });

  /// Traduce el código de dificultad a texto legible en español
  String _textoDificultad(String dificultad) {
    switch (dificultad) {
      case 'FACIL': return 'Fácil';
      case 'MEDIA': return 'Media';
      case 'DIFICIL': return 'Difícil';
      default: return dificultad;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFdbc1ba).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF91412b).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Miniatura de la receta
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imagenUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 88,
                  color: const Color(0xFFf4e5e2),
                  child: const Icon(
                    Icons.restaurant,
                    color: Color(0xFF732b16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Información textual de la receta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadatos: tiempo y tipo de comida
                  Row(
                    children: [
                      if (receta.generadaPorIa)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF732b16).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 10,
                                color: Color(0xFF732b16),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'IA',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF732b16),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Título de la receta
                  Text(
                    receta.titulo,
                    style: GoogleFonts.newsreader(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF211a18),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Tiempo total y dificultad
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: Color(0xFF88726d),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${receta.tiempoTotal} min',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _textoDificultad(receta.dificultad),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Color(0xFFdbc1ba),
            ),
          ],
        ),
      ),
    );
  }
}
