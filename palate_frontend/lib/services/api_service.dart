import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/receta.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // ==================== AUTH ====================

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

  Future<List<Receta>> obtenerRecetas() async {
    final respuesta = await http.get(Uri.parse('$baseUrl/recetas'));

    if (respuesta.statusCode == 200) {
      final List<dynamic> lista = json.decode(respuesta.body);
      return lista.map((json) => Receta.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar recetas');
    }
  }
}
