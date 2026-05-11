class Usuario {
  final int id;
  final String email;
  final String nombre;
  final String? avatarUrl;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.avatarUrl,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}
