import 'package:flutter/material.dart';
import '../models/intolerancia.dart';
import '../models/receta.dart';
import '../services/api_service.dart';

class RecetasViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Receta> recetas = [];
  List<Intolerancia> aversiones = [];

  bool cargando = true;
  String? error;

  Future<void> cargarRecetas() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      recetas = await _apiService.obtenerRecetas();
      cargando = false;
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar las recetas';
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarAversiones(int usuarioId) async {
    try {
      final datos = await _apiService.obtenerAversiones(usuarioId);
      aversiones = datos
          .map((j) => Intolerancia.fromJson(j))
          .where((a) => !a.superada)
          .toList();
      notifyListeners();
    } catch (_) {
      aversiones = [];
      notifyListeners();
    }
  }
}
