import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';
import 'package:namer_app/screens/agregar_presupuesto_screen.dart';

import 'package:namer_app/models/gasto.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../main.dart';
import 'agregar_gasto_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _showBudgets = false;
  final _animationDuration = const Duration(milliseconds: 400);
  final _animationCurve = Curves.easeOutQuart;
  final _optionsBackgroundColor = Colors.grey[50]!;
  final _optionsBorderColor = Colors.grey[200]!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PresupuestoProvider>(context, listen: false)
          .verificarPresupuestosVencidos();
    });
  }

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

  Widget _buildMainMenu() {
    final provider = Provider.of<PresupuestoProvider>(context);
    return _buildCardsList(provider);
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_showBudgets ? 'Presupuestos' : 'Menú Principal'),
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

  Widget _buildCardsList(PresupuestoProvider provider) {
    return ListView.builder(
      itemCount: provider.cards.length,
      itemBuilder: (context, index) {
        final card = provider.cards[index];
        final saldo = double.parse(card['amount'] ?? '0');
        final presupuestosCount = provider.presupuestos
            .where((p) => p.tarjetaSeleccionada == card['number'])
            .length;
        final isSelected = provider.selectedCardIndex == index;

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                provider.selectCard(index);
                Future.delayed(const Duration(milliseconds: 50), () {
                  if (mounted) setState(() {});
                });
              },
              child: Container(
                width: double.infinity,
                height: 180,
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(card['color'] ?? 0xFF6200EE).withOpacity(0.8),
                      Color(card['color'] ?? 0xFF6200EE),
                    ],
                  ),
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

                    // Tipo de tarjeta
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Text(
                        card['type']?.toUpperCase() ?? 'TARJETA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Número de tarjeta
                    Positioned(
                      top: 80,
                      left: 20,
                      right: 20,
                      child: Text(
                        '•••• •••• •••• ${card['number']?.substring(12) ?? '••••'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 2,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),

                    // Nombre y detalles
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card['name']?.toUpperCase() ?? 'NOMBRE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Saldo: \$${saldo.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: saldo >= 0 ? Colors.green[200] : Colors.red[200],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Presupuestos: $presupuestosCount',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              AnimatedSwitcher(
                duration: _animationDuration,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: _animationCurve,
                    ),
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: 1.0,
                      child: child,
                    ),
                  );
                },
                child: _buildCardOptions(provider, card),
              ),
          ],
        ).animate(
          delay: Duration(milliseconds: index * 50),
        ).fadeIn(duration: 500.ms).slideX(
          begin: 0.1,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  Widget _buildCardOptions(PresupuestoProvider provider, Map<String, dynamic> card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedSize(
        duration: _animationDuration,
        curve: _animationCurve,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: _optionsBackgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: _optionsBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Presupuestos',
                      icon: Icons.calculate,
                      color: Colors.deepPurple[400]!,
                      onPressed: () {
                        provider.setSelectedCardNumber(card['number']);
                        setState(() => _showBudgets = true);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Gastos',
                      icon: Icons.money_off,
                      color: Colors.red[400]!,
                      onPressed: () => _showExpensesForCard(card['number']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Alertas',
                      icon: Icons.notifications,
                      color: Colors.amber[600]!,
                      onPressed: () => _showComingSoon(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Reportes',
                      icon: Icons.bar_chart,
                      color: Colors.teal[400]!,
                      onPressed: () => _showComingSoon(context),
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

  Widget _buildOptionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color.withOpacity(0.2)),
        foregroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return color.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showExpensesForCard(String cardNumber) {
    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    final card = provider.cards.firstWhere(
          (c) => c['number'] == cardNumber,
      orElse: () => {'name': 'Tarjeta desconocida'},
    );

    final gastos = provider.gastosPorTarjeta(cardNumber);
    final totalGastos = gastos.fold(0.0, (sum, g) => sum + g.monto);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Text(
              'Gastos - ${card['name']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Total: \$${totalGastos.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Divider(),
            Expanded(
              child: gastos.isEmpty
                  ? _buildEmptyGastos()
                  : ListView.builder(
                itemCount: gastos.length,
                itemBuilder: (ctx, index) => _buildGastoItem(gastos[index]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _navigateToAddGasto(cardNumber),
              child: const Text('AGREGAR GASTO'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGastos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.money_off, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay gastos registrados',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGastoItem(Gasto gasto) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.money_off, color: Colors.red),
        title: Text(gasto.nombre),
        subtitle: Text(
          '${gasto.fecha.day}/${gasto.fecha.month}/${gasto.fecha.year} - ${gasto.categoria}',
        ),
        trailing: Text(
          '-\$${gasto.monto.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _navigateToAddGasto(String cardNumber) {
    Navigator.pop(context); // Cierra el bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarGastoScreen(tarjetaSeleccionada: cardNumber),
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
          MaterialPageRoute(
            builder: (ctx) => AgregarPresupuestoScreen(
              tarjetaPreseleccionada: Provider.of<PresupuestoProvider>(context, listen: false)
                  .selectedCardNumber,
            ),
          ),
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
  final _animationDuration = const Duration(milliseconds: 400);
  final _animationCurve = Curves.easeOutQuart;
  final _optionsBackgroundColor = Colors.grey[50]!;
  final _optionsBorderColor = Colors.grey[200]!;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
        body: SingleChildScrollView( // Añade esto como contenedor principal
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _showBudgets ? _buildBudgetView() : _buildMainMenu(),
          ),
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    final provider = Provider.of<PresupuestoProvider>(context);
    return _buildCardsList(provider);
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

  Widget _buildCardsList(PresupuestoProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(provider.cards.length, (index) {
          final card = provider.cards[index];
          final saldo = double.tryParse(card['amount']?.toString() ?? '0') ?? 0;
          final presupuestosCount = provider.presupuestos
              .where((p) => p.tarjetaSeleccionada == card['number'])
              .length;
          final isSelected = provider.selectedCardIndex == index;

          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  provider.selectCard(index);
                  setState(() {});
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(card['color'] ?? Colors.deepPurpleAccent).withOpacity(0.8),
                        Color(card['color'] ?? Colors.deepPurpleAccent),
                      ],
                    ),
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

                      // Tipo de tarjeta
                      Positioned(
                        top: 20,
                        right: 20,
                        child: _buildCardTypeIcon(card['type']),
                      ),

                      // Contenido principal
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['name']?.toString().toUpperCase() ?? 'TARJETA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Saldo: \$${saldo.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: saldo >= 0 ? Colors.green[200] : Colors.red[200],
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '•••• •••• •••• ${card['number']?.toString().substring(12) ?? '••••'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                fontFamily: 'Courier',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Presupuestos: $presupuestosCount',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isSelected)
                _buildCardOptions(provider, card),
            ],
          ).animate(
            delay: Duration(milliseconds: index * 50),
          ).fadeIn(duration: 500.ms).slideY(
            begin: 0.1,
            curve: Curves.easeOutCubic,
          );
        }),
      ),
    );
  }

  Widget _buildCardTypeIcon(String? cardType) {
    switch (cardType?.toLowerCase()) {
      case 'visa':
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
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

  Widget _buildCardOptions(PresupuestoProvider provider, Map<String, dynamic> card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedSize(
        duration: _animationDuration,
        curve: _animationCurve,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: _optionsBackgroundColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: _optionsBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Presupuestos',
                      icon: Icons.calculate,
                      color: Colors.deepPurple[400]!,
                      onPressed: () {
                        // 1. Establece la tarjeta seleccionada
                        provider.setSelectedCardNumber(card['number']);
                        // 2. Navega a la pantalla de agregar presupuesto
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgregarPresupuestoScreen(
                              tarjetaPreseleccionada: card['number'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Gastos',
                      icon: Icons.money_off,
                      color: Colors.red[400]!,
                      //onPressed: () => _showExpensesForCard(card['number']),
                      onPressed: () => _showComingSoonDialog(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Alertas',
                      icon: Icons.notifications,
                      color: Colors.amber[600]!,
                      onPressed: () => _showComingSoonDialog(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOptionButton(
                      text: 'Reportes',
                      icon: Icons.bar_chart,
                      color: Colors.teal[400]!,
                      onPressed: () => _showComingSoonDialog(context),
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



  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top,
                  size: 50,
                  color: Colors.deepPurpleAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Próximamente",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Estamos trabajando en esta funcionalidad y estará disponible pronto.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Entendido"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color.withOpacity(0.2)),
        foregroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return color.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaEstiloNuevo(Map<String, dynamic> card) {
    final color = Color(card['color'] ?? 0xFF6200EE);
    final saldo = double.parse(card['amount'] ?? '0');

    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color],
        ),
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
            child: Text(
              card['type']?.toUpperCase() ?? 'TARJETA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Número de tarjeta (últimos 4 dígitos)
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Text(
              '•••• •••• •••• ${card['number']?.substring(12) ?? '••••'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
                fontFamily: 'Courier',
              ),
            ),
          ),

          // Nombre y saldo
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['name']?.toUpperCase() ?? 'NOMBRE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saldo: \$${saldo.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: saldo >= 0 ? Colors.green[200] : Colors.red[200],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExpensesForCard(String cardNumber) {
    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    final card = provider.cards.firstWhere(
          (c) => c['number'] == cardNumber,
      orElse: () => {'name': 'Tarjeta desconocida'},
    );

    final gastos = provider.presupuestos
        .where((p) => p.tarjetaSeleccionada == cardNumber)
        .toList();

    final totalGastos = gastos.fold(0.0, (sum, p) => sum + p.cantidad);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Gastos - ${card['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (gastos.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No hay gastos registrados para esta tarjeta',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL GASTOS:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${totalGastos.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                fontSize: 16,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: gastos.length,
                        itemBuilder: (context, index) {
                          final gasto = gastos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(Icons.money_off,
                                  color: Colors.red[400]),
                              title: Text(gasto.nombre),
                              subtitle: Text(
                                  '${gasto.fechaPago.toLocal().toString().split(' ')[0]}'),
                              trailing: Text(
                                  '\$${gasto.cantidad.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
          MaterialPageRoute(
            builder: (ctx) => AgregarPresupuestoScreen(
              tarjetaPreseleccionada: Provider.of<PresupuestoProvider>(context, listen: false)
                  .selectedCardNumber,
            ),
          ),
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
}*/



/*import 'package:flutter/material.dart';
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

  Widget _buildMainMenu() {
    final provider = Provider.of<PresupuestoProvider>(context);
    return _buildCardsList(provider); // Simplemente retorna la lista de tarjetas
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



  Widget _buildCardsList(PresupuestoProvider provider) {
    return ListView.builder(
      itemCount: provider.cards.length,
      itemBuilder: (context, index) {
        final card = provider.cards[index];
        final saldo = double.parse(card['amount'] ?? '0');
        final presupuestosCount = provider.presupuestos
            .where((p) => p.tarjetaSeleccionada == card['number'])
            .length;
        final isSelected = provider.selectedCardIndex == index;

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                provider.selectCard(index);
              },
              child: Card(
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
                ),
              ),
            ),
            if (isSelected) _buildCardOptions(provider, card),
          ],
        ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.5);
      },
    );
  }

  Widget _buildCardOptions(PresupuestoProvider provider, Map<String, dynamic> card) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          _buildOptionButton(
            text: 'GESTIÓN DE PRESUPUESTOS',
            icon: Icons.calculate,
            onPressed: () {
              provider.setSelectedCardNumber(card['number']);
              setState(() => _showBudgets = true);
            },
          ),
          const SizedBox(height: 8),
          _buildOptionButton(
            text: 'GASTOS',
            icon: Icons.money_off,
            onPressed: () => _showExpensesForCard(card['number']),
          ),
          const SizedBox(height: 8),
          _buildOptionButton(
            text: 'ALERTAS Y NOTIFICACIONES',
            icon: Icons.notifications,
            onPressed: () => _showComingSoon(context),
          ),
          const SizedBox(height: 8),
          _buildOptionButton(
            text: 'REPORTES Y ESTADÍSTICAS',
            icon: Icons.bar_chart,
            onPressed: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showExpensesForCard(String cardNumber) {
    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    final card = provider.cards.firstWhere(
          (c) => c['number'] == cardNumber,
      orElse: () => {'name': 'Tarjeta desconocida'},
    );

    final gastos = provider.presupuestos
        .where((p) => p.tarjetaSeleccionada == cardNumber)
        .toList();

    final totalGastos = gastos.fold(0.0, (sum, p) => sum + p.cantidad);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Gastos - ${card['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (gastos.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No hay gastos registrados para esta tarjeta',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL GASTOS:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${totalGastos.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                fontSize: 16,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: gastos.length,
                        itemBuilder: (context, index) {
                          final gasto = gastos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(Icons.money_off,
                                  color: Colors.red[400]),
                              title: Text(gasto.nombre),
                              subtitle: Text(
                                  '${gasto.fechaPago.toLocal().toString().split(' ')[0]}'),
                              trailing: Text(
                                  '\$${gasto.cantidad.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
}*/

