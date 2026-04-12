class Usuario {
  final String email;
  final String nombre;

  Usuario({required this.email, required this.nombre});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
    );
  }
}
