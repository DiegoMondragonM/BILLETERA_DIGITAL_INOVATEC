import 'package:flutter/material.dart';
import '../Service/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  String cardType = 'Visa';
  Color cardColor = Colors.purple[300]!; // Color por defecto de la tarjeta

  // Lista de colores para seleccionar
  List<Color> availableColors = [
    Colors.purple[300]!,
    Colors.blue[300]!,
    Colors.green[300]!,
    Colors.orange[300]!,
    Colors.red[300]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Tarjeta')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              // Vista previa de la tarjeta
              _buildCardPreview(),
              SizedBox(height: 20.0),
              // Formulario de registro de tarjeta
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Nombre de la Tarjeta',
                      hintText: 'Ejemplo: Mi Tarjeta Personal',
                    ),
                    SizedBox(height: 20.0),
                    _buildTextField(
                      controller: numberController,
                      label: 'Número de la Tarjeta',
                      hintText: 'XXXX XXXX XXXX XXXX',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.0),
                    _buildCardTypeField(),
                    SizedBox(height: 20.0),
                    _buildTextField(
                      controller: amountController,
                      label: 'Monto de la Tarjeta',
                      hintText: '\$0.00',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.0),
                    _buildTextField(
                      controller: expiryDateController,
                      label: 'Fecha de Vencimiento (MM/AAAA)',
                      hintText: 'MM/AAAA',
                    ),
                    SizedBox(height: 20.0),
                    // Selector de color de la tarjeta
                    _buildColorPicker(),
                    SizedBox(height: 40.0),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista previa de la tarjeta que se está registrando
  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor, // Color seleccionado
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameController.text.isNotEmpty
                ? nameController.text
                : 'Nombre de la Tarjeta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            numberController.text.isNotEmpty
                ? numberController.text
                : 'XXXX XXXX XXXX XXXX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Tipo: $cardType',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          SizedBox(height: 10.0),
          Text(
            expiryDateController.text.isNotEmpty
                ? expiryDateController.text
                : 'MM/AAAA',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  // Campo de texto general
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {}); // Actualiza la vista previa de la tarjeta
      },
    );
  }

  // Campo para seleccionar el tipo de tarjeta
  Widget _buildCardTypeField() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile(
            title: Text('Visa'),
            value: 'Visa',
            groupValue: cardType,
            onChanged: (value) {
              setState(() {
                cardType = value.toString();
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: Text('Mastercard'),
            value: 'Mastercard',
            groupValue: cardType,
            onChanged: (value) {
              setState(() {
                cardType = value.toString();
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile(
            title: Text('American Express'),
            value: 'American Express',
            groupValue: cardType,
            onChanged: (value) {
              setState(() {
                cardType = value.toString();
              });
            },
          ),
        ),
      ],
    );
  }

  // Selector de color de la tarjeta
  Widget _buildColorPicker() {
    return Row(
      children:
          availableColors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  cardColor = color; // Actualizar el color de la tarjeta
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        cardColor == color ? Colors.black : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // Botón para guardar la tarjeta
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            final dbHelper = DBHelper();
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getInt('userId') ?? 0; // Obtiene el ID real

            if (userId <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: Usuario no identificado')),
              );
              return;
            }

            // Validación adicional del número de tarjeta
            if (numberController.text.length < 16) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Número de tarjeta inválido')),
              );
              return;
            }

            final result = await dbHelper.insertCard({
              'name': nameController.text,
              'number': numberController.text,
              'type': cardType,
              'amount': amountController.text,
              'expiryDate': expiryDateController.text,
              'color': cardColor.value,
              'userId': userId,
            });

            if (result > 0) {
              // Si la inserción fue exitosa
              Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al guardar la tarjeta')),
              );
            }
          } catch (e) {
            print('Error al insertar tarjeta: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error crítico: ${e.toString()}')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
      ),
      child: Text('Guardar Tarjeta', style: TextStyle(fontSize: 18.0)),
    );
  }
}
