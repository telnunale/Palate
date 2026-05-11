import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/intolerancia.dart';
import '../utils/imagen_optim.dart';
import '../utils/parser_tiempos.dart';
import 'feedback_dialog.dart';
import 'temporizador_dialog.dart';

///
class ModoCocinaView extends StatefulWidget {
  final String tituloReceta;

  final String imagenUrl;

  final List<String> pasos;

  final int recetaId;

  final List<Intolerancia> aversionesAfectadas;

  const ModoCocinaView({
    super.key,
    required this.tituloReceta,
    required this.imagenUrl,
    required this.pasos,
    required this.recetaId,
    required this.aversionesAfectadas,
  });

  @override
  State<ModoCocinaView> createState() => _ModoCocinaViewState();
}

class _ModoCocinaViewState extends State<ModoCocinaView> {
  int _indicePaso = 0;

  bool get _esPrimero => _indicePaso == 0;
  bool get _esUltimo => _indicePaso == widget.pasos.length - 1;
  String get _textoPaso => widget.pasos[_indicePaso].trim();
  int get _totalPasos => widget.pasos.length;

  Future<void> _siguiente() async {
    if (_esUltimo) {
      await _finalizar();
      return;
    }
    setState(() => _indicePaso++);
  }

  void _anterior() {
    if (_esPrimero) return;
    setState(() => _indicePaso--);
  }

  Future<void> _finalizar() async {
    ResultadoFeedback resultado = ResultadoFeedback.saltado;
    if (widget.aversionesAfectadas.isNotEmpty) {
      final res = await FeedbackDialog.mostrar(
        context,
        aversiones: widget.aversionesAfectadas,
      );
      resultado = res;
    }
    if (!mounted) return;
    Navigator.pop(context, resultado);
  }

  Future<bool> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFfff8f6),
        title: Text(
          'Cerrar modo cocina',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF211a18),
          ),
        ),
        content: Text(
          'Perderas el progreso del paso a paso. Podras volver a iniciar la receta cuando quieras.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF55433e),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Continuar cocinando',
                style: GoogleFonts.inter(color: const Color(0xFF732b16))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Salir',
                style: GoogleFonts.inter(color: const Color(0xFFba1a1a))),
          ),
        ],
      ),
    );
    return salir ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final minutosDetectados = ParserTiempos.extraerMinutos(_textoPaso);
    final progreso = (_indicePaso + 1) / _totalPasos;

    // PopScope intercepta el gesto/boton atras del sistema para pedir
    // confirmacion antes de abandonar el modo cocina.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final salir = await _confirmarSalida();
        if (!mounted) return;
        if (salir) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFfff8f6),
        body: SafeArea(
          child: Column(
            children: [
              _Cabecera(
                indicePaso: _indicePaso,
                totalPasos: _totalPasos,
                progreso: progreso,
                onCerrar: () async {
                  final salir = await _confirmarSalida();
                  if (!mounted) return;
                  if (salir) Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    children: [
                      _ImagenHero(imagenUrl: widget.imagenUrl),
                      const SizedBox(height: 16),
                      _TarjetaInstruccion(
                        tituloReceta: widget.tituloReceta,
                        numeroPaso: _indicePaso + 1,
                        texto: _textoPaso,
                        minutosDetectados: minutosDetectados,
                        recetaId: widget.recetaId,
                      ),
                    ],
                  ),
                ),
              ),
              _BarraNavegacion(
                esPrimero: _esPrimero,
                esUltimo: _esUltimo,
                onAnterior: _anterior,
                onSiguiente: _siguiente,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final int indicePaso;
  final int totalPasos;
  final double progreso;
  final VoidCallback onCerrar;

  const _Cabecera({
    required this.indicePaso,
    required this.totalPasos,
    required this.progreso,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFfff8f6),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFfaebe7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PASO ${indicePaso + 1} DE $totalPasos',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: const Color(0xFF732b16),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFe6d7d4),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF91412b),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onCerrar,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFfff0ed),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFF732b16),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagenHero extends StatelessWidget {
  final String imagenUrl;

  const _ImagenHero({required this.imagenUrl});

  @override
  Widget build(BuildContext context) {
    // El hero del modo cocina ocupa todo el ancho de pantalla menos los
    // padding laterales. Se calcula el ancho fisico real para pedir al
    // CDN una imagen exactamente del tamano que se va a mostrar.
    final anchoLogico = MediaQuery.of(context).size.width - 32;
    final urlOptimizada = ImagenOptim.paraAncho(context, imagenUrl, anchoLogico);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          urlOptimizada,
          fit: BoxFit.cover,
          // cacheWidth indica al framework que decodifique la imagen ya
          // a este tamano fisico, evitando consumo extra de memoria al
          // mantener un bitmap mucho mayor de lo necesario.
          cacheWidth: ImagenOptim.anchoFisico(context, anchoLogico),
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFf4e5e2),
            child: const Center(
              child: Icon(
                Icons.restaurant,
                size: 48,
                color: Color(0xFF732b16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaInstruccion extends StatelessWidget {
  final String tituloReceta;
  final int numeroPaso;
  final String texto;
  final int? minutosDetectados;
  final int recetaId;

  const _TarjetaInstruccion({
    required this.tituloReceta,
    required this.numeroPaso,
    required this.texto,
    required this.minutosDetectados,
    required this.recetaId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFf4e5e2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF91412b).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tituloReceta,
            style: GoogleFonts.newsreader(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF732b16),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            texto,
            style: GoogleFonts.newsreader(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.55,
              color: const Color(0xFF211a18),
            ),
          ),
          if (minutosDetectados != null) ...[
            const SizedBox(height: 24),
            _Temporizador(
              minutos: minutosDetectados!,
              idTimer: recetaId * 100 + numeroPaso,
              descripcionPaso: 'Paso $numeroPaso',
            ),
          ],
        ],
      ),
    );
  }
}

class _Temporizador extends StatelessWidget {
  final int minutos;
  final int idTimer;
  final String descripcionPaso;

  const _Temporizador({
    required this.minutos,
    required this.idTimer,
    required this.descripcionPaso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFfaebe7),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFfdb733),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer,
                  color: Color(0xFF604100),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEMPORIZADOR SUGERIDO',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                      color: const Color(0xFF55433e),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ParserTiempos.formatearDuracion(minutos),
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF211a18),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                TemporizadorDialog.mostrar(
                  context,
                  idTimer: idTimer,
                  minutosSugeridos: minutos,
                  descripcionPaso: descripcionPaso,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF91412b),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Iniciar Temporizador',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraNavegacion extends StatelessWidget {
  final bool esPrimero;
  final bool esUltimo;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;

  const _BarraNavegacion({
    required this.esPrimero,
    required this.esUltimo,
    required this.onAnterior,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFfff8f6),
        border: Border(
          top: BorderSide(color: const Color(0xFFfaebe7)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: esPrimero ? null : onAnterior,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: esPrimero
                        ? const Color(0xFFdbc1ba)
                        : const Color(0xFF88726d),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  foregroundColor: const Color(0xFF732b16),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(
                  'Anterior',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onSiguiente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF732b16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  esUltimo ? Icons.check : Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  esUltimo ? 'Terminar' : 'Siguiente',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
