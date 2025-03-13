import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddCardScreen(),
    );
  }
}


class LoginScreen extends StatefulWidget {
  @override
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
                  Icon(
                    Icons.account_circle,
                    color: Colors.black,
                    size: 100.0,
                  ),
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
                          _obscureText ? Icons.visibility : Icons.visibility_off,
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE510B3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
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
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    _buildTextField(Icons.person, 'Ingresa tu nombre(s)'),
                    SizedBox(height: 10.0),
                    _buildTextField(Icons.person, 'Ingresa tu apellido paterno'),
                    SizedBox(height: 10.0),
                    _buildTextField(Icons.person, 'Ingresa tu apellido materno'),
                    SizedBox(height: 10.0),
                    _buildTextField(Icons.email, 'Ingresa tu correo electrónico'),
                    SizedBox(height: 10.0),
                    // Campo de contraseña con botón para mostrar u ocultar
                    _buildPasswordField(Icons.lock, 'Ingresa tu contraseña', _obscurePassword, () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    }),
                    SizedBox(height: 10.0),
                    // Campo de confirmar contraseña con botón para mostrar u ocultar
                    _buildPasswordField(Icons.lock, 'Confirma tu contraseña', _obscureConfirmPassword, () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    }),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE510B3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
                      ),
                      child: Text(
                        'CREAR CUENTA',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
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

  Widget _buildTextField(IconData icon, String hintText, {bool obscureText = false}) {
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

  Widget _buildPasswordField(IconData icon, String hintText, bool obscureText, VoidCallback toggleVisibility) {
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
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
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
                child: userCards.isEmpty
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
            backgroundImage: hasProfilePicture
                ? NetworkImage(userProfilePicUrl) // Imagen del usuario
                : null, // Icono por defecto
            backgroundColor: Colors.grey[200],
            child: hasProfilePicture
                ? null
                : Icon(Icons.account_circle, size: 100, color: Colors.white),
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
            onPressed: _addNewCard, // Llamar a la función para agregar una tarjeta
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text(
              'Agregar Tarjeta',
              style: TextStyle(fontSize: 16.0),
            ),
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
              child: AnimatedCard(index: i, cardInfo: userCards[i]), // Tarjeta animada
            ),
          ),
        Positioned(
          bottom: 20.0,
          child: ElevatedButton(
            onPressed: _addNewCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text(
              'Agregar Tarjeta',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ],
    );
  }

  // Método para agregar una nueva tarjeta (actualiza el estado)
  void _addNewCard() {
    setState(() {
      userCards.add('Tarjeta ${userCards.length + 1}');
    });
  }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  String cardType = 'Visa';
  Color cardColor = Colors.purple[300]!; // Color por defecto de la tarjeta

  // Lista de colores para seleccionar
  List<Color> availableColors = [
    Colors.purple[300]!,
    Colors.blue[300]!,
    Colors.green[300]!,
    Colors.orange[300]!,
    Colors.red[300]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Tarjeta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),

              // Tarjeta vista previa
              _buildCardPreview(),

              SizedBox(height: 20.0),

              // Formulario de registro de tarjeta
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Nombre de la Tarjeta',
                      hintText: 'Ejemplo: Mi Tarjeta Personal',
                    ),
                    SizedBox(height: 20.0),
                    _buildTextField(
                      controller: numberController,
                      label: 'Número de la Tarjeta',
                      hintText: 'XXXX XXXX XXXX XXXX',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.0),
                    _buildCardTypeField(),
                    SizedBox(height: 20.0),
                    _buildTextField(
                      controller: amountController,
                      label: 'Monto de la Tarjeta',
                      hintText: '\$0.00',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.0),
                    _buildTextField(
                      controller: expiryDateController,
                      label: 'Fecha de Vencimiento (MM/AAAA)',
                      hintText: 'MM/AAAA',
                    ),
                    SizedBox(height: 20.0),

                    // Selector de color de la tarjeta
                    _buildColorPicker(),

                    SizedBox(height: 40.0),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista previa de la tarjeta que se está registrando
  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor, // Color seleccionado
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameController.text.isNotEmpty
                ? nameController.text
                : 'Nombre de la Tarjeta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            numberController.text.isNotEmpty
                ? numberController.text
                : 'XXXX XXXX XXXX XXXX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Tipo: $cardType',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            expiryDateController.text.isNotEmpty
                ? expiryDateController.text
                : 'MM/AAAA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  // Campo de texto general
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {}); // Para actualizar la vista previa de la tarjeta
      },
    );
  }

  // Campo de tipo de tarjeta (Visa, Mastercard o American Express)
  Widget _buildCardTypeField() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
            title: Text('Visa'),
            value: 'Visa',
            groupValue: cardType,
            onChanged: (value) {
              setState(() {
                cardType = value.toString();
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: Text('Mastercard'),
            value: 'Mastercard',
            groupValue: cardType,
            onChanged: (value) {
              setState(() {
                cardType = value.toString();
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: Text('American Express'),
            value: 'American Express',
            groupValue: cardType,
            onChanged: (value) {
              setState(() {
                cardType = value.toString();
              });
            },
          ),
        ),
      ],
    );
  }

  // Selector de color de tarjeta
  Widget _buildColorPicker() {
    return Row(
      children: availableColors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              cardColor = color; // Actualizar el color de la tarjeta
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: cardColor == color ? Colors.black : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Botón para guardar la tarjeta
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Guardar tarjeta y regresar a la pantalla principal
          Navigator.pop(context, {
            'name': nameController.text,
            'number': numberController.text,
            'type': cardType,
            'amount': amountController.text,
            'expiryDate': expiryDateController.text,
            'color': cardColor.value, // Guardar color de tarjeta
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
      ),
      child: Text(
        'Guardar Tarjeta',
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}
