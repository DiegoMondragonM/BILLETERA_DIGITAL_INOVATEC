// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '/screens/agregar_presupuesto_screen.dart';
import '/models/presupuesto.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Presupuesto> presupuestos = [];

  void _agregarPresupuesto(
    String nombre,
    double cantidad,
    DateTime fechaPago,
    String tarjetaSeleccionada,
  ) {
    setState(() {
      presupuestos.add(
        Presupuesto(
          nombre: nombre,
          cantidad: cantidad,
          fechaPago: fechaPago,
          tarjetaSeleccionada: tarjetaSeleccionada, // Añade este campo
        ),
      );
    });
  }

  void _calcularTotal() {
    double total = 0;
    for (var presupuesto in presupuestos) {
      total += presupuesto.cantidad;
    }
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Total de Presupuestos'),
            content: Text(
              'El total de presupuestos es: \$${total.toStringAsFixed(2)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _eliminarPresupuesto(int index) {
    setState(() {
      presupuestos.removeAt(index);
    });
  }

  void _limpiarPresupuestos() {
    setState(() {
      presupuestos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestor de Presupuestos')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: presupuestos.length,
              itemBuilder:
                  (ctx, index) => ListTile(
                    title: Text(presupuestos[index].nombre),
                    subtitle: Text(
                      'Cantidad: \$${presupuestos[index].cantidad.toStringAsFixed(2)} - Fecha: ${presupuestos[index].fechaPago.toLocal().toString().split(' ')[0]} - Tarjeta: ${presupuestos[index].tarjetaSeleccionada}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _eliminarPresupuesto(index),
                    ),
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (ctx) => AgregarPresupuestoScreen(
                        onAgregarPresupuesto: _agregarPresupuesto,
                      ),
                ),
              );
            },
            child: Text('Agregar Presupuesto'),
          ),
          ElevatedButton(
            onPressed: _calcularTotal,
            child: Text('Calcular Total'),
          ),
          ElevatedButton(
            onPressed: _limpiarPresupuestos,
            child: Text('Limpiar Todos los Presupuestos'),
          ),
        ],
      ),
    );
  }
}
