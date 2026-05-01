import 'package:flutter/material.dart';
import '../models/receta.dart';
import '../services/api_service.dart';

/// ViewModel para la pantalla de inicio (Home).
/// Sigue el patrón MVVM: recupera datos del servidor y notifica
/// a la vista para que se actualice cuando los datos cambian.
class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Lista completa de recetas cargadas desde el servidor
  List<Receta> recetas = [];

  /// Indica si hay una operación de carga en curso
  bool cargando = true;

  /// Mensaje de error si la carga falla
  String? error;

  /// Número total de recetas disponibles
  int get totalRecetas => recetas.length;

  /// Las dos recetas más recientes, ordenadas por id descendente
  List<Receta> get recetasRecientes {
    if (recetas.isEmpty) return [];
    final ordenadas = List<Receta>.from(recetas)
      ..sort((a, b) => b.id.compareTo(a.id));
    return ordenadas.take(2).toList();
  }

  /// Carga los datos necesarios para la pantalla de inicio.
  /// Obtiene las recetas del servidor para mostrar estadísticas y recientes.
  Future<void> cargarDatos() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      recetas = await _apiService.obtenerRecetas();
      cargando = false;
      notifyListeners();
    } catch (e) {
      error = 'No se pudieron cargar los datos';
      cargando = false;
      notifyListeners();
    }
  }
}
