import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/intolerancia.dart';
import '../services/api_service.dart';

class GestionarAversionView extends StatefulWidget {
  final int usuarioId;

  final Intolerancia? aversion;

  final List<Map<String, dynamic>> catalogoAlimentos;

  const GestionarAversionView({
    super.key,
    required this.usuarioId,
    required this.catalogoAlimentos,
    this.aversion,
  });

  @override
  State<GestionarAversionView> createState() => _GestionarAversionViewState();
}

class _GestionarAversionViewState extends State<GestionarAversionView> {
  final ApiService _apiService = ApiService();
  final TextEditingController _busquedaCtrl = TextEditingController();

  double _nivelRechazo = 5;

  Map<String, dynamic>? _alimentoSeleccionado;

  bool _mostrarSugerencias = false;

  final Map<String, bool> _motivosActivos = {
    'TEXTURA': false,
    'SABOR': false,
    'OLOR': false,
    'COLOR': false,
  };

  final Map<String, double> _intensidades = {
    'TEXTURA': 3,
    'SABOR': 3,
    'OLOR': 3,
    'COLOR': 3,
  };

  bool _guardando = false;

  String? _error;

  bool get _esEdicion => widget.aversion != null;

  @override
  void initState() {
    super.initState();
    // Si se esta editando, precargar los valores existentes
    if (_esEdicion) {
      _nivelRechazo = widget.aversion!.nivelRechazo.toDouble();
      _busquedaCtrl.text = widget.aversion!.nombreAlimento;
      // Precargar los motivos sensoriales existentes para no perderlos al editar
      for (final motivo in widget.aversion!.motivos) {
        final tipo = motivo['tipo'] as String?;
        final intensidad = (motivo['intensidad'] as num?)?.toDouble() ?? 3.0;
        if (tipo != null && _motivosActivos.containsKey(tipo)) {
          _motivosActivos[tipo] = true;
          _intensidades[tipo] = intensidad;
        }
      }
    }
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _sugerenciasFiltradas {
    final texto = _busquedaCtrl.text.toLowerCase();
    if (texto.isEmpty) return widget.catalogoAlimentos.take(5).toList();
    return widget.catalogoAlimentos
        .where((a) =>
            (a['nombre'] as String?)?.toLowerCase().contains(texto) ?? false)
        .take(6)
        .toList();
  }

  List<Map<String, dynamic>> get _motivosParaEnviar {
    return _motivosActivos.entries
        .where((e) => e.value)
        .map((e) => {
              'tipo': e.key,
              'intensidad': _intensidades[e.key]!.round(),
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: Column(
          children: [
            _CabeceraFormulario(
              titulo: _esEdicion ? 'Editar Aversión' : 'Añadir Aversión',
              onVolver: () => Navigator.pop(context),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _esEdicion
                          ? 'Ajusta el nivel de rechazo y\nlos motivos sensoriales.'
                          : '¿Qué alimento quieres añadir?',
                      style: GoogleFonts.newsreader(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF732b16),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registra los detalles del alimento que te genera rechazo '
                      'para que la IA pueda adaptar las recetas.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF55433e),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!_esEdicion) ...[
                      _EtiquetaSeccion(texto: 'NOMBRE DEL ALIMENTO'),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          TextField(
                            controller: _busquedaCtrl,
                            onChanged: (_) {
                              setState(() {
                                _mostrarSugerencias = true;
                                _alimentoSeleccionado = null;
                              });
                            },
                            onTap: () {
                              setState(() => _mostrarSugerencias = true);
                            },
                            style: GoogleFonts.inter(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Ej: Cilantro, Champiñones...',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFFdbc1ba),
                              ),
                              suffixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF88726d),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFfff0ed),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Lista de sugerencias de alimentos
                      if (_mostrarSugerencias &&
                          _sugerenciasFiltradas.isNotEmpty &&
                          _alimentoSeleccionado == null) ...[
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFdbc1ba).withOpacity(0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF91412b).withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _sugerenciasFiltradas.map((alimento) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _alimentoSeleccionado = alimento;
                                    _busquedaCtrl.text =
                                        alimento['nombre'] as String? ?? '';
                                    _mostrarSugerencias = false;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: const Color(0xFFdbc1ba)
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.restaurant,
                                        size: 16,
                                        color: Color(0xFF88726d),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        alimento['nombre'] as String? ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF211a18),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (alimento['categoria'] != null)
                                        Text(
                                          '· ${alimento['categoria']}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: const Color(0xFF88726d),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // Indicador de alimento seleccionado
                      if (_alimentoSeleccionado != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfaebe7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Color(0xFF732b16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Seleccionado: ${_alimentoSeleccionado!['nombre']}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF732b16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),
                    ],

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfaebe7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFdbc1ba).withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _EtiquetaSeccion(texto: 'NIVEL DE RECHAZO'),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFfdb733).withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_nivelRechazo.round()}',
                                  style: GoogleFonts.newsreader(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF7f5700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _nivelRechazo,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: const Color(0xFF732b16),
                            inactiveColor: const Color(0xFFdbc1ba),
                            onChanged: (valor) {
                              setState(() => _nivelRechazo = valor);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Casi lo tolero (1)',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF88726d),
                                ),
                              ),
                              Text(
                                'Lo evito siempre (10)',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF88726d),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _EtiquetaSeccion(texto: 'RAZONES SENSORIALES'),
                    const SizedBox(height: 12),

                    // Tarjeta por cada tipo de motivo sensorial
                    ..._motivosActivos.keys.map(
                      (tipo) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TarjetaMotivoSensorial(
                          tipo: tipo,
                          activo: _motivosActivos[tipo]!,
                          intensidad: _intensidades[tipo]!,
                          onToggle: (valor) {
                            setState(() => _motivosActivos[tipo] = valor);
                          },
                          onIntensidadCambiada: (valor) {
                            setState(() => _intensidades[tipo] = valor);
                          },
                        ),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFffdad6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFba1a1a),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFFba1a1a),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF91412b),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 0,
                        ),
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                        label: Text(
                          _esEdicion
                              ? 'Actualizar aversión'
                              : 'Guardar aversión',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Future<void> _guardar() async {
    if (!_esEdicion && _alimentoSeleccionado == null) {
      setState(() => _error = 'Selecciona un alimento de la lista.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      if (_esEdicion) {
        // Edicion: actualizacion atomica via PUT
        await _apiService.actualizarAversion(
          id: widget.aversion!.id,
          nivelRechazo: _nivelRechazo.round(),
          motivos: _motivosParaEnviar,
        );
      } else {
        // Creacion: nueva aversion via POST
        await _apiService.crearAversion(
          usuarioId: widget.usuarioId,
          alimentoId: _alimentoSeleccionado!['id'] as int,
          nivelRechazo: _nivelRechazo.round(),
          motivos: _motivosParaEnviar,
        );
      }

      // Devuelve true al padre para que pueda diferenciar guardado exitoso
      // de cancelacion (back button) y mostrar el SnackBar correspondiente
      // ademas de refrescar la lista.
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final msg = e.toString().replaceFirst('Exception: ', '');
        _error = msg.isNotEmpty
            ? msg
            : 'No se pudo guardar la aversion. Intenta de nuevo.';
        _guardando = false;
      });
    }
  }
}

