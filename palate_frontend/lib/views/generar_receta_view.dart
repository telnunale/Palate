import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/usuario.dart';
import '../models/intolerancia.dart';
import '../models/producto_despensa.dart';
import '../viewmodels/generar_receta_viewmodel.dart';
import 'receta_detalle.dart';

class GenerarRecetaView extends StatefulWidget {
  final Usuario usuario;

  const GenerarRecetaView({super.key, required this.usuario});

  @override
  State<GenerarRecetaView> createState() => _GenerarRecetaViewState();
}

class _GenerarRecetaViewState extends State<GenerarRecetaView> {
  final _viewModel = GenerarRecetaViewModel();
  final _descripcionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel
        .cargarContexto(widget.usuario.id)
        .then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: Column(
          children: [
            _AppBarGenerar(onVolver: () => Navigator.pop(context)),

            Expanded(
              child: _viewModel.cargandoContexto
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF732b16),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generar Receta\nAdaptada',
                            style: GoogleFonts.newsreader(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF732b16),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Personaliza tu experiencia culinaria con IA.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF55433e),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            '¿QUÉ QUIERES COMER HOY?',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: const Color(0xFF55433e),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              TextField(
                                controller: _descripcionCtrl,
                                maxLines: 3,
                                onChanged: (valor) {
                                  _viewModel.descripcion = valor;
                                },
                                style: GoogleFonts.inter(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText:
                                      'Ej: Una cena ligera con pollo y algo refrescante...',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF88726d),
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFfff0ed),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              const Positioned(
                                bottom: 12,
                                right: 12,
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFF732b16),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _TarjetaOpcion(
                            icono: Icons.kitchen,
                            colorIcono: const Color(0xFF7f5700),
                            titulo: 'Mi Despensa',
                            activo: _viewModel.usarDespensa,
                            onToggle: (valor) {
                              setState(() => _viewModel.usarDespensa = valor);
                            },
                            contenido: _viewModel.usarDespensa
                                ? _ContenidoDespensa(
                                    despensa: _viewModel.despensa
                                        .take(5)
                                        .toList(),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),

                          _TarjetaOpcion(
                            icono: Icons.heart_broken_outlined,
                            colorIcono: const Color(0xFF732b16),
                            titulo: 'Aversión',
                            activo: _viewModel.usarAversion,
                            onToggle: (valor) {
                              setState(() {
                                _viewModel.usarAversion = valor;
                                if (!valor) {
                                  _viewModel.limpiarAversiones();
                                }
                              });
                            },
                            contenido: _viewModel.usarAversion
                                ? _SelectorAversion(
                                    aversiones: _viewModel.aversiones,
                                    seleccionadas:
                                        _viewModel.aversionesSeleccionadas,
                                    maxSeleccion:
                                        GenerarRecetaViewModel
                                            .maxAversionesSeleccionadas,
                                    onTogglear: (aversion) {
                                      final aceptado =
                                          _viewModel.alternarAversion(aversion);
                                      if (!aceptado) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Maximo de 2 aversiones por receta',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        setState(() {});
                                      }
                                    },
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF91412b)
                                      .withOpacity(0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment_turned_in_outlined,
                                      color: Color(0xFF7f5700),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dificultad',
                                      style: GoogleFonts.newsreader(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF211a18),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Selector de dificultad tipo pill
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFfff0ed),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    children: [
                                      _PillDificultad(
                                        etiqueta: 'Fácil',
                                        activo:
                                            _viewModel.dificultad == 'FACIL',
                                        onTap: () => setState(
                                          () => _viewModel.dificultad =
                                              'FACIL',
                                        ),
                                      ),
                                      _PillDificultad(
                                        etiqueta: 'Media',
                                        activo:
                                            _viewModel.dificultad == 'MEDIA',
                                        onTap: () => setState(
                                          () => _viewModel.dificultad =
                                              'MEDIA',
                                        ),
                                      ),
                                      _PillDificultad(
                                        etiqueta: 'Difícil',
                                        activo:
                                            _viewModel.dificultad == 'DIFICIL',
                                        onTap: () => setState(
                                          () => _viewModel.dificultad =
                                              'DIFICIL',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          _TarjetaEstrategiaIA(viewModel: _viewModel),
                          const SizedBox(height: 24),

                          if (_viewModel.error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFffdad6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFba1a1a),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _viewModel.error!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFFba1a1a),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF732b16),
                                    Color(0xFF91412b),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF732b16)
                                        .withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _viewModel.generando
                                    ? null
                                    : _generarReceta,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                icon: _viewModel.generando
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.restaurant_menu,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                label: Text(
                                  _viewModel.generando
                                      ? 'Generando...'
                                      : 'Generar Receta',
                                  style: GoogleFonts.newsreader(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFFf4e5e2),
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Color(0xCC000000),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'INSPIRACIÓN DEL DÍA',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          'Descubre nuevos sabores',
                                          style: GoogleFonts.newsreader(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  Future<void> _generarReceta() async {
    setState(() {});
    final receta = await _viewModel.generar(widget.usuario.id);

    // Si la pantalla se ha desechado mientras la IA generaba la receta,
    // descartamos el resultado sin tocar el arbol de widgets.
    if (!mounted) return;
    setState(() {});

    if (receta != null) {
      // El backend asigna una imagen tematica al persistir la receta.
      // Si por alguna razon viene null (recetas viejas sin migrar) se usa
      // un placeholder generico para que la pantalla de detalle no quede
      // sin foto.
      final imagen = (receta.imagenUrl != null && receta.imagenUrl!.isNotEmpty)
          ? receta.imagenUrl!
          : 'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=600';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecetaDetalleView(
            recetaId: receta.id,
            titulo: receta.titulo,
            imagenUrl: imagen,
            usuario: widget.usuario,
          ),
        ),
      );
    }
  }
}

class _AppBarGenerar extends StatelessWidget {
  final VoidCallback onVolver;

  const _AppBarGenerar({required this.onVolver});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onVolver,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFfff0ed),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF732b16),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
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

class _TarjetaOpcion extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final bool activo;
  final ValueChanged<bool> onToggle;
  final Widget? contenido;

