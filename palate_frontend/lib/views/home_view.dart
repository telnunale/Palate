import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario.dart';
import '../models/receta.dart';
import '../models/receta_recomendada.dart';
import '../viewmodels/home_viewmodel.dart';
import '../utils/imagen_optim.dart';
import 'generar_receta_view.dart';
import 'receta_detalle.dart';

class HomeView extends StatefulWidget {
  final Usuario usuario;

  const HomeView({super.key, required this.usuario});

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    // Carga los datos al inicializar la pantalla. Se pasa el id del usuario
    // autenticado para que el ViewModel pueda obtener las recomendaciones
    // personalizadas del motor en dos capas.
    _viewModel
        .cargarDatos(widget.usuario.id)
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  void recargar() {
    _viewModel.cargarDatos(widget.usuario.id).then((_) {
      if (mounted) setState(() {});
    });
  }

  String _imagenReceta(Receta receta, int index) {
    if (receta.imagenUrl != null && receta.imagenUrl!.isNotEmpty) {
      return receta.imagenUrl!;
    }
    return _fallbackImagenes[index % _fallbackImagenes.length];
  }

  static const List<String> _fallbackImagenes = [
    'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=400',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
    'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=400',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: _viewModel.cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF732b16)),
              )
            : _viewModel.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off_outlined,
                            size: 52,
                            color: Color(0xFF88726d),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se pudieron cargar los datos',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.newsreader(
                              fontSize: 22,
                              color: const Color(0xFF732b16),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // Reintentar la carga de datos al pulsar el botón
                              _viewModel
                                  .cargarDatos(widget.usuario.id)
                                  .then((_) {
                                    if (mounted) setState(() {});
                                  });
                            },
                            child: Text(
                              'Reintentar',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: const Color(0xFF732b16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _AppBar()),

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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _BannerIA(
                        onGenerarReceta: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GenerarRecetaView(usuario: widget.usuario),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _GridEstadisticas(
                        totalRecetas: _viewModel.totalRecetas,
                        totalDespensa: _viewModel.totalDespensa,
                        totalAversiones: _viewModel.totalAversiones,
                      ),
                    ),
                  ),

                  // Esta seccion solo aparece cuando hay recetas en BD que el
                  // motor de recomendacion ha podido puntuar para el perfil
                  // del usuario. Si la lista esta vacia, se muestra una
                  // tarjeta de invitacion a generar la primera receta.
                  SliverToBoxAdapter(
                    child: _SeccionRecomendadas(
                      recomendadas: _viewModel.recetasRecomendadas,
                      imagenReceta: _imagenReceta,
                      usuario: widget.usuario,
                    ),
                  ),

                  // El listado completo es accesible desde la pestana
                  // "Recetas" de la navegacion inferior, por lo que aqui
                  // se omite cualquier acceso directo redundante.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Text(
                        'Recetas recientes',
                        style: GoogleFonts.newsreader(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF211a18),
                        ),
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
                            imagenUrl: _imagenReceta(receta, index),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecetaDetalleView(
                                    recetaId: receta.id,
                                    titulo: receta.titulo,
                                    imagenUrl: _imagenReceta(receta, index),
                                    usuario: widget.usuario,
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenerarRecetaView(usuario: widget.usuario),
            ),
          );
        },
        backgroundColor: const Color(0xFF732b16),
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
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
    );
  }
}

class _BannerIA extends StatelessWidget {
  final VoidCallback onGenerarReceta;

  const _BannerIA({required this.onGenerarReceta});

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
                      onTap: onGenerarReceta,
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

class _GridEstadisticas extends StatelessWidget {
  final int totalRecetas;
  final int totalDespensa;
  final int totalAversiones;

  const _GridEstadisticas({
    required this.totalRecetas,
    required this.totalDespensa,
    required this.totalAversiones,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TileEstadistica(valor: '$totalRecetas', etiqueta: 'Recetas'),
        const SizedBox(width: 12),
        _TileEstadistica(valor: '$totalDespensa', etiqueta: 'Despensa'),
        const SizedBox(width: 12),
        _TileEstadistica(valor: '$totalAversiones', etiqueta: 'Aversiones'),
      ],
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

class _TarjetaRecetaCompacta extends StatelessWidget {
  final Receta receta;
  final String imagenUrl;
  final VoidCallback onTap;

  const _TarjetaRecetaCompacta({
    required this.receta,
    required this.imagenUrl,
    required this.onTap,
  });

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
                ImagenOptim.paraAncho(context, imagenUrl, 88),
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                cacheWidth: ImagenOptim.anchoFisico(context, 88),
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

class _SeccionRecomendadas extends StatelessWidget {
  final List<RecetaRecomendada> recomendadas;

  final String Function(Receta, int) imagenReceta;

  final Usuario usuario;

  const _SeccionRecomendadas({
    required this.recomendadas,
    required this.imagenReceta,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Row(
            children: [
              const Icon(
                Icons.recommend_outlined,
                color: Color(0xFF732b16),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Recomendadas para ti',
                style: GoogleFonts.newsreader(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF211a18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Sugerencias del motor de recomendacion segun tu perfil sensorial.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF88726d),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Estado vacio: invita a generar la primera receta para que el
        // motor pueda empezar a recomendar contenido relevante.
        if (recomendadas.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _EstadoSinRecomendaciones(usuario: usuario),
          )
        else
          // Carrusel horizontal con las recetas mejor puntuadas
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: recomendadas.length,
              itemBuilder: (context, index) {
                final receta = recomendadas[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _TarjetaRecomendada(
                    receta: receta,
                    imagenUrl: imagenReceta(receta, index),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecetaDetalleView(
                            recetaId: receta.id,
                            titulo: receta.titulo,
                            imagenUrl: imagenReceta(receta, index),
                            usuario: usuario,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _TarjetaRecomendada extends StatelessWidget {
  final RecetaRecomendada receta;
  final String imagenUrl;
  final VoidCallback onTap;

  const _TarjetaRecomendada({
    required this.receta,
    required this.imagenUrl,
    required this.onTap,
  });

  Color _colorBadge(int score) {
    if (score >= 80) return const Color(0xFF7f5700);
    if (score >= 60) return const Color(0xFF91412b);
    return const Color(0xFF88726d);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFdbc1ba).withOpacity(0.3),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de cabecera con badge de puntuacion superpuesto
            SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    // Carrusel horizontal: cada tarjeta ronda los 280px
                    // de ancho. Pedir esa resolucion exacta optimiza la
                    // descarga sin perder nitidez en pantallas HiDPI.
                    ImagenOptim.paraAncho(context, imagenUrl, 280),
                    fit: BoxFit.cover,
                    cacheWidth: ImagenOptim.anchoFisico(context, 280),
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFf4e5e2),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          color: Color(0xFF732b16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: _colorBadge(receta.score),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${receta.score}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _colorBadge(receta.score),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informacion textual de la receta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receta.titulo,
                      style: GoogleFonts.newsreader(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF211a18),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        receta.motivoRecomendacion,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF88726d),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Color(0xFF88726d),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${receta.tiempoTotal} min',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF88726d),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoSinRecomendaciones extends StatelessWidget {
  final Usuario usuario;

  const _EstadoSinRecomendaciones({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFfff0ed),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFdbc1ba).withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF732b16),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Aun no hay recomendaciones',
                style: GoogleFonts.newsreader(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF732b16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Genera tu primera receta con IA para que el motor empiece a aprender de tu perfil.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF55433e),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenerarRecetaView(usuario: usuario),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF732b16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Generar receta',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
