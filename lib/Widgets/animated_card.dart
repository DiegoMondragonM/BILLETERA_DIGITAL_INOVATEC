import 'package:flutter/material.dart';

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
