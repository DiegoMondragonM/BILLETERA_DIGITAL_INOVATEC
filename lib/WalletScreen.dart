import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/AddCardScreen.dart';
import 'package:flutter_application_1/CardDetailScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';
import 'package:flutter_application_1/SaludFinancieraScreen.dart';
import 'package:http/http.dart' as http;

class WalletScreen extends StatefulWidget {
  final String nombreUsuario; // sigue disponible si quieres mostrar el nombre
  final String correo; // ahora la PK que pasamos desde el login

  const WalletScreen({
    super.key,
    required this.nombreUsuario,
    required this.correo,
  });

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _baseUrl = 'http://10.0.2.2:3000'; //'http://10.0.2.2:3000' o 'http://192.168.1.71:3000'
  List<Map<String, dynamic>> userCards = [];
  int _currentIndex = 0; // Índice de la pestaña activa

  @override
  void initState() {
    super.initState();
    _fetchCards(); // Cargar tarjetas al iniciar la pantalla
  }

  Future<void> _fetchCards() async {
    // Percent‑encode del correo
    final emailEnc = Uri.encodeComponent(widget.correo.trim());
    // Ahora llamamos a /tarjetas/:correo
    final uri = Uri.parse('$_baseUrl/tarjetas/$emailEnc');
    print('👉 GET $uri');

    try {
      final resp = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      print('👈 ${resp.statusCode} ${resp.body}');

      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        setState(() => userCards = data.cast<Map<String, dynamic>>());
      } else {
        debugPrint('Error al cargar tarjetas: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Excepción en _fetchCards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar personalizado: "TuApp" a la izquierda y botón lápiz a la derecha.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8.0), // margen a la izquierda
            const Text(
              'TuApp',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications, size: 30, color: Colors.grey),
              onPressed: () {
                // Define la acción del botón de lápiz aquí.
              },
            ),
          ],
        ),
      ),
      body: userCards.isEmpty ? _buildNoCardsSection() : _buildCardsList(),
      // Aquí es donde añadimos el FAB:
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddCardScreen(
                    correo: widget.correo,
                    nombreUsuario: widget.nombreUsuario,
                  ),
            ),
          );
          if (added == true) {
            _fetchCards(); // 🔄 refresca la lista
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          // Actualiza el índice y navega según el ítem seleccionado.
          if (index == 0) {
            // Tarjetas: nos quedamos en esta pantalla.
            setState(() {
              _currentIndex = index;
            });
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
            setState(() {
              _currentIndex = index;
            });
          } else if (index == 2) {
            // Agregar Tarjeta: usa animación slide para navegar a AddCardScreen.
            final Map<String, dynamic>? newCard =
                await Navigator.push<Map<String, dynamic>>(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            AddCardScreen(
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
            setState(() {
              // Al volver, forzamos que la pestaña activa sea "Tarjetas".
              _currentIndex = 0;
              if (newCard != null) {
                userCards.add(newCard);
              }
            });
          } else if (index == 3) {
            // Perfil: navega a la pantalla de Perfil (ejemplo).
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ProfileScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
              ),
            );
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
    );
  }

  // Se muestra cuando no hay tarjetas registradas.
  Widget _buildNoCardsSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card, size: 100, color: Colors.black),
          const SizedBox(height: 20.0),
          const Text(
            'No tienes tarjetas registradas',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  // Se construye la vista de tarjetas como una pila (Stack) con animación.
  Widget _buildCardsList() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final containerHeight = userCards.length * 50.0 + 200;

    return Container(
      height: containerHeight,
      clipBehavior: Clip.none,
      child: Stack(
        children:
            userCards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final topOffset = index * 50.0;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: topOffset,
                left: (screenWidth - cardWidth) / 2,
                width: cardWidth,
                child: GestureDetector(
                  onTap: () async {
                    final borrada = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CardDetailScreen(
                              card: card,
                              correo: widget.correo,
                            ),
                      ),
                    );

                    if (borrada == true) {
                      setState(() {
                        userCards.removeWhere((c) => c['id'] == card['id']);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tarjeta borrada')),
                      );
                    }
                  },

                  child: AnimatedCardItem(
                    delay: index * 100,
                    child: _buildCardItem(card),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // Función auxiliar que enmascara los primeros 12 dígitos.
  String maskCardNumber(String cardNumber) {
    // Si el número viene en formato "1234 5678 9012 3456", lo separamos por espacios.
    List<String> parts = cardNumber.split(' ');
    if (parts.length == 4) {
      // Enmascaramos los primeros 3 grupos y dejamos visible el último.
      return "**** **** **** ${parts[3]}";
    } else {
      // En caso de que el número no tenga ese formato, quitamos espacios y enmascaramos
      String digits = cardNumber.replaceAll(' ', '');
      if (digits.length <= 12) return cardNumber;
      String masked = '*' * 12 + digits.substring(12);
      // Opcional: puedes reinsertar espacios cada 4 dígitos si lo deseas.
      return masked.replaceAllMapped(
        RegExp(r".{4}"),
        (match) => "${match.group(0)} ",
      );
    }
  }

  // Widget que muestra los datos de la tarjeta.
  // Dentro de _buildCardItem, envuelto en GestureDetector:
  Widget _buildCardItem(Map<String, dynamic> card) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    CardDetailScreen(card: card, correo: widget.correo),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              Animation<Offset> slideAnimation = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              );
              return SlideTransition(position: slideAnimation, child: child);
            },
          ),
        );
      },
      child: Card(
        color:
            card['color'] != null ? Color(card['color']) : Colors.purple[300]!,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card['nombre_tarjeta'] ?? 'Nombre de la Tarjeta',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                maskCardNumber(card['numero_tarjeta'] ?? 'XXXX XXXX XXXX XXXX'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${card['tipo_tarjeta']}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Vence: ${card['fecha_vencimiento']}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCardItem extends StatefulWidget {
  final Widget child;
  final int delay; // Retardo en milisegundos para el efecto en cascada

  const AnimatedCardItem({super.key, required this.child, this.delay = 0});

  @override
  _AnimatedCardItemState createState() => _AnimatedCardItemState();
}

class _AnimatedCardItemState extends State<AnimatedCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  bool _hovering = false; // Controla si el mouse está sobre el widget

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Animación de entrada: desliza la tarjeta desde un 20% abajo a su posición final
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Animación de escalado: desde 0.9 a 1
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MouseRegion para detectar cuando el mouse entra o sale,
    // y AnimatedContainer para animar la traslación vertical.
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (event) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovering ? -20 : 0, 0),
        curve: Curves.easeInOut,
        child: SlideTransition(
          position: _offsetAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
        ),
      ),
    );
  }
}