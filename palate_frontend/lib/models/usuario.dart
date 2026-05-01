/// Modelo que representa a un usuario autenticado en la aplicación.
/// Contiene los datos básicos devueltos por el servidor tras el login.
class Usuario {
  /// Identificador único del usuario en la base de datos
  final int id;

  /// Dirección de correo electrónico del usuario
  final String email;

  /// Nombre completo del usuario
  final String nombre;

  /// URL del avatar del usuario (puede ser nulo si no tiene foto)
  final String? avatarUrl;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.avatarUrl,
  });

  /// Crea una instancia de [Usuario] a partir de un mapa JSON.
  /// Se utiliza para deserializar la respuesta del servidor.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}
