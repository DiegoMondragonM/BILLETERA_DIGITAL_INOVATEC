import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';

class AgregarGastoScreen extends StatefulWidget {
  final String? tarjetaSeleccionada;

  const AgregarGastoScreen({super.key, this.tarjetaSeleccionada});

  @override
  State<AgregarGastoScreen> createState() => _AgregarGastoScreenState();
}

class _AgregarGastoScreenState extends State<AgregarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _montoController = TextEditingController();
  String? _tarjetaSeleccionada;
  String _categoria = 'Comida';
  final _categorias = ['Comida', 'Transporte', 'Entretenimiento', 'Servicios', 'Otros'];

  @override
  void initState() {
    super.initState();
    _tarjetaSeleccionada = widget.tarjetaSeleccionada;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tarjetaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una tarjeta')),
      );
      return;
    }

    try {
      await Provider.of<PresupuestoProvider>(context, listen: false).agregarGastoManual(
        nombre: _nombreController.text,
        monto: double.parse(_montoController.text),
        tarjetaId: _tarjetaSeleccionada!,
        categoria: _categoria,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PresupuestoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Ingresa una descripción'
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _montoController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Ingresa un monto';
                    final monto = double.tryParse(value!);
                    if (monto == null) return 'Monto inválido';
                    if (monto <= 0) return 'Debe ser mayor a cero';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _categoria,
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _categoria = value!),
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTarjetaDropdown(provider.cards),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('REGISTRAR GASTO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaDropdown(List<Map<String, dynamic>> cards) {
    return DropdownButtonFormField<String>(
      value: _tarjetaSeleccionada,
      items: cards.map<DropdownMenuItem<String>>((card) { // Especifica el tipo aquí
        return DropdownMenuItem<String>(
          value: card['number'] as String, // Asegura que sea String
          child: Text(card['name'] ?? 'Sin nombre'),
        );
      }).toList(),
      onChanged: (String? value) => setState(() => _tarjetaSeleccionada = value),
      decoration: const InputDecoration(
        labelText: 'Tarjeta',
        prefixIcon: Icon(Icons.credit_card),
      ),
      validator: (value) => value == null ? 'Selecciona una tarjeta' : null,
    );
  }
}