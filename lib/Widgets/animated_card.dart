import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final int index;
  final String cardInfo;
  final Color cardColor; // Nuevo: Color personalizado desde la DB
  final String? cardType; // Nuevo: Tipo de tarjeta (Visa/Mastercard/etc)
  final String? lastDigits; // Nuevo: Últimos 4 dígitos para mayor seguridad

  const AnimatedCard({
    required this.index,
    required this.cardInfo,
    this.cardColor = Colors.deepPurpleAccent, // Valor por defecto
    this.cardType,
    this.lastDigits,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform:
          Matrix4.identity()
            ..translate(0.0, -index * 20.0) // Efecto de apilamiento
            ..rotateZ(
              -index * 0.01,
            ), // Ligera inclinación para efecto más realista
      child: Card(
        elevation: 6,
        margin: EdgeInsets.all(8),
        color: cardColor, // Usa el color personalizado
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 300,
          height: 180,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo según tipo de tarjeta (arriba a la derecha)
              _buildCardLogo(),

              // Nombre de la tarjeta (centrado)
              Center(
                child: Text(
                  cardInfo,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto blanco para mejor contraste
                  ),
                ),
              ),

              // Detalles inferiores
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lastDigits != null)
                    Text(
                      '•••• •••• •••• $lastDigits',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 2.0,
                      ),
                    ),
                  if (cardType != null)
                    Text(
                      cardType!.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardLogo() {
    // Mapeo de tipos de tarjeta a sus respectivos assets
    const cardLogos = {
      'visa': 'assets/images/visa_logo.png',
      'mastercard': 'assets/images/mastercard_logo.png',
      'american express': 'assets/images/amex_logo.png',
    };

    return Align(
      alignment: Alignment.topRight,
      child:
          cardType != null
              ? _buildSafeImage(cardLogos[cardType!.toLowerCase()]!)
              : Icon(Icons.credit_card, color: Colors.white, size: 40),
    );
  }

  // Widget auxiliar para cargar imágenes con manejo de errores
  Widget _buildSafeImage(String imagePath) {
    return Image.asset(
      imagePath,
      width: 60,
      height: 40,
      color: Colors.white,
      errorBuilder: (context, error, stackTrace) {
        //print('Error cargando logo: $error');
        return Icon(Icons.credit_card, color: Colors.white, size: 40);
      },
    );
  }
}
