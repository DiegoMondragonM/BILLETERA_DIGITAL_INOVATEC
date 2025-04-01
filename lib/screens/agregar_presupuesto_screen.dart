import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/providers/presupuesto_provider.dart';
import 'package:namer_app/models/presupuesto.dart';

class AgregarPresupuestoScreen extends StatefulWidget {
  const AgregarPresupuestoScreen({super.key});

  @override
  State<AgregarPresupuestoScreen> createState() => _AgregarPresupuestoScreenState();
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
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      selectableDayPredicate: (DateTime date) {
        return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      },
    );

    if (fechaSeleccionada != null) {
      setState(() => _fechaPago = fechaSeleccionada);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tarjetaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una tarjeta para continuar')),
      );
      return;
    }

    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    final cantidad = double.parse(_cantidadController.text);

    try {
      await provider.agregarPresupuesto(
        Presupuesto(
          nombre: _nombreController.text,
          cantidad: cantidad,
          fechaPago: _fechaPago,
          tarjetaSeleccionada: _tarjetaSeleccionada!,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PresupuestoProvider>(context);
    final cards = provider.cards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Presupuesto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submit,
            tooltip: 'Guardar presupuesto',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del presupuesto',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _cantidadController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Ingresa una cantidad';
                    final amount = double.tryParse(value!);
                    if (amount == null) return 'Ingresa un número válido';
                    if (amount <= 0) return 'La cantidad debe ser mayor a cero';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => _seleccionarFecha(context),
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
                DropdownButtonFormField<String>(
                  value: _tarjetaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar tarjeta',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                  items: cards.map((card) {
                    final saldo = double.parse(card['amount'] ?? '0');
                    return DropdownMenuItem<String>(
                      value: card['number'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card['name'] ?? 'Sin nombre'),
                          Text(
                            'Saldo: \$${saldo.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: saldo >= 0 ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _tarjetaSeleccionada = value),
                  validator: (value) => value == null ? 'Selecciona una tarjeta' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('GUARDAR PRESUPUESTO'),
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


