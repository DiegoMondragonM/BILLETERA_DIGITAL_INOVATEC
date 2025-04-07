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

  // Añade esto para poder comparar presupuestos
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Presupuesto &&
              runtimeType == other.runtimeType &&
              nombre == other.nombre &&
              cantidad == other.cantidad &&
              fechaPago == other.fechaPago &&
              tarjetaSeleccionada == other.tarjetaSeleccionada;

  @override
  int get hashCode =>
      nombre.hashCode ^
      cantidad.hashCode ^
      fechaPago.hashCode ^
      tarjetaSeleccionada.hashCode;

  get id => null;
}


/*// lib/models/presupuesto.dart
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
}*/
