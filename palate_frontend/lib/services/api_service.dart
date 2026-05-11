import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/receta.dart';
import '../models/receta_recomendada.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.16:8080/api';

  Future<Usuario> login(String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      return Usuario.fromJson(json.decode(respuesta.body));
    } else {
      final error = json.decode(respuesta.body);
      throw Exception(error['error'] ?? 'Error al iniciar sesion');
    }
  }

  Future<String> registro(String nombre, String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/auth/registro'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      final datos = json.decode(respuesta.body);
      return datos['mensaje'] ?? 'Registro correcto';
    } else {
      final error = json.decode(respuesta.body);
      throw Exception(error['error'] ?? 'Error al registrarse');
    }
  }

  Future<List<Receta>> obtenerRecetas() async {
    final respuesta = await http.get(Uri.parse('$baseUrl/recetas')).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.map((json) => Receta.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar recetas');
    }
  }

  Future<Map<String, dynamic>> obtenerRecetaPorId(int id) async {
    final respuesta = await http.get(Uri.parse('$baseUrl/recetas/$id')).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al cargar la receta');
    }
  }

  Future<Receta> generarReceta(String descripcion) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/recetas/generar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'descripcion': descripcion}),
    ).timeout(const Duration(seconds: 60));

    if (respuesta.statusCode == 200) {
      return Receta.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al generar la receta');
    }
  }

  Future<Receta> generarRecetaConAversion(
    String descripcion,
    List<int> intoleranciaIds,
  ) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/recetas/generar-con-aversion'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'descripcion': descripcion,
        'intoleranciaIds': intoleranciaIds,
      }),
    ).timeout(const Duration(seconds: 60));

    if (respuesta.statusCode == 200) {
      return Receta.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al generar la receta con aversion');
    }
  }

  Future<Receta> generarRecetaConDespensa({
    required int usuarioId,
    String? descripcion,
    List<int> intoleranciaIds = const [],
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/recetas/generar-con-despensa'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuarioId': usuarioId,
        if (descripcion != null) 'descripcion': descripcion,
        if (intoleranciaIds.isNotEmpty) 'intoleranciaIds': intoleranciaIds,
      }),
    ).timeout(const Duration(seconds: 60));

    if (respuesta.statusCode == 200) {
      return Receta.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al generar la receta con despensa');
    }
  }

  Future<List<RecetaRecomendada>> obtenerRecomendaciones(int usuarioId) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/recomendaciones/$usuarioId'),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista
          .map((json) => RecetaRecomendada.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar las recomendaciones');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerDespensa(int usuarioId) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/despensa/$usuarioId'),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar la despensa');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerProximosACaducar(
    int usuarioId,
    int dias,
  ) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/despensa/$usuarioId/proximos/$dias'),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener productos proximos a caducar');
    }
  }

  Future<Map<String, dynamic>> agregarProducto({
    required int usuarioId,
    required int alimentoId,
    required String cantidad,
    required String unidad,
    String? fechaCaducidad,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/despensa'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuarioId': usuarioId,
        'alimentoId': alimentoId,
        'cantidad': cantidad,
        'unidad': unidad,
        if (fechaCaducidad != null) 'fechaCaducidad': fechaCaducidad,
      }),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al agregar el producto');
    }
  }

  Future<Map<String, dynamic>> actualizarProducto(
    int id,
    Map<String, dynamic> datos,
  ) async {
    final respuesta = await http.put(
      Uri.parse('$baseUrl/despensa/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datos),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al actualizar el producto');
    }
  }

  Future<void> eliminarProducto(int id) async {
    final respuesta = await http.delete(
      Uri.parse('$baseUrl/despensa/$id'),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar el producto');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerAversiones(int usuarioId) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/intolerancias/$usuarioId'),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar las aversiones');
    }
  }

  Future<void> crearAversion({
    required int usuarioId,
    required int alimentoId,
    required int nivelRechazo,
    required List<Map<String, dynamic>> motivos,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/intolerancias'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuarioId': usuarioId,
        'alimentoId': alimentoId,
        'nivelRechazo': nivelRechazo,
        'motivos': motivos,
      }),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode != 200) {
      try {
        final cuerpo = json.decode(respuesta.body) as Map<String, dynamic>;
        final mensaje = cuerpo['error'] as String?;
        throw Exception(
          mensaje ?? 'Error al registrar la aversion (${respuesta.statusCode})',
        );
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(
          'Error al registrar la aversion (${respuesta.statusCode})',
        );
      }
    }
  }

  Future<void> eliminarAversion(int id) async {
    final respuesta = await http.delete(
      Uri.parse('$baseUrl/intolerancias/$id'),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar la aversion');
    }
  }

  Future<void> actualizarAversion({
    required int id,
    required int nivelRechazo,
    required List<Map<String, dynamic>> motivos,
  }) async {
    final respuesta = await http.put(
      Uri.parse('$baseUrl/intolerancias/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nivelRechazo': nivelRechazo,
        'motivos': motivos,
      }),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode != 200) {
      try {
        final cuerpo = json.decode(respuesta.body) as Map<String, dynamic>;
        final mensaje = cuerpo['error'] as String?;
        throw Exception(
          mensaje ?? 'Error al actualizar la aversion (${respuesta.statusCode})',
        );
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Error al actualizar la aversion (${respuesta.statusCode})');
      }
    }
  }

  Future<Map<String, dynamic>> registrarFeedback({
    required int intoleranciaId,
    required bool tolerado,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/intolerancias/$intoleranciaId/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'intoleranciaId': intoleranciaId,
        'tolerado': tolerado,
      }),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al registrar el feedback');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerCatalogoAlimentos(
    int usuarioId,
  ) async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/alimentos'))
        .timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      final ordenada = lista.cast<Map<String, dynamic>>().toList();
      ordenada.sort((a, b) =>
          ((a['nombre'] as String?) ?? '')
              .toLowerCase()
              .compareTo(((b['nombre'] as String?) ?? '').toLowerCase()));
      return ordenada;
    } else {
      throw Exception('Error al cargar el catalogo de alimentos');
    }
  }

  Future<Map<String, dynamic>> crearAlimento({
    required String nombre,
    String categoria = 'Otros',
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/alimentos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nombre': nombre, 'categoria': categoria}),
    ).timeout(const Duration(seconds: 30));

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body) as Map<String, dynamic>;
    } else {
      try {
        final cuerpo = json.decode(respuesta.body) as Map<String, dynamic>;
        throw Exception(cuerpo['error'] ?? 'Error al crear el alimento');
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Error al crear el alimento (${respuesta.statusCode})');
      }
    }
  }
}
