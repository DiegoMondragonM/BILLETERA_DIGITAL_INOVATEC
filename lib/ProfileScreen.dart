import 'package:flutter/material.dart';
import 'package:flutter_application_1/AddCardScreen.dart';
import 'package:flutter_application_1/SaludFinancieraScreen.dart';
import 'package:flutter_application_1/WalletScreen.dart';
import 'package:flutter_application_1/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String nombreUsuario;
  // Si es necesario, agrega otros parámetros como correo.
  final String correo;

  const ProfileScreen({
    Key? key,
    required this.nombreUsuario,
    required this.correo,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Como en el menú de Wallet, la pestaña de Perfil es la última (índice 3)
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      // Usamos el mismo BottomNavigationBar de tu WalletScreen.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 0) {
            // Ítem "Tarjetas": navegamos a la pantalla de Wallet/Tarjetas.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => WalletScreen(
                      nombreUsuario:
                          widget
                              .nombreUsuario, // aquí podrías pasar el nombre si lo guardas en sesión
                      correo: widget.correo,
                    ),
              ),
            );
          } else if (index == 1) {
            // Ítem "Salud Financiera": navegamos a la pantalla correspondiente.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SaludFinancieraScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
              ),
            );
          } else if (index == 2) {
            // Ítem "Agregar Tarjeta": navegamos con animación a AddCardScreen.
            // Navega con animación a AddCardScreen sin asignar el resultado a una variable.
            await Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder:
                    (context, animation, secondaryAnimation) => AddCardScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
            // Después de regresar de AddCardScreen, actualiza el índice.
            setState(() {
              _currentIndex = 3; // Regresa al índice de Perfil.
            });
          } else if (index == 3) {
            // Ítem "Perfil": ya estás en esta pantalla.
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tarjetas"),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: "Salud Financiera",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_card_rounded),
            label: "Agregar Tarjeta",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
      // Contenido principal del profileScreen
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título "Perfil"
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Configuración',
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Fila: foto de perfil, saludo y botón de edición.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      // Acción opcional: cambiar o ver foto de perfil.
                    },
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        'assets/images/profile_pic.png',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hola 👋!',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          widget.nombreUsuario,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // Navega a "editar perfil"
                      //Navigator.pushNamed(context, '/editarPerfil');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Contenedor blanco que muestra la lista de botones
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      // Primera sección: "Perfil", "Notificaciones" y "Personalización"
                      _buildBoton(
                        title: 'Perfil',
                        icon: Icons.account_circle,
                        onTap: () {
                          // Acción al seleccionar "Perfil"
                        },
                      ),
                      _buildBoton(
                        title: 'Notificaciones',
                        icon: Icons.notifications,
                        onTap: () {
                          // Acción para Notificaciones
                        },
                      ),
                      _buildBoton(
                        title: 'Personalización',
                        icon: Icons.brush,
                        onTap: () {
                          // Acción para Personalización
                        },
                      ),
                      const Divider(),
                      // Segunda sección: "Cambiar contraseña" y "Soporte"
                      _buildBoton(
                        title: 'Cambiar contraseña',
                        icon: Icons.lock,
                        onTap: () {
                          // Acción para cambiar contraseña
                        },
                      ),
                      _buildBoton(
                        title: 'Soporte',
                        icon: Icons.report_problem,
                        onTap: () {
                          // Acción para soporte
                        },
                      ),
                      const Divider(),
                      // Tercera sección: "Cerrar sesión"
                      _buildBoton(
                        title: 'Cerrar sesión',
                        icon: Icons.exit_to_app,
                        color:
                            Colors
                                .red, // Se especifica el color rojo para este botón
                        onTap: () {
                          _mostrarDialogoCerrarSesion(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método auxiliar para construir cada botón con ícono.
  // Método _buildBoton modificado para aceptar un parámetro opcional "color"
  Widget _buildBoton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87, // Valor por defecto: negro
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 18, color: color)),
      onTap: onTap,
    );
  }

  /// Muestra un diálogo para confirmar el cierre de sesión.
  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Desea cerrar su sesión?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sí'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navegamos a la pantalla de login.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
