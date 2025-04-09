import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../Service/db_helper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // Controladores para cada campo
  TextEditingController nameController = TextEditingController();
  TextEditingController apellidoPaterno = TextEditingController();
  TextEditingController apellidoMaterno = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo morado degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9B00FF), Color(0xFFE510B3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenedor blanco centrado para el formulario de registro
          Center(
            child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LOGO EMPRESA',
                      style: TextStyle(
                        fontSize: 28.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'HOLA!',
                      style: TextStyle(
                        fontSize: 35.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bienvenido a la aplicación [Nombre de la aplicación]',
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                    ),
                    SizedBox(height: 20.0),
                    _buildTextField(
                      Icons.person,
                      'Ingresa tu nombre(s)',
                      controller: nameController,
                    ),
                    SizedBox(height: 10.0),
                    _buildTextField(
                      Icons.person,
                      'Ingresa tu apellido paterno',
                      controller: apellidoPaterno,
                    ),
                    SizedBox(height: 10.0),
                    _buildTextField(
                      Icons.person,
                      'Ingresa tu apellido materno',
                      controller: apellidoMaterno,
                    ),
                    SizedBox(height: 10.0),
                    _buildTextField(
                      Icons.email,
                      'Ingresa tu correo electrónico',
                      controller: emailController,
                    ),
                    SizedBox(height: 10.0),
                    _buildPasswordField(
                      Icons.lock,
                      
                      'Ingresa tu contraseña',
                      _obscurePassword,
                      () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      controller: passwordController,
                    ),
                    SizedBox(height: 10.0),
                    _buildPasswordField(
                      Icons.lock,
                      'Confirma tu contraseña',
                      _obscureConfirmPassword,
                      () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      controller: confirmPasswordController,
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE510B3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 100.0,
                          vertical: 15.0,
                        ),
                      ),
                      child: Text(
                        'CREAR CUENTA',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: Text(
                        '¿Ya tienes una cuenta? Ingresa Aquí!',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          decoration: TextDecoration.underline,
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
    );
  }

  // Función para registrar el usuario en la base de datos
  Future<void> _registerUser() async {
    final name = nameController.text.trim();
    final apellidoPterno = apellidoPaterno.text.trim();
    final apellidoMterno = apellidoMaterno.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        apellidoPterno.isEmpty ||
        apellidoMterno.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Por favor, completa todos los campos');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Las contraseñas no coinciden');
      return;
    }

    // Inserta el usuario en la base de datos
    Map<String, dynamic> newUser = {
      'name': name,
      'apellido_paterno': apellidoMterno,
      'apellido_materno': apellidoMterno,
      'email': email,
      'password': password, // Nota: en producción, encripta la contraseña
    };

    try {
      await DBHelper().insertUser(newUser);
      _showMessage('Usuario registrado correctamente');
      //navegar a la pantalla de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      _showMessage('Error al registrar el usuario: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  //modifocada para aceptar el controlador
  Widget _buildTextField(
    IconData icon,
    String hintText, {
    bool obscureText = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    IconData icon,
    String hintText,
    bool obscureText,
    VoidCallback toggleVisibility, {
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