class _CabeceraFormulario extends StatelessWidget {
  final String titulo;
  final VoidCallback onVolver;

  const _CabeceraFormulario({
    required this.titulo,
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onVolver,
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
            titulo,
            style: GoogleFonts.newsreader(
              fontSize: 20,
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

class _EtiquetaSeccion extends StatelessWidget {
  final String texto;
  const _EtiquetaSeccion({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: const Color(0xFF732b16),
      ),
    );
  }
}

class _TarjetaMotivoSensorial extends StatelessWidget {
  final String tipo;
  final bool activo;
  final double intensidad;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onIntensidadCambiada;

  const _TarjetaMotivoSensorial({
    required this.tipo,
    required this.activo,
    required this.intensidad,
    required this.onToggle,
    required this.onIntensidadCambiada,
  });

  IconData _iconoMotivo() {
    switch (tipo) {
      case 'TEXTURA': return Icons.texture;
      case 'SABOR': return Icons.local_dining;
      case 'OLOR': return Icons.air;
      case 'COLOR': return Icons.palette_outlined;
      default: return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: activo ? Colors.white : const Color(0xFFfff8f6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activo
              ? const Color(0xFFdbc1ba)
              : const Color(0xFFdbc1ba).withOpacity(0.4),
        ),
        boxShadow: activo
            ? [
                BoxShadow(
                  color: const Color(0xFF91412b).withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Checkbox de activacion
                  GestureDetector(
                    onTap: () => onToggle(!activo),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: activo
                            ? const Color(0xFF732b16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: activo
                              ? const Color(0xFF732b16)
                              : const Color(0xFF88726d),
                          width: 2,
                        ),
                      ),
                      child: activo
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _iconoMotivo(),
                    size: 18,
                    color: activo
                        ? const Color(0xFF732b16)
                        : const Color(0xFF88726d),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tipo[0] + tipo.substring(1).toLowerCase(),
                    style: GoogleFonts.newsreader(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: activo
                          ? const Color(0xFF211a18)
                          : const Color(0xFF88726d),
                    ),
                  ),
                ],
              ),
              if (activo)
                Text(
                  'Nivel ${intensidad.round()}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF732b16),
                  ),
                ),
            ],
          ),

          // Slider de intensidad (solo visible cuando el motivo esta activo)
          if (activo) ...[
            const SizedBox(height: 8),
            Slider(
              value: intensidad,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: const Color(0xFF7f5700),
              inactiveColor: const Color(0xFFdbc1ba),
              onChanged: onIntensidadCambiada,
            ),
          ],
        ],
      ),
    );
  }
}
