import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/intolerancia.dart';
import '../viewmodels/aversiones_viewmodel.dart';
import 'gestionar_aversion_view.dart';

class AversionesView extends StatefulWidget {
  final int usuarioId;

  const AversionesView({super.key, required this.usuarioId});

  @override
  State<AversionesView> createState() => _AversionesViewState();
}

class _AversionesViewState extends State<AversionesView> {
  final _viewModel = AversionesViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.cargarAversiones(widget.usuarioId).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: Column(
          children: [
            _AppBarAversiones(onVolver: () => Navigator.pop(context)),

            Expanded(
              child: _viewModel.cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF732b16),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titulo e introduccion
                          Text(
                            'Mis aversiones\nalimentarias',
                            style: GoogleFonts.newsreader(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF211a18),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gestiona los alimentos que te generan rechazo. '
                            'La IA adapta las recetas segun tu perfil sensorial.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF55433e),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Seccion de aversiones activas: las que el usuario
                          // todavia esta trabajando para superar.
                          if (_viewModel.aversiones.isEmpty)
                            _EstadoVacioAversiones()
                          else ...[
                            if (_viewModel.aversionesActivas.isNotEmpty)
                              _GridAversiones(
                                aversiones: _viewModel.aversionesActivas,
                                onEditar: (aversion) =>
                                    _navegarAGestionar(aversion),
                                onEliminar: (id) async {
                                  await _viewModel.eliminarAversion(
                                      id, widget.usuarioId);
                                  // Comprobacion de mounted antes de setState
                                  // para evitar errores si el usuario navega
                                  // durante la operacion asincrona.
                                  if (!mounted) return;
                                  setState(() {});
                                },
                              ),

                            // Seccion de aversiones superadas: se mantienen como
                            // historico de logros aunque ya no afecten a la IA.
                            if (_viewModel.aversionesSuperadas.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _CabeceraSuperadas(
                                cantidad: _viewModel.aversionesSuperadas.length,
                              ),
                              const SizedBox(height: 12),
                              _GridAversiones(
                                aversiones: _viewModel.aversionesSuperadas,
                                onEditar: (aversion) =>
                                    _navegarAGestionar(aversion),
                                onEliminar: (id) async {
                                  await _viewModel.eliminarAversion(
                                      id, widget.usuarioId);
                                  if (!mounted) return;
                                  setState(() {});
                                },
                              ),
                            ],
                          ],

                          const SizedBox(height: 16),

                          // Tarjeta de agrega nueva aversion
                          GestureDetector(
                            onTap: () => _navegarAGestionar(null),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFdbc1ba),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFfaebe7),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Icon(
                                      Icons.add_reaction_outlined,
                                      color: Color(0xFF732b16),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '¿Algún otro alimento?',
                                    style: GoogleFonts.newsreader(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF211a18),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tu perfil sensorial evoluciona con el tiempo.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF88726d),
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarAGestionar(null),
        backgroundColor: const Color(0xFF732b16),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navegarAGestionar(Intolerancia? aversion) async {
    // Cargar catalogo de alimentos si aun no se ha cargado
    if (_viewModel.catalogoAlimentos.isEmpty) {
      await _viewModel.cargarCatalogo(widget.usuarioId);
    }

    if (!mounted) return;

    // En creacion, excluir alimentos para los que ya existe aversion
    // para evitar la violacion de restriccion unica en la base de datos
    final idsConAversion =
        _viewModel.aversiones.map((a) => a.alimentoId).toSet();
    final catalogoDisponible = aversion != null
        ? _viewModel.catalogoAlimentos
        : _viewModel.catalogoAlimentos
            .where((a) => !idsConAversion.contains(a['id'] as int? ?? 0))
            .toList();

    // El formulario devuelve true cuando el guardado se completa con
    // exito, null si el usuario cancela. Permite mostrar el SnackBar de
    // confirmacion solo cuando hay un cambio efectivo en la lista.
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GestionarAversionView(
          usuarioId: widget.usuarioId,
          aversion: aversion,
          catalogoAlimentos: catalogoDisponible,
        ),
      ),
    );

    // Recargar aversiones al volver del formulario
    await _viewModel.cargarAversiones(widget.usuarioId);
    if (!mounted) return;
    setState(() {});

    if (guardado == true) {
      final mensaje = aversion != null
          ? 'Aversión actualizada'
          : 'Aversión guardada';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF732b16),
        ),
      );
    }
  }
}

class _AppBarAversiones extends StatelessWidget {
  final VoidCallback onVolver;

