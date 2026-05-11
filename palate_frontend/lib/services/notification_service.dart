import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

///
class NotificationService {
  static final NotificationService instancia = NotificationService._interno();

  NotificationService._interno();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  static const String _canalTemporizadorId = 'palate_temporizador';

  ///
  Future<void> init() async {
    if (_inicializado) return;

    // Inicializa la base de datos de zonas horarias para que la programacion
    // de notificaciones use la hora local del dispositivo correctamente.
    tz_data.initializeTimeZones();

    // Configuracion especifica para Android: usa el icono por defecto del launcher
    const ajustesAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuracion para iOS: el plugin gestiona los permisos automaticamente
    // si el usuario los ha aceptado previamente.
    const ajustesIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const ajustes = InitializationSettings(
      android: ajustesAndroid,
      iOS: ajustesIOS,
    );

    await _plugin.initialize(ajustes);
    _inicializado = true;
  }

  ///
  Future<bool> solicitarPermisos() async {
    try {
      // Permiso de notificaciones en Android 13+ y otras restricciones
      final implAndroid = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (implAndroid != null) {
        final concedido = await implAndroid.requestNotificationsPermission();
        return concedido ?? true;
      }

      // En iOS se pide permiso explicito de alerta y sonido
      final implIOS = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (implIOS != null) {
        final concedido = await implIOS.requestPermissions(
          alert: true,
          sound: true,
        );
        return concedido ?? false;
      }

      return true;
    } catch (e) {
      // Si la solicitud falla por configuracion del sistema, se permite
      // continuar sin notificacion: el usuario seguira viendo el countdown
      // mientras la app este abierta.
      debugPrint('Error solicitando permisos de notificacion: $e');
      return false;
    }
  }

  Future<void> programarNotificacion({
    required int id,
    required DateTime cuando,
    required String titulo,
    required String cuerpo,
  }) async {
    // Detalles de la notificacion para Android: canal, prioridad y categoria
    // marcan a la notificacion como un aviso de alarma temporal.
    const detallesAndroid = AndroidNotificationDetails(
      _canalTemporizadorId,
      'Temporizadores de cocina',
      channelDescription: 'Avisos cuando termina un temporizador de receta.',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    );

    const detallesIOS = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const detalles = NotificationDetails(
      android: detallesAndroid,
      iOS: detallesIOS,
    );

    // Conversion de DateTime a TZDateTime usando la zona horaria local
    final tzCuando = tz.TZDateTime.from(cuando, tz.local);

    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tzCuando,
      detalles,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelar(int id) async {
    await _plugin.cancel(id);
  }
}
