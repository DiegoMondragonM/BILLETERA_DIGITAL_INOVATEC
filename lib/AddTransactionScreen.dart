import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/AddCardScreen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Clase para cada entrada de detalle.
class DetailEntry {
  TextEditingController descriptionController;
  TextEditingController amountController;

  DetailEntry({
    required this.descriptionController,
    required this.amountController,
  });
}

class AddTransactionScreen extends StatefulWidget {
  final String correo; // Correo electrónico del usuario, recibido por el constructor.
  final int tarjetaId; // ID de la tarjeta, recibido por el constructor.
  const AddTransactionScreen({super.key, required this.correo, required this.tarjetaId, required Map<String, dynamic> card});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos principales.
  final _headerController = TextEditingController();
  final _amountController = TextEditingController();

  // Valor por defecto para el tipo de operación.
  String _operationType = "Ingreso";
  DateTime selectedDate = DateTime.now();

  // Lista de detalles. El primer detalle no se puede quitar, sus campos no son obligatorios.
  List<DetailEntry> detailEntries = [];
  bool _showDetails = false;
  bool _submitted = false;

  static const String baseUrl = 'http://10.0.2.2:3000'; //'http://10.0.2.2:3000 o 'http://192.168.1.71:3000'

  @override
  void initState() {
    super.initState();
    // Se añade el primer detalle.
    detailEntries.add(
      DetailEntry(
        descriptionController: TextEditingController(),
        amountController: TextEditingController(),
      ),
    );
    // Listener para actualizar totales en tiempo real.
    for (var entry in detailEntries) {
      entry.amountController.addListener(_updateTotals);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _amountController.dispose();
    for (var entry in detailEntries) {
      entry.descriptionController.dispose();
      entry.amountController.dispose();
    }
    super.dispose();
  }

  // Determina cambios en los campos.
  bool get hasChanges {
    if (_headerController.text.isNotEmpty) return true;
    if (_amountController.text.isNotEmpty) return true;
    if (detailEntries.any(
      (entry) =>
          entry.descriptionController.text.isNotEmpty ||
          entry.amountController.text.isNotEmpty,
    )) {
      return true;
    }
    return false;
  }

  // Suma de los montos de los detalles.
  double get totalDetailAmount {
    double total = 0.0;
    for (var entry in detailEntries) {
      String text = entry.amountController.text;
      text = text.replaceAll("\$", "").replaceAll(",", "").trim();
      double value = double.tryParse(text) ?? 0.0;
      total += value;
    }
    return total;
  }

  // Formatea el total de los detalles.
  String get formattedTotal => "\$${totalDetailAmount.toStringAsFixed(2)}";

  // Valida que el total principal coincida con la suma de los detalles.
  bool get isAmountMatching {
    String topText =
        _amountController.text.replaceAll("\$", "").replaceAll(",", "").trim();
    double topValue = double.tryParse(topText) ?? 0.0;
    return (topValue == totalDetailAmount);
  }

  // Actualiza la interfaz al cambiar montos.
  void _updateTotals() {
    setState(() {});
  }

  // Agrega un nuevo registro de detalle debajo del actual.
  void _addDetailEntry(int index) {
    setState(() {
      DetailEntry newEntry = DetailEntry(
        descriptionController: TextEditingController(),
        amountController: TextEditingController(),
      );
      newEntry.amountController.addListener(_updateTotals);
      detailEntries.insert(index + 1, newEntry);
    });
  }

  // Remueve un detalle (solo se permite si hay más de uno).
  void _removeDetailEntry(int index) {
    setState(() {
      if (detailEntries.length > 1) {
        detailEntries.removeAt(index);
      }
    });
  }

  // Muestra la alerta para descartar cambios.
  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Descartar cambios?"),
            content: const Text("¿Desea descartar los cambios realizados?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: const Text("Sí"),
              ),
            ],
          ),
    );
  }

  // Lógica de guardado (aquí enviarías los datos a tu base de datos).
  void _onSave() async {
    setState(() {
      _submitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    // Extraer y limpiar datos principales
    String header = _headerController.text.trim();
    String totalText =
        _amountController.text.replaceAll("\$", "").replaceAll(",", "").trim();
    double totalAmount = double.tryParse(totalText) ?? 0.0;

    // Construir los detalles a partir de los registros de la lista detailEntries.
    String detalles = "";
    for (int i = 0; i < detailEntries.length; i++) {
      String desc = detailEntries[i].descriptionController.text.trim();
      String amount =
          detailEntries[i].amountController.text
              .replaceAll("\$", "")
              .replaceAll(",", "")
              .trim();
      if (desc.isNotEmpty && amount.isNotEmpty) {
        detalles += "$desc: $amount";
        if (i < detailEntries.length - 1) {
          detalles += "\n";
        }
      }
    }

    // Preparar el payload
    Map<String, dynamic> payload = {
      "correo_electronico": widget.correo, // recibido por el constructor
      'tarjeta_id': widget.tarjetaId, // recibido por el constructor
      "encabezado": header,
      "tipo": _operationType.toLowerCase(), // Envía "ingreso" o "gasto"
      "monto": totalAmount,
      "detalles":
          detalles.isEmpty ? null : detalles, // Enviar null si está vacío,
      "fecha_movimiento": DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(selectedDate),
    };

    print("Enviando payload: $payload");

    // Enviar la transacción a la base de datos
    //await _postTransaction(payload);

    // Al finalizar, puedes cerrar la pantalla y actualizar la UI que depende de estos datos.
    bool success = await _postTransaction(payload);
    if (success) {
      Navigator.pop(context, true); // <-- devolvemos un flag
    }
  }
  
  Future<bool> _postTransaction(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/movimientos');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Error ${response.statusCode}: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Excepción al registrar transacción: $e");
    }

    return false; // Ensure a boolean value is always returned.
  }

  // Helper para crear un TextField estilizado.
  // Solo es obligatorio si requiredField es true.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool requiredField = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color.fromARGB(255, 238, 238, 238),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            // Se muestra una X roja solo si es obligatorio y está vacío tras intentar guardar.
            suffixIcon:
                _submitted && requiredField && controller.text.trim().isEmpty
                    ? const Icon(Icons.close, color: Colors.red)
                    : null,
          ),
          validator:
              requiredField
                  ? (value) {
                    if (_submitted && (value == null || value.trim().isEmpty)) {
                      return "Campo obligatorio";
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  // Selector de fecha.
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Widget para seleccionar fecha.
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Selector de tipo de operación.
  Widget _buildOperationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tipo de Operación:",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _operationType,
          items:
              ["Ingreso", "Gasto"].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
          onChanged: (value) {
            setState(() {
              _operationType = value!;
            });
          },
        ),
      ],
    );
  }

  // Sección de detalles (descripción y monto) que se muestra solo al desplegar.
  Widget _buildDetailsSection() {
    String detallesLabel =
        _operationType == "Ingreso"
            ? "Detalles del ingreso"
            : "Detalles del gasto";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado para expandir/contraer detalles.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              detallesLabel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: AnimatedRotation(
                turns: _showDetails ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.add, color: Colors.blue),
              ),
              onPressed: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
            ),
          ],
        ),
        // Solo se muestran los detalles (los campos y el 'Total') al expandir.
        if (_showDetails) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: detailEntries.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller:
                              detailEntries[index].descriptionController,
                          label: "Descripción",
                          hintText: "Ej. Renta, Sueldo, etc.",
                          requiredField: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField(
                          controller: detailEntries[index].amountController,
                          label: "Monto",
                          hintText: "\$0.00",
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            // Permite dígitos y punto.
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                            CurrencyInputFormatter(),
                          ],
                          requiredField: false,
                        ),
                      ),
                      // Botón para quitar el detalle (si no es el primero).
                      if (index > 0)
                        IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _removeDetailEntry(index),
                        ),
                      // Botón para agregar un nuevo detalle.
                      IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: const Icon(Icons.add, color: Colors.blue),
                        onPressed: () => _addDetailEntry(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          // La fila "Total" se muestra solo al expandir los detalles.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formattedTotal,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isAmountMatching)
            const Text(
              "El total no coincide con la suma de los detalles.",
              style: TextStyle(color: Colors.red),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Botón "X" con confirmación de descartar cambios.
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text("Añadir ${_operationType.toLowerCase()}"),
        actions: [
          // Botón "Editar" para alguna acción extra.
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Lógica de edición.
              print("Editar pulsado");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOperationTypeSelector(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _headerController,
                  label: "Encabezado:",
                  hintText: "Ej. Ingreso por o gasto por...",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _amountController,
                  label:
                      _operationType == "Ingreso"
                          ? "Total ingreso:"
                          : "Total gasto:",
                  hintText: "Ej. \$0.00",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    // Permite dígitos y punto.
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    CurrencyInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 16),
                _buildDetailsSection(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onSave,
                  child: const Text("Guardar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
