import 'package:flutter/material.dart';
import '../models/producto_despensa.dart';
import '../services/api_service.dart';

class DespensaViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductoDespensa> _productos = [];

  String? categoriaSeleccionada;

  bool cargando = true;
  String? error;

  List<Map<String, dynamic>> catalogoAlimentos = [];
  bool cargandoCatalogo = false;

  List<ProductoDespensa> get productosFiltrados {
    if (categoriaSeleccionada == null || categoriaSeleccionada == 'Todos') {
      return List.unmodifiable(_productos);
    }
    return _productos
        .where((p) => p.categoriaAlimento == categoriaSeleccionada)
        .toList();
  }

  int get totalProductos => _productos.length;

  List<ProductoDespensa> get proximosACaducar {
    return _productos.where((p) {
      final dias = p.diasHastaCaducidad;
      return dias != null && dias <= 3;
    }).toList()
      ..sort((a, b) =>
          (a.diasHastaCaducidad ?? 999)
              .compareTo(b.diasHastaCaducidad ?? 999));
  }

  List<String> get categorias {
    final cats = <String>{'Todos'};
    for (final p in _productos) {
      if (p.categoriaAlimento != null && p.categoriaAlimento!.isNotEmpty) {
        cats.add(p.categoriaAlimento!);
      }
    }
    return cats.toList();
  }

  Future<void> cargarProductos(int usuarioId) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final datos = await _apiService.obtenerDespensa(usuarioId);
      _productos = datos
          .map((json) => ProductoDespensa.fromJson(json))
          .where((p) => !p.consumido)
          .toList();
      cargando = false;
      notifyListeners();
    } catch (e) {
      error = 'No se pudo cargar la despensa';
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> marcarConsumido(int id, int usuarioId) async {
    try {
      await _apiService.actualizarProducto(id, {'consumido': true});
      await cargarProductos(usuarioId);
    } catch (e) {
      error = 'No se pudo actualizar el producto';
      notifyListeners();
    }
  }

  Future<void> actualizarProducto(
    int id,
    int usuarioId, {
    required String cantidad,
    required String unidad,
    String? fechaCaducidad,
  }) async {
    try {
      await _apiService.actualizarProducto(id, {
        'cantidad': _normalizarDecimal(cantidad),
        'unidad': unidad,
        if (fechaCaducidad != null) 'fechaCaducidad': fechaCaducidad,
      });
      await cargarProductos(usuarioId);
    } catch (e) {
      error = 'No se pudo actualizar el producto';
      notifyListeners();
    }
  }

  String _normalizarDecimal(String valor) {
    return valor.trim().replaceAll(',', '.');
  }

  Future<void> eliminarProducto(int id, int usuarioId) async {
    try {
      await _apiService.eliminarProducto(id);
      await cargarProductos(usuarioId);
    } catch (e) {
      error = 'No se pudo eliminar el producto';
      notifyListeners();
    }
  }

  void seleccionarCategoria(String? categoria) {
    categoriaSeleccionada = categoria;
    notifyListeners();
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

  Future<void> agregarProducto({
    required int usuarioId,
    required int alimentoId,
    required String cantidad,
    required String unidad,
    String? fechaCaducidad,
  }) async {
    try {
      await _apiService.agregarProducto(
        usuarioId: usuarioId,
        alimentoId: alimentoId,
        cantidad: _normalizarDecimal(cantidad),
        unidad: unidad,
        fechaCaducidad: fechaCaducidad,
      );
      await cargarProductos(usuarioId);
    } catch (e) {
      error = 'No se pudo agregar el producto';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> crearAlimento({
    required String nombre,
    String categoria = 'Otros',
  }) async {
    try {
      final alimento = await _apiService.crearAlimento(
        nombre: nombre,
        categoria: categoria,
      );
      final id = alimento['id'] as int? ?? 0;
      if (id > 0) {
        final yaExiste = catalogoAlimentos.any((a) => a['id'] == id);
        if (!yaExiste) {
          catalogoAlimentos = [...catalogoAlimentos, alimento];
          catalogoAlimentos.sort((a, b) =>
              ((a['nombre'] as String?) ?? '')
                  .toLowerCase()
                  .compareTo(((b['nombre'] as String?) ?? '').toLowerCase()));
          notifyListeners();
        }
      }
      return alimento;
    } catch (e) {
      error = 'No se pudo crear el alimento';
      notifyListeners();
      return null;
    }
  }
}
