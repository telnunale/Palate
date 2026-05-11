class ProductoDespensa {
  final int id;
  final int alimentoId;
  final String nombreAlimento;
  final String? categoriaAlimento;
  final String? imagenAlimento;
  final String? fechaCaducidad;
  final double cantidad;
  final String unidad;
  final bool consumido;

  const ProductoDespensa({
    required this.id,
    required this.alimentoId,
    required this.nombreAlimento,
    this.categoriaAlimento,
    this.imagenAlimento,
    this.fechaCaducidad,
    required this.cantidad,
    required this.unidad,
    required this.consumido,
  });

  int? get diasHastaCaducidad {
    if (fechaCaducidad == null) return null;
    final fecha = DateTime.tryParse(fechaCaducidad!);
    if (fecha == null) return null;
    final hoy = DateTime.now();
    final diferencia = DateTime(fecha.year, fecha.month, fecha.day)
        .difference(DateTime(hoy.year, hoy.month, hoy.day));
    return diferencia.inDays;
  }

  factory ProductoDespensa.fromJson(Map<String, dynamic> json) {
    final alimento = json['alimento'] as Map<String, dynamic>?;
    return ProductoDespensa(
      id: json['id'] ?? 0,
      alimentoId: alimento?['id'] as int? ?? 0,
      nombreAlimento: alimento?['nombre'] as String? ?? '',
      categoriaAlimento: alimento?['categoria'] as String?,
      imagenAlimento: alimento?['imagenUrl'] as String?,
      fechaCaducidad: json['fechaCaducidad'] as String?,
      cantidad: (json['cantidad'] as num?)?.toDouble() ?? 0,
      unidad: json['unidad'] as String? ?? '',
      consumido: json['consumido'] as bool? ?? false,
    );
  }
}
