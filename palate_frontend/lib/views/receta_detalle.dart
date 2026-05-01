import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

/// Pantalla de detalle de una receta.
/// Muestra la imagen, información general, lista de ingredientes con
/// codificación visual por rol, e instrucciones paso a paso.
class RecetaDetalleView extends StatefulWidget {
  /// Identificador de la receta a mostrar
  final int recetaId;

  /// Título de la receta, mostrado mientras carga el detalle completo
  final String titulo;

  /// URL de la imagen representativa de la receta
  final String imagenUrl;

  const RecetaDetalleView({
    super.key,
    required this.recetaId,
    required this.titulo,
    required this.imagenUrl,
  });

  @override
  State<RecetaDetalleView> createState() => _RecetaDetalleViewState();
}

class _RecetaDetalleViewState extends State<RecetaDetalleView> {
  final ApiService _apiService = ApiService();

  /// Datos completos de la receta devueltos por el servidor
  Map<String, dynamic>? receta;

  /// Indica si se está cargando la información
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarReceta();
  }

  /// Solicita al servidor el detalle completo de la receta,
  /// incluyendo los ingredientes con sus roles y métodos de preparación.
  Future<void> _cargarReceta() async {
    try {
      final datos = await _apiService.obtenerRecetaPorId(widget.recetaId);
      setState(() {
        receta = datos;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  /// Traduce el código de dificultad a texto en español
  String _textoDificultad(String dificultad) {
    switch (dificultad) {
      case 'FACIL': return 'Fácil';
      case 'MEDIA': return 'Intermedio';
      case 'DIFICIL': return 'Difícil';
      default: return dificultad;
    }
  }

  /// Determina el color del borde izquierdo del ingrediente según su rol.
  /// - PROTAGONISTA: terracota (color primario)
  /// - SECUNDARIO: ámbar (color secundario)
  /// - COMPLEMENTO: gris (color de contorno)
  Color _colorPorRol(String? rol) {
    switch (rol) {
      case 'PROTAGONISTA': return const Color(0xFF732b16);
      case 'SECUNDARIO': return const Color(0xFF7f5700);
      default: return const Color(0xFF88726d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF732b16)),
            )
          : receta == null
              ? Center(
                  child: Text(
                    'Error al cargar la receta',
                    style: GoogleFonts.inter(color: const Color(0xFF55433e)),
                  ),
                )
              : _ContenidoDetalle(
                  receta: receta!,
                  imagenUrl: widget.imagenUrl,
                  onColorPorRol: _colorPorRol,
                  onTextoDificultad: _textoDificultad,
                ),
    );
  }
}

/// Widget que contiene todo el contenido visual del detalle de la receta.
class _ContenidoDetalle extends StatelessWidget {
  final Map<String, dynamic> receta;
  final String imagenUrl;
  final Color Function(String?) onColorPorRol;
  final String Function(String) onTextoDificultad;

  const _ContenidoDetalle({
    required this.receta,
    required this.imagenUrl,
    required this.onColorPorRol,
    required this.onTextoDificultad,
  });

  @override
  Widget build(BuildContext context) {
    final esIA = receta['generadaPorIa'] == true;

    return Stack(
      children: [
        // ── Contenido principal con scroll ──
        CustomScrollView(
          slivers: [
            // ── Barra de navegación superior (fija) ──
            SliverToBoxAdapter(
              child: _BarraSuperior(),
            ),

            // ── Imagen hero con esquinas inferiores redondeadas ──
            SliverToBoxAdapter(
              child: _ImagenHero(
                imagenUrl: imagenUrl,
                esGeneradaPorIA: esIA,
              ),
            ),

            // ── Sección de información general ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la receta
                    Text(
                      (receta['titulo'] as String?) ?? '',
                      style: GoogleFonts.newsreader(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF211a18),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Descripción breve
                    Text(
                      (receta['descripcion'] as String?) ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF55433e),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Chips de información: preparación, cocción, dificultad
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ChipInfo(
                          icono: Icons.access_time,
                          valor: '${receta['tiempoPreparacion'] ?? 0} min',
                          etiqueta: 'Preparación',
                        ),
                        _ChipInfo(
                          icono: Icons.local_fire_department,
                          valor: '${receta['tiempoCoccion'] ?? 0} min',
                          etiqueta: 'Cocción',
                          colorIcono: const Color(0xFF7f5700),
                        ),
                        _ChipInfo(
                          icono: Icons.signal_cellular_alt,
                          valor: onTextoDificultad(
                            (receta['dificultad'] as String?) ?? '',
                          ),
                          etiqueta: 'Dificultad',
                          colorIcono: const Color(0xFF7f5700),
                          colorTexto: const Color(0xFF7f5700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Sección de ingredientes ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SeccionIngredientes(
                  ingredientes: (receta['ingredientes'] as List<dynamic>?) ?? [],
                  onColorPorRol: onColorPorRol,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Sección de instrucciones paso a paso ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SeccionInstrucciones(
                  instrucciones:
                      (receta['instrucciones'] as String?) ?? '',
                ),
              ),
            ),

            // Espacio para que el contenido no quede tapado por la barra inferior
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // ── Barra inferior fija con acciones principales ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: const _BarraAcciones(),
        ),
      ],
    );
  }
}

/// Barra de navegación superior con botones de volver y compartir.
class _BarraSuperior extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón volver
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFfff0ed),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF732b16),
                size: 20,
              ),
            ),
          ),

          // Logotipo centrado
          Text(
            'Palate',
            style: GoogleFonts.newsreader(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF732b16),
            ),
          ),

          // Botón compartir
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFfff0ed),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.share_outlined,
              color: Color(0xFF732b16),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Imagen de cabecera con esquinas inferiores redondeadas.
