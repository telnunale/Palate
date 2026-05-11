import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/producto_despensa.dart';
import '../viewmodels/despensa_viewmodel.dart';
import 'calendario_view.dart';

class DespensaView extends StatefulWidget {
  final int usuarioId;

  const DespensaView({super.key, required this.usuarioId});

  @override
  State<DespensaView> createState() => _DespensaViewState();
}

class _DespensaViewState extends State<DespensaView> {
  final _viewModel = DespensaViewModel();

  @override
  void initState() {
    super.initState();
    Future.wait([
      _viewModel.cargarProductos(widget.usuarioId),
      _viewModel.cargarCatalogo(widget.usuarioId),
    ]).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: _viewModel.cargando
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF732b16)),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _AppBarDespensa(
                      onCalendario: _abrirCalendario,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mi despensa',
                            style: GoogleFonts.newsreader(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF211a18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFffdbd1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_viewModel.totalProductos} artículos',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3b0800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_viewModel.proximosACaducar.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: _BannerAlertaCaducidad(
                          cantidad: _viewModel.proximosACaducar.length,
                          nombres: _viewModel.proximosACaducar
                              .take(3)
                              .map((p) => p.nombreAlimento)
                              .toList(),
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        itemCount: _viewModel.categorias.length,
                        itemBuilder: (context, index) {
                          final categoria = _viewModel.categorias[index];
                          final activo = categoria ==
                              (_viewModel.categoriaSeleccionada ?? 'Todos');
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _ChipCategoria(
                              etiqueta: categoria,
                              activo: activo,
                              onTap: () {
                                setState(() {
                                  _viewModel.seleccionarCategoria(categoria);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  _viewModel.productosFiltrados.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(48),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.kitchen,
                                    size: 56,
                                    color: Color(0xFFdbc1ba),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Despensa vacía',
                                    style: GoogleFonts.newsreader(
                                      fontSize: 20,
                                      color: const Color(0xFF88726d),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Agrega productos con el botón +',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFF88726d),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final producto =
                                  _viewModel.productosFiltrados[index];
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 0, 20, 10),
                                child: Dismissible(
                                  key: Key('producto_${producto.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFFffdad6),
                                      borderRadius:
                                          BorderRadius.circular(24),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding:
                                        const EdgeInsets.only(right: 20),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Color(0xFFba1a1a),
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    _viewModel
                                        .eliminarProducto(
                                          producto.id,
                                          widget.usuarioId,
                                        )
                                        .then((_) {
                                      if (mounted) setState(() {});
                                    });
                                  },
                                  child: _TarjetaProducto(
                                    producto: producto,
                                    onTap: () =>
                                        _mostrarModalEditar(producto),
                                  ),
                                ),
                              );
                            },
                            childCount:
                                _viewModel.productosFiltrados.length,
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarModalAgregar(),
        backgroundColor: const Color(0xFF91412b),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _abrirCalendario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarioView(usuarioId: widget.usuarioId),
      ),
    );
  }

  void _mostrarModalAgregar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalAgregarProducto(
        catalogoAlimentos: _viewModel.catalogoAlimentos,
        onCrearAlimento: (nombre) =>
            _viewModel.crearAlimento(nombre: nombre),
        onGuardar: (alimentoId, cantidad, unidad, fecha) async {
          await _viewModel.agregarProducto(
            usuarioId: widget.usuarioId,
            alimentoId: alimentoId,
            cantidad: cantidad,
            unidad: unidad,
            fechaCaducidad: fecha,
          );
          if (mounted) {
            setState(() {});
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _mostrarModalEditar(ProductoDespensa producto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalProducto(
        titulo: 'Editar producto',
        nombreInicial: producto.nombreAlimento,
        cantidadInicial: producto.cantidad.toString(),
        unidadInicial: producto.unidad,
        fechaInicial: producto.fechaCaducidad,
        mostrarEliminar: true,
        mostrarConsumido: true,
        onGuardar: (nombre, cantidad, unidad, fecha) async {
          await _viewModel.actualizarProducto(
            producto.id,
            widget.usuarioId,
            cantidad: cantidad,
            unidad: unidad,
            fechaCaducidad: fecha,
          );
          if (mounted) {
            setState(() {});
            Navigator.pop(context);
          }
        },
        onEliminar: () async {
          await _viewModel.eliminarProducto(
              producto.id, widget.usuarioId);
          if (mounted) {
            setState(() {});
            Navigator.pop(context);
          }
        },
        onConsumido: () async {
          await _viewModel.marcarConsumido(
              producto.id, widget.usuarioId);
          if (mounted) {
            setState(() {});
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _AppBarDespensa extends StatelessWidget {
  final VoidCallback onCalendario;

  const _AppBarDespensa({required this.onCalendario});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Color(0xFF732b16)),
              const SizedBox(width: 6),
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

          GestureDetector(
            onTap: onCalendario,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFfff0ed),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Color(0xFF732b16),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerAlertaCaducidad extends StatelessWidget {
  final int cantidad;
  final List<String> nombres;

  const _BannerAlertaCaducidad({
    required this.cantidad,
    required this.nombres,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFfdb733).withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF7f5700).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7f5700),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consumir pronto',
                  style: GoogleFonts.newsreader(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6d4a00),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tienes $cantidad artículos que caducan pronto: '
                  '${nombres.join(', ')}.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF55433e),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _ChipCategoria({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo
              ? const Color(0xFF91412b)
              : const Color(0xFFf4e5e2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          etiqueta,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : const Color(0xFF55433e),
          ),
        ),
      ),
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  final ProductoDespensa producto;
  final VoidCallback onTap;

  const _TarjetaProducto({
    required this.producto,
    required this.onTap,
  });

  Color _colorBadge(int? dias) {
    if (dias == null) return const Color(0xFFf4e5e2);
    if (dias <= 2) return const Color(0xFFffdad6);
    if (dias <= 7) return const Color(0xFFffdead);
    return const Color(0xFFf4e5e2);
  }

  Color _colorTextoBadge(int? dias) {
    if (dias == null) return const Color(0xFF88726d);
    if (dias <= 2) return const Color(0xFFba1a1a);
    if (dias <= 7) return const Color(0xFF7f5700);
    return const Color(0xFF88726d);
  }

  String _textoBadge(int? dias) {
    if (dias == null) return '';
    if (dias < 0) return 'Caducado';
    if (dias == 0) return 'Caduca hoy';
    if (dias == 1) return '1 día';
    return '$dias días';
  }

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

  @override
  Widget build(BuildContext context) {
    final dias = producto.diasHastaCaducidad;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFdbc1ba).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF91412b).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFfff0ed),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: producto.imagenAlimento != null
                  ? Image.network(
                      producto.imagenAlimento!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          _iconoCategoria(producto.categoriaAlimento),
                          color: const Color(0xFF732b16),
                          size: 28,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        _iconoCategoria(producto.categoriaAlimento),
                        color: const Color(0xFF732b16),
                        size: 28,
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          producto.nombreAlimento,
                          style: GoogleFonts.newsreader(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF211a18),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dias != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _colorBadge(dias),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _textoBadge(dias),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _colorTextoBadge(dias),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        producto.categoriaAlimento ?? 'General',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFdbc1ba),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${producto.cantidad % 1 == 0 ? producto.cantidad.toInt() : producto.cantidad} ${producto.unidad}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF88726d),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalProducto extends StatefulWidget {
  final String titulo;
  final String? nombreInicial;
  final String? cantidadInicial;
  final String? unidadInicial;
  final String? fechaInicial;
  final bool mostrarEliminar;
  final bool mostrarConsumido;
  final Future<void> Function(
    String nombre,
    String cantidad,
    String unidad,
    String? fechaCaducidad,
  ) onGuardar;
  final VoidCallback? onEliminar;
  final VoidCallback? onConsumido;

  const _ModalProducto({
    required this.titulo,
    this.nombreInicial,
    this.cantidadInicial,
    this.unidadInicial,
    this.fechaInicial,
    this.mostrarEliminar = false,
    this.mostrarConsumido = false,
    required this.onGuardar,
    this.onEliminar,
    this.onConsumido,
  });

  @override
  State<_ModalProducto> createState() => _ModalProductoState();
}

class _ModalProductoState extends State<_ModalProducto> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _cantidadCtrl;
  String _unidadSeleccionada = 'Unidades';
  DateTime? _fechaSeleccionada;
  bool _guardando = false;

  final List<String> _unidades = [
    'Unidades',
    'Gramos',
    'Kilogramos',
    'Litros',
    'Mililitros',
  ];

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.nombreInicial ?? '');
    _cantidadCtrl =
        TextEditingController(text: widget.cantidadInicial ?? '1');

    if (widget.unidadInicial != null &&
        _unidades.contains(widget.unidadInicial)) {
      _unidadSeleccionada = widget.unidadInicial!;
    }

    if (widget.fechaInicial != null) {
      _fechaSeleccionada = DateTime.tryParse(widget.fechaInicial!);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  String get _textoFecha {
    if (_fechaSeleccionada == null) return 'Seleccionar fecha';
    return '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}';
  }

  String? get _fechaISO {
    if (_fechaSeleccionada == null) return null;
    final d = _fechaSeleccionada!;
    return '${d.year}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFdbc1ba),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.titulo,
                style: GoogleFonts.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF732b16),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Color(0xFF88726d)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _EtiquetaModal(texto: 'Producto'),
          const SizedBox(height: 6),
          TextField(
            controller: _nombreCtrl,
            readOnly: widget.nombreInicial != null,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Ej. Leche, Tomates, Arroz...',
              hintStyle: GoogleFonts.inter(color: const Color(0xFFdbc1ba)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF88726d)),
              filled: true,
              fillColor: const Color(0xFFfff0ed),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EtiquetaModal(texto: 'Cantidad'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cantidadCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFfff0ed),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EtiquetaModal(texto: 'Unidad'),
                    const SizedBox(height: 6),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFfff0ed),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _unidadSeleccionada,
                          isExpanded: true,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF211a18),
                          ),
                          items: _unidades
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u),
                                ),
                              )
                              .toList(),
                          onChanged: (valor) {
                            setState(() {
                              _unidadSeleccionada = valor!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _EtiquetaModal(texto: 'Fecha de caducidad'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fechaSeleccionada ??
                    DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate:
                    DateTime.now().add(const Duration(days: 3650)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF732b16),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (fecha != null) {
                setState(() => _fechaSeleccionada = fecha);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFfff0ed),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _textoFecha,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _fechaSeleccionada != null
                          ? const Color(0xFF211a18)
                          : const Color(0xFFdbc1ba),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF88726d),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _guardando
                  ? null
                  : () async {
                      setState(() => _guardando = true);
                      await widget.onGuardar(
                        _nombreCtrl.text.trim(),
                        _cantidadCtrl.text.trim(),
                        _unidadSeleccionada,
                        _fechaISO,
                      );
                      if (mounted) setState(() => _guardando = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF91412b),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Guardar en despensa',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          if (widget.mostrarConsumido && widget.onConsumido != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: widget.onConsumido,
              icon: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF732b16),
              ),
              label: Text(
                'Marcar como consumido',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF732b16),
                ),
              ),
            ),
          ],

          if (widget.mostrarEliminar && widget.onEliminar != null) ...[
            TextButton.icon(
              onPressed: widget.onEliminar,
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFba1a1a),
              ),
              label: Text(
                'Eliminar de la despensa',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFba1a1a),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModalAgregarProducto extends StatefulWidget {
  final List<Map<String, dynamic>> catalogoAlimentos;

  final Future<void> Function(
    int alimentoId,
    String cantidad,
    String unidad,
    String? fechaCaducidad,
  ) onGuardar;

  final Future<Map<String, dynamic>?> Function(String nombre) onCrearAlimento;

  const _ModalAgregarProducto({
    required this.catalogoAlimentos,
    required this.onGuardar,
    required this.onCrearAlimento,
  });

  @override
  State<_ModalAgregarProducto> createState() => _ModalAgregarProductoState();
}

