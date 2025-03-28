import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';

class AgregarPresupuestoScreen extends StatefulWidget {
  final Function(String, double, DateTime, String) onAgregarPresupuesto;

  const AgregarPresupuestoScreen({
    super.key,
    required this.onAgregarPresupuesto,
  });

  @override
  _AgregarPresupuestoScreenState createState() =>
      _AgregarPresupuestoScreenState();
}

class _AgregarPresupuestoScreenState extends State<AgregarPresupuestoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  DateTime _fechaPago = DateTime.now();
  String? _tarjetaSeleccionada;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaPago,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null && fechaSeleccionada != _fechaPago) {
      setState(() {
        _fechaPago = fechaSeleccionada;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final cantidad = double.parse(_cantidadController.text);

      if (_tarjetaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona una tarjeta para continuar'),
          ),
        );
        return;
      }

      final presupuestoProvider = Provider.of<PresupuestoProvider>(
        context,
        listen: false,
      );

      final tarjeta = presupuestoProvider.cards.firstWhere(
        (card) => card['name'] == _tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tarjeta no encontrada')));
        return;
      }

      final saldoTarjeta = double.tryParse(tarjeta['amount'] ?? '0') ?? 0;
      if (cantidad > saldoTarjeta) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo insuficiente en la tarjeta seleccionada'),
          ),
        );
        return;
      }

      widget.onAgregarPresupuesto(
        nombre,
        cantidad,
        _fechaPago,
        _tarjetaSeleccionada!,
      );
      Navigator.pop(context); // Regresar a MenuScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final presupuestoProvider = Provider.of<PresupuestoProvider>(context);
    final cards = presupuestoProvider.cards;

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Presupuesto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo para el nombre del presupuesto
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un nombre';
                    }
                    return null;
                  },
                ),

                // Campo para la cantidad del presupuesto
                TextFormField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una cantidad';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),

                // Selector de fecha de pago
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Fecha de pago: ${_fechaPago.toLocal().toString().split(' ')[0]}',
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _seleccionarFecha(context),
                      child: const Text('Seleccionar fecha'),
                    ),
                  ],
                ),

                // Selector de tarjeta
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _tarjetaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar tarjeta',
                  ),
                  items:
                      cards.map<DropdownMenuItem<String>>((card) {
                        return DropdownMenuItem<String>(
                          value: card['name'],
                          child: Text(card['name']),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tarjetaSeleccionada = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una tarjeta';
                    }
                    return null;
                  },
                ),

                // Botón para guardar el presupuesto
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Guardar Presupuesto'),
                ),
              ],
            ),
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



/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';

class AgregarPresupuestoScreen extends StatefulWidget {
  final Function(String, double, DateTime, String) onAgregarPresupuesto;

  const AgregarPresupuestoScreen({
    super.key,
    required this.onAgregarPresupuesto,
  });

  @override
  _AgregarPresupuestoScreenState createState() =>
      _AgregarPresupuestoScreenState();
}

class _AgregarPresupuestoScreenState extends State<AgregarPresupuestoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  DateTime _fechaPago = DateTime.now();
  String? _tarjetaSeleccionada;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaPago,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null && fechaSeleccionada != _fechaPago) {
      setState(() {
        _fechaPago = fechaSeleccionada;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final cantidad = double.parse(_cantidadController.text);

      if (_tarjetaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona una tarjeta para continuar'),
          ),
        );
        return;
      }

      final presupuestoProvider = Provider.of<PresupuestoProvider>(
        context,
        listen: false,
      );

      final tarjeta = presupuestoProvider.cards.firstWhere(
        (card) => card['name'] == _tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tarjeta no encontrada')));
        return;
      }

      final saldoTarjeta = double.tryParse(tarjeta['amount'] ?? '0') ?? 0;
      if (cantidad > saldoTarjeta) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo insuficiente en la tarjeta seleccionada'),
          ),
        );
        return;
      }

      widget.onAgregarPresupuesto(
        nombre,
        cantidad,
        _fechaPago,
        _tarjetaSeleccionada!,
      );
      Navigator.pop(context); // Regresar a MenuScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final presupuestoProvider = Provider.of<PresupuestoProvider>(context);
    final cards = presupuestoProvider.cards;

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Presupuesto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo para el nombre del presupuesto
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un nombre';
                    }
                    return null;
                  },
                ),

                // Campo para la cantidad del presupuesto
                TextFormField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa una cantidad';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),

                // Selector de fecha de pago
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Fecha de pago: ${_fechaPago.toLocal().toString().split(' ')[0]}',
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _seleccionarFecha(context),
                      child: const Text('Seleccionar fecha'),
                    ),
                  ],
                ),

                // Selector de tarjeta
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _tarjetaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar tarjeta',
                  ),
                  items:
                      cards.map<DropdownMenuItem<String>>((card) {
                        return DropdownMenuItem<String>(
                          value: card['name'],
                          child: Text(card['name']),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tarjetaSeleccionada = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una tarjeta';
                    }
                    return null;
                  },
                ),

                // Botón para guardar el presupuesto
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Guardar Presupuesto'),
                ),
              ],
            ),
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
}*/


