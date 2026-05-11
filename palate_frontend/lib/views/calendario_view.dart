import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/producto_despensa.dart';
import '../viewmodels/calendario_viewmodel.dart';

///
class CalendarioView extends StatefulWidget {
  final int usuarioId;

  const CalendarioView({super.key, required this.usuarioId});

  @override
  State<CalendarioView> createState() => _CalendarioViewState();
}

class _CalendarioViewState extends State<CalendarioView> {
  final _viewModel = CalendarioViewModel();

  DateTime _mesEnFoco = DateTime.now();

  DateTime _diaSeleccionado = DateTime.now();

  @override
  void initState() {
    super.initState();
    _viewModel.cargarProductos(widget.usuarioId).then((_) {
      if (mounted) setState(() {});
    });
  }

  Color _colorMarcador(int diasRestantes) {
    if (diasRestantes < 0) return const Color(0xFF88726d);
    if (diasRestantes <= 2) return const Color(0xFFba1a1a);
    if (diasRestantes <= 7) return const Color(0xFFfdb733);
    return const Color(0xFF7f5700);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: Column(
          children: [
            _AppBarCalendario(onVolver: () => Navigator.pop(context)),

            Expanded(
              child: _viewModel.cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF732b16),
                      ),
                    )
                  : _viewModel.error != null
                      ? Center(
                          child: Text(
                            _viewModel.error!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFba1a1a),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calendario de\ncaducidades',
                                style: GoogleFonts.newsreader(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF211a18),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Visualiza cuando caducan los productos de tu despensa.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF55433e),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _TarjetaCalendario(
                                diaSeleccionado: _diaSeleccionado,
                                mesEnFoco: _mesEnFoco,
                                productosPorFecha: _viewModel.productosPorFecha,
                                onDiaSeleccionado: (seleccionado, foco) {
                                  setState(() {
                                    _diaSeleccionado = seleccionado;
                                    _mesEnFoco = foco;
                                  });
                                },
                                onMesCambiado: (foco) {
                                  setState(() => _mesEnFoco = foco);
                                },
                                colorMarcador: _colorMarcador,
                              ),
                              const SizedBox(height: 20),

                              _ListaProductosDelDia(
                                dia: _diaSeleccionado,
                                productos:
                                    _viewModel.productosDelDia(_diaSeleccionado),
                                colorMarcador: _colorMarcador,
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
}

class _AppBarCalendario extends StatelessWidget {
  final VoidCallback onVolver;

  const _AppBarCalendario({required this.onVolver});

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

class _TarjetaCalendario extends StatelessWidget {
  final DateTime diaSeleccionado;
  final DateTime mesEnFoco;
  final Map<DateTime, List<ProductoDespensa>> productosPorFecha;
  final void Function(DateTime, DateTime) onDiaSeleccionado;
  final ValueChanged<DateTime> onMesCambiado;
  final Color Function(int) colorMarcador;

  const _TarjetaCalendario({
    required this.diaSeleccionado,
    required this.mesEnFoco,
    required this.productosPorFecha,
    required this.onDiaSeleccionado,
    required this.onMesCambiado,
    required this.colorMarcador,
  });

  static const _nombresMeses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  static const _inicialesDias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  List<ProductoDespensa> _eventosDelDia(DateTime dia) {
    final clave = DateTime(dia.year, dia.month, dia.day);
    return productosPorFecha[clave] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFdbc1ba).withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF91412b).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<ProductoDespensa>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: mesEnFoco,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: _eventosDelDia,
        selectedDayPredicate: (dia) => isSameDay(diaSeleccionado, dia),
        onDaySelected: onDiaSeleccionado,
        onPageChanged: onMesCambiado,
        availableGestures: AvailableGestures.horizontalSwipe,

        // Encabezado del calendario sin botones de cambio de formato,
        // mostrando solo el mes en espanol y los selectores de mes
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Color(0xFF732b16),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Color(0xFF732b16),
          ),
        ),

