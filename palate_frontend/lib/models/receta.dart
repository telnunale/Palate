class Receta {
  final int id;
  final String titulo;
  final String descripcion;
  final String instrucciones;
  final int tiempoPreparacion;
  final int tiempoCoccion;
  final String dificultad;
  final String? imagenUrl;
  final bool generadaPorIa;
  final List<int> idsAlimentos;
  final Map<int, List<String>> metodosPorAlimento;
  final double? caloriasTotal;
  final double? proteinasTotal;
  final double? hidratosTotal;
  final double? grasasTotal;

  Receta({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.instrucciones,
    required this.tiempoPreparacion,
    required this.tiempoCoccion,
    required this.dificultad,
    this.imagenUrl,
    this.generadaPorIa = false,
    this.idsAlimentos = const [],
    this.metodosPorAlimento = const {},
    this.caloriasTotal,
    this.proteinasTotal,
    this.hidratosTotal,
    this.grasasTotal,
  });

  int get tiempoTotal => tiempoPreparacion + tiempoCoccion;

  factory Receta.fromJson(Map<String, dynamic> json) {
    final ingredientesJson = json['ingredientes'] as List<dynamic>?;
    final ids = <int>[];
    final metodos = <int, List<String>>{};
    if (ingredientesJson != null) {
      for (final ing in ingredientesJson) {
        final ingMap = ing as Map<String, dynamic>;
        final alimento = ingMap['alimento'] as Map<String, dynamic>?;
        final id = alimento?['id'] as int?;
        if (id != null && id > 0) {
          ids.add(id);
          final metodo = ingMap['metodoPreparacion'] as String?;
          if (metodo != null) {
            metodos.putIfAbsent(id, () => []).add(metodo);
          }
        }
      }
    }

    return Receta(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      instrucciones: json['instrucciones'] ?? '',
      tiempoPreparacion: json['tiempoPreparacion'] ?? 0,
      tiempoCoccion: json['tiempoCoccion'] ?? 0,
      dificultad: json['dificultad'] ?? 'MEDIA',
      imagenUrl: json['imagenUrl'],
      generadaPorIa: json['generadaPorIa'] ?? false,
      idsAlimentos: ids,
      metodosPorAlimento: metodos,
      caloriasTotal: (json['caloriasTotal'] as num?)?.toDouble(),
      proteinasTotal: (json['proteinasTotal'] as num?)?.toDouble(),
      hidratosTotal: (json['hidratosTotal'] as num?)?.toDouble(),
      grasasTotal: (json['grasasTotal'] as num?)?.toDouble(),
    );
  }
}
