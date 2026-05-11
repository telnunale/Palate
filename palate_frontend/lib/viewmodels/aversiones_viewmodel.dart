import 'package:flutter/material.dart';
import '../models/intolerancia.dart';
import '../services/api_service.dart';

class AversionesViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Intolerancia> aversiones = [];
  List<Map<String, dynamic>> catalogoAlimentos = [];

  bool cargando = true;
  bool cargandoCatalogo = false;
  String? error;

  int get totalAversiones => aversiones.length;

  List<Intolerancia> get aversionesActivas =>
      aversiones.where((a) => !a.superada).toList();

  List<Intolerancia> get aversionesSuperadas =>
      aversiones.where((a) => a.superada).toList();

  Future<void> cargarAversiones(int usuarioId) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final datos = await _apiService.obtenerAversiones(usuarioId);
      aversiones = datos.map((json) => Intolerancia.fromJson(json)).toList();
      cargando = false;
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar las aversiones';
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarCatalogo(int usuarioId) async {
    cargandoCatalogo = true;
    notifyListeners();

    try {
      catalogoAlimentos = await _apiService.obtenerCatalogoAlimentos(usuarioId);
    } catch (_) {
      catalogoAlimentos = [];
    } finally {
      cargandoCatalogo = false;
      notifyListeners();
    }
  }

  Future<void> eliminarAversion(int id, int usuarioId) async {
    try {
      await _apiService.eliminarAversion(id);
      await cargarAversiones(usuarioId);
    } catch (e) {
      error = 'No se pudo eliminar la aversion';
      notifyListeners();
    }
  }
}
