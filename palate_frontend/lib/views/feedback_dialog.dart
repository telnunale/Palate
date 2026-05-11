import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/intolerancia.dart';
import '../services/api_service.dart';

enum ResultadoFeedback {
  tolerado,

  dificultad,

  saltado,
}

///
class FeedbackDialog extends StatefulWidget {
  final List<Intolerancia> aversiones;

  const FeedbackDialog({
    super.key,
    required this.aversiones,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();

  static Future<ResultadoFeedback> mostrar(
    BuildContext context, {
    required List<Intolerancia> aversiones,
  }) async {
    final resultado = await showDialog<ResultadoFeedback>(
      context: context,
      barrierDismissible: true,
      builder: (_) => FeedbackDialog(aversiones: aversiones),
    );
    return resultado ?? ResultadoFeedback.saltado;
  }
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final ApiService _apiService = ApiService();

  late Intolerancia _aversionSeleccionada;

  bool _enviando = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _aversionSeleccionada = widget.aversiones.first;
  }

  Future<void> _registrar(bool tolerado) async {
    setState(() {
      _enviando = true;
      _error = null;
    });

    try {
      await _apiService.registrarFeedback(
        intoleranciaId: _aversionSeleccionada.id,
        tolerado: tolerado,
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        tolerado ? ResultadoFeedback.tolerado : ResultadoFeedback.dificultad,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _error = 'No se pudo registrar el feedback. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tieneVariasAversiones = widget.aversiones.length > 1;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono representativo del feedback
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFfff0ed),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_alt_outlined,
                color: Color(0xFF732b16),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // Titulo de la pregunta principal
            Text(
              '¿Como te fue con\n${_aversionSeleccionada.nombreAlimento}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF211a18),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu respuesta ajusta automaticamente el nivel de progreso '
              'de esta aversion.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF55433e),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Selector de aversion si la receta afecta a varias
            if (tieneVariasAversiones) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFfff0ed),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Intolerancia>(
                    value: _aversionSeleccionada,
                    isExpanded: true,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF211a18),
                    ),
                    items: widget.aversiones
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(a.nombreAlimento),
                          ),
                        )
                        .toList(),
                    onChanged: _enviando
                        ? null
                        : (valor) {
                            if (valor != null) {
                              setState(() => _aversionSeleccionada = valor);
                            }
                          },
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Mensaje de error si falla el envio
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFffdad6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFba1a1a),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Boton tolerado: incrementa el progreso
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _enviando ? null : () => _registrar(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF732b16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.thumb_up_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Lo toleré bien',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Boton dificultad: decrementa el progreso
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _enviando ? null : () => _registrar(false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFdbc1ba)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(
                  Icons.thumb_down_outlined,
                  color: Color(0xFF732b16),
                  size: 18,
                ),
                label: Text(
                  'Me costó',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF732b16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Boton saltar: cierra sin registrar nada
            TextButton(
              onPressed: _enviando
                  ? null
                  : () => Navigator.pop(context, ResultadoFeedback.saltado),
              child: Text(
                'Saltar',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF88726d),
                ),
              ),
            ),

            // Indicador de carga durante el envio
            if (_enviando)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Color(0xFF732b16),
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