  const _TarjetaOpcion({
    required this.icono,
    required this.colorIcono,
    required this.titulo,
    required this.activo,
    required this.onToggle,
    this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF91412b).withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icono, color: colorIcono, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    titulo,
                    style: GoogleFonts.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF211a18),
                    ),
                  ),
                ],
              ),
              Switch(
                value: activo,
                onChanged: onToggle,
                activeColor: colorIcono,
              ),
            ],
          ),
          if (activo && contenido != null) ...[
            const SizedBox(height: 12),
            contenido!,
          ],
        ],
      ),
    );
  }
}

class _ContenidoDespensa extends StatelessWidget {
  final List<ProductoDespensa> despensa;

  const _ContenidoDespensa({required this.despensa});

  @override
  Widget build(BuildContext context) {
    if (despensa.isEmpty) {
      return Text(
        'Tu despensa está vacía. Agrega productos desde la pestaña Despensa.',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF88726d),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: despensa.map((producto) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFfff0ed),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF732b16).withOpacity(0.15),
            ),
          ),
          child: Text(
            producto.nombreAlimento,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF732b16),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SelectorAversion extends StatelessWidget {
  final List<Intolerancia> aversiones;
  final List<Intolerancia> seleccionadas;
  final int maxSeleccion;
  final ValueChanged<Intolerancia> onTogglear;

  const _SelectorAversion({
    required this.aversiones,
    required this.seleccionadas,
    required this.maxSeleccion,
    required this.onTogglear,
  });

  @override
  Widget build(BuildContext context) {
    if (aversiones.isEmpty) {
      return Text(
        'No tienes aversiones registradas. Agregalas desde tu Perfil.',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF88726d),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona hasta $maxSeleccion aversiones (${seleccionadas.length}/$maxSeleccion)',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF88726d),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: aversiones.map((aversion) {
            final activo = seleccionadas.any((a) => a.id == aversion.id);
            return GestureDetector(
              onTap: () => onTogglear(aversion),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: activo
                      ? const Color(0xFF732b16)
                      : const Color(0xFFfff0ed),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF732b16).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      activo
                          ? Icons.check_circle
                          : Icons.heart_broken_outlined,
                      size: 14,
                      color: activo ? Colors.white : const Color(0xFF732b16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${aversion.nombreAlimento} (${aversion.nivelRechazo}/10)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            activo ? Colors.white : const Color(0xFF732b16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TarjetaEstrategiaIA extends StatelessWidget {
  final GenerarRecetaViewModel viewModel;

  const _TarjetaEstrategiaIA({required this.viewModel});

  String _mensajeEstrategia() {
    final aversionesActivas = viewModel.usarAversion
        ? viewModel.aversionesSeleccionadas
        : const [];
    final hayMultiples = aversionesActivas.length > 1;

    if (viewModel.usarDespensa && aversionesActivas.isNotEmpty) {
      if (hayMultiples) {
        return 'La IA priorizara tus ingredientes disponibles y adaptara '
            'la receta para trabajar tus ${aversionesActivas.length} aversiones a la vez.';
      }
      return 'La IA generara una receta priorizando tus ingredientes disponibles '
          'y adaptandola para trabajar tu aversion de forma progresiva.';
    } else if (viewModel.usarDespensa) {
      return 'La IA priorizara los ingredientes que tienes en tu despensa '
          'para minimizar el desperdicio de alimentos.';
    } else if (aversionesActivas.isNotEmpty) {
      if (hayMultiples) {
        final nombres =
            aversionesActivas.map((a) => a.nombreAlimento).join(' y ');
        return 'La IA incluira $nombres respetando el nivel y los motivos '
            'de cada aversion para que las trabajes a la vez.';
      }
      final nivel = aversionesActivas.first.nivelRechazo;
      if (nivel <= 3) {
        return 'La IA ocultara el ingrediente rechazado en cantidades minimas '
            'para que lo experimentes sin percibirlo claramente.';
      } else if (nivel <= 6) {
        return 'La IA incluira el ingrediente en cantidad reducida con un '
            'metodo de preparacion que suavice sus caracteristicas.';
      } else {
        return 'La IA incluira el ingrediente con preparacion normal, '
            'ayudandote a trabajar la aversion de forma directa.';
      }
    }
    return 'La IA creara una receta personalizada segun tu descripcion.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF43423e).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF43423e).withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF43423e),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _mensajeEstrategia(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF55433e),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillDificultad extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _PillDificultad({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: activo
                ? [
                    BoxShadow(
                      color: const Color(0xFF91412b).withOpacity(0.08),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activo
                  ? const Color(0xFF7f5700)
                  : const Color(0xFF88726d),
            ),
          ),
        ),
      ),
    );
  }
}
