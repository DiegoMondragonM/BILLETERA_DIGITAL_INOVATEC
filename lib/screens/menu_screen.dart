import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';
import 'package:namer_app/screens/agregar_presupuesto_screen.dart';

import 'package:flutter_animate/flutter_animate.dart';

import '../main.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _showBudgets = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showBudgets) {
          setState(() => _showBudgets = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _showBudgets ? _buildBudgetView() : _buildMainMenu(),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Menú Principal'),
      backgroundColor: Colors.deepPurpleAccent,
      leading: _showBudgets
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => setState(() => _showBudgets = false),
      )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.credit_card),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCardScreen()),
          ),
          tooltip: 'Agregar tarjeta',
        ),
      ],
    );
  }

  Widget _buildMainMenu() {
    final provider = Provider.of<PresupuestoProvider>(context);
    return Column(
      children: [
        Expanded(
          child: _buildCardsList(provider),
        ),
        _buildMainButtons(),
      ],
    );
  }

  Widget _buildCardsList(PresupuestoProvider provider) {
    return ListView.builder(
      itemCount: provider.cards.length,
      itemBuilder: (context, index) {
        final card = provider.cards[index];
        final saldo = double.parse(card['amount'] ?? '0');
        final presupuestosCount = provider.presupuestos
            .where((p) => p.tarjetaSeleccionada == card['number'])
            .length;

        return Card(
          margin: const EdgeInsets.all(8.0),
          color: Color(card['color'] ?? 0xFF6200EE),
          child: ListTile(
            title: Text(
              card['name'] ?? 'Sin nombre',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•••• ${card['number']?.substring(15) ?? ''}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saldo: \$${saldo.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: saldo >= 0 ? Colors.green[200] : Colors.red[200],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Presupuestos: $presupuestosCount',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card['type'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(Icons.credit_card, color: Colors.white),
              ],
            ),
            onTap: () {
              // Mostrar detalles de la tarjeta
              _showCardDetails(context, card);
            },
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5);
      },
    );
  }

  Widget _buildMainButtons() {
    return Column(
      children: [
        _buildMenuButton(
          text: 'GESTIÓN DE PRESUPUESTOS',
          icon: Icons.calculate,
          onPressed: () => setState(() => _showBudgets = true),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          text: 'ALERTAS Y NOTIFICACIONES',
          icon: Icons.notifications,
          onPressed: () => _showComingSoon(context),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          text: 'REPORTES Y ESTADÍSTICAS',
          icon: Icons.bar_chart,
          onPressed: () => _showComingSoon(context),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBudgetView() {
    final provider = Provider.of<PresupuestoProvider>(context);
    return Column(
      children: [
        Expanded(child: _buildBudgetsList(provider)),
        _buildAddBudgetButton(),
        _buildTotalBudget(provider),
      ],
    );
  }

  Widget _buildBudgetsList(PresupuestoProvider provider) {
    if (provider.presupuestos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay presupuestos registrados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primer presupuesto',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.presupuestos.length,
      itemBuilder: (ctx, index) {
        final presupuesto = provider.presupuestos[index];
        final tarjeta = provider.cards.firstWhere(
              (t) => t['number'] == presupuesto.tarjetaSeleccionada,
          orElse: () => {'name': 'Tarjeta no encontrada', 'color': 0xFF6200EE},
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            leading: Container(
              width: 8,
              decoration: BoxDecoration(
                color: Color(tarjeta['color']),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(
              presupuesto.nombre,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '\$${presupuesto.cantidad.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 15.0),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      presupuesto.fechaPago.toLocal().toString().split(' ')[0],
                      style: const TextStyle(fontSize: 13.0),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.credit_card, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tarjeta['name'],
                        style: const TextStyle(fontSize: 13.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteBudget(context, provider, index),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5);
      },
    );
  }

  Widget _buildAddBudgetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const AgregarPresupuestoScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('AGREGAR PRESUPUESTO'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBudget(PresupuestoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL PRESUPUESTOS:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            '\$${provider.calcularTotal().toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  void _showCardDetails(BuildContext context, Map<String, dynamic> card) {
    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    final saldo = double.parse(card['amount'] ?? '0');
    final presupuestos = provider.presupuestosPorTarjeta(card['number'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(card['name'] ?? 'Detalles de tarjeta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•••• •••• •••• ${card['number']?.substring(15) ?? ''}'),
            const SizedBox(height: 12),
            Text('Tipo: ${card['type'] ?? 'No especificado'}'),
            Text('Vencimiento: ${card['expiryDate'] ?? 'No especificado'}'),
            const SizedBox(height: 12),
            Text(
              'Saldo disponible: \$${saldo.toStringAsFixed(2)}',
              style: TextStyle(
                color: saldo >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Presupuestos asociados: ${presupuestos.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, PresupuestoProvider provider, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: const Text('¿Estás seguro de eliminar este presupuesto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              provider.eliminarPresupuesto(index);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Presupuesto eliminado')),
              );
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Próximamente'),
        content: const Text('Esta funcionalidad estará disponible en la próxima actualización.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ENTENDIDO'),
          ),
        ],
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
}*/



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

