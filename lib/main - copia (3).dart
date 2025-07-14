import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color darkBlue = const Color(0xFF0B142D);
  bool showIndicators = false;
  bool showCharts = false;
  bool showTable = false;

  int anioSeleccionado = 2024; // o DateTime.now().year
  List<int> aniosDisponibles = [2021, 2022, 2023, 2024, 2025];

  String contratado = '';
  String contratos = '';
  String empresas = '';
  String instituciones = '';

  String formatearMillones(dynamic valor) {
    try {
      final numero = double.parse(valor.toString());
      final millones = numero / 1000000;
      return '\$${millones.toStringAsFixed(1).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}M';
    } catch (e) {
      return valor.toString();
    }
  }

  late Map<String, List<List<dynamic>>> todosLosDatos;
  late Future<void> datosCargados;

  @override
  void initState() {
    super.initState();
    datosCargados = cargarTodosLosArchivos();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => showIndicators = true);
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() => showCharts = true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => showTable = true);
    });
  }

  Future<String> obtenerToken() async {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/adolforosas/kivy-arsemed/main/rsna2023clave.txt',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final textoModificado = response.body;
      final textoSinExtremos = textoModificado.substring(
        4,
        textoModificado.length - 4,
      );
      final textoIntercambiado =
          textoSinExtremos[textoSinExtremos.length - 1] +
          textoSinExtremos.substring(1, textoSinExtremos.length - 1) +
          textoSinExtremos[0];

      String textoOriginal = '';
      for (var caracter in textoIntercambiado.runes) {
        final ascii = (caracter - 8 - 32) % (126 - 32) + 32;
        textoOriginal += String.fromCharCode(ascii);
      }
      return textoOriginal;
    } else {
      throw Exception('No se pudo obtener el token');
    }
  }

  Future<List<List<dynamic>>> leerCsvDesdeGitHub(
    String url,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'token $token'},
    );
    if (response.statusCode == 200) {
      final contenido = const Utf8Decoder().convert(response.bodyBytes);
      final csvData = const CsvToListConverter(eol: '\n').convert(contenido);
      print('✅ Cargado: $url');
      print(
        'Contratado: $contratado, Contratos: $contratos, Empresas: $empresas, Instituciones: $instituciones',
      );
      print(
        'Contratado: $contratado, Contratos: $contratos, Empresas: $empresas, Instituciones: $instituciones',
      );

      return csvData;
    } else {
      throw Exception('Error al leer $url: ${response.statusCode}');
    }
  }

  Future<void> cargarTodosLosArchivos() async {
    final token = await obtenerToken();
    final archivos = [
      'resumenes2.csv',
      for (var anio in [2021, 2022, 2023, 2024, 2025]) ...[
        'top10_$anio.csv',
        'top_10_empresas_${anio}2.csv',
        'top_10_instituciones_${anio}2.csv',
      ],
    ];

    final mapa = <String, List<List<dynamic>>>{};
    for (final archivo in archivos) {
      final url =
          'https://raw.githubusercontent.com/adolforosas/datos-app/main/$archivo';
      final datos = await leerCsvDesdeGitHub(url, token);
      mapa[archivo] = datos;
    }
    todosLosDatos = mapa;
    asignarValoresDesdeResumen();

    todosLosDatos = mapa;
  }

  void asignarValoresDesdeResumen() {
    final resumen = todosLosDatos['resumenes2.csv'];
    if (resumen != null && resumen.length > 1) {
      for (var fila in resumen.skip(1)) {
        if (fila.isNotEmpty &&
            fila[0].toString().trim() == anioSeleccionado.toString()) {
          setState(() {
            contratado = fila[1].toString();
            contratos = fila[2].toString();
            empresas = fila[3].toString();
            instituciones = fila[4].toString();
          });
          break;
        }
      }
    }
  }

  double calcularMaxY(String archivoCsv) {
    final datos = todosLosDatos[archivoCsv];
    if (datos == null || datos.length < 2) return 100.0;
    final valor = double.tryParse(datos[1][1].toString()) ?? 0.0;
    return valor * 1.10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        centerTitle: true,
        title: const Text(
          'Arsemed - Compras Públicas',
          style: TextStyle(
            color: Color.fromARGB(255, 182, 204, 232),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Año:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: anioSeleccionado,
                    dropdownColor: const Color(0xFF1A2B4C),
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.white,
                    items: aniosDisponibles.map((anio) {
                      return DropdownMenuItem<int>(
                        value: anio,
                        child: Text(
                          anio.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (nuevoAnio) {
                      if (nuevoAnio != null) {
                        setState(() {
                          anioSeleccionado = nuevoAnio;
                        });
                        asignarValoresDesdeResumen();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (!showIndicators)
                _buildLoadingMessage()
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildIndicator('Contratado', contratado),
                        ),
                        Expanded(
                          child: _buildIndicator('Contratos', contratos),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildIndicator('Empresas', empresas)),
                        Expanded(
                          child: _buildIndicator(
                            'Instituciones',
                            instituciones,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 20),
              FutureBuilder<void>(
                future: datosCargados,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return _buildLoadingMessage();
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    );
                  } else {
                    return Column(
                      children: [
                        _buildBarChart(
                          chartTitle:
                              'Instituciones con más compras (Millones)',
                          maxY: calcularMaxY(
                            'top_10_instituciones_${anioSeleccionado}2.csv',
                          ),
                          barGroups: [
                            for (
                              int i = 1;
                              i <
                                  (todosLosDatos['top_10_instituciones_${anioSeleccionado}2.csv']
                                          ?.length ??
                                      0);
                              i++
                            )
                              _makeBarGroup(
                                double.tryParse(
                                      todosLosDatos['top_10_instituciones_${anioSeleccionado}2.csv']![i][1]
                                          .toString(),
                                    ) ??
                                    0.0,
                                i,
                              ),
                          ],
                          bottomLabels: {
                            for (
                              int i = 1;
                              i <
                                  (todosLosDatos['top_10_instituciones_${anioSeleccionado}2.csv']
                                          ?.length ??
                                      0);
                              i++
                            )
                              i: todosLosDatos['top_10_instituciones_${anioSeleccionado}2.csv']![i][0]
                                  .toString(),
                          },
                        ),

                        const SizedBox(height: 30),
                        _buildBarChart(
                          chartTitle: 'Empresas con más ventas (Millones)',
                          maxY: calcularMaxY(
                            'top_10_empresas_${anioSeleccionado}2.csv',
                          ),
                          barGroups: [
                            for (
                              int i = 1;
                              i <
                                  (todosLosDatos['top_10_empresas_${anioSeleccionado}2.csv']
                                          ?.length ??
                                      0);
                              i++
                            )
                              _makeBarGroup(
                                double.tryParse(
                                      todosLosDatos['top_10_empresas_${anioSeleccionado}2.csv']![i][1]
                                          .toString(),
                                    ) ??
                                    0.0,
                                i,
                              ),
                          ],
                          bottomLabels: {
                            for (
                              int i = 1;
                              i <
                                  (todosLosDatos['top_10_empresas_${anioSeleccionado}2.csv']
                                          ?.length ??
                                      0);
                              i++
                            )
                              i: todosLosDatos['top_10_empresas_${anioSeleccionado}2.csv']![i][0]
                                  .toString(),
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Los 10 contratos más grandes',
                style: TextStyle(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(height: 30),
              if (!showTable)
                _buildLoadingMessage()
              else
                FutureBuilder<void>(
                  future: datosCargados,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return _buildLoadingMessage();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      );
                    } else {
                      final archivo = 'top10_${anioSeleccionado}.csv';
                      final data = todosLosDatos[archivo] ?? [];
                      return _buildTopContractsTable(data);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: const [
        CircularProgressIndicator(color: Colors.orange),
        SizedBox(height: 10),
        Text('Cargando...', style: TextStyle(color: Colors.white)),
      ],
    ),
  );

  static Widget _buildIndicator(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFF1A2B4C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.orange, fontSize: 16)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 20)),
        ],
      ),
    );
  }

  static Widget _buildBarChart({
    required String chartTitle,
    required List<BarChartGroupData> barGroups,
    required Map<int, String> bottomLabels,
    required double maxY,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(chartTitle, style: TextStyle(color: Colors.white, fontSize: 28)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: barGroups.length * 150,
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.start,
                maxY: maxY,
                barGroups: barGroups,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt() - 1;
                        if (index < 0 || index >= barGroups.length)
                          return const SizedBox();

                        final double barValue =
                            barGroups[index].barRods.first.toY;
                        final String textoFormateado =
                            '\$${barValue.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            textoFormateado,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final label = (bottomLabels[value.toInt()] ?? '');
                        final shortLabel = label.length > 17
                            ? label.substring(0, 17)
                            : label;
                        return Transform.rotate(
                          angle: -0.12,
                          child: Text(
                            shortLabel,
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 20),
                  ),

                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static BarChartGroupData _makeBarGroup(double value, int x) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 60,
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.zero,
        ),
      ],
    );
  }

  Widget _buildTopContractsTable(List<List<dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.white),
        columnWidths: const {
          0: FixedColumnWidth(88),
          1: FixedColumnWidth(180),
          2: FixedColumnWidth(85),
          3: FixedColumnWidth(120),
        },
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFF1A2B4C)),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Institución',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Proveedor',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Importe',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Producto',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          for (var i = 0; i < data.length; i++)
            _tableRow(
              data[i][0].toString(),
              data[i][1].toString(),
              data[i][2].toString(),
              data[i][3].toString(),
            ),
        ],
      ),
    );
  }

  TableRow _tableRow(String inst, String prov, String imp, String prod) {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF1A2B4C)),
      children: [
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(inst, style: TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(prov, style: TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(
            formatearMillones(imp),
            style: TextStyle(color: Colors.white),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(
            prod,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
