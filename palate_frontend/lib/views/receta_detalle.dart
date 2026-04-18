import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecetaDetalleView extends StatefulWidget {
  final int recetaId;
  final String titulo;
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
  Map<String, dynamic>? receta;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarReceta();
  }

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

  String _dificultadTexto(String dificultad) {
    switch (dificultad) {
      case 'FACIL':
        return 'Fácil';
      case 'MEDIA':
        return 'Media';
      case 'DIFICIL':
        return 'Difícil';
      default:
        return dificultad;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB85C38)))
          : receta == null
              ? const Center(child: Text('Erro ao cargar a receita'))
              : CustomScrollView(
                  slivers: [
                    // Imagen header con botón atrás
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      backgroundColor: const Color(0xFFFDF6EE),
                      leading: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          widget.imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF0EBE3),
                              child: const Center(
                                child: Icon(Icons.restaurant, size: 80, color: Color(0xFFB85C38)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Contenido
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            Text(
                              (receta!['titulo'] as String?) ?? '',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Descripción
                            Text(
                              (receta!['descripcion'] as String?) ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8A8A8A),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Info cards (tiempo + dificultad)
                            Row(
                              children: [
                                _InfoChip(
                                  icon: Icons.access_time,
                                  label: 'Preparación',
                                  valor: '${receta!['tiempoPreparacion'] ?? 0} min',
                                ),
                                const SizedBox(width: 12),
                                _InfoChip(
                                  icon: Icons.local_fire_department,
                                  label: 'Cocción',
                                  valor: '${receta!['tiempoCoccion'] ?? 0} min',
                                ),
                                const SizedBox(width: 12),
                                _InfoChip(
                                  icon: Icons.trending_up,
                                  label: 'Dificultade',
                                  valor: _dificultadTexto((receta!['dificultad'] as String?) ?? ''),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Ingredientes
                            const Text(
                              'Ingredientes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildIngredientes(),
                            const SizedBox(height: 32),

                            // Instrucciones
                            const Text(
                              'Preparación',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInstrucciones(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildIngredientes() {
    final ingredientes = receta!['ingredientes'] as List<dynamic>? ?? [];

    if (ingredientes.isEmpty) {
      return const Text(
        'Non hai ingredientes dispoñibles',
        style: TextStyle(color: Color(0xFF8A8A8A)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: ingredientes.asMap().entries.map((entry) {
          final index = entry.key;
          final ing = entry.value as Map<String, dynamic>;
          final alimento = ing['alimento'] as Map<String, dynamic>?;
          final nombre = alimento != null ? (alimento['nombre'] as String? ?? 'Descoñecido') : 'Descoñecido';
          final cantidad = ing['cantidad']?.toString() ?? '';
          final unidad = (ing['unidadMedida'] as String?) ?? '';
          final isLast = index == ingredientes.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0xFFF0EBE3), width: 1),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB85C38),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '$cantidad $unidad',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstrucciones() {
    final instrucciones = (receta!['instrucciones'] as String?) ?? '';
    final pasos = instrucciones.split(RegExp(r'\d+\.\s*'));
    final pasosLimpios = pasos.where((p) => p.trim().isNotEmpty).toList();

    if (pasosLimpios.isEmpty) {
      return Text(
        instrucciones,
        style: const TextStyle(fontSize: 15, color: Color(0xFF5A5A5A), height: 1.6),
      );
    }

    return Column(
      children: pasosLimpios.asMap().entries.map((entry) {
        final index = entry.key;
        final paso = entry.value.trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFB85C38).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFFB85C38),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    paso,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5A5A5A),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ==================== INFO CHIP ====================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFB85C38), size: 22),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A)),
            ),
          ],
        ),
      ),
    );
  }
}