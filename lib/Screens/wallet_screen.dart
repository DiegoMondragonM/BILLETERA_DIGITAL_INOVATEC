import 'package:flutter/material.dart';
import 'package:namer_app/Screens/add_card_screen.dart';
import 'package:namer_app/Screens/login_screen.dart';
import '../Widgets/animated_card.dart';
import '../Service/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namer_app/Screens/add_budget.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Variables de estado
  List<Map<String, dynamic>> userCards = [];
  bool isLoading = true;
  int _userId = 0;
  String _userEmail = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Paso 1: Cargar ID de usuario primero
  }

  // Carga el ID y email del usuario desde SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
      _userEmail = prefs.getString('userEmail') ?? 'Usuario';
    });

    if (_userId > 0) {
      await _loadCards(); // Paso 2: Cargar tarjetas si hay usuario
    } else {
      setState(() => isLoading = false); // Mostrar UI si no hay usuario
    }
  }

  // Carga las tarjetas del usuario actual
  Future<void> _loadCards() async {
    try {
      setState(() => isLoading = true);

      final dbHelper = DBHelper();
      final cards = await dbHelper.getCards(_userId);

      setState(() {
        userCards = cards;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando tarjetas: $e');
      setState(() => isLoading = false);
    }
  }

  // Cierra la sesión y redirige al login
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billetera'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadCards),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
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
            children: [
              _buildUserProfile(),
              SizedBox(height: 20),
              Expanded(
                child:
                    isLoading
                        ? _buildLoadingIndicator()
                        : userCards.isEmpty
                        ? _buildNoCardsSection()
                        : _buildCardStack(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Widgets de la interfaz
  // -------------------------

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Column(
      children: [
        CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        SizedBox(height: 10),
        Text(_userEmail, style: TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }

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
            onPressed: _addNewCard,
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

  Widget _buildCardStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < userCards.length; i++)
          Positioned(
            top: i * 10,
            child: GestureDetector(
              onTap: () => _showCardDetails(userCards[i]),
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  // Swipe hacia arriba
                  _sendCardToBack();
                }
              },
              child: AnimatedCard(
                index: i,
                cardInfo: userCards[i]['name'],
                cardColor: Color(userCards[i]['color']),
                cardType: userCards[i]['type'],
                onMenuPressed: () => _showCardOptions(userCards[i]),
              ),
            ),
          ),

        // Botón flotante
        Positioned(
          bottom: 20,
          child: ElevatedButton(
            onPressed: _addNewCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text('Agregar Tarjeta'),
          ),
        ),
      ],
    );
  }

  // -------------------------
  // Lógica adicional
  // -------------------------

  Future<void> _addNewCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCardScreen()),
    );

    if (result == true) {
      await _loadCards();
    }
  }

  void _showCardDetails(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(card['name']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Número: ${card['number']}'),
                Text('Tipo: ${card['type']}'),
                Text('Saldo: ${card['amount']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  void _sendCardToBack() {
    if (userCards.isNotEmpty) {
      setState(() {
        // Crear una copia de la lista para que sea mutable
        userCards = List<Map<String, dynamic>>.from(userCards);

        // Tomar la primera tarjeta y enviarla al final
        var firstCard = userCards.removeAt(0);
        userCards.add(firstCard);
      });
    }
  }

  void _showCardOptions(Map<String, dynamic> card) async {
    // Obtener el userId de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.add_shopping_cart),
                title: Text('Agregar Gasto'),
                onTap: () {
                  Navigator.pop(context);
                  //_addExpenseToCard(card);
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Agregar Presupuesto'),
                onTap: () {
                  Navigator.pop(context); // Cierra el bottom sheet
                  _navigateToAddBudget(
                    cardNumber: card['number'] as String,
                    userId: userId,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.analytics),
                title: Text('Ver Reportes'),
                onTap: () {
                  Navigator.pop(context);
                  //_showCardReports(card);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Nuevo método para navegar a la pantalla de presupuesto
  void _navigateToAddBudget({required String cardNumber, required int userId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddBudget(tarjetaPreseleccionada: cardNumber, userId: userId),
      ),
    ).then((saved) {
      if (saved == true) {
        _loadCards();
      }
    });
  }
}
