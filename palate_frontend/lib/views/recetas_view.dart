import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/recetas_viewmodel.dart';
import '../models/receta.dart';
import 'receta_detalle.dart';

/// Pantalla de listado de recetas con buscador y filtros por dificultad.
/// Muestra la primera receta como tarjeta destacada y el resto en formato lista.
class RecetasView extends StatefulWidget {
  const RecetasView({super.key});

  @override
  State<RecetasView> createState() => _RecetasViewState();
}

class _RecetasViewState extends State<RecetasView> {
  final _viewModel = RecetasViewModel();
  final _busquedaController = TextEditingController();

  /// Filtro de dificultad activo: null significa "Todas"
  String? _filtroDificultad;

  /// Filtro de recetas generadas por IA
  bool _soloIA = false;

  @override
  void initState() {
    super.initState();
    _viewModel.cargarRecetas().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  /// Aplica los filtros activos sobre la lista completa de recetas.
  /// Se filtra por texto de búsqueda, dificultad y si fue generada por IA.
  List<Receta> get _recetasFiltradas {
    return _viewModel.recetas.where((receta) {
      final textoBusqueda = _busquedaController.text.toLowerCase();
      final coincideTexto = textoBusqueda.isEmpty ||
          receta.titulo.toLowerCase().contains(textoBusqueda) ||
          receta.descripcion.toLowerCase().contains(textoBusqueda);

      final coincideDificultad = _filtroDificultad == null ||
          receta.dificultad == _filtroDificultad;

      final coincideIA = !_soloIA || receta.generadaPorIa;

      return coincideTexto && coincideDificultad && coincideIA;
    }).toList();
  }

  /// Devuelve una imagen de Unsplash según el índice de la receta
  String _imagenReceta(int index) {
    final imagenes = [
      'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=600',
      'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600',
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600',
      'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=600',
    ];
    return imagenes[index % imagenes.length];
  }

  /// Traduce el código de dificultad a texto en español
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
    final recetasFiltradas = _recetasFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: _viewModel.cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF732b16)),
              )
            : CustomScrollView(
                slivers: [
                  // ── Barra superior ──
                  SliverToBoxAdapter(child: _AppBarRecetas()),

                  // ── Buscador de recetas ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: TextField(
                        controller: _busquedaController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Buscar recetas...',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF88726d).withOpacity(0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF88726d),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFfff0ed),
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

                  // ── Chips de filtro por dificultad ──
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        children: [
                          _ChipFiltro(
                            etiqueta: 'Todas',
                            activo: _filtroDificultad == null && !_soloIA,
                            onTap: () => setState(() {
                              _filtroDificultad = null;
                              _soloIA = false;
                            }),
                          ),
                          const SizedBox(width: 8),
                          _ChipFiltro(
                            etiqueta: 'Fácil',
                            activo: _filtroDificultad == 'FACIL',
                            onTap: () => setState(() {
                              _filtroDificultad = 'FACIL';
                              _soloIA = false;
                            }),
                          ),
                          const SizedBox(width: 8),
                          _ChipFiltro(
                            etiqueta: 'Media',
                            activo: _filtroDificultad == 'MEDIA',
                            onTap: () => setState(() {
                              _filtroDificultad = 'MEDIA';
                              _soloIA = false;
                            }),
                          ),
                          const SizedBox(width: 8),
                          _ChipFiltro(
                            etiqueta: 'Difícil',
                            activo: _filtroDificultad == 'DIFICIL',
                            onTap: () => setState(() {
                              _filtroDificultad = 'DIFICIL';
                              _soloIA = false;
                            }),
                          ),
                          const SizedBox(width: 8),
                          _ChipFiltroIA(
                            activo: _soloIA,
                            onTap: () => setState(() {
                              _soloIA = !_soloIA;
                              _filtroDificultad = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // ── Tarjeta destacada (primera receta filtrada) ──
                  if (recetasFiltradas.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _TarjetaDestacada(
                          receta: recetasFiltradas.first,
                          imagenUrl: _imagenReceta(0),
                          textoDificultad: _textoDificultad(
                            recetasFiltradas.first.dificultad,
                          ),
                          onTap: () => _navegarADetalle(
                            recetasFiltradas.first,
                            _imagenReceta(0),
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ── Lista del resto de recetas ──
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Se omite la primera receta porque ya aparece destacada
                        final receta = recetasFiltradas[index + 1];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                          child: _TarjetaRecetaLista(
                            receta: receta,
                            imagenUrl: _imagenReceta(index + 1),
                            textoDificultad: _textoDificultad(receta.dificultad),
                            onTap: () => _navegarADetalle(
                              receta,
                              _imagenReceta(index + 1),
                            ),
                          ),
                        );
                      },
                      childCount: recetasFiltradas.length > 1
                          ? recetasFiltradas.length - 1
                          : 0,
                    ),
                  ),

                  // Estado vacío cuando no hay resultados para los filtros aplicados
                  if (recetasFiltradas.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: Color(0xFFdbc1ba),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No se encontraron recetas',
                                style: GoogleFonts.newsreader(
                                  fontSize: 18,
                                  color: const Color(0xFF88726d),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }

  /// Navega a la pantalla de detalle de la receta seleccionada.
  void _navegarADetalle(Receta receta, String imagenUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetaDetalleView(
          recetaId: receta.id,
          titulo: receta.titulo,
          imagenUrl: imagenUrl,
        ),
      ),
    );
  }
}

/// Barra superior con el logotipo de la app, campana y avatar.
class _AppBarRecetas extends StatelessWidget {
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
              const Icon(Icons.restaurant_menu, color: Color(0xFF732b16)),
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
          const Icon(Icons.notifications_outlined, color: Color(0xFF732b16)),
        ],
      ),
    );
  }
}

