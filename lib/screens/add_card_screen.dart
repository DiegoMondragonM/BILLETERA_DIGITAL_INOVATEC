import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _numeroController = TextEditingController();
  final _montoController = TextEditingController();
  final _vencimientoController = TextEditingController();

  String _tipoTarjeta = 'Visa';
  Color _colorTarjeta = Colors.purple[300]!;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroController.dispose();
    _montoController.dispose();
    _vencimientoController.dispose();
    super.dispose();
  }

  Future<void> _guardarTarjeta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final tarjeta = {
        'nombre': _nombreController.text,
        'numero': _numeroController.text,
        'tipo': _tipoTarjeta,
        'monto': _montoController.text,
        'vencimiento': _vencimientoController.text,
        'color': _colorTarjeta.value,
      };

      Provider.of<PresupuestoProvider>(context, listen: false)
          .agregarTarjeta(tarjeta);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _guardando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Tarjeta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campos del formulario...
              ElevatedButton(
                onPressed: _guardando ? null : _guardarTarjeta,
                child: _guardando
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Tarjeta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}