        // Estilos de los dias del calendario
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF55433e),
          ),
          defaultTextStyle: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF211a18),
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFFfdb733).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7f5700),
          ),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF732b16),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        calendarBuilders: CalendarBuilders<ProductoDespensa>(
          // Encabezado del mes con nombre en espanol
          headerTitleBuilder: (context, dia) {
            final mes = _nombresMeses[dia.month - 1];
            return Center(
              child: Text(
                '$mes ${dia.year}',
                style: GoogleFonts.newsreader(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF732b16),
                ),
              ),
            );
          },

          // Iniciales de la semana en espanol (L M X J V S D)
          dowBuilder: (context, dia) {
            final indice = dia.weekday - 1;
            return Center(
              child: Text(
                _inicialesDias[indice],
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: const Color(0xFF88726d),
                ),
              ),
            );
          },

          // Marcador inferior con un punto coloreado segun la urgencia.
          // Se elige el color del producto mas urgente del dia.
          markerBuilder: (context, dia, eventos) {
            if (eventos.isEmpty) return null;
            final hoy = DateTime.now();
            final base = DateTime(dia.year, dia.month, dia.day);
            final hoyBase = DateTime(hoy.year, hoy.month, hoy.day);
            final dias = base.difference(hoyBase).inDays;
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorMarcador(dias),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ListaProductosDelDia extends StatelessWidget {
  final DateTime dia;
  final List<ProductoDespensa> productos;
  final Color Function(int) colorMarcador;

  const _ListaProductosDelDia({
    required this.dia,
    required this.productos,
    required this.colorMarcador,
  });

  String _textoFecha() {
    const dias = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final nombreDia = dias[dia.weekday - 1];
    final nombreMes = meses[dia.month - 1];
    return '$nombreDia, ${dia.day} de $nombreMes';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera con la fecha seleccionada
        Text(
          _textoFecha(),
          style: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF732b16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          productos.isEmpty
              ? 'No hay productos que caduquen en esta fecha.'
              : '${productos.length} producto${productos.length == 1 ? '' : 's'} '
                  'caduca${productos.length == 1 ? '' : 'n'} este dia.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF55433e),
          ),
        ),
        const SizedBox(height: 12),

        // Lista de productos o estado vacio
        if (productos.isEmpty)
          _EstadoVacio()
        else
          Column(
            children: productos
                .map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TarjetaProductoCalendario(
                        producto: p,
                        colorMarcador: colorMarcador,
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFfff0ed),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFdbc1ba).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available,
            size: 36,
            color: Color(0xFFdbc1ba),
          ),
          const SizedBox(height: 8),
          Text(
            'Dia tranquilo',
            style: GoogleFonts.newsreader(
              fontSize: 16,
              color: const Color(0xFF88726d),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProductoCalendario extends StatelessWidget {
  final ProductoDespensa producto;
  final Color Function(int) colorMarcador;

  const _TarjetaProductoCalendario({
    required this.producto,
    required this.colorMarcador,
  });

  IconData _iconoCategoria(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case 'verduras':
      case 'vegetales':
        return Icons.eco;
      case 'frutas':
        return Icons.apple;
      case 'carnes':
        return Icons.lunch_dining;
      case 'pescados':
        return Icons.set_meal;
      case 'lacteos':
        return Icons.water_drop;
      case 'cereales':
      case 'panaderia':
        return Icons.bakery_dining;
      case 'condimentos':
        return Icons.spa;
      case 'legumbres':
        return Icons.grass;
      default:
        return Icons.restaurant;
    }
  }

  String _textoDias(int dias) {
    if (dias < 0) return 'Caducado';
    if (dias == 0) return 'Caduca hoy';
    if (dias == 1) return 'En 1 dia';
    return 'En $dias dias';
  }

  @override
  Widget build(BuildContext context) {
    final dias = producto.diasHastaCaducidad ?? 0;
    final color = colorMarcador(dias);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFdbc1ba).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFfff0ed),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _iconoCategoria(producto.categoriaAlimento),
              color: const Color(0xFF732b16),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombreAlimento,
                  style: GoogleFonts.newsreader(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF211a18),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${producto.cantidad % 1 == 0 ? producto.cantidad.toInt() : producto.cantidad} '
                  '${producto.unidad}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF88726d),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _textoDias(dias),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
