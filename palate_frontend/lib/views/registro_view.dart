import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/registro_viewmodel.dart';

/// Pantalla de registro de nuevos usuarios.
/// Recoge nombre, email y contraseña, y los envía al servidor
/// para crear una cuenta nueva.
class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _viewModel = RegistroViewModel();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Controla la visibilidad de la contraseña
  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;

  /// Indica si el usuario ha aceptado los términos y condiciones
  bool _terminosAceptados = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida los campos y envía la petición de registro al servidor.
  /// Verifica que las contraseñas coincidan antes de llamar a la API.
  void _registro() async {
    if (!_terminosAceptados) {
      setState(() {
        _viewModel.error = 'Debes aceptar los términos y condiciones';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _viewModel.error = 'Las contraseñas no coinciden';
      });
      return;
    }

    _viewModel.nombre = _nombreController.text.trim();
    _viewModel.email = _emailController.text.trim();
    _viewModel.password = _passwordController.text;

    final ok = await _viewModel.registro();
    setState(() {});

    if (ok && mounted) {
      // Tras el registro exitoso, vuelve al login tras 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfff8f6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabecera con logo y enlace de vuelta al login ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        color: Color(0xFF732b16),
                        size: 28,
                      ),
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
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Ya tengo cuenta',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: const Color(0xFF91412b),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Título y subtítulo del formulario ──
              Text(
                'Crear cuenta',
                style: GoogleFonts.newsreader(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF211a18),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Regístrate para guardar tus recetas y organizar tu despensa.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF55433e),
                ),
              ),
              const SizedBox(height: 32),

              // ── Campo: nombre completo ──
              _EtiquetaCampo(texto: 'NOMBRE COMPLETO'),
              const SizedBox(height: 8),
              _CampoTexto(
                controller: _nombreController,
                icono: Icons.person_outline,
                placeholder: 'Tu nombre',
                tipo: TextInputType.name,
              ),
              const SizedBox(height: 20),

              // ── Campo: correo electrónico ──
              _EtiquetaCampo(texto: 'CORREO ELECTRÓNICO'),
              const SizedBox(height: 8),
              _CampoTexto(
                controller: _emailController,
                icono: Icons.mail_outline,
                placeholder: 'ejemplo@correo.com',
                tipo: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // ── Campo: contraseña ──
              _EtiquetaCampo(texto: 'CONTRASEÑA'),
              const SizedBox(height: 8),
              _CampoPassword(
                controller: _passwordController,
                ocultar: _ocultarPassword,
                onToggle: () => setState(() => _ocultarPassword = !_ocultarPassword),
              ),
              const SizedBox(height: 20),

              // ── Campo: confirmación de contraseña ──
              _EtiquetaCampo(texto: 'CONFIRMAR CONTRASEÑA'),
              const SizedBox(height: 8),
              _CampoPassword(
                controller: _confirmPasswordController,
                ocultar: _ocultarConfirmPassword,
                onToggle: () => setState(
                  () => _ocultarConfirmPassword = !_ocultarConfirmPassword,
                ),
                icono: Icons.check_circle_outline,
              ),
              const SizedBox(height: 20),

              // ── Checkbox de términos y condiciones ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _terminosAceptados,
                    onChanged: (valor) {
                      setState(() {
                        _terminosAceptados = valor ?? false;
                      });
                    },
                    activeColor: const Color(0xFF732b16),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Acepto los términos y condiciones y la política de privacidad.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF55433e),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Mensaje de error ──
              if (_viewModel.error != null) ...[
                const SizedBox(height: 12),
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
                          _viewModel.error!,
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

              // ── Mensaje de éxito tras el registro ──
              if (_viewModel.exito != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _viewModel.exito!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Botón de registro con gradiente ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF91412b), Color(0xFFD98A73)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF732b16).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _viewModel.cargando ? null : _registro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    icon: _viewModel.cargando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                    label: Text(
                      'REGISTRARSE',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta de campo en mayúsculas con estilo label-lg del diseño.
class _EtiquetaCampo extends StatelessWidget {
  final String texto;
  const _EtiquetaCampo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: const Color(0xFF55433e),
      ),
    );
  }
}

/// Campo de texto genérico con icono de prefijo.
class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final IconData icono;
  final String placeholder;
  final TextInputType tipo;

  const _CampoTexto({
    required this.controller,
    required this.icono,
    required this.placeholder,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: GoogleFonts.inter(color: const Color(0xFFdbc1ba)),
        prefixIcon: Icon(icono, color: const Color(0xFF88726d)),
        filled: true,
        fillColor: const Color(0xFFfff0ed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 16,
        ),
      ),
    );
  }
}

/// Campo de texto para contraseña con botón de mostrar/ocultar.
class _CampoPassword extends StatelessWidget {
  final TextEditingController controller;
  final bool ocultar;
  final VoidCallback onToggle;
  final IconData icono;

  const _CampoPassword({
    required this.controller,
    required this.ocultar,
    required this.onToggle,
    this.icono = Icons.lock_outline,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: GoogleFonts.inter(color: const Color(0xFFdbc1ba)),
        prefixIcon: Icon(icono, color: const Color(0xFF88726d)),
        suffixIcon: IconButton(
          icon: Icon(
            ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF88726d),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFfff0ed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 16,
        ),
      ),
    );
  }
}
