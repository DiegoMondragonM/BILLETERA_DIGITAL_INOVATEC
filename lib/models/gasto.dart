class Gasto {
  final String id;
  final String nombre;
  final double monto;
  final DateTime fecha;
  final String? tarjetaId;
  final String? presupuestoId; // Para relacionar con presupuestos
  final String categoria;

  Gasto({
    required this.nombre,
    required this.monto,
    required this.fecha,
    this.tarjetaId,
    this.presupuestoId,
    this.categoria = 'Otros',
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Conversión a/desde JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'monto': monto,
    'fecha': fecha.toIso8601String(),
    'tarjetaId': tarjetaId,
    'presupuestoId': presupuestoId,
    'categoria': categoria,
  };

  factory Gasto.fromJson(Map<String, dynamic> json) => Gasto(
    id: json['id'],
    nombre: json['nombre'],
    monto: json['monto'].toDouble(),
    fecha: DateTime.parse(json['fecha']),
    tarjetaId: json['tarjetaId'],
    presupuestoId: json['presupuestoId'],
    categoria: json['categoria'] ?? 'Otros',
  );
}