  const _AppBarAversiones({required this.onVolver});

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

class _CabeceraSuperadas extends StatelessWidget {
  final int cantidad;

  const _CabeceraSuperadas({required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.emoji_events_outlined,
          color: Color(0xFF7f5700),
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          'Aversiones superadas',
          style: GoogleFonts.newsreader(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF211a18),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFfdb733).withOpacity(0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$cantidad',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6d4a00),
            ),
          ),
        ),
      ],
    );
  }
}

class _EstadoVacioAversiones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.sentiment_satisfied_alt,
              size: 56,
              color: Color(0xFFdbc1ba),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin aversiones registradas',
              style: GoogleFonts.newsreader(
                fontSize: 18,
                color: const Color(0xFF88726d),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega alimentos que te generan rechazo\npara personalizar tus recetas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF88726d),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridAversiones extends StatelessWidget {
  final List<Intolerancia> aversiones;
  final void Function(Intolerancia) onEditar;
  final void Function(int) onEliminar;

  const _GridAversiones({
    required this.aversiones,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: aversiones.length,
      itemBuilder: (context, index) {
        return _TarjetaAversion(
          aversion: aversiones[index],
          onEditar: () => onEditar(aversiones[index]),
          onEliminar: () => onEliminar(aversiones[index].id),
        );
      },
    );
  }
}

class _TarjetaAversion extends StatelessWidget {
  final Intolerancia aversion;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaAversion({
    required this.aversion,
    required this.onEditar,
    required this.onEliminar,
  });

  Future<void> _confirmarEliminacion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Eliminar aversion',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF211a18),
          ),
        ),
        content: Text(
          '¿Seguro que quieres eliminar la aversion a "${aversion.nombreAlimento}"? '
          'Esta accion no se puede deshacer.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF55433e),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF88726d),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Eliminar',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFba1a1a),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      onEliminar();
    }
  }

  Color _colorBarra(int nivel) {
    if (nivel >= 7) return const Color(0xFFba1a1a);
    if (nivel >= 4) return const Color(0xFFfdb733);
    return Colors.green;
  }

  Color _colorTextoNivel(int nivel) {
    if (nivel >= 7) return const Color(0xFFba1a1a);
    if (nivel >= 4) return const Color(0xFF7f5700);
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFdbc1ba).withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF91412b).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: imagen y boton de edicion
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen o inicial del alimento
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFfaebe7),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: aversion.imagenAlimento != null
                    ? Image.network(
                        aversion.imagenAlimento!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            aversion.nombreAlimento.isNotEmpty
                                ? aversion.nombreAlimento[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.newsreader(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF732b16),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          aversion.nombreAlimento.isNotEmpty
                              ? aversion.nombreAlimento[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.newsreader(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF732b16),
                          ),
                        ),
                      ),
              ),
              const Spacer(),
              // Boton de edicion: abre el formulario de la aversion
              GestureDetector(
                onTap: onEditar,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF88726d),
                ),
              ),
              const SizedBox(width: 12),
              // Boton de eliminacion: muestra una confirmacion antes de
              // borrar la aversion para evitar accidentes destructivos.
              GestureDetector(
                onTap: () => _confirmarEliminacion(context),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFFba1a1a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nombre del alimento
          Text(
            aversion.nombreAlimento,
            style: GoogleFonts.newsreader(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF211a18),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Badge de estado de progreso
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFfdb733).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              aversion.etiquetaEstado,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFF6d4a00),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Nivel de rechazo y barra
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rechazo',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF88726d),
                ),
              ),
              Text(
                '${aversion.nivelRechazo}/10',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _colorTextoNivel(aversion.nivelRechazo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: aversion.nivelRechazo / 10,
              backgroundColor: const Color(0xFFf4e5e2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _colorBarra(aversion.nivelRechazo),
              ),
              minHeight: 6,
            ),
          ),

          // Barra adicional de progreso. Visualiza el avance del usuario en
          // la superacion de la aversion, complementando la barra de rechazo.
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF88726d),
                ),
              ),
              Text(
                '${aversion.nivelProgreso}/${aversion.nivelRechazo}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7f5700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              // El valor se acota a 1.0 para evitar desbordes visuales
              // si el progreso ya supero el rechazo (caso aversion superada).
              value: aversion.nivelRechazo == 0
                  ? 0
                  : (aversion.nivelProgreso / aversion.nivelRechazo)
                      .clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFf4e5e2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7f5700),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
