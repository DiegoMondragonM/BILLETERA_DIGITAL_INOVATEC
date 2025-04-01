import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screens/agregar_presupuesto_screen.dart';
import '/providers/presupuesto_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _calcularTotal(BuildContext context) {
    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    final total = provider.calcularTotal();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Total de Presupuestos'),
        content: Text(
          'El total de presupuestos es: \$${total.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarPresupuesto(BuildContext context, int index) async {
    try {
      await Provider.of<PresupuestoProvider>(context, listen: false)
          .eliminarPresupuesto(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
      );
    }
  }

  Future<void> _limpiarPresupuestos(BuildContext context) async {
    try {
      final provider = Provider.of<PresupuestoProvider>(context, listen: false);
      // Llamamos a un método del provider en lugar de manipular directamente los datos
      await provider.limpiarPresupuestos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al limpiar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final presupuestos = Provider.of<PresupuestoProvider>(context).presupuestos;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de Presupuestos')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: presupuestos.length,
              itemBuilder: (ctx, index) => ListTile(
                title: Text(presupuestos[index].nombre),
                subtitle: Text(
                  'Cantidad: \$${presupuestos[index].cantidad.toStringAsFixed(2)} - '
                      'Fecha: ${presupuestos[index].fechaPago.toLocal().toString().split(' ')[0]} - '
                      'Tarjeta: ${presupuestos[index].tarjetaSeleccionada}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _eliminarPresupuesto(context, index),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const AgregarPresupuestoScreen(),
                ),
              );
            },
            child: const Text('Agregar Presupuesto'),
          ),
          ElevatedButton(
            onPressed: () => _calcularTotal(context),
            child: const Text('Calcular Total'),
          ),
          ElevatedButton(
            onPressed: () => _limpiarPresupuestos(context),
            child: const Text('Limpiar Todos los Presupuestos'),
          ),
        ],
      ),
    );
  }
}



/*// lib/screens/home_screen.dart
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
}*/
