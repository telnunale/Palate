///
class ParserTiempos {
  static final RegExp _patronTiempo = RegExp(
    r'(\d+)\s*(minutos?|min|horas?|h)\b',
    caseSensitive: false,
  );

  static final RegExp _patronMediaHora = RegExp(
    r'media\s+hora',
    caseSensitive: false,
  );

  ///
  static int? extraerMinutos(String texto) {
    final tiempos = extraerTodosMinutos(texto);
    return tiempos.isEmpty ? null : tiempos.first;
  }

  static List<int> extraerTodosMinutos(String texto) {
    final resultados = <int>[];

    // Caso especial 'media hora': se anade primero si aparece antes que
    // cualquier coincidencia numerica.
    final coincMedia = _patronMediaHora.firstMatch(texto);
    if (coincMedia != null) {
      resultados.add(30);
    }

    // Resto de coincidencias numericas
    for (final coinc in _patronTiempo.allMatches(texto)) {
      final cantidad = int.tryParse(coinc.group(1) ?? '');
      final unidad = coinc.group(2)?.toLowerCase() ?? '';
      if (cantidad == null) continue;

      final esHora = unidad.startsWith('h');
      final minutos = esHora ? cantidad * 60 : cantidad;

      // Acotamiento defensivo: ningun paso de receta razonable supera 12 horas
      if (minutos > 0 && minutos <= 720) {
        resultados.add(minutos);
      }
    }

    return resultados;
  }

  static String formatearDuracion(int minutos) {
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    final restantes = minutos % 60;
    if (restantes == 0) return '$horas h';
    return '$horas h $restantes min';
  }
}
