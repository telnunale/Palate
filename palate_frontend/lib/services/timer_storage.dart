import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimerActivo {
  final int id;

  final DateTime fin;

  final String descripcion;

  const TimerActivo({
    required this.id,
    required this.fin,
    required this.descripcion,
  });

  Duration get restante => fin.difference(DateTime.now());

  bool get terminado => DateTime.now().isAfter(fin);

  Map<String, dynamic> toJson() => {
        'id': id,
        'fin': fin.toIso8601String(),
        'descripcion': descripcion,
      };

  factory TimerActivo.fromJson(Map<String, dynamic> json) {
    return TimerActivo(
      id: json['id'] as int,
      fin: DateTime.parse(json['fin'] as String),
      descripcion: json['descripcion'] as String,
    );
  }
}

///
class TimerStorage {
  static const String _clave = 'palate_timers_activos';

  static Future<List<TimerActivo>> obtenerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_clave);
    if (json == null || json.isEmpty) return [];

    try {
      final lista = jsonDecode(json) as List<dynamic>;
      final timers = lista
          .map((e) => TimerActivo.fromJson(e as Map<String, dynamic>))
          .toList();

      // Limpieza perezosa: descarta los terminados
      return timers.where((t) => !t.terminado).toList();
    } catch (_) {
      // Si el JSON esta corrupto, se limpia para evitar errores recurrentes
      await prefs.remove(_clave);
      return [];
    }
  }

  static Future<void> guardar(TimerActivo timer) async {
    final actuales = await obtenerTodos();
    actuales.removeWhere((t) => t.id == timer.id);
    actuales.add(timer);
    await _persistir(actuales);
  }

  static Future<TimerActivo?> obtener(int id) async {
    final todos = await obtenerTodos();
    for (final t in todos) {
      if (t.id == id) return t;
    }
    return null;
  }

  static Future<void> eliminar(int id) async {
    final actuales = await obtenerTodos();
    actuales.removeWhere((t) => t.id == id);
    await _persistir(actuales);
  }

  static Future<void> _persistir(List<TimerActivo> timers) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(timers.map((t) => t.toJson()).toList());
    await prefs.setString(_clave, json);
  }
}
