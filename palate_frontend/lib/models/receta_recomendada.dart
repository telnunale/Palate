import 'receta.dart';

class RecetaRecomendada extends Receta {
  final int score;
  final String motivoRecomendacion;

  RecetaRecomendada({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.instrucciones,
    required super.tiempoPreparacion,
    required super.tiempoCoccion,
    required super.dificultad,
    super.imagenUrl,
    super.generadaPorIa,
    required this.score,
    required this.motivoRecomendacion,
  });

  factory RecetaRecomendada.fromJson(Map<String, dynamic> json) {
    return RecetaRecomendada(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      instrucciones: json['instrucciones'] ?? '',
      tiempoPreparacion: json['tiempoPreparacion'] ?? 0,
      tiempoCoccion: json['tiempoCoccion'] ?? 0,
      dificultad: json['dificultad'] ?? 'MEDIA',
      imagenUrl: json['imagenUrl'],
      generadaPorIa: json['generadaPorIa'] ?? false,
      score: json['score'] ?? 0,
      motivoRecomendacion: json['motivoRecomendacion'] ?? '',
    );
  }
}
