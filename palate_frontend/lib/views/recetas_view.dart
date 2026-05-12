import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/recetas_viewmodel.dart';
import '../models/intolerancia.dart';
import '../models/receta.dart';
import '../models/usuario.dart';
import '../utils/imagen_optim.dart';
import 'receta_detalle.dart';
import 'generar_receta_view.dart';

class RecetasView extends StatefulWidget {
  final Usuario usuario;

  const RecetasView({super.key, required this.usuario});

  @override
  State<RecetasView> createState() => RecetasViewState();
}

class RecetasViewState extends State<RecetasView> {
  final _viewModel = RecetasViewModel();
  final _busquedaController = TextEditingController();

  int? _filtroTiempo;
  final Set<int> _aversionesFiltro = <int>{};

  @override
  void initState() {
    super.initState();
    recargar();
  }

  void recargar() {
    _viewModel.cargarRecetas().then((_) {
      if (mounted) setState(() {});
    });
    _viewModel.cargarAversiones(widget.usuario.id).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  List<Receta> get _recetasFiltradas {
    return _viewModel.recetas.where((receta) {
      final textoBusqueda = _busquedaController.text.trim().toLowerCase();
      final coincideTexto = textoBusqueda.isEmpty ||
          receta.titulo.toLowerCase().contains(textoBusqueda) ||
          receta.descripcion.toLowerCase().contains(textoBusqueda);

      final coincideTiempo = _coincideFiltroTiempo(receta);

      final coincideAversion = _coincideFiltroAversion(receta);

      return coincideTexto &&
          coincideTiempo &&
          coincideAversion;
    }).toList();
  }

  int _idAlimento(Intolerancia a) => a.alimentoId;

  static const Map<String, Set<String>> _metodosContraindicadosPorMotivo = {
    'TEXTURA': {'CRUDO', 'AL_VAPOR', 'HERVIDO'},
    'SABOR': {'CRUDO', 'HERVIDO'},
    'OLOR': {'CRUDO', 'AL_VAPOR'},
    'COLOR': {'CRUDO'},
  };

  bool _coincideFiltroAversion(Receta receta) {
    if (_aversionesFiltro.isEmpty) return true;

    for (final aversion in _viewModel.aversiones) {
      if (!_aversionesFiltro.contains(aversion.alimentoId)) continue;
      if (!receta.idsAlimentos.contains(aversion.alimentoId)) continue;

      final metodos = receta.metodosPorAlimento[aversion.alimentoId];
      if (metodos == null || metodos.isEmpty) return true;

      final contraindicados = _contraindicadosParaAversion(aversion);
      if (contraindicados.isEmpty) return true;

      if (metodos.any((m) => !contraindicados.contains(m))) return true;
    }
    return false;
  }

  Set<String> _contraindicadosParaAversion(Intolerancia aversion) {
    final resultado = <String>{};
    for (final motivo in aversion.motivos) {
      final tipo = motivo['tipo'] as String?;
      if (tipo == null) continue;
      final lista = _metodosContraindicadosPorMotivo[tipo];
      if (lista != null) resultado.addAll(lista);
    }
    return resultado;
  }

  bool _coincideFiltroTiempo(Receta receta) {
    if (_filtroTiempo == null) return true;
    final total = receta.tiempoTotal;
    if (_filtroTiempo == 45) return total >= 45;
    return total <= _filtroTiempo!;
  }

  String _imagenReceta(Receta receta, int index) {
    if (receta.imagenUrl != null && receta.imagenUrl!.isNotEmpty) {
      return receta.imagenUrl!;
    }
    return _fallbackImagenes[index % _fallbackImagenes.length];
  }

  static const List<String> _fallbackImagenes = [
    'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=600',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600',
    'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=600',
  ];

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
                  SliverToBoxAdapter(child: _AppBarRecetas()),

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

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        children: [
                          _ChipFiltro(
                            etiqueta: 'Todas',
                            activo: _filtroTiempo == null &&
                                _aversionesFiltro.isEmpty,
                            onTap: () => setState(() {
                              _filtroTiempo = null;
                              _aversionesFiltro.clear();
                            }),
                          ),
                          const SizedBox(width: 8),
                          _ChipFiltro(
                            etiqueta: '15 min',
                            activo: _filtroTiempo == 15,
                            onTap: () => setState(() {
                              _filtroTiempo = _filtroTiempo == 15 ? null : 15;
                            }),
                          ),
                          const SizedBox(width: 8),
                          _ChipFiltro(
                            etiqueta: '30 min',
                            activo: _filtroTiempo == 30,
                            onTap: () => setState(() {
                              _filtroTiempo = _filtroTiempo == 30 ? null : 30;
                            }),
                          ),
                          const SizedBox(width: 8),
                          _ChipFiltro(
                            etiqueta: '45+ min',
                            activo: _filtroTiempo == 45,
                            onTap: () => setState(() {
                              _filtroTiempo = _filtroTiempo == 45 ? null : 45;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_viewModel.aversiones.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                          itemCount: _viewModel.aversiones.length,
                          itemBuilder: (context, index) {
                            final aversion = _viewModel.aversiones[index];
                            final id = _idAlimento(aversion);
                            final activo = _aversionesFiltro.contains(id);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _ChipFiltroAversion(
                                etiqueta: aversion.nombreAlimento,
                                activo: activo,
                                onTap: () => setState(() {
                                  if (activo) {
                                    _aversionesFiltro.remove(id);
                                  } else {
                                    _aversionesFiltro.add(id);
                                  }
                                }),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  if (recetasFiltradas.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _TarjetaDestacada(
                          receta: recetasFiltradas.first,
                          imagenUrl: _imagenReceta(recetasFiltradas.first, 0),
                          textoDificultad: _textoDificultad(
                            recetasFiltradas.first.dificultad,
                          ),
                          onTap: () => _navegarADetalle(
                            recetasFiltradas.first,
                            _imagenReceta(recetasFiltradas.first, 0),
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final receta = recetasFiltradas[index + 1];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                          child: _TarjetaRecetaLista(
                            receta: receta,
                            imagenUrl: _imagenReceta(receta, index + 1),
                            textoDificultad: _textoDificultad(receta.dificultad),
                            onTap: () => _navegarADetalle(
                              receta,
                              _imagenReceta(receta, index + 1),
                            ),
                          ),
                        );
                      },
                      childCount: recetasFiltradas.length > 1
                          ? recetasFiltradas.length - 1
                          : 0,
                    ),
                  ),

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

  void _navegarADetalle(Receta receta, String imagenUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetaDetalleView(
          recetaId: receta.id,
          titulo: receta.titulo,
          imagenUrl: imagenUrl,
          usuario: widget.usuario,
        ),
      ),
    );
  }
}

class _AppBarRecetas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
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
    );
  }
}

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

class _ChipFiltroAversion extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _ChipFiltroAversion({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activo
              ? const Color(0xFF732b16)
              : const Color(0xFF732b16).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF732b16).withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.heart_broken_outlined,
              size: 12,
              color: activo ? Colors.white : const Color(0xFF732b16),
            ),
            const SizedBox(width: 4),
            Text(
              etiqueta,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: activo ? Colors.white : const Color(0xFF732b16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Builder(
                builder: (ctx) {
                  final ancho = MediaQuery.of(ctx).size.width - 48;
                  return Image.network(
                    ImagenOptim.paraAncho(ctx, imagenUrl, ancho),
                    fit: BoxFit.cover,
                    cacheWidth: ImagenOptim.anchoFisico(ctx, ancho),
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFf4e5e2),
                      child: const Center(
                        child: Icon(Icons.restaurant, size: 60, color: Color(0xFF732b16)),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.titulo,
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF211a18),
                    ),
                  ),
                  const SizedBox(height: 8),

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
                      if (receta.caloriasTotal != null) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.bolt,
                            size: 15, color: Color(0xFF88726d)),
                        const SizedBox(width: 4),
                        Text(
                          '${receta.caloriasTotal!.round()} kcal',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF88726d),
                          ),
                        ),
                      ],
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    ImagenOptim.paraAncho(context, imagenUrl, 88),
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    cacheWidth: ImagenOptim.anchoFisico(context, 88),
                    errorBuilder: (_, __, ___) => Container(
                      width: 88,
                      height: 88,
                      color: const Color(0xFFf4e5e2),
                      child: const Icon(Icons.restaurant, color: Color(0xFF732b16)),
                    ),
                  ),
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
