/// Modelo que representa una receta de cocina.
/// Mapea la estructura del DTO devuelto por el endpoint GET /recetas.
class Receta {
  /// Identificador único de la receta
  final int id;

  /// Nombre o título de la receta
  final String titulo;

  /// Descripción breve del plato
  final String descripcion;

  /// Pasos de elaboración detallados
  final String instrucciones;

  /// Tiempo de preparación en minutos
  final int tiempoPreparacion;

  /// Tiempo de cocción en minutos
  final int tiempoCoccion;

  /// Nivel de dificultad: FACIL, MEDIA o DIFICIL
  final String dificultad;

  /// URL de la imagen representativa (puede ser nula)
  final String? imagenUrl;

  /// Indica si la receta fue generada automáticamente por la IA
  final bool generadaPorIa;

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
  });

  /// Suma del tiempo de preparación y cocción
  int get tiempoTotal => tiempoPreparacion + tiempoCoccion;

  /// Crea una instancia de [Receta] a partir de un mapa JSON.
  factory Receta.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