class _ModalAgregarProductoState extends State<_ModalAgregarProducto> {
  final TextEditingController _busquedaCtrl = TextEditingController();
  final TextEditingController _cantidadCtrl = TextEditingController(text: '1');

  Map<String, dynamic>? _alimentoSeleccionado;

  bool _mostrarSugerencias = false;

  String _unidadSeleccionada = 'Unidades';
  DateTime? _fechaSeleccionada;
  bool _guardando = false;
  bool _creandoAlimento = false;
  String? _error;

  final List<String> _unidades = [
    'Unidades',
    'Gramos',
    'Kilogramos',
    'Litros',
    'Mililitros',
  ];

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _crearAlimentoNuevo() async {
    final nombre = _busquedaCtrl.text.trim();
    if (nombre.isEmpty || _creandoAlimento) return;
    setState(() {
      _creandoAlimento = true;
      _error = null;
    });
    final nuevo = await widget.onCrearAlimento(nombre);
    if (!mounted) return;
    setState(() {
      _creandoAlimento = false;
      if (nuevo != null) {
        _alimentoSeleccionado = nuevo;
        _busquedaCtrl.text = nuevo['nombre'] as String? ?? nombre;
        _mostrarSugerencias = false;
      } else {
        _error = 'No se pudo crear el alimento. Intentalo de nuevo.';
      }
    });
  }

