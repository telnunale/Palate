import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/intolerancia.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../utils/formato_cantidad.dart';
import '../utils/imagen_optim.dart';
import '../utils/parser_tiempos.dart';
import 'feedback_dialog.dart';
import 'modo_cocina_view.dart';
import 'temporizador_dialog.dart';

///
class RecetaDetalleView extends StatefulWidget {
  final int recetaId;

  final String titulo;

  final String imagenUrl;

  final Usuario? usuario;

  const RecetaDetalleView({
    super.key,
    required this.recetaId,
    required this.titulo,
    required this.imagenUrl,
    this.usuario,
  });

  @override
  State<RecetaDetalleView> createState() => _RecetaDetalleViewState();
}

class _RecetaDetalleViewState extends State<RecetaDetalleView> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? receta;

  List<Intolerancia> _aversionesAfectadas = const [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final datos = await _apiService.obtenerRecetaPorId(widget.recetaId);

      List<Intolerancia> afectadas = const [];
      if (widget.usuario != null) {
        afectadas = await _detectarAversionesAfectadas(datos);
      }

      if (!mounted) return;
      setState(() {
        receta = datos;
        _aversionesAfectadas = afectadas;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargando = false;
      });
    }
  }

  Future<List<Intolerancia>> _detectarAversionesAfectadas(
    Map<String, dynamic> recetaJson,
  ) async {
    try {
      final aversionesJson =
          await _apiService.obtenerAversiones(widget.usuario!.id);
      final aversiones = aversionesJson
          .map((json) => Intolerancia.fromJson(json))
          .where((a) => !a.superada)
          .toList();

      final ingredientes =
          (recetaJson['ingredientes'] as List<dynamic>?) ?? const [];
      final idsIngredientes = ingredientes
          .map((ing) => (ing['alimento'] as Map<String, dynamic>?)?['id'])
          .whereType<int>()
          .toSet();

      return aversiones
          .where((a) => idsIngredientes.contains(a.alimentoId))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _onCocinar() async {
    if (receta == null) return;

    // Reutiliza el mismo parser que la seccion de instrucciones de la
    // pantalla de detalle para mantener una sola fuente de verdad sobre
    // como dividir el texto en pasos individuales.
    final pasos = _parsearPasos((receta!['instrucciones'] as String?) ?? '');
    if (pasos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta receta no tiene pasos detallados.')),
      );
      return;
    }

    final resultado = await Navigator.push<ResultadoFeedback>(
      context,
      MaterialPageRoute(
        builder: (_) => ModoCocinaView(
          tituloReceta: (receta!['titulo'] as String?) ?? '',
          imagenUrl: widget.imagenUrl,
          pasos: pasos,
          recetaId: (receta!['id'] as int?) ?? 0,
          aversionesAfectadas: _aversionesAfectadas,
        ),
      ),
    );

    if (!mounted) return;

    // Si el usuario abandono el modo cocina antes de terminar (back
    // button + confirmacion), no se muestra ningun mensaje para no
    // contradecir su decision de no completar la receta.
    if (resultado == null) return;

    String mensaje;
    switch (resultado) {
      case ResultadoFeedback.tolerado:
        mensaje = '¡Buen trabajo! Tu progreso ha avanzado.';
        break;
      case ResultadoFeedback.dificultad:
        mensaje = 'Gracias por la sinceridad. Lo intentaremos con menos intensidad.';
        break;
      case ResultadoFeedback.saltado:
        mensaje = '¡Buen provecho! 🍽️';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  List<String> _parsearPasos(String texto) {
    final pasos = texto.split(RegExp(r'\d+\.\s*'));
    return pasos.where((p) => p.trim().isNotEmpty).toList();
  }

  String _textoDificultad(String dificultad) {
    switch (dificultad) {
      case 'FACIL': return 'Fácil';
      case 'MEDIA': return 'Intermedio';
      case 'DIFICIL': return 'Difícil';
      default: return dificultad;
    }
  }

  Color _colorPorRol(String? rol) {
    switch (rol) {
      case 'PROTAGONISTA': return const Color(0xFF732b16);
      case 'SECUNDARIO': return const Color(0xFF7f5700);
      default: return const Color(0xFF88726d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tieneReceta = !cargando && receta != null;
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
                  aversionesAfectadas: _aversionesAfectadas,
                ),
      // La barra de acciones se monta como bottomNavigationBar para que
      // Scaffold reserve automaticamente el espacio inferior y el ultimo
      // paso de las instrucciones nunca quede tapado por la barra fija
      // ni por los gestos del sistema (home indicator iOS, gesture bar
      // Android). Reemplaza el patron previo Stack + Positioned que
      // requeria un SizedBox manual cuyo alto era frecuentemente
      // insuficiente cuando aparecia el aviso de aversiones.
      bottomNavigationBar: tieneReceta
          ? _BarraAcciones(
              aversionesAfectadas: _aversionesAfectadas,
              onCocinar: _onCocinar,
            )
          : null,
    );
  }
}

class _ContenidoDetalle extends StatelessWidget {
  final Map<String, dynamic> receta;
  final String imagenUrl;
  final Color Function(String?) onColorPorRol;
  final String Function(String) onTextoDificultad;

  final List<Intolerancia> aversionesAfectadas;

  const _ContenidoDetalle({
    required this.receta,
    required this.imagenUrl,
    required this.onColorPorRol,
    required this.onTextoDificultad,
    required this.aversionesAfectadas,
  });

  @override
  Widget build(BuildContext context) {
    final esIA = receta['generadaPorIa'] == true;

    return CustomScrollView(
      slivers: [
            SliverToBoxAdapter(
              child: _BarraSuperior(),
            ),

            SliverToBoxAdapter(
              child: _ImagenHero(
                imagenUrl: imagenUrl,
                esGeneradaPorIA: esIA,
              ),
            ),

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
                        if (receta['caloriasTotal'] != null)
                          _ChipInfo(
                            icono: Icons.bolt,
                            valor: '${(receta['caloriasTotal'] as num).round()} kcal',
                            etiqueta: 'Energía',
                            colorIcono: const Color(0xFF7f5700),
                          ),
                      ],
                    ),
                    if (receta['caloriasTotal'] != null) ...[
                      const SizedBox(height: 12),
                      _BloqueMacros(
                        proteinas: (receta['proteinasTotal'] as num?)?.toDouble(),
                        hidratos: (receta['hidratosTotal'] as num?)?.toDouble(),
                        grasas: (receta['grasasTotal'] as num?)?.toDouble(),
                      ),
                    ],
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SeccionInstrucciones(
                  instrucciones:
                      (receta['instrucciones'] as String?) ?? '',
                  // El id de la receta se utiliza para construir el id unico
                  // del temporizador de cada paso, garantizando que dos pasos
                  // de recetas distintas no compartan notificacion.
                  recetaId: (receta['id'] as int?) ?? 0,
                ),
              ),
            ),

            // Pequeno margen final para separar el ultimo paso del borde
            // inferior del contenido. Scaffold ya reserva el alto de la
            // barra de acciones, asi que aqui no hace falta compensar
            // por la barra ni por los gestos del sistema.
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
  }
}

