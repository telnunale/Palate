import 'package:flutter/material.dart';
import '../models/receta.dart';
import '../models/receta_recomendada.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Receta> recetas = [];
  List<RecetaRecomendada> recetasRecomendadas = [];
  int totalDespensa = 0;
  int totalAversiones = 0;

  bool cargando = true;
  String? error;

  int get totalRecetas => recetas.length;

  List<Receta> get recetasRecientes {
    if (recetas.isEmpty) return [];
    final ordenadas = List<Receta>.from(recetas)
      ..sort((a, b) => b.id.compareTo(a.id));
    return ordenadas.take(2).toList();
  }

  Future<void> cargarDatos(int usuarioId) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _apiService.obtenerRecetas(),
        _apiService.obtenerRecomendaciones(usuarioId).catchError(
          (_) => <RecetaRecomendada>[],
        ),
        _apiService.obtenerDespensa(usuarioId).catchError(
          (_) => <Map<String, dynamic>>[],
        ),
        _apiService.obtenerAversiones(usuarioId).catchError(
          (_) => <Map<String, dynamic>>[],
        ),
      ]);
      recetas = resultados[0] as List<Receta>;
      recetasRecomendadas = resultados[1] as List<RecetaRecomendada>;

      final despensaJson = resultados[2] as List<Map<String, dynamic>>;
      totalDespensa = despensaJson
          .where((p) => p['consumido'] != true)
          .length;

      final aversionesJson = resultados[3] as List<Map<String, dynamic>>;
      totalAversiones = aversionesJson.length;

      cargando = false;
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar los datos';
      cargando = false;
      notifyListeners();
    }
  }
}
