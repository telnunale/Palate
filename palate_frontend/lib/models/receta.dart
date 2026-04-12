class Receta {
  final int id;
  final String titulo;
  final String descripcion;
  final String instrucciones;
  final int tiempoPreparacion;
  final int tiempoCoccion;
  final String dificultad;
  final String? imagenUrl;

  Receta({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.instrucciones,
    required this.tiempoPreparacion,
    required this.tiempoCoccion,
    required this.dificultad,
    this.imagenUrl,
  });

  int get tiempoTotal => tiempoPreparacion + tiempoCoccion;

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
    );
  }
}
