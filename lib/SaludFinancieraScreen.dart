import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AddCardScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';
import 'package:flutter_application_1/WalletScreen.dart';
import 'package:http/http.dart' as http;

class Tarjeta {
  final int id;
  final String nombreTarjeta;
  final String numeroTarjeta;
  final double monto;

  Tarjeta({
    required this.id,
    required this.nombreTarjeta,
    required this.numeroTarjeta,
    required this.monto,
  });

  factory Tarjeta.fromJson(Map<String, dynamic> json) {
    double montoValor;
    if (json['monto'] is String) {
      montoValor = double.parse(json['monto']);
    } else if (json['monto'] is int) {
      montoValor = (json['monto'] as int).toDouble();
    } else {
      montoValor = json['monto'];
    }
    return Tarjeta(
      id: json['id'],
      nombreTarjeta: json['nombre_tarjeta'],
      numeroTarjeta: json['numero_tarjeta'],
      monto: montoValor,
    );
  }
}

class Movimiento {
  final String encabezado;
  final String tipo;
  final double monto;
  final DateTime fecha;
  final int tarjetaId;

  Movimiento({
    required this.encabezado,
    required this.tipo,
    required this.monto,
    required this.fecha,
    required this.tarjetaId,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    double montoValor;
    if (json['monto'] is String) {
      montoValor = double.parse(json['monto']);
    } else if (json['monto'] is int) {
      montoValor = (json['monto'] as int).toDouble();
    } else {
      montoValor = json['monto'];
    }
    return Movimiento(
      encabezado: json['encabezado'],
      tipo: json['tipo'],
      monto: montoValor,
      fecha: DateTime.parse(json['fecha_movimiento']),
      tarjetaId: json['tarjeta_id'],
    );
  }
}

class SaludFinancieraScreen extends StatefulWidget {
  final String nombreUsuario;
  final String correo;

  const SaludFinancieraScreen({
    Key? key,
    required this.nombreUsuario,
    required this.correo,
  }) : super(key: key);

  @override
  _SaludFinancieraScreenState createState() => _SaludFinancieraScreenState();
}

class _SaludFinancieraScreenState extends State<SaludFinancieraScreen> {
  String _selectedFilter = 'De hoy';
  Tarjeta? _selectedCard;
  bool _isLoading = true;
  bool _showingGastos = true;
  int _currentIndex = 1;

  List<Movimiento> _movimientos = [];
  double _totalOperaciones = 0.0;
  double _totalGastos = 0.0;
  double _totalIngresos = 0.0;

  List<Tarjeta> _tarjetas =
      []; // Lista global a nivel de estado //NO TOCAR NO TOCAR
  static const String baseUrl =
      'http://10.0.2.2:3000'; //'http://10.0.2.2:3000 o 'http://192.168.1.71:3000'

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  /// Función para eliminar acentos en una cadena.
  String removeDiacritics(String str) {
    // Define pares de caracteres acentuados y no acentuados.
    const Map<String, String> diacriticsMap = {
      "á": "a",
      "à": "a",
      "ä": "a",
      "â": "a",
      "ã": "a",
      "Á": "A",
      "À": "A",
      "Ä": "A",
      "Â": "A",
      "Ã": "A",
      "é": "e",
      "è": "e",
      "ë": "e",
      "ê": "e",
      "É": "E",
      "È": "E",
      "Ë": "E",
      "Ê": "E",
      "í": "i",
      "ì": "i",
      "ï": "i",
      "î": "i",
      "Í": "I",
      "Ì": "I",
      "Ï": "I",
      "Î": "I",
      "ó": "o",
      "ò": "o",
      "ö": "o",
      "ô": "o",
      "õ": "o",
      "Ó": "O",
      "Ò": "O",
      "Ö": "O",
      "Ô": "O",
      "Õ": "O",
      "ú": "u",
      "ù": "u",
      "ü": "u",
      "û": "u",
      "Ú": "U",
      "Ù": "U",
      "Ü": "U",
      "Û": "U",
      "ñ": "n",
      "Ñ": "N",
      "ç": "c",
      "Ç": "C",
    };

    diacriticsMap.forEach((key, value) {
      str = str.replaceAll(key, value);
    });
    return str;
  }