class _BarraSuperior extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Boton volver
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
          const SizedBox(width: 12),
          Text(
            'Palate',
            style: GoogleFonts.newsreader(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF732b16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagenHero extends StatelessWidget {
  final String imagenUrl;
  final bool esGeneradaPorIA;

  const _ImagenHero({
    required this.imagenUrl,
    required this.esGeneradaPorIA,
  });

  @override
  Widget build(BuildContext context) {
    // Hero a ancho completo de pantalla. Pedimos al CDN una imagen al
    // ancho fisico exacto y dejamos que Flutter la decodifique al mismo
    // tamano para no malgastar memoria con bitmaps sobredimensionados.
    final anchoLogico = MediaQuery.of(context).size.width;
    final urlOptimizada = ImagenOptim.paraAncho(context, imagenUrl, anchoLogico);
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
              urlOptimizada,
              fit: BoxFit.cover,
              cacheWidth: ImagenOptim.anchoFisico(context, anchoLogico),
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
              final cantidadNum = (ing['cantidad'] as num?)?.toDouble() ?? 0;
              final unidad = (ing['unidadMedida'] as String?) ?? '';
              final rol = ing['rol'] as String?;
              final oculto = ing['oculto'] == true;

              return _TarjetaIngrediente(
                nombre: nombre,
                cantidad: FormatoCantidad.legible(cantidadNum, unidad),
                colorBorde: onColorPorRol(rol),
                oculto: oculto,
              );
            },
          ),
      ],
    );
  }
}

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

