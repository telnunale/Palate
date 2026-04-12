import 'package:flutter/material.dart';
import '../models/receta.dart';
import '../services/api_service.dart';

class RecetasViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Receta> recetas = [];
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
}