  /// Función para categorizar un movimiento. Se normaliza tanto el encabezado como
  /// cada palabra clave para que la comparación sea insensible a mayúsculas, minúsculas y acentos.
  String categorizarMovimiento(String encabezado) {
    final descripcionNormalizada = removeDiacritics(encabezado).toLowerCase();

    final Map<String, List<String>> categoriasClave = {
      "Básicos": [
        "supermercado",
        "super",
        "mercado",
        "comida",
        "alquiler",
        "servicios",
        "transporte",
        "pasaje",
        "gas",
        "agua",
        "luz",
        "telefono",
        "renta",
        "hipoteca",
        "despensa",
        "ropa",
        "celular",
        "computadora",
        "educacion",
      ],
      "Entretenimiento": [
        "cine",
        "suscripcion",
        "juegos",
        "concierto",
        "eventos",
        "Netflix",
        "Spotify",
        "Amazon",
        "Disney+",
        "HBO MAX",
        "videojuego",
      ],
      "Finanzas": [
        "banco",
        "inversion",
        "ahorro",
        "prestamo",
        "intereses",
        "deudas",
        "deuda",
        "curso",
        "deposito",
        "transferencia",
      ],
      "Salud": [
        "medico",
        "farmacia",
        "seguro",
        "hospital",
        "gimnasio",
        "medicinas",
      ],
      "Otros": [
        "otros",
        "misc",
        "varios",
        "regalo",
        "donacion",
        "fiesta",
        "celebracion",
        "navidad",
        "cumpleaños",
        "cumple",
        "cumpleaño",
        "vacaciones",
        "viaje",
        "viajar",
        "turismo",
        "hotel",
        "reloj",
      ],
    };

    for (var categoria in categoriasClave.keys) {
      for (var palabraClave in categoriasClave[categoria]!) {
        // Normalizamos la palabra clave para la comparación.
        final palabraNormalizada = removeDiacritics(palabraClave).toLowerCase();
        if (descripcionNormalizada.contains(palabraNormalizada)) {
          return categoria;
        }
      }
    }
    return "Otros"; // O la categoría que decidas en caso de no haber coincidencias.
  }

  /// Mapa que relaciona cada categoría con un Color específico.
  final Map<String, Color> coloresCategoria = {
    "Básicos": Colors.blue,
    "Entretenimiento": Colors.orange,
    "Finanzas": Colors.green,
    "Salud": Colors.red,
    "Otros": Colors.grey, // Color asignado para la categoría 'Otros'
  };

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    // Primero carga las tarjetas para seleccionar la adecuada.
    await _loadTarjetas();
    // Solo si ya se seleccionó una tarjeta, se cargan los movimientos.
    if (_selectedCard != null) {
      await _loadMovimientos();
      _recalcularTotalesFiltrados();
    } else {
      print("No hay tarjeta seleccionada.");
    }
    setState(() => _isLoading = false);
  }

  Future<List<Tarjeta>> fetchTarjetas(String correo) async {
    final url = Uri.parse('$baseUrl/tarjetas/$correo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> tarjetasJson = json.decode(response.body);
      return tarjetasJson.map((json) => Tarjeta.fromJson(json)).toList();
    }
    throw Exception('Error al cargar tarjetas');
  }

  Future<void> _loadTarjetas() async {
    try {
      final tarjetas = await fetchTarjetas(widget.correo);
      print('Tarjetas obtenidas correctamente: $tarjetas');
      setState(() {
        _tarjetas = tarjetas;
        if (tarjetas.isNotEmpty) {
          _selectedCard = tarjetas.first;
        }
      });
    } catch (e) {
      print('Error al cargar tarjetas: $e');
    }
  }

