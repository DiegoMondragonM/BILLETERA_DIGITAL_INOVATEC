// lib/models/presupuesto.dart
class Presupuesto {
  final String nombre;
  final double cantidad;
  final DateTime fechaPago;
  final String tarjetaSeleccionada;

  Presupuesto({
    required this.nombre,
    required this.cantidad,
    required this.fechaPago,
    required this.tarjetaSeleccionada,
  });
}
