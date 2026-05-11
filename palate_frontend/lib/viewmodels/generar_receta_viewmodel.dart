import 'package:flutter/material.dart';
import '../models/receta.dart';
import '../models/intolerancia.dart';
import '../models/producto_despensa.dart';
import '../services/api_service.dart';

class GenerarRecetaViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Intolerancia> aversiones = [];
  List<ProductoDespensa> despensa = [];

  String descripcion = '';
  bool usarDespensa = false;
  bool usarAversion = false;

  static const int maxAversionesSeleccionadas = 2;

  final List<Intolerancia> aversionesSeleccionadas = [];

  Intolerancia? get aversionSeleccionada =>
      aversionesSeleccionadas.isEmpty ? null : aversionesSeleccionadas.first;

  String dificultad = 'MEDIA';

  bool generando = false;
  Receta? recetaGenerada;
  String? error;
  bool cargandoContexto = true;

  Future<void> cargarContexto(int usuarioId) async {
    cargandoContexto = true;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _apiService.obtenerAversiones(usuarioId),
        _apiService.obtenerDespensa(usuarioId),
      ]);

      aversiones = resultados[0]
          .map((json) => Intolerancia.fromJson(json))
          .toList();

      despensa = resultados[1]
          .map((json) => ProductoDespensa.fromJson(json))
          .where((p) => !p.consumido)
          .toList();
    } catch (_) {
      aversiones = [];
      despensa = [];
    } finally {
      cargandoContexto = false;
      notifyListeners();
    }
  }

  Future<Receta?> generar(int usuarioId) async {
    if (!usarDespensa && descripcion.trim().isEmpty) {
      error = 'Describe lo que quieres cocinar';
      notifyListeners();
      return null;
    }

    generando = true;
    error = null;
    recetaGenerada = null;
    notifyListeners();

    final descripcionBase = descripcion.trim().isEmpty
        ? 'Sugiere una receta usando los ingredientes disponibles'
        : descripcion.trim();

    final descripcionCompleta = dificultad != 'MEDIA'
        ? '$descripcionBase (dificultad: ${_textoDificultad(dificultad)})'
        : descripcionBase;

    final idsAversion =
        (usarAversion && aversionesSeleccionadas.isNotEmpty)
            ? aversionesSeleccionadas.map((a) => a.id).toList()
            : <int>[];

    try {
      Receta receta;

      if (usarDespensa) {
        receta = await _apiService.generarRecetaConDespensa(
          usuarioId: usuarioId,
          descripcion: descripcionCompleta,
          intoleranciaIds: idsAversion,
        );
      } else if (idsAversion.isNotEmpty) {
        receta = await _apiService.generarRecetaConAversion(
          descripcionCompleta,
          idsAversion,
        );
      } else {
        receta = await _apiService.generarReceta(descripcionCompleta);
      }

      recetaGenerada = receta;
      generando = false;
      notifyListeners();
      return receta;
    } catch (e) {
      error = 'No se pudo generar la receta. Intenta de nuevo.';
      generando = false;
      notifyListeners();
      return null;
    }
  }

  bool alternarAversion(Intolerancia aversion) {
    final existente = aversionesSeleccionadas
        .indexWhere((a) => a.id == aversion.id);
    if (existente >= 0) {
      aversionesSeleccionadas.removeAt(existente);
      notifyListeners();
      return true;
    }
    if (aversionesSeleccionadas.length >= maxAversionesSeleccionadas) {
      return false;
    }
    aversionesSeleccionadas.add(aversion);
    notifyListeners();
    return true;
  }

  void limpiarAversiones() {
    if (aversionesSeleccionadas.isEmpty) return;
    aversionesSeleccionadas.clear();
    notifyListeners();
  }

  String _textoDificultad(String codigo) {
    switch (codigo) {
      case 'FACIL': return 'facil';
      case 'DIFICIL': return 'dificil';
      default: return 'media';
    }
  }
}
