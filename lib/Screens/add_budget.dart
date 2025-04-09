import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/db_helper.dart';

class AddBudget extends StatefulWidget {
  final String? tarjetaPreseleccionada;
  final int? userId;

  const AddBudget({super.key, this.tarjetaPreseleccionada, this.userId});

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  DateTime _fechaPago = DateTime.now();
  String? _tarjetaSeleccionada;
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _budgets = [];
  final DBHelper _dbHelper = DBHelper();
  bool _isSaving = false;
  bool _isLoadingBudgets = false;

  @override
  void initState() {
    super.initState();
    _loadUserCards();
    _loadBudgets();
  }

  Future<void> _loadUserCards() async {
    if (widget.userId == null || widget.userId! <= 0) return;

    final cards = await _dbHelper.getCards(widget.userId!);
    if (mounted) {
      setState(() {
        _cards = cards;
        _tarjetaSeleccionada = widget.tarjetaPreseleccionada;
      });
    }
  }

  Future<void> _loadBudgets() async {
    if (widget.userId == null || widget.userId! <= 0) return;

    if (mounted) {
      setState(() => _isLoadingBudgets = true);
    }

    try {
      final budgets = await _dbHelper.getBudgetsByUser(widget.userId!);
      if (mounted) {
        setState(() => _budgets = budgets);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar presupuestos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingBudgets = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaPago,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null && mounted) {
      setState(() => _fechaPago = pickedDate);
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate() || _tarjetaSeleccionada == null)
      return;
    if (widget.userId == null || widget.userId! <= 0) return;

    setState(() => _isSaving = true);

    try {
      final budgetData = {
        'name': _nombreController.text.trim(),
        'amount': double.parse(_cantidadController.text),
        'paymentDate': _fechaPago.toIso8601String(),
        'cardNumber': _tarjetaSeleccionada!,
        'userId': widget.userId!,
      };

      await _dbHelper.insertBudget(budgetData);
      // Recargar la lista de presupuestos después de guardar
      await _loadBudgets();

      // Limpiar el formulario
      _nombreController.clear();
      _cantidadController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presupuesto guardado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildCardPreview() {
    final card = _cards.firstWhere(
      (c) => c['number'] == _tarjetaSeleccionada,
      orElse:
          () => {
            'name': 'Tarjeta no seleccionada',
            'color': 0xFF6200EE,
            'number': '••••',
          },
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(card['color'] as int).withOpacity(0.8),
            Color(card['color'] as int),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                card['name']?.toString() ?? 'Tarjeta',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '•••• ${_tarjetaSeleccionada?.substring(_tarjetaSeleccionada!.length - 4) ?? '••••'}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDropdown() {
    return DropdownButtonFormField<String>(
      value: _tarjetaSeleccionada,
      decoration: InputDecoration(
        labelText: 'Tarjeta',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items:
          _cards
              .map(
                (card) => DropdownMenuItem<String>(
                  value: card['number'] as String,
                  child: Text(
                    "${card['name']} (•••• ${card['number'].toString().substring(card['number'].toString().length - 4)})",
                  ),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _tarjetaSeleccionada = value),
      validator: (value) => value == null ? 'Selecciona una tarjeta' : null,
    );
  }

  Widget _buildBudgetList() {
    if (_isLoadingBudgets) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_budgets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay presupuestos guardados'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Presupuestos guardados:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _budgets.length,
          itemBuilder: (context, index) {
            final budget = _budgets[index];
            final paymentDate = DateTime.parse(budget['paymentDate']);
            final cardNumber = budget['cardNumber'] as String;
            final card = _cards.firstWhere(
              (c) => c['number'] == cardNumber,
              orElse: () => {'name': 'Tarjeta no encontrada'},
            );

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(budget['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${budget['amount'].toString()}'),
                    Text(
                      'Fecha: ${paymentDate.toLocal().toString().split(' ')[0]}',
                    ),
                    Text(
                      'Tarjeta: ${card['name']} (•••• ${cardNumber.substring(cardNumber.length - 4)})',
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBudget(budget['id']),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _deleteBudget(int id) async {
    try {
      await _dbHelper.deleteBudget(id);
      await _loadBudgets();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Presupuesto eliminado')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Presupuesto'),
        actions: [
          IconButton(
            icon:
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveBudget,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa una cantidad';
                  final amount = double.tryParse(value!);
                  if (amount == null || amount <= 0) return 'Cantidad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => _selectDate(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(
                      'Fecha: ${_fechaPago.toLocal().toString().split(' ')[0]}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_tarjetaSeleccionada != null) _buildCardPreview(),
              if (_tarjetaSeleccionada == null) _buildCardDropdown(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('GUARDAR PRESUPUESTO'),
              ),
              const SizedBox(height: 30),
              _buildBudgetList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }
}