/// Muestra el badge "Generada por IA" si corresponde.
class _ImagenHero extends StatelessWidget {
  final String imagenUrl;
  final bool esGeneradaPorIA;

  const _ImagenHero({
    required this.imagenUrl,
    required this.esGeneradaPorIA,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(48),
        bottomRight: Radius.circular(48),
      ),
      child: SizedBox(
        height: 340,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imagenUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFf4e5e2),
                child: const Center(
                  child: Icon(Icons.restaurant, size: 80, color: Color(0xFF732b16)),
                ),
              ),
            ),
            // Badge de receta generada por IA
            if (esGeneradaPorIA)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFdbc1ba).withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    'Generada por IA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: const Color(0xFF732b16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Chip de información con icono, valor principal y etiqueta secundaria.
class _ChipInfo extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color colorIcono;
  final Color colorTexto;

  const _ChipInfo({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    this.colorIcono = const Color(0xFF732b16),
    this.colorTexto = const Color(0xFF211a18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFf4e5e2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: colorIcono),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorTexto,
                ),
              ),
              Text(
                etiqueta,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF88726d),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sección de ingredientes con grid y codificación de color por rol.
class _SeccionIngredientes extends StatelessWidget {
  final List<dynamic> ingredientes;
  final Color Function(String?) onColorPorRol;

  const _SeccionIngredientes({
    required this.ingredientes,
    required this.onColorPorRol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Row(
          children: [
            const Icon(Icons.shopping_basket,
                color: Color(0xFF732b16), size: 20),
            const SizedBox(width: 8),
            Text(
              'Ingredientes',
              style: GoogleFonts.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF211a18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (ingredientes.isEmpty)
          Text(
            'No hay ingredientes disponibles',
            style: GoogleFonts.inter(color: const Color(0xFF88726d)),
          )
        else
          // Grid de dos columnas para los ingredientes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.0,
            ),
            itemCount: ingredientes.length,
            itemBuilder: (context, index) {
              final ing = ingredientes[index] as Map<String, dynamic>;
              final alimento = ing['alimento'] as Map<String, dynamic>?;
              final nombre = alimento?['nombre'] as String? ?? 'Desconocido';
              final cantidad = ing['cantidad']?.toString() ?? '';
              final unidad = (ing['unidadMedida'] as String?) ?? '';
              final rol = ing['rol'] as String?;
              final oculto = ing['oculto'] == true;

              return _TarjetaIngrediente(
                nombre: nombre,
                cantidad: '$cantidad $unidad'.trim(),
                colorBorde: onColorPorRol(rol),
                oculto: oculto,
              );
            },
          ),
      ],
    );
  }
}

