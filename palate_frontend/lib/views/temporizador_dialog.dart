import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';
import '../services/timer_storage.dart';
import '../utils/parser_tiempos.dart';

///
///
class TemporizadorDialog extends StatefulWidget {
  final int idTimer;

  final int minutosSugeridos;

  final String descripcionPaso;

  const TemporizadorDialog({
    super.key,
    required this.idTimer,
    required this.minutosSugeridos,
    required this.descripcionPaso,
  });

  static Future<void> mostrar(
    BuildContext context, {
    required int idTimer,
    required int minutosSugeridos,
    required String descripcionPaso,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TemporizadorDialog(
        idTimer: idTimer,
        minutosSugeridos: minutosSugeridos,
        descripcionPaso: descripcionPaso,
      ),
    );
  }

  @override
  State<TemporizadorDialog> createState() => _TemporizadorDialogState();
}

class _TemporizadorDialogState extends State<TemporizadorDialog> {
  late int _segundosRestantes;

  bool _enMarcha = false;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.minutosSugeridos * 60;
    _restaurarTimerActivo();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _restaurarTimerActivo() async {
    final guardado = await TimerStorage.obtener(widget.idTimer);
    if (guardado == null || !mounted) return;

    final restante = guardado.restante;
    if (restante.inSeconds <= 0) {
      // El temporizador ya termino mientras la app estaba cerrada
      await TimerStorage.eliminar(widget.idTimer);
      return;
    }

    setState(() {
      _segundosRestantes = restante.inSeconds;
      _enMarcha = true;
    });
    _arrancarTicker();
  }

  Future<void> _iniciar() async {
    if (_segundosRestantes <= 0) return;

    // Solicita permisos de notificacion solo si aun no se han concedido.
    // Si el usuario los rechaza se mantiene la cuenta atras visual; al
    // terminar no recibira notificacion del sistema.
    await NotificationService.instancia.solicitarPermisos();

    final fin = DateTime.now().add(Duration(seconds: _segundosRestantes));

    await NotificationService.instancia.programarNotificacion(
      id: widget.idTimer,
      cuando: fin,
      titulo: 'Temporizador finalizado',
      cuerpo: widget.descripcionPaso,
    );

    await TimerStorage.guardar(TimerActivo(
      id: widget.idTimer,
      fin: fin,
      descripcion: widget.descripcionPaso,
    ));

    if (!mounted) return;
    setState(() => _enMarcha = true);
    _arrancarTicker();
  }

  Future<void> _pausar() async {
    _ticker?.cancel();
    await NotificationService.instancia.cancelar(widget.idTimer);
    await TimerStorage.eliminar(widget.idTimer);
    if (!mounted) return;
    setState(() => _enMarcha = false);
  }

  Future<void> _reiniciar() async {
    if (_enMarcha) {
      await _pausar();
    }
    if (!mounted) return;
    setState(() => _segundosRestantes = widget.minutosSugeridos * 60);
  }

  void _arrancarTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      if (_segundosRestantes <= 0) {
        _ticker?.cancel();
        await TimerStorage.eliminar(widget.idTimer);
        if (!mounted) return;
        setState(() => _enMarcha = false);
        return;
      }
      setState(() => _segundosRestantes--);
    });
  }

  String get _textoCuentaAtras {
    final horas = _segundosRestantes ~/ 3600;
    final minutos = (_segundosRestantes % 3600) ~/ 60;
    final segundos = _segundosRestantes % 60;
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    if (horas > 0) {
      return '${dosDigitos(horas)}:${dosDigitos(minutos)}:${dosDigitos(segundos)}';
    }
    return '${dosDigitos(minutos)}:${dosDigitos(segundos)}';
  }

  double get _progreso {
    final total = widget.minutosSugeridos * 60;
    if (total <= 0) return 0;
    return 1 - (_segundosRestantes / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final terminado = _segundosRestantes <= 0;

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
            // Cabecera con icono y titulo
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFfff0ed),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    color: Color(0xFF732b16),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Temporizador',
                    style: GoogleFonts.newsreader(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF211a18),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Color(0xFF88726d),
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Texto del paso al que se refiere el temporizador
            Text(
              widget.descripcionPaso,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF55433e),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Cuenta atras circular grande
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _progreso,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFf4e5e2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        terminado
                            ? const Color(0xFF7f5700)
                            : const Color(0xFF732b16),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        terminado ? '¡Listo!' : _textoCuentaAtras,
                        style: GoogleFonts.newsreader(
                          fontSize: terminado ? 28 : 32,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF211a18),
                        ),
                      ),
                      if (!terminado) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Sugerencia: ${ParserTiempos.formatearDuracion(widget.minutosSugeridos)}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF88726d),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Controles principales: Iniciar / Pausar y Reiniciar
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: terminado
                          ? null
                          : (_enMarcha ? _pausar : _iniciar),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF732b16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        _enMarcha ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        _enMarcha ? 'Pausar' : 'Iniciar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: OutlinedButton(
                    onPressed: _reiniciar,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFdbc1ba)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Color(0xFF732b16),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Pie informativo: avisa de que la notificacion sonara aunque
            // la aplicacion este cerrada, asi el usuario sabe que puede
            // dejar el dispositivo y volver a la cocina con tranquilidad.
            const SizedBox(height: 10),
            Text(
              'Recibiras una notificacion al terminar, aunque cierres la app.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF88726d),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
