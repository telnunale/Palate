import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String email = '';
  String password = '';
  String? error;
  bool cargando = false;

  Future<Usuario?> login() async {
    error = null;
    cargando = true;
    notifyListeners();

    try {
      final usuario = await _apiService.login(email, password);
      cargando = false;
      notifyListeners();
      return usuario;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      cargando = false;
      notifyListeners();
      return null;
    }
  }
}