/// Tarjeta individual de ingrediente con borde izquierdo de color según rol.
class _TarjetaIngrediente extends StatelessWidget {
  final String nombre;
  final String cantidad;
  final Color colorBorde;
  final bool oculto;

  const _TarjetaIngrediente({
    required this.nombre,
    required this.cantidad,
    required this.colorBorde,
    required this.oculto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFfff0ed),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: colorBorde, width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cantidad,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorBorde,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nombre,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF211a18),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Icono indicador de ingrediente oculto
                    if (oculto)
                      const Icon(
                        Icons.visibility_off_outlined,
                        size: 12,
                        color: Color(0xFF88726d),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección de instrucciones con pasos numerados y línea conectora visual.
class _SeccionInstrucciones extends StatelessWidget {
  final String instrucciones;

  const _SeccionInstrucciones({required this.instrucciones});

  /// Divide el texto de instrucciones en pasos individuales.
  /// El servidor devuelve los pasos numerados como "1. Paso uno 2. Paso dos..."
  List<String> _parsearPasos(String texto) {
    final pasos = texto.split(RegExp(r'\d+\.\s*'));
    return pasos.where((p) => p.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pasos = _parsearPasos(instrucciones);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Row(
          children: [
            const Icon(Icons.restaurant,
                color: Color(0xFF732b16), size: 20),
            const SizedBox(width: 8),
            Text(
              'Instrucciones',
              style: GoogleFonts.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF211a18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Si no se pueden parsear los pasos, muestra el texto completo
        if (pasos.isEmpty)
          Text(
            instrucciones,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF55433e),
              height: 1.6,
            ),
          )
        else
          Column(
            children: pasos.asMap().entries.map((entry) {
              final index = entry.key;
              final paso = entry.value.trim();
              final esUltimo = index == pasos.length - 1;

              return _TarjetaPaso(
                numero: index + 1,
                texto: paso,
                esUltimo: esUltimo,
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Tarjeta de un paso de las instrucciones con número y línea conectora.
class _TarjetaPaso extends StatelessWidget {
  final int numero;
  final String texto;
  final bool esUltimo;

  const _TarjetaPaso({
    required this.numero,
    required this.texto,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: número del paso y línea conectora
          Column(
            children: [
              // Círculo numerado
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF732b16),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$numero',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Línea vertical conectora (excepto en el último paso)
              if (!esUltimo)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.only(top: 4),
                  color: const Color(0xFFdbc1ba).withOpacity(0.5),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Tarjeta con el texto del paso
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFfaebe7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                texto,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF55433e),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de acciones fija en la parte inferior de la pantalla.
/// Contiene el botón de guardar y el botón principal de cocinar.
class _BarraAcciones extends StatelessWidget {
  const _BarraAcciones();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFfff8f6).withOpacity(0.97),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFdbc1ba).withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón guardar / marcar como favorita
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: const Color(0xFFdbc1ba)),
            ),
            child: const Icon(
              Icons.bookmark_border,
              color: Color(0xFF732b16),
            ),
          ),
          const SizedBox(width: 12),

          // Botón principal: "¡Voy a cocinarlo!"
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Buen provecho! 🍽️'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF732b16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  '¡Voy a cocinarlo!',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
