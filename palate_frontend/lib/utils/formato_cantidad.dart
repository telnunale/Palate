class FormatoCantidad {
  static String legible(double cantidad, String unidad) {
    final unidadNormalizada = _normalizarUnidad(unidad);
    final cantidadTexto = _formatearCantidad(cantidad);

    if (_esUnidadContable(unidadNormalizada)) {
      return '$cantidadTexto $unidadNormalizada';
    }
    return '$cantidadTexto $unidadNormalizada';
  }

  static String _formatearCantidad(double valor) {
    if (valor == valor.roundToDouble()) {
      return valor.toInt().toString();
    }

    final entero = valor.floor();
    final fraccion = valor - entero;
    final fraccionTexto = _fraccionLegible(fraccion);

    if (fraccionTexto == null) {
      return valor.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    if (entero == 0) return fraccionTexto;
    return '$entero y $fraccionTexto';
  }

  static String? _fraccionLegible(double fraccion) {
    const tolerancia = 0.02;
    final candidatos = <double, String>{
      0.25: '1/4',
      0.333: '1/3',
      0.5: '1/2',
      0.667: '2/3',
      0.75: '3/4',
    };
    for (final entry in candidatos.entries) {
      if ((fraccion - entry.key).abs() < tolerancia) return entry.value;
    }
    return null;
  }

  static String _normalizarUnidad(String unidad) {
    final u = unidad.toLowerCase().trim();
    switch (u) {
      case 'ud':
      case 'uds':
      case 'unidad':
      case 'unidades':
        return 'ud';
      case 'cucharada':
      case 'cucharadas':
      case 'cda':
        return 'cucharada';
      case 'cucharadita':
      case 'cucharaditas':
      case 'cdta':
        return 'cucharadita';
      case 'diente':
      case 'dientes':
        return 'diente';
      case 'vaso':
      case 'vasos':
        return 'vaso';
      case 'taza':
      case 'tazas':
        return 'taza';
      case 'pellizco':
      case 'pizca':
        return 'pizca';
      default:
        return unidad;
    }
  }

  static bool _esUnidadContable(String unidad) {
    return const {'ud', 'cucharada', 'cucharadita', 'diente', 'vaso', 'taza', 'pizca'}
        .contains(unidad);
  }
}
