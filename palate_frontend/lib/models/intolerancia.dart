class Intolerancia {
  final int id;
  final int alimentoId;
  final String nombreAlimento;
  final String? categoriaAlimento;
  final String? imagenAlimento;
  final int nivelRechazo;
  final int nivelProgreso;
  final bool superada;
  final String? fechaRegistro;
  final List<Map<String, dynamic>> motivos;

  const Intolerancia({
    required this.id,
    required this.alimentoId,
    required this.nombreAlimento,
    this.categoriaAlimento,
    this.imagenAlimento,
    required this.nivelRechazo,
    required this.nivelProgreso,
    this.superada = false,
    this.fechaRegistro,
    this.motivos = const [],
  });

  String get etiquetaEstado {
    if (superada) return 'Superada';
    if (nivelProgreso >= 7) return 'Avanzado';
    if (nivelProgreso >= 4) return 'Explorando';
    return 'En progreso';
  }

  String get etiquetaRechazo {
    if (nivelRechazo >= 10) return 'Extremo (10/10)';
    if (nivelRechazo >= 7) return 'Alto ($nivelRechazo/10)';
    if (nivelRechazo >= 4) return 'Moderado ($nivelRechazo/10)';
    return 'Bajo ($nivelRechazo/10)';
  }

  factory Intolerancia.fromJson(Map<String, dynamic> json) {
    final alimento = json['alimento'] as Map<String, dynamic>?;
    return Intolerancia(
      id: json['id'] ?? 0,
      alimentoId: alimento?['id'] as int? ?? 0,
      nombreAlimento: alimento?['nombre'] as String? ?? '',
      categoriaAlimento: alimento?['categoria'] as String?,
      imagenAlimento: alimento?['imagenUrl'] as String?,
      nivelRechazo: json['nivelRechazo'] as int? ?? 0,
      nivelProgreso: json['nivelProgreso'] as int? ?? 0,
      superada: json['superada'] as bool? ?? false,
      fechaRegistro: json['fechaRegistro'] as String?,
      motivos: (json['motivos'] as List<dynamic>?)
              ?.map((m) => m as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
