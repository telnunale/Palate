import 'package:flutter/material.dart';
import '../models/producto_despensa.dart';
import '../services/api_service.dart';

class CalendarioViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductoDespensa> _productos = [];

  bool cargando = true;
  String? error;

  int get totalProductos => _productos.length;

  Map<DateTime, List<ProductoDespensa>> get productosPorFecha {
    final mapa = <DateTime, List<ProductoDespensa>>{};
    for (final producto in _productos) {
      final fecha = _parsearFecha(producto.fechaCaducidad);
      if (fecha == null) continue;
      mapa.putIfAbsent(fecha, () => []).add(producto);
    }
    return mapa;
  }

  List<ProductoDespensa> productosDelDia(DateTime dia) {
    final clave = DateTime(dia.year, dia.month, dia.day);
    return productosPorFecha[clave] ?? const [];
  }

  Future<void> cargarProductos(int usuarioId) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final datos = await _apiService.obtenerDespensa(usuarioId);
      _productos = datos
          .map((json) => ProductoDespensa.fromJson(json))
          .where((p) => !p.consumido && p.fechaCaducidad != null)
          .toList();
      cargando = false;
      notifyListeners();
    } catch (e) {
      error = 'No se pudo cargar el calendario';
      cargando = false;
      notifyListeners();
    }
  }

  DateTime? _parsearFecha(String? iso) {
    if (iso == null) return null;
    final fecha = DateTime.tryParse(iso);
    if (fecha == null) return null;
    return DateTime(fecha.year, fecha.month, fecha.day);
  }
}
