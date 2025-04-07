import 'package:flutter/material.dart';
import 'package:namer_app/models/presupuesto.dart';

import '../models/gasto.dart';

class PresupuestoProvider with ChangeNotifier {
  int? selectedCardIndex;
  String? selectedCardNumber;
  // Lista de presupuestos
  List<Presupuesto> _presupuestos = [];

  // Lista de tarjetas
  List<Map<String, dynamic>> _cards = [];

  // Getters
  List<Presupuesto> get presupuestos => _presupuestos;
  List<Map<String, dynamic>> get cards => _cards;

  List<Gasto> _gastos = [];

  List<Gasto> get gastos => List.unmodifiable(_gastos);

  // Agregar gasto manual
  Future<void> agregarGastoManual({
    required String nombre,
    required double monto,
    required String tarjetaId,
    String? categoria,
  }) async {
    try {
      final tarjeta = _cards.firstWhere(
            (c) => c['number'] == tarjetaId,
        orElse: () => throw Exception('Tarjeta no encontrada'),
      );

      final nuevoSaldo = double.parse(tarjeta['amount']) - monto;
      if (nuevoSaldo < 0) throw Exception('Saldo insuficiente');

      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);

      _gastos.add(Gasto(
        nombre: nombre,
        monto: monto,
        fecha: DateTime.now(),
        tarjetaId: tarjetaId,
        categoria: categoria ?? 'Otros',
      ));

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Convertir presupuesto a gasto (automático)
  void convertirPresupuestoAGasto(Presupuesto presupuesto) {
    try {
      final tarjeta = _cards.firstWhere(
            (c) => c['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => throw Exception('Tarjeta no encontrada'),
      );

      final nuevoSaldo = double.parse(tarjeta['amount']) - presupuesto.cantidad;
      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);

      _gastos.add(Gasto(
        nombre: presupuesto.nombre,
        monto: presupuesto.cantidad,
        fecha: presupuesto.fechaPago,
        tarjetaId: presupuesto.tarjetaSeleccionada,
        presupuestoId: presupuesto.id,
        categoria: 'Presupuesto',
      ));

      notifyListeners();
    } catch (e) {
      print('Error al convertir presupuesto: $e');
    }
  }

  // Verificar presupuestos vencidos
  void verificarPresupuestosVencidos() {
    final ahora = DateTime.now();
    for (final presupuesto in _presupuestos) {
      if (presupuesto.fechaPago.isBefore(ahora) ||
          presupuesto.fechaPago.isAtSameMomentAs(ahora)) {
        if (!_gastos.any((g) => g.presupuestoId == presupuesto.id)) {
          convertirPresupuestoAGasto(presupuesto);
        }
      }
    }
  }

  // Obtener gastos por tarjeta
  List<Gasto> gastosPorTarjeta(String tarjetaId) {
    return _gastos.where((g) => g.tarjetaId == tarjetaId).toList();
  }


  /////////
  void selectCard(int index) {
    if (selectedCardIndex == index) {
      selectedCardIndex = null;
      selectedCardNumber = null;
    } else {
      selectedCardIndex = index;
      selectedCardNumber = cards[index]['number'];
    }
    notifyListeners();
  }

  void setSelectedCardNumber(String number) {
    selectedCardNumber = number;
    notifyListeners();
  }

  // Método para verificar si una tarjeta ya existe (por nombre o número)
  String? tarjetaExiste(String nombre, String numero) {
    final nombreExiste = _cards.any((card) => card['name'] == nombre);
    final numeroExiste = _cards.any((card) => card['number'] == numero);

    if (nombreExiste && numeroExiste) {
      return 'Ya existe una tarjeta con el mismo nombre y número.';
    } else if (nombreExiste) {
      return 'Ya existe una tarjeta con el mismo nombre.';
    } else if (numeroExiste) {
      return 'Ya existe una tarjeta con el mismo número.';
    }
    return null;
  }

  // Método para agregar un presupuesto
  Future<void> agregarPresupuesto(Presupuesto presupuesto) async {
    try {
      // Buscar la tarjeta por número
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) {
        throw Exception('Tarjeta no encontrada');
      }

      final saldoActual = double.parse(tarjeta['amount']);
      final nuevoSaldo = saldoActual - presupuesto.cantidad;

      if (nuevoSaldo < 0) {
        throw Exception('Saldo insuficiente en la tarjeta seleccionada');
      }

      // Actualizar el saldo de la tarjeta
      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      _presupuestos.add(presupuesto);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para editar un presupuesto existente
  Future<void> editarPresupuesto(int index, Presupuesto nuevoPresupuesto) async {
    try {
      if (index < 0 || index >= _presupuestos.length) {
        throw Exception('Índice de presupuesto inválido');
      }

      final presupuestoOriginal = _presupuestos[index];

      // Si cambió la tarjeta, debemos ajustar los saldos
      if (presupuestoOriginal.tarjetaSeleccionada != nuevoPresupuesto.tarjetaSeleccionada) {
        // Restaurar saldo en tarjeta original
        final tarjetaOriginal = _cards.firstWhere(
              (card) => card['number'] == presupuestoOriginal.tarjetaSeleccionada,
          orElse: () => {},
        );

        if (tarjetaOriginal.isNotEmpty) {
          final saldoActual = double.parse(tarjetaOriginal['amount']);
          tarjetaOriginal['amount'] = (saldoActual + presupuestoOriginal.cantidad).toStringAsFixed(2);
        }

        // Descontar de nueva tarjeta
        final nuevaTarjeta = _cards.firstWhere(
              (card) => card['number'] == nuevoPresupuesto.tarjetaSeleccionada,
          orElse: () => {},
        );

        if (nuevaTarjeta.isEmpty) {
          throw Exception('Nueva tarjeta no encontrada');
        }

        final saldoNuevaTarjeta = double.parse(nuevaTarjeta['amount']);
        final nuevoSaldo = saldoNuevaTarjeta - nuevoPresupuesto.cantidad;

        if (nuevoSaldo < 0) {
          throw Exception('Saldo insuficiente en la nueva tarjeta seleccionada');
        }

        nuevaTarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      }
      // Si es la misma tarjeta pero cambió el monto
      else if (presupuestoOriginal.cantidad != nuevoPresupuesto.cantidad) {
        final tarjeta = _cards.firstWhere(
              (card) => card['number'] == nuevoPresupuesto.tarjetaSeleccionada,
          orElse: () => {},
        );

        if (tarjeta.isNotEmpty) {
          final saldoActual = double.parse(tarjeta['amount']);
          final diferencia = presupuestoOriginal.cantidad - nuevoPresupuesto.cantidad;
          final nuevoSaldo = saldoActual + diferencia;

          if (nuevoSaldo < 0) {
            throw Exception('Saldo insuficiente en la tarjeta seleccionada');
          }

          tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
        }
      }

      _presupuestos[index] = nuevoPresupuesto;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para eliminar un presupuesto
  Future<void> eliminarPresupuesto(int index) async {
    try {
      if (index < 0 || index >= _presupuestos.length) return;

      final presupuesto = _presupuestos[index];
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isNotEmpty) {
        // Restaurar el saldo al eliminar el presupuesto
        final saldoActual = double.parse(tarjeta['amount']);
        tarjeta['amount'] = (saldoActual + presupuesto.cantidad).toStringAsFixed(2);
      }

      _presupuestos.removeAt(index);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para limpiar todos los presupuestos
  Future<void> limpiarPresupuestos() async {
    // Primero restaurar todos los saldos de las tarjetas
    for (final presupuesto in _presupuestos) {
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isNotEmpty) {
        final saldoActual = double.parse(tarjeta['amount']);
        tarjeta['amount'] = (saldoActual + presupuesto.cantidad).toStringAsFixed(2);
      }
    }

    _presupuestos.clear();
    notifyListeners();
  }

  // Método para calcular el total de presupuestos
  double calcularTotal() {
    return _presupuestos.fold(0, (sum, presupuesto) => sum + presupuesto.cantidad);
  }

  // Método para agregar tarjetas
  Future<void> agregarTarjeta(Map<String, dynamic> nuevaTarjeta) async {
    try {
      // Validar que no exista
      final error = tarjetaExiste(nuevaTarjeta['name'], nuevaTarjeta['number']);
      if (error != null) throw Exception(error);

      // Validar y formatear el monto inicial
      final monto = double.tryParse(nuevaTarjeta['amount']?.toString() ?? '0') ?? 0;
      if (monto < 0) throw Exception('El monto inicial no puede ser negativo');

      nuevaTarjeta['amount'] = monto.toStringAsFixed(2);
      _cards.add(nuevaTarjeta);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para eliminar una tarjeta
  Future<void> eliminarTarjeta(int index) async {
    try {
      if (index < 0 || index >= _cards.length) return;

      // Eliminar también los presupuestos asociados a esta tarjeta
      final numeroTarjeta = _cards[index]['number'];
      _presupuestos.removeWhere((p) => p.tarjetaSeleccionada == numeroTarjeta);

      _cards.removeAt(index);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para obtener el saldo de una tarjeta
  double obtenerSaldoTarjeta(String numeroTarjeta) {
    final tarjeta = _cards.firstWhere(
          (card) => card['number'] == numeroTarjeta,
      orElse: () => {},
    );

    if (tarjeta.isEmpty) throw Exception('Tarjeta no encontrada');
    return double.parse(tarjeta['amount']);
  }

  // Método para actualizar el saldo de una tarjeta
  Future<void> actualizarSaldoTarjeta(String numeroTarjeta, double nuevoSaldo) async {
    try {
      if (nuevoSaldo < 0) throw Exception('El saldo no puede ser negativo');

      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == numeroTarjeta,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) throw Exception('Tarjeta no encontrada');
      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener presupuestos por tarjeta
  List<Presupuesto> presupuestosPorTarjeta(String numeroTarjeta) {
    return _presupuestos.where((p) => p.tarjetaSeleccionada == numeroTarjeta).toList();
  }

  // Calcular total de presupuestos por tarjeta
  double totalPresupuestosPorTarjeta(String numeroTarjeta) {
    return presupuestosPorTarjeta(numeroTarjeta)
        .fold(0, (sum, presupuesto) => sum + presupuesto.cantidad);
  }

  // Método para obtener una tarjeta por su número
  Map<String, dynamic>? obtenerTarjetaPorNumero(String numeroTarjeta) {
    try {
      return _cards.firstWhere(
            (card) => card['number'] == numeroTarjeta,
      );
    } catch (e) {
      return null;
    }
  }
}


/*import 'package:flutter/material.dart';
import 'package:namer_app/models/presupuesto.dart';

class PresupuestoProvider with ChangeNotifier {
  // Lista de presupuestos
  List<Presupuesto> _presupuestos = [];

  // Lista de tarjetas
  List<Map<String, dynamic>> _cards = [];

  // Getters
  List<Presupuesto> get presupuestos => _presupuestos;
  List<Map<String, dynamic>> get cards => _cards;

  // Método para verificar si una tarjeta ya existe (por nombre o número)
  String? tarjetaExiste(String nombre, String numero) {
    final nombreExiste = _cards.any((card) => card['name'] == nombre);
    final numeroExiste = _cards.any((card) => card['number'] == numero);

    if (nombreExiste && numeroExiste) {
      return 'Ya existe una tarjeta con el mismo nombre y número.';
    } else if (nombreExiste) {
      return 'Ya existe una tarjeta con el mismo nombre.';
    } else if (numeroExiste) {
      return 'Ya existe una tarjeta con el mismo número.';
    }
    return null;
  }

  // Método para agregar un presupuesto
  Future<void> agregarPresupuesto(Presupuesto presupuesto) async {
    try {
      // Buscar la tarjeta por número
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) {
        throw Exception('Tarjeta no encontrada');
      }

      final saldoActual = double.parse(tarjeta['amount']);
      final nuevoSaldo = saldoActual - presupuesto.cantidad;

      if (nuevoSaldo < 0) {
        throw Exception('Saldo insuficiente en la tarjeta seleccionada');
      }

      // Actualizar el saldo de la tarjeta
      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      _presupuestos.add(presupuesto);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para editar un presupuesto existente
  Future<void> editarPresupuesto(int index, Presupuesto nuevoPresupuesto) async {
    try {
      if (index < 0 || index >= _presupuestos.length) {
        throw Exception('Índice de presupuesto inválido');
      }

      final presupuestoOriginal = _presupuestos[index];

      // Si cambió la tarjeta, debemos ajustar los saldos
      if (presupuestoOriginal.tarjetaSeleccionada != nuevoPresupuesto.tarjetaSeleccionada) {
        // Restaurar saldo en tarjeta original
        final tarjetaOriginal = _cards.firstWhere(
              (card) => card['number'] == presupuestoOriginal.tarjetaSeleccionada,
          orElse: () => {},
        );

        if (tarjetaOriginal.isNotEmpty) {
          final saldoActual = double.parse(tarjetaOriginal['amount']);
          tarjetaOriginal['amount'] = (saldoActual + presupuestoOriginal.cantidad).toStringAsFixed(2);
        }

        // Descontar de nueva tarjeta
        final nuevaTarjeta = _cards.firstWhere(
              (card) => card['number'] == nuevoPresupuesto.tarjetaSeleccionada,
          orElse: () => {},
        );

        if (nuevaTarjeta.isEmpty) {
          throw Exception('Nueva tarjeta no encontrada');
        }

        final saldoNuevaTarjeta = double.parse(nuevaTarjeta['amount']);
        final nuevoSaldo = saldoNuevaTarjeta - nuevoPresupuesto.cantidad;

        if (nuevoSaldo < 0) {
          throw Exception('Saldo insuficiente en la nueva tarjeta seleccionada');
        }

        nuevaTarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      }
      // Si es la misma tarjeta pero cambió el monto
      else if (presupuestoOriginal.cantidad != nuevoPresupuesto.cantidad) {
        final tarjeta = _cards.firstWhere(
              (card) => card['number'] == nuevoPresupuesto.tarjetaSeleccionada,
          orElse: () => {},
        );

        if (tarjeta.isNotEmpty) {
          final saldoActual = double.parse(tarjeta['amount']);
          final diferencia = presupuestoOriginal.cantidad - nuevoPresupuesto.cantidad;
          final nuevoSaldo = saldoActual + diferencia;

          if (nuevoSaldo < 0) {
            throw Exception('Saldo insuficiente en la tarjeta seleccionada');
          }

          tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
        }
      }

      _presupuestos[index] = nuevoPresupuesto;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para eliminar un presupuesto
  Future<void> eliminarPresupuesto(int index) async {
    try {
      if (index < 0 || index >= _presupuestos.length) return;

      final presupuesto = _presupuestos[index];
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isNotEmpty) {
        // Restaurar el saldo al eliminar el presupuesto
        final saldoActual = double.parse(tarjeta['amount']);
        tarjeta['amount'] = (saldoActual + presupuesto.cantidad).toStringAsFixed(2);
      }

      _presupuestos.removeAt(index);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para limpiar todos los presupuestos
  Future<void> limpiarPresupuestos() async {
    // Primero restaurar todos los saldos de las tarjetas
    for (final presupuesto in _presupuestos) {
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isNotEmpty) {
        final saldoActual = double.parse(tarjeta['amount']);
        tarjeta['amount'] = (saldoActual + presupuesto.cantidad).toStringAsFixed(2);
      }
    }

    _presupuestos.clear();
    notifyListeners();
  }

  // Método para calcular el total de presupuestos
  double calcularTotal() {
    return _presupuestos.fold(0, (sum, presupuesto) => sum + presupuesto.cantidad);
  }

  // Método para agregar tarjetas
  Future<void> agregarTarjeta(Map<String, dynamic> nuevaTarjeta) async {
    try {
      // Validar que no exista
      final error = tarjetaExiste(nuevaTarjeta['name'], nuevaTarjeta['number']);
      if (error != null) throw Exception(error);

      // Validar y formatear el monto inicial
      final monto = double.tryParse(nuevaTarjeta['amount']?.toString() ?? '0') ?? 0;
      if (monto < 0) throw Exception('El monto inicial no puede ser negativo');

      nuevaTarjeta['amount'] = monto.toStringAsFixed(2);
      _cards.add(nuevaTarjeta);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para eliminar una tarjeta
  Future<void> eliminarTarjeta(int index) async {
    try {
      if (index < 0 || index >= _cards.length) return;

      // Eliminar también los presupuestos asociados a esta tarjeta
      final numeroTarjeta = _cards[index]['number'];
      _presupuestos.removeWhere((p) => p.tarjetaSeleccionada == numeroTarjeta);

      _cards.removeAt(index);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para obtener el saldo de una tarjeta
  double obtenerSaldoTarjeta(String numeroTarjeta) {
    final tarjeta = _cards.firstWhere(
          (card) => card['number'] == numeroTarjeta,
      orElse: () => {},
    );

    if (tarjeta.isEmpty) throw Exception('Tarjeta no encontrada');
    return double.parse(tarjeta['amount']);
  }

  // Método para actualizar el saldo de una tarjeta
  Future<void> actualizarSaldoTarjeta(String numeroTarjeta, double nuevoSaldo) async {
    try {
      if (nuevoSaldo < 0) throw Exception('El saldo no puede ser negativo');

      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == numeroTarjeta,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) throw Exception('Tarjeta no encontrada');
      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener presupuestos por tarjeta
  List<Presupuesto> presupuestosPorTarjeta(String numeroTarjeta) {
    return _presupuestos.where((p) => p.tarjetaSeleccionada == numeroTarjeta).toList();
  }

  // Calcular total de presupuestos por tarjeta
  double totalPresupuestosPorTarjeta(String numeroTarjeta) {
    return presupuestosPorTarjeta(numeroTarjeta)
        .fold(0, (sum, presupuesto) => sum + presupuesto.cantidad);
  }

  // Método para obtener una tarjeta por su número
  Map<String, dynamic>? obtenerTarjetaPorNumero(String numeroTarjeta) {
    try {
      return _cards.firstWhere(
            (card) => card['number'] == numeroTarjeta,
      );
    } catch (e) {
      return null;
    }
  }
}*/



/*import 'package:flutter/material.dart';
import 'package:namer_app/models/presupuesto.dart';

class PresupuestoProvider with ChangeNotifier {
  // Lista de presupuestos
  List<Presupuesto> _presupuestos = [];

  // Lista de tarjetas
  List<Map<String, dynamic>> _cards = [];

  // Getters
  List<Presupuesto> get presupuestos => _presupuestos;
  List<Map<String, dynamic>> get cards => _cards;

  // Método para verificar si una tarjeta ya existe (por nombre o número)
  String? tarjetaExiste(String nombre, String numero) {
    final nombreExiste = _cards.any((card) => card['name'] == nombre);
    final numeroExiste = _cards.any((card) => card['number'] == numero);

    if (nombreExiste && numeroExiste) {
      return 'Ya existe una tarjeta con el mismo nombre y número.';
    } else if (nombreExiste) {
      return 'Ya existe una tarjeta con el mismo nombre.';
    } else if (numeroExiste) {
      return 'Ya existe una tarjeta con el mismo número.';
    }
    return null;
  }

  // Método para agregar un presupuesto (MODIFICADO a async)
  Future<void> agregarPresupuesto(Presupuesto presupuesto) async {
    try {
      // Buscar la tarjeta por número
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) {
        throw Exception('Tarjeta no encontrada');
      }

      final saldoActual = double.parse(tarjeta['amount']);
      final nuevoSaldo = saldoActual - presupuesto.cantidad;

      if (nuevoSaldo < 0) {
        throw Exception('Saldo insuficiente en la tarjeta seleccionada');
      }

      // Actualizar el saldo de la tarjeta
      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      _presupuestos.add(presupuesto);
      notifyListeners();
    } catch (e) {
      rethrow; // Permite manejar el error en el UI
    }
  }

  // Método para eliminar un presupuesto (MODIFICADO a async)
  Future<void> eliminarPresupuesto(int index) async {
    try {
      if (index < 0 || index >= _presupuestos.length) return;

      final presupuesto = _presupuestos[index];
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == presupuesto.tarjetaSeleccionada,
        orElse: () => {},
      );

      if (tarjeta.isNotEmpty) {
        // Restaurar el saldo al eliminar el presupuesto
        final saldoActual = double.parse(tarjeta['amount']);
        tarjeta['amount'] = (saldoActual + presupuesto.cantidad).toStringAsFixed(2);
      }

      _presupuestos.removeAt(index);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> limpiarPresupuestos() async {
    _presupuestos.clear();
    notifyListeners(); // Esto ahora está dentro de la clase ChangeNotifier
  }

  // Método para calcular el total de presupuestos
  double calcularTotal() {
    return _presupuestos.fold(0, (sum, presupuesto) => sum + presupuesto.cantidad);
  }

  // Método para agregar tarjetas (MODIFICADO a async)
  Future<void> agregarTarjeta(Map<String, dynamic> nuevaTarjeta) async {
    try {
      // Validar que no exista
      final error = tarjetaExiste(nuevaTarjeta['name'], nuevaTarjeta['number']);
      if (error != null) throw Exception(error);

      // Validar y formatear el monto inicial
      final monto = double.tryParse(nuevaTarjeta['amount']?.toString() ?? '0') ?? 0;
      nuevaTarjeta['amount'] = monto.toStringAsFixed(2);

      _cards.add(nuevaTarjeta);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para eliminar una tarjeta (MODIFICADO a async)
  Future<void> eliminarTarjeta(int index) async {
    try {
      if (index < 0 || index >= _cards.length) return;

      // Eliminar también los presupuestos asociados a esta tarjeta
      final numeroTarjeta = _cards[index]['number'];
      _presupuestos.removeWhere((p) => p.tarjetaSeleccionada == numeroTarjeta);

      _cards.removeAt(index);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método para obtener el saldo de una tarjeta
  double obtenerSaldoTarjeta(String numeroTarjeta) {
    final tarjeta = _cards.firstWhere(
          (card) => card['number'] == numeroTarjeta,
      orElse: () => {},
    );

    if (tarjeta.isEmpty) throw Exception('Tarjeta no encontrada');
    return double.parse(tarjeta['amount']);
  }

  // Método para actualizar el saldo de una tarjeta (MODIFICADO a async)
  Future<void> actualizarSaldoTarjeta(String numeroTarjeta, double nuevoSaldo) async {
    try {
      final tarjeta = _cards.firstWhere(
            (card) => card['number'] == numeroTarjeta,
        orElse: () => {},
      );

      if (tarjeta.isEmpty) throw Exception('Tarjeta no encontrada');
      tarjeta['amount'] = nuevoSaldo.toStringAsFixed(2);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Método: Obtener presupuestos por tarjeta
  List<Presupuesto> presupuestosPorTarjeta(String numeroTarjeta) {
    return _presupuestos.where((p) => p.tarjetaSeleccionada == numeroTarjeta).toList();
  }

  // Método: Calcular total de presupuestos por tarjeta
  double totalPresupuestosPorTarjeta(String numeroTarjeta) {
    return presupuestosPorTarjeta(numeroTarjeta)
        .fold(0, (sum, presupuesto) => sum + presupuesto.cantidad);
  }
}*/


/*import 'package:flutter/material.dart';
import 'package:namer_app/models/presupuesto.dart';

class PresupuestoProvider with ChangeNotifier {
  // Lista de presupuestos
  List<Presupuesto> _presupuestos = [];

  // Lista de tarjetas
  List<Map<String, dynamic>> _cards = [];

  // Getter para obtener la lista de presupuestos
  List<Presupuesto> get presupuestos => _presupuestos;

  // Getter para obtener la lista de tarjetas
  List<Map<String, dynamic>> get cards => _cards;

  // Método para verificar si una tarjeta ya existe (por nombre o número)
  String? tarjetaExiste(String nombre, String numero) {
    // Verificar si el nombre ya existe
    final nombreExiste = _cards.any((card) => card['name'] == nombre);

    // Verificar si el número ya existe
    final numeroExiste = _cards.any((card) => card['number'] == numero);

    if (nombreExiste && numeroExiste) {
      return 'Ya existe una tarjeta con el mismo nombre y número.';
    } else if (nombreExiste) {
      return 'Ya existe una tarjeta con el mismo nombre.';
    } else if (numeroExiste) {
      return 'Ya existe una tarjeta con el mismo número.';
    }

    return null; // No hay duplicados
  }

  // Método para agregar un presupuesto
  void agregarPresupuesto(Presupuesto presupuesto, String tarjetaSeleccionada) {
    // Verificar si la tarjeta seleccionada tiene saldo suficiente
    final tarjeta = _cards.firstWhere(
      (card) => card['name'] == tarjetaSeleccionada,
      orElse: () => {},
    );

    if (tarjeta.isNotEmpty) {
      final saldoTarjeta = double.parse(tarjeta['amount']);
      if (presupuesto.cantidad > saldoTarjeta) {
        throw Exception('Saldo insuficiente en la tarjeta seleccionada');
      }

      // Actualizar el saldo de la tarjeta
      tarjeta['amount'] = (saldoTarjeta - presupuesto.cantidad).toString();
    }

    _presupuestos.add(presupuesto);
    notifyListeners(); // Notifica a los listeners que el estado ha cambiado
  }

  // Método para eliminar un presupuesto
  void eliminarPresupuesto(int index) {
    _presupuestos.removeAt(index);
    notifyListeners();
  }

  // Método para calcular el total de presupuestos
  double calcularTotal() {
    double total = 0;
    for (var presupuesto in _presupuestos) {
      total += presupuesto.cantidad;
    }
    return total;
  }

  // Método para agregar una tarjeta
  void agregarTarjeta(Map<String, dynamic> card) {
    // Verificar si la tarjeta ya existe
    final error = tarjetaExiste(card['name'], card['number']);
    if (error != null) {
      throw Exception(error); // Lanzar excepción con el mensaje de error
    }

    _cards.add(card);
    notifyListeners(); // Notifica a los listeners que el estado ha cambiado
  }

  // Método para eliminar una tarjeta
  void eliminarTarjeta(int index) {
    _cards.removeAt(index);
    notifyListeners();
  }

  // Método para obtener el saldo de una tarjeta
  double obtenerSaldoTarjeta(String nombreTarjeta) {
    final tarjeta = _cards.firstWhere(
      (card) => card['name'] == nombreTarjeta,
      orElse: () => {},
    );

    if (tarjeta.isNotEmpty) {
      return double.parse(tarjeta['amount']);
    } else {
      throw Exception('Tarjeta no encontrada');
    }
  }

  // Método para actualizar el saldo de una tarjeta
  void actualizarSaldoTarjeta(String nombreTarjeta, double nuevoSaldo) {
    final tarjeta = _cards.firstWhere(
      (card) => card['name'] == nombreTarjeta,
      orElse: () => {},
    );

    if (tarjeta.isNotEmpty) {
      tarjeta['amount'] = nuevoSaldo.toString();
      notifyListeners();
    } else {
      throw Exception('Tarjeta no encontrada');
    }
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:namer_app/models/presupuesto.dart';

class PresupuestoProvider with ChangeNotifier {
  // Lista de presupuestos
  List<Presupuesto> _presupuestos = [];

  // Lista de tarjetas
  List<Map<String, dynamic>> _cards = [];

  // Getter para obtener la lista de presupuestos
  List<Presupuesto> get presupuestos => _presupuestos;

  // Getter para obtener la lista de tarjetas
  List<Map<String, dynamic>> get cards => _cards;

  // Método para agregar un presupuesto
  void agregarPresupuesto(Presupuesto presupuesto) {
    _presupuestos.add(presupuesto);
    notifyListeners(); // Notifica a los listeners que el estado ha cambiado
  }

  // Método para eliminar un presupuesto
  void eliminarPresupuesto(int index) {
    _presupuestos.removeAt(index);
    notifyListeners();
  }

  // Método para calcular el total de presupuestos
  double calcularTotal() {
    double total = 0;
    for (var presupuesto in _presupuestos) {
      total += presupuesto.cantidad;
    }
    return total;
  }

  // Método para agregar una tarjeta
  void agregarTarjeta(Map<String, dynamic> card) {
    _cards.add(card);
    notifyListeners(); // Notifica a los listeners que el estado ha cambiado
  }

  // Método para eliminar una tarjeta
  void eliminarTarjeta(int index) {
    _cards.removeAt(index);
    notifyListeners();
  }
}*/