class _SeccionInstrucciones extends StatelessWidget {
  final String instrucciones;

  final int recetaId;

  const _SeccionInstrucciones({
    required this.instrucciones,
    required this.recetaId,
  });

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
                // Id unico por temporizador: combina receta y paso para que
                // varias recetas abiertas a la vez no se machaquen entre si.
                idTimer: recetaId * 100 + (index + 1),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _TarjetaPaso extends StatelessWidget {
  final int numero;
  final String texto;
  final bool esUltimo;

  final int idTimer;

  const _TarjetaPaso({
    required this.numero,
    required this.texto,
    required this.esUltimo,
    required this.idTimer,
  });

  @override
  Widget build(BuildContext context) {
    // Deteccion automatica de tiempos en el texto del paso.
    // Si el parser no encuentra ninguna expresion temporal, [minutosDetectados]
    // sera null y el boton de temporizador no se renderizara.
    final minutosDetectados = ParserTiempos.extraerMinutos(texto);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: numero del paso y linea conectora
          Column(
            children: [
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

          // Tarjeta con el texto del paso y boton temporizador opcional
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFfaebe7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texto,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF55433e),
                      height: 1.5,
                    ),
                  ),

                  // Boton de temporizador: solo aparece si el parser ha
                  // detectado una expresion temporal en el texto del paso.
                  if (minutosDetectados != null) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        TemporizadorDialog.mostrar(
                          context,
                          idTimer: idTimer,
                          minutosSugeridos: minutosDetectados,
                          descripcionPaso: 'Paso $numero: ${_resumirPaso(texto)}',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF732b16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Temporizador ${ParserTiempos.formatearDuracion(minutosDetectados)}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resumirPaso(String texto) {
    final limpio = texto.trim();
    if (limpio.length <= 60) return limpio;
    return '${limpio.substring(0, 57)}...';
  }
}

class _BarraAcciones extends StatelessWidget {
  final List<Intolerancia> aversionesAfectadas;

  final VoidCallback onCocinar;

  const _BarraAcciones({
    required this.aversionesAfectadas,
    required this.onCocinar,
  });

  @override
  Widget build(BuildContext context) {
    final muestraAviso = aversionesAfectadas.isNotEmpty;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Aviso de aversiones detectadas: solo se muestra cuando la
          // receta contiene algun ingrediente con aversion registrada.
          if (muestraAviso) ...[
            _AvisoAversiones(aversiones: aversionesAfectadas),
            const SizedBox(height: 10),
          ],
          // Boton principal: "¡Voy a cocinarlo!"
          // Ocupa todo el ancho disponible al ser la unica accion principal
          // de la pantalla de detalle de la receta.
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onCocinar,
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
        ],
      ),
    );
  }
}

class _AvisoAversiones extends StatelessWidget {
  final List<Intolerancia> aversiones;

  const _AvisoAversiones({required this.aversiones});

  @override
  Widget build(BuildContext context) {
    final nombres = aversiones.map((a) => a.nombreAlimento).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFfdb733).withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7f5700).withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.psychology_alt_outlined,
            size: 18,
            color: Color(0xFF7f5700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta receta contiene: $nombres. Tras cocinar te pediremos '
              'feedback para actualizar tu progreso.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF55433e),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BloqueMacros extends StatelessWidget {
  final double? proteinas;
  final double? hidratos;
  final double? grasas;

  const _BloqueMacros({this.proteinas, this.hidratos, this.grasas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFfff0ed),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ItemMacro(etiqueta: 'Proteínas', valor: proteinas),
          _ItemMacro(etiqueta: 'Hidratos', valor: hidratos),
          _ItemMacro(etiqueta: 'Grasas', valor: grasas),
        ],
      ),
    );
  }
}

class _ItemMacro extends StatelessWidget {
  final String etiqueta;
  final double? valor;

  const _ItemMacro({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    final texto = valor != null ? '${valor!.round()} g' : '—';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          texto,
          style: GoogleFonts.newsreader(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF211a18),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF88726d),
          ),
        ),
      ],
    );
  }
}