  Future<List<Movimiento>> fetchMovimientos(
    String correo,
    int tarjetaId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/movimientos?correo=$correo&tarjeta_id=$tarjetaId',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> movimientosJson = json.decode(response.body);
      return movimientosJson.map((json) => Movimiento.fromJson(json)).toList();
    }
    throw Exception('Error al cargar movimientos');
  }

  Future<void> _loadMovimientos() async {
    try {
      // Se asume que _selectedCard no es nulo ya que lo cargaste previamente.
      final movimientos = await fetchMovimientos(
        widget.correo,
        _selectedCard!.id,
      );
      print('Movimientos obtenidos correctamente: $movimientos');
      setState(() => _movimientos = movimientos);
    } catch (e) {
      print('Error al cargar movimientos: $e');
    }
  }

  void _recalcularTotalesFiltrados() {
    if (_selectedCard == null) return;
    double ingresos = 0.0, gastos = 0.0;

    DateTime now = DateTime.now();
    DateTime start;
    DateTime end;
    DateTime hoy = DateTime(now.year, now.month, now.day); // hoy a las 00:00

    // Definir el rango de fechas según el filtro seleccionado
    switch (_selectedFilter) {
      case 'De hoy':
        start = hoy;
        end = hoy.add(
          Duration(days: 1),
        ); // hasta mañana a las 00:00 (excluyente)
        break;
      case 'Últimos 7 días':
        // Para incluir 7 días completos (hoy y 6 días anteriores)
        start = hoy.subtract(Duration(days: 6));
        end = hoy.add(Duration(days: 1));
        break;
      case 'Mes':
        start = DateTime(now.year, now.month, 1);
        end =
            (now.month == 12)
                ? DateTime(now.year + 1, 1, 1)
                : DateTime(now.year, now.month + 1, 1);
        break;
      default:
        start = hoy;
        end = hoy.add(Duration(days: 1));
    }

    // Recorre los movimientos y suma solo los que correspondan a la tarjeta seleccionada
    // y que caigan dentro del rango de fechas.
    for (var mov in _movimientos) {
      if (mov.tarjetaId != _selectedCard!.id) continue;
      // Comprobamos si el movimiento está en el rango [start, end)
      if (mov.fecha.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          mov.fecha.isBefore(end)) {
        if (mov.tipo.toLowerCase() == 'ingreso') {
          ingresos += mov.monto;
        } else if (mov.tipo.toLowerCase() == 'gasto') {
          gastos += mov.monto;
        }
      }
    }
    // Mensajes de depuración para confirmar los totales filtrados
    print('Total ingresos filtrado: $ingresos');
    print('Total gastos filtrado: $gastos');

    setState(() {
      _totalIngresos = ingresos;
      _totalGastos = gastos;
      _totalOperaciones = _showingGastos ? gastos : ingresos;
    });
  }

  List<Movimiento> _getMovimientosFiltrados() {
    DateTime now = DateTime.now();
    DateTime hoy = DateTime(now.year, now.month, now.day);
    DateTime start, end;

    switch (_selectedFilter) {
      case 'Día':
        start = hoy;
        end = hoy.add(Duration(days: 1));
        break;
      case 'Últimos 7 días':
        start = hoy.subtract(Duration(days: 6));
        end = hoy.add(Duration(days: 1));
        break;
      case 'Mes':
        start = DateTime(now.year, now.month, 1);
        end =
            (now.month == 12)
                ? DateTime(now.year + 1, 1, 1)
                : DateTime(now.year, now.month + 1, 1);
        break;
      default:
        start = hoy;
        end = hoy.add(Duration(days: 1));
    }

    // Filtrar primero por fecha
    List<Movimiento> filtradosPorFecha =
        _movimientos.where((mov) {
          return mov.fecha.isAfter(start.subtract(Duration(milliseconds: 1))) &&
              mov.fecha.isBefore(end);
        }).toList();

    // Luego, según la vista actual, filtrar por tipo de movimiento
    if (_showingGastos) {
      return filtradosPorFecha
          .where((mov) => mov.tipo.toLowerCase() == 'gasto')
          .toList();
    } else {
      return filtradosPorFecha
          .where((mov) => mov.tipo.toLowerCase() == 'ingreso')
          .toList();
    }
  }

  Map<String, double> _getTotalesPorCategoria() {
    // Obtenemos los movimientos ya filtrados por fecha y tipo (ingresos o gastos)
    List<Movimiento> movsFiltrados = _getMovimientosFiltrados();
    Map<String, double> totales = {};

    for (var mov in movsFiltrados) {
      // Se categoriza el movimiento por su encabezado
      String categoria = categorizarMovimiento(mov.encabezado);
      // Acumulamos el monto de cada movimiento en la categoría correspondiente
      totales[categoria] = (totales[categoria] ?? 0) + mov.monto;
    }
    return totales;
  }

  // Genera las secciones del gráfico de pastel según la vista (Gastos o Ingresos).
  List<PieChartSectionData> _generatePieChartSectionsPorCategoria() {
    // Obtenemos el mapa de totales para cada categoría
    final Map<String, double> totales = _getTotalesPorCategoria();

    // Calculamos el total global (suma de todos los montos)
    double totalGlobal = totales.values.fold(
      0.0,
      (prev, element) => prev + element,
    );

    List<PieChartSectionData> sections = [];

    // Iteramos sobre cada categoría para crear una sección correspondiente
    totales.forEach((categoria, monto) {
      // Calculamos porcentaje (si totalGlobal es 0, asignamos 0 para evitar división por cero)
      double porcentaje = totalGlobal > 0 ? (monto / totalGlobal) * 100 : 0;

      // Obtenemos el color definido en el mapa; si no, usamos un color por defecto (gris)
      Color color = coloresCategoria[categoria] ?? Colors.grey;

      // Creamos la sección para el gráfico
      sections.add(
        PieChartSectionData(
          color: color,
          // Si monto es 0, se podría asignar un valor mínimo para que se muestre algo (o simplemente 0)
          value: monto == 0 ? 1 : monto,
          title: '${porcentaje.toStringAsFixed(0)}%',
          radius: 50, // O cualquier radio que desees
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    // Si no se encontraron transacciones (sección vacía), agregamos una sección dummy
    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: "0%",
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  // Construye el ícono de cada categoría.
  Widget _buildCategoryIcon(String label, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.7),
          radius: 20,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Construye cada ítem para la lista de movimientos (transacciones).
  Widget _buildTransactionItem(
    String title,
    String amount,
    Color indicatorColor,
  ) {
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: indicatorColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(title),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Obtener la lista de movimientos filtrados según el rango (_selectedFilter)
    List<Movimiento> movimientosFiltrados =
        _getMovimientosFiltrados(); //NO TOCAR NO TOCAR

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => WalletScreen(
                        correo: widget.correo,
                        nombreUsuario: widget.nombreUsuario,
                      ),
                ),
              );
            }
          },
        ),
        // Título compuesto por una columna que muestra el título principal y el subtítulo del modo actual.
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Salud Financiera'),
            Text(
              _showingGastos ? 'Gastos' : 'Ingresos',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        // PopupMenuButton para alternar entre Gastos e Ingresos.
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _showingGastos = (value == 'Gastos');
                // Actualizamos _totalOperaciones según el filtro seleccionado.
                _totalOperaciones =
                    _showingGastos ? _totalGastos : _totalIngresos;
              });
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'Gastos', child: Text('Gastos')),
                  PopupMenuItem(value: 'Ingresos', child: Text('Ingresos')),
                ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      // Envolvemos todo el contenido en SingleChildScrollView para que sea desplazable.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Botón para elegir la tarjeta.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: screenWidth * 0.9,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _showCardSelection,
                    child: Text(
                      'Tarjeta Seleccionada: ${_selectedCard?.nombreTarjeta ?? 'Seleccionar'}',
                    ),
                  ),
                ),
              ),
            ),
            // Fila: Saldo de la tarjeta y botón de filtro.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo de la tarjeta',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedCard != null
                            ? '\$${_selectedCard!.monto.toStringAsFixed(2)}'
                            : '\$0.00',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _showFilterOptions,
                    child: Text('Filtro: $_selectedFilter'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Área del gráfico de pastel en un contenedor con altura definida.
            // Aquí se ajusta el margen para separar del resto de elementos.
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              padding: const EdgeInsets.all(10),
              height: 200,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: _generatePieChartSectionsPorCategoria(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      return;
                                    }
                                  });
                                },
                              ),
                            ),
                            swapAnimationDuration: const Duration(
                              milliseconds: 800,
                            ),
                            swapAnimationCurve: Curves.easeInOut,
                          ),
                          Center(
                            child: Text(
                              '\$${_totalOperaciones.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
            // Fila de categorías: Se muestran diferentes iconos según la vista seleccionada.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:
                  _showingGastos
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCategoryIcon(
                            'Básicos',
                            Colors.blue,
                            Icons.home,
                          ),
                          _buildCategoryIcon(
                            'Entretenimiento',
                            Colors.orange,
                            Icons.movie,
                          ),
                          _buildCategoryIcon(
                            'Finanzas',
                            Colors.green,
                            Icons.account_balance,
                          ),
                          _buildCategoryIcon(
                            'Salud',
                            Colors.red,
                            Icons.health_and_safety,
                          ),
                          _buildCategoryIcon(
                            'Otros',
                            Colors.grey,
                            Icons.attach_money_rounded,
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildCategoryIcon(
                            'Trabajo',
                            Colors.blue,
                            Icons.work,
                          ),
                          _buildCategoryIcon(
                            'Inversión',
                            Colors.green,
                            Icons.trending_up,
                          ),
                          _buildCategoryIcon(
                            'Bienestar',
                            Colors.red,
                            Icons.attach_money_rounded,
                          ),
                        ],
                      ),
            ),
            const SizedBox(height: 10),
            // Justo después del SizedBox que separa la fila de categorías de los movimientos:
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Movimientos recientes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            // Lista de movimientos filtrados.
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movimientosFiltrados.length,
              itemBuilder: (context, index) {
                final mov = movimientosFiltrados[index];
                final categoria = categorizarMovimiento(mov.encabezado);
                final colorCategoria =
                    coloresCategoria[categoria] ?? Colors.grey;
                return _buildTransactionItem(
                  mov.encabezado,
                  mov.tipo.toLowerCase() == 'gasto'
                      ? '-\$${mov.monto.toStringAsFixed(2)}'
                      : '+\$${mov.monto.toStringAsFixed(2)}',
                  colorCategoria,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      // Botón de navegación inferior (ButtonNavigationBar ya implementado en walletScreen y AddCardScreen)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          // Actualiza el índice y navega según el ítem seleccionado.
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => WalletScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
              ),
            );
          } else if (index == 1) {
            // Ítem "Salud Financiera": navegamos a la pantalla correspondiente.
            setState(() {
              _currentIndex = index;
            });
          } else if (index == 2) {
            // Agregar Tarjeta: usa animación slide para navegar a AddCardScreen.
            await Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder:
                    (context, animation, secondaryAnimation) => AddCardScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
            // Después de regresar de AddCardScreen, actualiza el índice.
            setState(() {
              _currentIndex = 1; // Regresa al índice de Salud Financiera.
            });
          } else if (index == 3) {
            // Perfil: navega a la pantalla de Perfil (ejemplo).
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ProfileScreen(
                      correo: widget.correo,
                      nombreUsuario: widget.nombreUsuario,
                    ),
              ),
            );
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tarjetas"),

          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            label: "Salud Financiera",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_card_rounded),
            label: "Agregar Tarjeta",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  // Método para mostrar la lista de tarjetas en un modal inferior
  void _showCardSelection() async {
    try {
      // Muestra un diálogo de carga mientras se obtienen las tarjetas
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final tarjetas = await fetchTarjetas(widget.correo);
      Navigator.pop(context); // Cierra el diálogo de carga

      // Ahora muestra el modal con la lista de tarjetas
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: tarjetas.length,
            itemBuilder: (context, index) {
              final tarjeta = tarjetas[index];
              return ListTile(
                title: Text(tarjeta.nombreTarjeta),
                subtitle: Text('Saldo: \$${tarjeta.monto.toStringAsFixed(2)}'),
                onTap: () {
                  setState(() {
                    // Actualiza la tarjeta seleccionada, aquí puedes almacenar el objeto completo o solo el nombre, depende de tu lógica
                    _selectedCard = tarjeta;
                    // Además, podrías actualizar el saldo mostrado en la interfaz u otros datos
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // Cierra el diálogo de carga si ocurre un error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar tarjetas: $e')));
    }
  }

  // Método para mostrar las opciones de filtro en un modal inferior.
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text("De hoy"),
              onTap: () {
                setState(() {
                  _selectedFilter = "De hoy";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Últimos 7 días"),
              onTap: () {
                setState(() {
                  _selectedFilter = "Últimos 7 días";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Mes"),
              onTap: () {
                setState(() {
                  _selectedFilter = "Mes";
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}