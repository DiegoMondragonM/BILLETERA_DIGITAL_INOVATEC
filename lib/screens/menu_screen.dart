import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';
import 'package:namer_app/screens/agregar_presupuesto_screen.dart';
import 'package:namer_app/models/presupuesto.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Para animaciones

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _mostrarPresupuestos =
      false; // Controla si se muestran los presupuestos y el botón

  @override
  Widget build(BuildContext context) {
    final presupuestoProvider = Provider.of<PresupuestoProvider>(context);
    final presupuestos = presupuestoProvider.presupuestos;
    final cards = presupuestoProvider.cards; // Obtener la lista de tarjetas

    return WillPopScope(
      onWillPop: () async {
        // Si _mostrarPresupuestos es true, lo cambiamos a false y evitamos que la pantalla se cierre
        if (_mostrarPresupuestos) {
          setState(() {
            _mostrarPresupuestos = false;
          });
          return false; // Evita que la pantalla se cierre
        }
        return true; // Permite que la pantalla se cierre
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Menú Principal'),
          backgroundColor: Colors.deepPurpleAccent,
          leading:
              _mostrarPresupuestos
                  ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _mostrarPresupuestos = false;
                      });
                    },
                  )
                  : null,
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Navegar a AddCardScreen para agregar una nueva tarjeta
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardScreen()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Lista de tarjetas registradas (solo se muestra si _mostrarPresupuestos es false)
              if (!_mostrarPresupuestos)
                Expanded(
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        color: Color(
                          card['color'],
                        ), // Color de fondo de la tarjeta
                        child: ListTile(
                          title: Text(
                            card['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Número: ${card['number']}\nTipo: ${card['type']}\nMonto: \$${card['amount']}\nVencimiento: ${card['expiryDate']}',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(
                            Icons.credit_card,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5);
                    },
                  ),
                ),

              // Lista de presupuestos (visible cuando _mostrarPresupuestos es true)
              if (_mostrarPresupuestos)
                Expanded(
                  child: ListView.builder(
                    itemCount: presupuestos.length,
                    itemBuilder: (ctx, index) {
                      final presupuesto = presupuestos[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            presupuesto.nombre,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cantidad: \$${presupuesto.cantidad.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Text(
                                'Fecha: ${presupuesto.fechaPago.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Text(
                                'Tarjeta: ${presupuesto.tarjetaSeleccionada}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.deepPurpleAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => presupuestoProvider.eliminarPresupuesto(
                                  index,
                                ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5);
                    },
                  ),
                ),

              // Botón para agregar un nuevo presupuesto (visible cuando _mostrarPresupuestos es true)
              if (_mostrarPresupuestos)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (ctx) => AgregarPresupuestoScreen(
                              onAgregarPresupuesto: (
                                nombre,
                                cantidad,
                                fechaPago,
                                tarjetaSeleccionada,
                              ) {
                                final presupuestoProvider =
                                    Provider.of<PresupuestoProvider>(
                                      context,
                                      listen: false,
                                    );
                                try {
                                  presupuestoProvider.agregarPresupuesto(
                                    Presupuesto(
                                      nombre: nombre,
                                      cantidad: cantidad,
                                      fechaPago: fechaPago,
                                      tarjetaSeleccionada: tarjetaSeleccionada,
                                    ),
                                    tarjetaSeleccionada,
                                  );
                                } catch (e) {
                                  // Mostrar un mensaje de error si el saldo es insuficiente
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                            ),
                      ),
                    );
                  },
                  child: Text('Agregar Presupuesto'),
                ),

              // Total de presupuestos (visible cuando _mostrarPresupuestos es true)
              if (_mostrarPresupuestos)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(
                    'Total de Presupuestos: \$${presupuestoProvider.calcularTotal().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Botones principales (solo se muestran si _mostrarPresupuestos es false)
              if (!_mostrarPresupuestos) ...[
                SizedBox(height: 20),
                // Botón 1: CALCULO DE SALDOS
                ElevatedButton(
                  onPressed: () {
                    // Mostrar/ocultar la lista de presupuestos y el botón "Agregar Presupuesto"
                    setState(() {
                      _mostrarPresupuestos = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'CALCULO DE SALDOS',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 20),
                // Botón 2: ALERTA DE PRESUPUESTOS
                ElevatedButton(
                  onPressed: () {
                    print("Botón 2 presionado");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'ALERTA DE PRESUPUESTOS',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 20),
                // Botón 3: GENERADOR DE REPORTES
                ElevatedButton(
                  onPressed: () {
                    print("Botón 3 presionado");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'GENERADOR DE REPORTES',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';
import 'package:namer_app/screens/agregar_presupuesto_screen.dart';
import 'package:namer_app/models/presupuesto.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Para animaciones

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _mostrarPresupuestos =
      false; // Controla si se muestran los presupuestos y el botón

  @override
  Widget build(BuildContext context) {
    final presupuestoProvider = Provider.of<PresupuestoProvider>(context);
    final presupuestos = presupuestoProvider.presupuestos;
    final cards = presupuestoProvider.cards; // Obtener la lista de tarjetas

    return WillPopScope(
      onWillPop: () async {
        // Si _mostrarPresupuestos es true, lo cambiamos a false y evitamos que la pantalla se cierre
        if (_mostrarPresupuestos) {
          setState(() {
            _mostrarPresupuestos = false;
          });
          return false; // Evita que la pantalla se cierre
        }
        return true; // Permite que la pantalla se cierre
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Menú Principal'),
          backgroundColor: Colors.deepPurpleAccent,
          leading:
              _mostrarPresupuestos
                  ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _mostrarPresupuestos = false;
                      });
                    },
                  )
                  : null,
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Navegar a AddCardScreen para agregar una nueva tarjeta
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardScreen()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Lista de tarjetas registradas (solo se muestra si _mostrarPresupuestos es false)
              if (!_mostrarPresupuestos)
                Expanded(
                  child: ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        color: Color(
                          card['color'],
                        ), // Color de fondo de la tarjeta
                        child: ListTile(
                          title: Text(
                            card['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Número: ${card['number']}\nTipo: ${card['type']}\nMonto: \$${card['amount']}\nVencimiento: ${card['expiryDate']}',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(
                            Icons.credit_card,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5);
                    },
                  ),
                ),

              // Lista de presupuestos (visible cuando _mostrarPresupuestos es true)
              if (_mostrarPresupuestos)
                Expanded(
                  child: ListView.builder(
                    itemCount: presupuestos.length,
                    itemBuilder:
                        (ctx, index) => ListTile(
                          title: Text(presupuestos[index].nombre),
                          subtitle: Text(
                            'Cantidad: \$${presupuestos[index].cantidad.toStringAsFixed(2)} - Fecha: ${presupuestos[index].fechaPago.toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed:
                                () => presupuestoProvider.eliminarPresupuesto(
                                  index,
                                ),
                          ),
                        ),
                  ),
                ),

              // Botón para agregar un nuevo presupuesto (visible cuando _mostrarPresupuestos es true)
              if (_mostrarPresupuestos)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (ctx) => AgregarPresupuestoScreen(
                              onAgregarPresupuesto: (
                                nombre,
                                cantidad,
                                fechaPago,
                                tarjetaSeleccionada,
                              ) {
                                final presupuestoProvider =
                                    Provider.of<PresupuestoProvider>(
                                      context,
                                      listen: false,
                                    );
                                try {
                                  presupuestoProvider.agregarPresupuesto(
                                    Presupuesto(
                                      nombre: nombre,
                                      cantidad: cantidad,
                                      fechaPago: fechaPago,
                                      tarjetaSeleccionada: tarjetaSeleccionada,
                                    ),
                                    tarjetaSeleccionada,
                                  );
                                } catch (e) {
                                  // Mostrar un mensaje de error si el saldo es insuficiente
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                            ),
                      ),
                    );
                  },
                  child: Text('Agregar Presupuesto'),
                ),

              // Total de presupuestos (visible cuando _mostrarPresupuestos es true)
              if (_mostrarPresupuestos)
                Text(
                  'Total de Presupuestos: \$${presupuestoProvider.calcularTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

              // Botones principales (solo se muestran si _mostrarPresupuestos es false)
              if (!_mostrarPresupuestos) ...[
                SizedBox(height: 20),
                // Botón 1: CALCULO DE SALDOS
                ElevatedButton(
                  onPressed: () {
                    // Mostrar/ocultar la lista de presupuestos y el botón "Agregar Presupuesto"
                    setState(() {
                      _mostrarPresupuestos = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'CALCULO DE SALDOS',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 20),
                // Botón 2: ALERTA DE PRESUPUESTOS
                ElevatedButton(
                  onPressed: () {
                    print("Botón 2 presionado");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'ALERTA DE PRESUPUESTOS',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 20),
                // Botón 3: GENERADOR DE REPORTES
                ElevatedButton(
                  onPressed: () {
                    print("Botón 3 presionado");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'GENERADOR DE REPORTES',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}*/

