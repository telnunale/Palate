import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistroViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String nombre = '';
  String email = '';
  String password = '';
  String? error;
  String? exito;
  bool cargando = false;

  Future<bool> registro() async {
    error = null;
    exito = null;
    cargando = true;
    notifyListeners();

    try {
      final mensaje = await _apiService.registro(nombre, email, password);
      exito = mensaje;
      cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      cargando = false;
      notifyListeners();
      return false;
    }
  }
}
