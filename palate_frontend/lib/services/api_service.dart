import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/receta.dart';

/// Servicio centralizado para la comunicación con el servidor backend.
/// Gestiona todas las peticiones HTTP a la API REST de Palate.
/// La URL base apunta al servidor Spring Boot ejecutándose localmente.
class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // ==================== AUTENTICACIÓN ====================

  /// Autentica al usuario con email y contraseña.
  /// Lanza una [Exception] si las credenciales son incorrectas.
  Future<Usuario> login(String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (respuesta.statusCode == 200) {
      return Usuario.fromJson(json.decode(respuesta.body));
    } else {
      final error = json.decode(respuesta.body);
      throw Exception(error['error'] ?? 'Error al iniciar sesión');
    }
  }

  /// Registra un nuevo usuario en el sistema.
  /// Devuelve el mensaje de confirmación del servidor.
  Future<String> registro(String nombre, String email, String password) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/auth/registro'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'email': email,
        'password': password,
      }),
    );

    if (respuesta.statusCode == 200) {
      final datos = json.decode(respuesta.body);
      return datos['mensaje'] ?? 'Registro correcto';
    } else {
      final error = json.decode(respuesta.body);
      throw Exception(error['error'] ?? 'Error al registrarse');
    }
  }

  // ==================== RECETAS ====================

  /// Obtiene el listado completo de recetas disponibles.
  Future<List<Receta>> obtenerRecetas() async {
    final respuesta = await http.get(Uri.parse('$baseUrl/recetas'));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.map((json) => Receta.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar recetas');
    }
  }

  /// Obtiene el detalle completo de una receta, incluyendo sus ingredientes.
  /// Devuelve el mapa JSON sin parsear para acceder a todos los campos del DTO.
  Future<Map<String, dynamic>> obtenerRecetaPorId(int id) async {
    final respuesta = await http.get(Uri.parse('$baseUrl/recetas/$id'));

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al cargar la receta');
    }
  }

  /// Genera una nueva receta usando inteligencia artificial a partir
  /// de una descripción libre del usuario.
  Future<Receta> generarReceta(String descripcion) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/recetas/generar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'descripcion': descripcion}),
    );

    if (respuesta.statusCode == 200) {
      return Receta.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al generar la receta');
    }
  }

  /// Genera una receta adaptada para superar una aversión alimentaria concreta.
  /// El parámetro [intoleranciaId] identifica el alimento rechazado y sus motivos,
  /// que la IA usa para decidir cómo incorporarlo de forma progresiva.
  Future<Receta> generarRecetaConAversion(
    String descripcion,
    int intoleranciaId,
  ) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/recetas/generar-con-aversion'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'descripcion': descripcion,
        'intoleranciaId': intoleranciaId,
      }),
    );

    if (respuesta.statusCode == 200) {
      return Receta.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al generar la receta con aversión');
    }
  }

  /// Genera una receta priorizando los ingredientes disponibles en la despensa.
  /// Opcionalmente acepta una aversión para aplicar ambas restricciones a la vez.
  Future<Receta> generarRecetaConDespensa({
    required int usuarioId,
    String? descripcion,
    int? intoleranciaId,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/recetas/generar-con-despensa'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuarioId': usuarioId,
        if (descripcion != null) 'descripcion': descripcion,
        if (intoleranciaId != null) 'intoleranciaId': intoleranciaId,
      }),
    );

    if (respuesta.statusCode == 200) {
      return Receta.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al generar la receta con despensa');
    }
  }

  // ==================== DESPENSA ====================

  /// Obtiene los productos activos (no consumidos) de la despensa del usuario.
  Future<List<Map<String, dynamic>>> obtenerDespensa(int usuarioId) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/despensa/$usuarioId'),
    );

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar la despensa');
    }
  }

  /// Obtiene los productos que caducan en los próximos [dias] días.
  Future<List<Map<String, dynamic>>> obtenerProximosACaducar(
    int usuarioId,
    int dias,
  ) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/despensa/$usuarioId/proximos/$dias'),
    );

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener productos próximos a caducar');
    }
  }

  /// Añade un nuevo producto a la despensa del usuario.
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
    );

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al añadir el producto');
    }
  }

  /// Actualiza los datos de un producto de la despensa.
  /// [datos] puede contener cualquier combinación de campos a modificar.
  Future<Map<String, dynamic>> actualizarProducto(
    int id,
    Map<String, dynamic> datos,
  ) async {
    final respuesta = await http.put(
      Uri.parse('$baseUrl/despensa/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(datos),
    );

    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al actualizar el producto');
    }
  }

  /// Elimina un producto de la despensa de forma permanente.
  Future<void> eliminarProducto(int id) async {
    final respuesta = await http.delete(
      Uri.parse('$baseUrl/despensa/$id'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar el producto');
    }
  }

  // ==================== AVERSIONES ====================

  /// Obtiene la lista de aversiones alimentarias registradas por el usuario.
  Future<List<Map<String, dynamic>>> obtenerAversiones(int usuarioId) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/intolerancias/$usuarioId'),
    );

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar las aversiones');
    }
  }

  /// Registra una nueva aversión alimentaria para el usuario.
  /// [motivos] es una lista de mapas con 'tipo' e 'intensidad' de cada rechazo sensorial.
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
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al registrar la aversión');
    }
  }

  /// Elimina una aversión alimentaria del perfil del usuario.
  Future<void> eliminarAversion(int id) async {
    final respuesta = await http.delete(
      Uri.parse('$baseUrl/intolerancias/$id'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar la aversión');
    }
  }
}