/// Chip de filtro para dificultad.
class _ChipFiltro extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo
              ? const Color(0xFFfdb733)
              : const Color(0xFFf4e5e2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          etiqueta,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: activo
                ? const Color(0xFF6d4a00)
                : const Color(0xFF55433e),
          ),
        ),
      ),
    );
  }
}

/// Chip especial para filtrar recetas generadas por IA.
class _ChipFiltroIA extends StatelessWidget {
  final bool activo;
  final VoidCallback onTap;

  const _ChipFiltroIA({required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo
              ? const Color(0xFF732b16).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF732b16).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 14,
              color: Color(0xFF732b16),
            ),
            const SizedBox(width: 4),
            Text(
              'Generado por IA',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF732b16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta grande para la receta más destacada del listado.
/// Ocupa el ancho completo y muestra la imagen en formato 16:10.
class _TarjetaDestacada extends StatelessWidget {
  final Receta receta;
  final String imagenUrl;
  final String textoDificultad;
  final VoidCallback onTap;

  const _TarjetaDestacada({
    required this.receta,
    required this.imagenUrl,
    required this.textoDificultad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF91412b).withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen en proporción 16:10
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                imagenUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFf4e5e2),
                  child: const Center(
                    child: Icon(Icons.restaurant, size: 60, color: Color(0xFF732b16)),
                  ),
                ),
              ),
            ),

            // Información de la receta
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          receta.titulo,
                          style: GoogleFonts.newsreader(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF211a18),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border,
                        color: Color(0xFF88726d),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Metadatos: tiempo, dificultad, badge IA
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 15, color: Color(0xFF88726d)),
                      const SizedBox(width: 4),
                      Text(
                        '${receta.tiempoTotal} min',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.restaurant,
                          size: 15, color: Color(0xFF88726d)),
                      const SizedBox(width: 4),
                      Text(
                        textoDificultad,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                      if (receta.generadaPorIa) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.auto_awesome,
                            size: 15, color: Color(0xFF91412b)),
                        const SizedBox(width: 4),
                        Text(
                          'Receta IA',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF91412b),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Descripción truncada a 2 líneas
                  Text(
                    receta.descripcion,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF55433e),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

/// Tarjeta compacta para el resto de recetas en el listado.
/// Muestra una miniatura cuadrada a la izquierda y la información a la derecha.
class _TarjetaRecetaLista extends StatelessWidget {
  final Receta receta;
  final String imagenUrl;
  final String textoDificultad;
  final VoidCallback onTap;

  const _TarjetaRecetaLista({
    required this.receta,
    required this.imagenUrl,
    required this.textoDificultad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: receta.generadaPorIa
              ? const Color(0xFF732b16).withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: receta.generadaPorIa
                ? const Color(0xFF732b16).withOpacity(0.12)
                : const Color(0xFFdbc1ba).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Miniatura
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    imagenUrl,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 88,
                      height: 88,
                      color: const Color(0xFFf4e5e2),
                      child: const Icon(Icons.restaurant, color: Color(0xFF732b16)),
                    ),
                  ),
                  // Overlay de IA sobre la miniatura
                  if (receta.generadaPorIa)
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF732b16).withOpacity(0.15),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Información textual
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.titulo,
                    style: GoogleFonts.newsreader(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: receta.generadaPorIa
                          ? const Color(0xFF732b16)
                          : const Color(0xFF211a18),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${receta.tiempoTotal} min',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        textoDificultad,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                    ],
                  ),
                  if (receta.generadaPorIa) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Personalizado para ti',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: const Color(0xFF732b16),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Color(0xFFdbc1ba)),
          ],
        ),
      ),
    );
  }
}
