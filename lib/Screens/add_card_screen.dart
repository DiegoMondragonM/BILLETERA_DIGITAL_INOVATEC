import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/Screens/wallet_screen.dart';
import '../Service/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String _cardType = 'Visa';
  Color _cardColor = Colors.blue[800]!;
  bool _isSaving = false;

  final List<Color> _availableColors = [
    Colors.blue[800]!,
    Colors.red[800]!,
    Colors.teal[800]!,
    Colors.purple[800]!,
    Colors.orange[800]!,
    Colors.indigo[800]!,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _amountController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      if (userId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no identificado')),
        );
        return;
      }

      final cardData = {
        'name': _nameController.text.trim(),
        'number': _numberController.text.replaceAll(' ', ''),
        'type': _cardType,
        'amount':
            _amountController.text.isNotEmpty
                ? double.parse(_amountController.text).toStringAsFixed(2)
                : '0.00',
        'expiryDate': _expiryDateController.text.trim(),
        'color': _cardColor.value,
        'userId': userId,
      };

      // Opción 2: Usar DBHelper directamente
      final dbHelper = DBHelper();
      final result = await dbHelper.insertCard(cardData);

      if (result > 0) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WalletScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la tarjeta')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Tarjeta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildRealisticCardPreview(),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tarjeta',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Ingresa un nombre para la tarjeta'
                            : null,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa el número';
                  if (value!.replaceAll(' ', '').length != 16) {
                    return 'Debe tener 16 dígitos';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              _buildEnhancedCardTypeSelector(),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto inicial',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: '1000.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa un monto';
                  final amount = double.tryParse(value!);
                  if (amount == null) return 'Monto inválido';
                  if (amount < 0) return 'Debe ser positivo';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Vencimiento (MM/AA)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: 'MM/AA',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardExpiryFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Ingresa la fecha';
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                    return 'Formato MM/AA';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 25),
              _buildEnhancedColorSelector(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColorByCardType(),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('GUARDAR TARJETA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares (los mismos que en el primer código)
  Widget _buildRealisticCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
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
          Positioned(top: 20, right: 20, child: _buildCardTypeLogo()),
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Text(
              _numberController.text.isEmpty
                  ? '•••• •••• •••• ••••'
                  : _formatCardNumber(_numberController.text),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 2,
                fontFamily: 'Courier',
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'NOMBRE DEL TITULAR'
                      : _nameController.text.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  _expiryDateController.text.isEmpty
                      ? '••/••'
                      : _expiryDateController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCardTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de tarjeta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: PageView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCardTypeOption(
                'Visa',
                Icons.credit_card,
                Colors.blue[800]!,
              ),
              _buildCardTypeOption(
                'Mastercard',
                Icons.credit_card,
                Colors.red[800]!,
              ),
              _buildCardTypeOption(
                'Amex',
                Icons.credit_card,
                Colors.teal[800]!,
              ),
            ],
            onPageChanged: (index) {
              setState(() {
                _cardType = ['Visa', 'Mastercard', 'Amex'][index];
                _cardColor = _availableColors[index];
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardTypeOption(String type, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _cardType = type;
          _cardColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _cardType == type ? color.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _cardType == type ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la tarjeta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _availableColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              return GestureDetector(
                onTap: () => setState(() => _cardColor = color),
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.8), color],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _cardColor == color
                              ? Colors.black
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child:
                      _cardColor == color
                          ? const Center(
                            child: Icon(Icons.check, color: Colors.white),
                          )
                          : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardTypeLogo() {
    switch (_cardType.toLowerCase()) {
      case 'visa':
        return const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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

  LinearGradient _getCardGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_cardColor.withOpacity(0.8), _cardColor],
    );
  }

  Color _getButtonColorByCardType() {
    switch (_cardType.toLowerCase()) {
      case 'visa':
        return Colors.blue[800]!;
      case 'mastercard':
        return Colors.red[800]!;
      case 'amex':
        return Colors.teal[800]!;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  String _formatCardNumber(String input) {
    final cleaned = input.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) return oldValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
