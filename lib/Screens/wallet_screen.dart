import 'package:flutter/material.dart';
import '../Widgets/animated_card.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<String> userCards = []; // Lista de tarjetas registradas
  bool hasProfilePicture = false; // True si el usuario tiene foto de perfil
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
              _buildUserProfile(),
              SizedBox(height: 20.0),
              Expanded(
                child:
                    userCards.isEmpty
                        ? _buildNoCardsSection()
                        : _buildCardStack(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.0,
            backgroundImage:
                hasProfilePicture ? NetworkImage(userProfilePicUrl) : null,
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
            top: i * 10.0,
            child: GestureDetector(
              onTap: () {
                // Lógica para seleccionar la tarjeta o ver detalles
              },
              child: AnimatedCard(index: i, cardInfo: userCards[i]),
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
            child: Text('Agregar Tarjeta', style: TextStyle(fontSize: 16.0)),
          ),
        ),
      ],
    );
  }

  void _addNewCard() {
    setState(() {
      userCards.add('Tarjeta ${userCards.length + 1}');
    });
  }
}