  List<Map<String, dynamic>> get _sugerenciasFiltradas {
    final texto = _busquedaCtrl.text.toLowerCase().trim();
    if (texto.isEmpty) return widget.catalogoAlimentos.take(5).toList();
    return widget.catalogoAlimentos
        .where(
          (a) =>
              (a['nombre'] as String?)?.toLowerCase().contains(texto) ?? false,
        )
        .take(6)
        .toList();
  }

  bool get _puedeCrearNuevo {
    final texto = _busquedaCtrl.text.trim();
    if (texto.isEmpty) return false;
    final coincidenciaExacta = widget.catalogoAlimentos.any(
      (a) => (a['nombre'] as String?)?.toLowerCase() == texto.toLowerCase(),
    );
    return !coincidenciaExacta;
  }

  String? get _fechaISO {
    if (_fechaSeleccionada == null) return null;
    final d = _fechaSeleccionada!;
    return '${d.year}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFdbc1ba),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agregar a la despensa',
                  style: GoogleFonts.newsreader(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF732b16),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Color(0xFF88726d)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _EtiquetaModal(texto: 'Producto'),
            const SizedBox(height: 6),
            TextField(
              controller: _busquedaCtrl,
              onChanged: (_) {
                setState(() {
                  _mostrarSugerencias = true;
                  _alimentoSeleccionado = null;
                });
              },
              onTap: () => setState(() => _mostrarSugerencias = true),
              style: GoogleFonts.inter(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
                hintStyle: GoogleFonts.inter(color: const Color(0xFFdbc1ba)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF88726d)),
                suffixIcon: _alimentoSeleccionado != null
                    ? const Icon(Icons.check_circle, color: Color(0xFF732b16))
                    : null,
                filled: true,
                fillColor: const Color(0xFFfff0ed),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            if (_mostrarSugerencias &&
                _alimentoSeleccionado == null &&
                (_sugerenciasFiltradas.isNotEmpty || _puedeCrearNuevo)) ...[
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
                      color: const Color(0xFF91412b).withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ..._sugerenciasFiltradas.map((alimento) {
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFf4e5e2),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.restaurant,
                                size: 16,
                                color: Color(0xFF91412b),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                alimento['nombre'] as String? ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF211a18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (_puedeCrearNuevo)
                      GestureDetector(
                        onTap: _crearAlimentoNuevo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFfff0ed),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                size: 16,
                                color: Color(0xFF732b16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _creandoAlimento
                                      ? 'Creando...'
                                      : 'Crear "${_busquedaCtrl.text.trim()}"',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF732b16),
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
            ],
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EtiquetaModal(texto: 'Cantidad'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _cantidadCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 15),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFfff0ed),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EtiquetaModal(texto: 'Unidad'),
                      const SizedBox(height: 6),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFfff0ed),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _unidadSeleccionada,
                            isExpanded: true,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF211a18),
                            ),
                            items: _unidades
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ),
                                )
                                .toList(),
                            onChanged: (valor) {
                              setState(() => _unidadSeleccionada = valor!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _EtiquetaModal(texto: 'Fecha de caducidad'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaSeleccionada ??
                      DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF732b16),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (fecha != null) setState(() => _fechaSeleccionada = fecha);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFfff0ed),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fechaSeleccionada == null
                          ? 'Seleccionar fecha (opcional)'
                          : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: _fechaSeleccionada != null
                            ? const Color(0xFF211a18)
                            : const Color(0xFFdbc1ba),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF88726d),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFFba1a1a),
                ),
              ),
            ],
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _guardando
                    ? null
                    : () async {
                        if (_alimentoSeleccionado == null) {
                          setState(
                            () => _error = 'Selecciona un alimento de la lista.',
                          );
                          return;
                        }
                        if (_cantidadCtrl.text.trim().isEmpty) {
                          setState(() => _error = 'Indica la cantidad.');
                          return;
                        }
                        setState(() {
                          _guardando = true;
                          _error = null;
                        });
                        await widget.onGuardar(
                          _alimentoSeleccionado!['id'] as int,
                          _cantidadCtrl.text.trim(),
                          _unidadSeleccionada,
                          _fechaISO,
                        );
                        if (mounted) setState(() => _guardando = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF91412b),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Guardar en despensa',
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
    );
  }
}

class _EtiquetaModal extends StatelessWidget {
  final String texto;
  const _EtiquetaModal({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: const Color(0xFF55433e),
      ),
    );
  }
}
