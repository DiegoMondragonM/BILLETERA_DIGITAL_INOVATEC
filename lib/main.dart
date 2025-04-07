import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';
import 'package:namer_app/screens/menu_screen.dart';

import 'package:provider/provider.dart';

void main() {
  // Forzar el modo de renderizado Canvas (desactiva Impeller/OpenGL)
  debugDefaultTargetPlatformOverride =
      TargetPlatform.fuchsia; // Truco temporal para software rendering
  runApp(
    ChangeNotifierProvider(
      create: (context) => PresupuestoProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WalletScreen(),
      /*AddCardScreen()*/
      // Pantalla inicial es AddCardScreen
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

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
          // Contenedor blanco para el login
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BIENVENIDO :D!',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Icon(Icons.account_circle, color: Colors.black, size: 100.0),
                  SizedBox(height: 20.0),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(Icons.email),
                      hintText: 'Ingresa tu correo electrónico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Campo de contraseña con botón para mostrar u ocultar
                  TextField(
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(Icons.lock),
                      hintText: 'Ingresa tu contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      // Navegar a WalletScreen después del inicio de sesión
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WalletScreen()),
                      );
                    },
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
                      'INICIAR SESIÓN',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      '¿No tienes una cuenta? Ingresa Aquí!',
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
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                    _buildTextField(Icons.person, 'Ingresa tu nombre(s)'),
                    SizedBox(height: 10.0),
                    _buildTextField(
                      Icons.person,
                      'Ingresa tu apellido paterno',
                    ),
                    SizedBox(height: 10.0),
                    _buildTextField(
                      Icons.person,
                      'Ingresa tu apellido materno',
                    ),
                    SizedBox(height: 10.0),
                    _buildTextField(
                      Icons.email,
                      'Ingresa tu correo electrónico',
                    ),
                    SizedBox(height: 10.0),
                    // Campo de contraseña con botón para mostrar u ocultar
                    _buildPasswordField(
                      Icons.lock,
                      'Ingresa tu contraseña',
                      _obscurePassword,
                      () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    SizedBox(height: 10.0),
                    // Campo de confirmar contraseña con botón para mostrar u ocultar
                    _buildPasswordField(
                      Icons.lock,
                      'Confirma tu contraseña',
                      _obscureConfirmPassword,
                      () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {},
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

  Widget _buildTextField(
    IconData icon,
    String hintText, {
    bool obscureText = false,
  }) {
    return TextField(
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
    VoidCallback toggleVisibility,
  ) {
    return TextField(
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

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<String> userCards = []; // Lista que contiene las tarjetas registradas
  bool hasProfilePicture = false; // Cambia a true si el usuario tiene foto
  String userProfilePicUrl = ''; // URL de la foto del usuario (si la tiene)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billetera'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfile(), // Sección de foto o icono de usuario
              SizedBox(height: 20.0),
              Expanded(
                child:
                    userCards.isEmpty
                        ? _buildNoCardsSection() // Mostrar si no hay tarjetas registradas
                        : _buildCardStack(), // Mostrar las tarjetas apiladas si las hay
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la sección del perfil de usuario (con foto o icono por defecto)
  Widget _buildUserProfile() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.0,
            backgroundImage:
                hasProfilePicture
                    ? NetworkImage(userProfilePicUrl) // Imagen del usuario
                    : null, // Icono por defecto
            backgroundColor: Colors.grey[200],
            child:
                hasProfilePicture
                    ? null
                    : Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.white,
                    ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Usuario',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Widget que muestra cuando no hay tarjetas registradas
  Widget _buildNoCardsSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card, size: 100, color: Colors.white),
          SizedBox(height: 20.0),
          Text(
            'No tienes tarjetas registradas',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () {
              // Navegar a AddCardScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCardScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text('Agregar Tarjeta', style: TextStyle(fontSize: 16.0)),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar las tarjetas registradas en forma apilada
  Widget _buildCardStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < userCards.length; i++)
          Positioned(
            top: i * 10.0,
            child: GestureDetector(
              onTap: () {
                // Lógica para seleccionar la tarjeta o ver detalles
              },
              child: AnimatedCard(
                index: i,
                cardInfo: userCards[i],
              ), // Tarjeta animada
            ),
          ),
        Positioned(
          bottom: 20.0,
          child: ElevatedButton(
            onPressed: () {
              // Navegar a AddCardScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCardScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text('Agregar Tarjeta', style: TextStyle(fontSize: 16.0)),
          ),
        ),
      ],
    );
  }

  // Método para agregar una nueva tarjeta (actualiza el estado)
  /*void _addNewCard() {
    setState(() {
      userCards.add('Tarjeta ${userCards.length + 1}');
    });
  }*/
}

// Widget para la tarjeta animada
class AnimatedCard extends StatelessWidget {
  final int index;
  final String cardInfo;

  const AnimatedCard({required this.index, required this.cardInfo});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..translate(0.0, -index * 20.0),
      child: Card(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 300,
          height: 180,
          child: Center(
            child: Text(
              cardInfo,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String _cardType = 'Visa';
  Color _cardColor = Colors.blue[800]!;
  bool _isSaving = false;

  final List<Color> _availableColors = [
    Colors.blue[800]!,    // Azul oscuro para Visa
    Colors.red[800]!,      // Rojo para Mastercard
    Colors.teal[800]!,     // Verde azulado para Amex
    Colors.purple[800]!,   // Morado
    Colors.orange[800]!,   // Naranja
    Colors.indigo[800]!,   // Indigo
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _amountController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final cardData = {
        'name': _nameController.text.trim(),
        'number': _numberController.text.trim(),
        'type': _cardType,
        'amount': _amountController.text.isNotEmpty
            ? double.parse(_amountController.text).toStringAsFixed(2)
            : '0.00',
        'expiryDate': _expiryDateController.text.trim(),
        'color': _cardColor.value,
      };

      await Provider.of<PresupuestoProvider>(context, listen: false)
          .agregarTarjeta(cardData);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Tarjeta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Vista previa de la tarjeta (mejorada)
              _buildRealisticCardPreview(),
              const SizedBox(height: 30),

              // Nombre de la tarjeta
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tarjeta',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Ingresa un nombre para la tarjeta'
                    : null,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Número de tarjeta con formato
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa el número';
                  if (value!.replaceAll(' ', '').length != 16) {
                    return 'Debe tener 16 dígitos';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Tipo de tarjeta (mejorado)
              _buildEnhancedCardTypeSelector(),
              const SizedBox(height: 20),

              // Monto inicial
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto inicial',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: '1000.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa un monto';
                  final amount = double.tryParse(value!);
                  if (amount == null) return 'Monto inválido';
                  if (amount < 0) return 'Debe ser positivo';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Fecha de vencimiento
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Vencimiento (MM/AA)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: 'MM/AA',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardExpiryFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa la fecha';
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                    return 'Formato MM/AA';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 25),

              // Selector de color (mejorado)
              _buildEnhancedColorSelector(),
              const SizedBox(height: 30),

              // Botón de guardar
              ElevatedButton(
                onPressed: _isSaving ? null : _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColorByCardType(),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('GUARDAR TARJETA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealisticCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Chip de tarjeta
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.amber[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Logo del tipo de tarjeta
          Positioned(
            top: 20,
            right: 20,
            child: _buildCardTypeLogo(),
          ),

          // Número de tarjeta
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Text(
              _numberController.text.isEmpty
                  ? '•••• •••• •••• ••••'
                  : _formatCardNumber(_numberController.text),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
                fontFamily: 'Courier',
              ),
            ),
          ),

          // Nombre y fecha
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'NOMBRE DEL TITULAR'
                      : _nameController.text.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _expiryDateController.text.isEmpty
                      ? '••/••'
                      : _expiryDateController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCardTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de tarjeta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: PageView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCardTypeOption('Visa', Icons.credit_card, Colors.blue[800]!),
              _buildCardTypeOption('Mastercard', Icons.credit_card, Colors.red[800]!),
              _buildCardTypeOption('Amex', Icons.credit_card, Colors.teal[800]!),
            ],
            onPageChanged: (index) {
              setState(() {
                _cardType = ['Visa', 'Mastercard', 'Amex'][index];
                _cardColor = _availableColors[index];
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardTypeOption(String type, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _cardType = type;
          _cardColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _cardType == type ? color.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _cardType == type ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la tarjeta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _availableColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              return GestureDetector(
                onTap: () => setState(() => _cardColor = color),
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.8),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _cardColor == color
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _cardColor == color
                      ? const Center(
                      child: Icon(Icons.check, color: Colors.white))
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardTypeLogo() {
    switch (_cardType.toLowerCase()) {
      case 'visa':
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        );
      case 'mastercard':
        return const Text(
          'MasterCard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'amex':
        return const Text(
          'AMEX',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return const Icon(Icons.credit_card, color: Colors.white, size: 30);
    }
  }

  LinearGradient _getCardGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _cardColor.withOpacity(0.8),
        _cardColor,
      ],
    );
  }

  Color _getButtonColorByCardType() {
    switch (_cardType.toLowerCase()) {
      case 'visa':
        return Colors.blue[800]!;
      case 'mastercard':
        return Colors.red[800]!;
      case 'amex':
        return Colors.teal[800]!;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  String _formatCardNumber(String input) {
    final cleaned = input.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) return oldValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}


/*class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String _cardType = 'Visa';
  Color _cardColor = Colors.purple[300]!;
  bool _isSaving = false;

  final List<Color> _availableColors = [
    Colors.purple[300]!,
    Colors.blue[300]!,
    Colors.green[300]!,
    Colors.orange[300]!,
    Colors.red[300]!,
    Colors.teal[300]!,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _amountController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final cardData = {
        'name': _nameController.text.trim(),
        'number': _numberController.text.trim(),
        'type': _cardType,
        'amount': _amountController.text.isNotEmpty
            ? double.parse(_amountController.text).toStringAsFixed(2)
            : '0.00',
        'expiryDate': _expiryDateController.text.trim(),
        'color': _cardColor.value,
      };

      await Provider.of<PresupuestoProvider>(context, listen: false)
          .agregarTarjeta(cardData);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Tarjeta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Vista previa de la tarjeta
              _buildCardPreview(),
              const SizedBox(height: 30),

              // Nombre de la tarjeta
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tarjeta',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Ingresa un nombre para la tarjeta'
                    : null,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Número de tarjeta con formato
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa el número';
                  if (value!.replaceAll(' ', '').length != 16) {
                    return 'Debe tener 16 dígitos';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Tipo de tarjeta
              _buildCardTypeSelector(),
              const SizedBox(height: 20),

              // Monto inicial
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto inicial',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: '1000.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa un monto';
                  final amount = double.tryParse(value!);
                  if (amount == null) return 'Monto inválido';
                  if (amount < 0) return 'Debe ser positivo';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Fecha de vencimiento
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Vencimiento (MM/AA)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: 'MM/AA',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardExpiryFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa la fecha';
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                    return 'Formato MM/AA';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 25),

              // Selector de color
              _buildColorSelector(),
              const SizedBox(height: 30),

              // Botón de guardar
              ElevatedButton(
                onPressed: _isSaving ? null : _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('GUARDAR TARJETA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _cardType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _numberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _formatCardNumber(_numberController.text),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TITULAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _nameController.text.isEmpty
                        ? 'NOMBRE DEL TITULAR'
                        : _nameController.text.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VENCIMIENTO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _expiryDateController.text.isEmpty
                        ? '••/••'
                        : _expiryDateController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de tarjeta',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Visa'),
                selected: _cardType == 'Visa',
                onSelected: (_) => setState(() => _cardType = 'Visa'),
                selectedColor: Colors.deepPurpleAccent,
                labelStyle: TextStyle(
                  color: _cardType == 'Visa' ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Text('Mastercard'),
                selected: _cardType == 'Mastercard',
                onSelected: (_) => setState(() => _cardType = 'Mastercard'),
                selectedColor: Colors.deepPurpleAccent,
                labelStyle: TextStyle(
                  color: _cardType == 'Mastercard' ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Text('Amex'),
                selected: _cardType == 'Amex',
                onSelected: (_) => setState(() => _cardType = 'Amex'),
                selectedColor: Colors.deepPurpleAccent,
                labelStyle: TextStyle(
                  color: _cardType == 'Amex' ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la tarjeta',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _availableColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              return GestureDetector(
                onTap: () => setState(() => _cardColor = color),
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _cardColor == color
                          ? Colors.black
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _cardColor == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatCardNumber(String input) {
    final cleaned = input.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }
}

// Formateador para número de tarjeta (agrega espacios cada 4 dígitos)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) return oldValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Formateador para fecha de vencimiento (MM/AA)
class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}*/


