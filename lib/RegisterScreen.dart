import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

// Lista global para almacenar los usuarios registrados de forma local.
List<Map<String, dynamic>> registeredUsers = [];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Para el botón de loading

  // Controladores para los campos del formulario.
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController =
      TextEditingController();
  final TextEditingController _apellidoMaternoController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Función que simula el registro del usuario.
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (registeredUsers.any(
      (user) => user['correo'] == _emailController.text.trim(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El correo ya está registrado")),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      // Genera el hash de la contraseña antes de usarla
      final String plainPassword = _passwordController.text.trim();
      final String hashedPassword = _hashPassword(plainPassword);

      // Realiza la solicitud HTTP POST al backend.
      const String baseUrl = String.fromEnvironment(
        'BACKEND_URL',
        defaultValue: 'http://10.0.2.2:3000', //'http://10.0.2.2:3000' o 'http://192.168.1.71:3000'
      );
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombreController.text.trim(),
          'apellidoPaterno': _apellidoPaternoController.text.trim(),
          'apellidoMaterno': _apellidoMaternoController.text.trim(),
          'correo': _emailController.text.trim(),
          'password': hashedPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Registro exitoso: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario registrado correctamente.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        // Manejo de errores
        print("Error al registrar: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _hashPassword(String password) {
    // Convierte la contraseña a bytes usando UTF8
    final bytes = utf8.encode(password);
    // Aplica el algoritmo SHA-256
    final digest = sha256.convert(bytes);
    // Devuelve el hash en formato hexadecimal (string)
    return digest.toString();
  }

  // Función para validar el correo electrónico, incluyendo dominios permitidos.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9_.+-]+@([a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+)$",
    );
    final match = emailRegex.firstMatch(email);
    if (match == null) return false;
    // Lista de dominios permitidos.
    const allowedDomains = [
      'gmail.com',
      'outlook.com',
      'hotmail.com',
      'apple.com',
      'icloud.com',
    ];
    final domain = match.group(1)?.toLowerCase();
    return (domain != null && allowedDomains.contains(domain));
  }

  // Función para determinar y mostrar la fuerza de la contraseña.
  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'(?=.*[A-Z])').hasMatch(password)) score++;
    if (RegExp(r'(?=.*[0-9])').hasMatch(password)) score++;
    if (RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password)) score++;

    if (score <= 2) return "Débil";
    if (score <= 4) return "Medio";
    return "Fuerte";
  }

  // Helper para crear un campo de texto con hintText y subrayado.
  Widget _buildTextField(
    IconData icon,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: const UnderlineInputBorder(),
      ),
      validator: validator,
    );
  }

  // Helper para crear un campo de contraseña con hintText.
  Widget _buildPasswordField(
    IconData icon,
    String hint,
    TextEditingController controller,
    bool obscureText,
    VoidCallback toggleVisibility, {
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: const UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Variables para restricción de anchos.
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth * 0.8; // 80% del ancho de la pantalla

    return Scaffold(
      // Fondo degradado que abarca toda la pantalla.
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título superior fuera del contenedor.
              const Text(
                'Crea tu cuenta para continuar 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),
              // Contenedor blanco centrado con el formulario.
              Center(
                child: Container(
                  width: fieldWidth + 40,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícono y mensaje de bienvenida.
                        const Icon(
                          Icons.account_circle,
                          color: Color(0xFF4568DC),
                          size: 80,
                        ),
                        const SizedBox(height: 10.0),
                        const Text(
                          'Registra tu cuenta en MiAplicacion',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Campo: Ingresa tu nombre(s)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ingresa tu nombre(s)',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: SizedBox(
                            width: fieldWidth,
                            child: _buildTextField(
                              Icons.person,
                              "Juan",
                              _nombreController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\d')),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Campo obligatorio";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Campo: Ingresa tu apellido paterno
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ingresa tu apellido paterno',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: SizedBox(
                            width: fieldWidth,
                            child: _buildTextField(
                              Icons.person,
                              "Pérez",
                              _apellidoPaternoController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\d')),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Campo obligatorio";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Campo: Ingresa tu apellido materno
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ingresa tu apellido materno',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: SizedBox(
                            width: fieldWidth,
                            child: _buildTextField(
                              Icons.person,
                              "García",
                              _apellidoMaternoController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\d')),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Campo obligatorio";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Campo: Ingresa tu correo electrónico
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ingresa tu correo electrónico',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: SizedBox(
                            width: fieldWidth,
                            child: _buildTextField(
                              Icons.email,
                              "tu@ejemplo.com",
                              _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Campo obligatorio";
                                }
                                if (!_isValidEmail(value.trim())) {
                                  return "Correo o dominio inválido";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Campo: Ingresa tu contraseña.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ingresa tu contraseña',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: SizedBox(
                            width: fieldWidth,
                            child: _buildPasswordField(
                              Icons.lock,
                              "********",
                              _passwordController,
                              _obscurePassword,
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Campo obligatorio";
                                }
                                if (value.trim().length < 6) {
                                  return "Debe tener al menos 6 caracteres";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        if (_passwordController.text.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Fuerza: ${_getPasswordStrength(_passwordController.text)}",
                              style: TextStyle(
                                color:
                                    _getPasswordStrength(
                                              _passwordController.text,
                                            ) ==
                                            "Fuerte"
                                        ? Colors.green
                                        : _getPasswordStrength(
                                              _passwordController.text,
                                            ) ==
                                            "Medio"
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20.0),
                        // Campo: Confirma tu contraseña.
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Confirma tu contraseña',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Center(
                          child: SizedBox(
                            width: fieldWidth,
                            child: _buildPasswordField(
                              Icons.lock,
                              "********",
                              _confirmPasswordController,
                              _obscureConfirmPassword,
                              () => setState(
                                () =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Campo obligatorio";
                                }
                                if (value.trim() !=
                                    _passwordController.text.trim()) {
                                  return "Las contraseñas no coinciden";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        // Botón "CREAR CUENTA".
                        Center(
                          child: SizedBox(
                            width: fieldWidth,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4568DC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'CREAR CUENTA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Botón para ir al Login.
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              '¿Ya tienes una cuenta? Inicia sesión',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}