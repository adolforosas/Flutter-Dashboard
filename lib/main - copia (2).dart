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

  String formatearMillones(dynamic valor) {
    try {
      final numero = double.parse(valor.toString());
      final millones = numero / 1000000;
      return '\$${millones.toStringAsFixed(1).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}M';
    } catch (e) {
      return valor.toString();
    }
  }

  late Future<List<List<dynamic>>> contratos2022;

  @override
  void initState() {
    super.initState();

    contratos2022 = cargarTop10Contratos();

    Future.delayed(const Duration(milliseconds: 2300), () {
      setState(() => showIndicators = true);
    });
    Future.delayed(const Duration(milliseconds: 3900), () {
      setState(() => showCharts = true);
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
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
      return csvData;
    } else {
      throw Exception('Error al leer $url: ${response.statusCode}');
    }
  }

  Future<List<List<dynamic>>> cargarTop10Contratos() async {
    final token = await obtenerToken();
    final url =
        'https://raw.githubusercontent.com/adolforosas/datos-app/main/top10_2022.csv';
    return await leerCsvDesdeGitHub(url, token);
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
              if (!showIndicators)
                _buildLoadingMessage()
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildIndicator(
                            'Contratado',
                            '\$9,731,675,758',
                          ),
                        ),
                        Expanded(child: _buildIndicator('Contratos', '8104')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildIndicator('Empresas', '151')),
                        Expanded(
                          child: _buildIndicator('Instituciones', '116'),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (!showCharts)
                _buildLoadingMessage()
              else
                Column(
                  children: [
                    _buildBarChart(
                      chartTitle: 'Instituciones con más compras (Millones)',
                      maxY: 10000000000,
                      barGroups: [
                        _makeBarGroup(9816581609, 0),
                        _makeBarGroup(2750607883, 1),
                        _makeBarGroup(1197166095, 2),
                        _makeBarGroup(1093500864, 3),
                        _makeBarGroup(536427903.3, 4),
                        _makeBarGroup(309405787.4, 5),
                        _makeBarGroup(244887058.7, 6),
                        _makeBarGroup(209407097.2, 7),
                        _makeBarGroup(187850003.7, 8),
                        _makeBarGroup(180751672.8, 9),
                      ],
                      bottomLabels: {
                        0: 'IMSS',
                        1: 'SEDENA',
                        2: 'IMSSB',
                        3: 'ISSSTE',
                        4: 'SEMAR',
                        5: 'HGO',
                        6: 'INCAN',
                        7: 'GTO',
                        8: 'PUE',
                        9: 'SADM',
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildBarChart(
                      chartTitle: 'Empresas con más ventas (Millones)',
                      maxY: 1200,
                      barGroups: [
                        _makeBarGroup(1162.84, 0),
                        _makeBarGroup(1048.33, 1),
                        _makeBarGroup(963.44, 2),
                        _makeBarGroup(636.05, 3),
                        _makeBarGroup(549.29, 4),
                        _makeBarGroup(526.21, 5),
                        _makeBarGroup(409.47, 6),
                        _makeBarGroup(350.72, 7),
                        _makeBarGroup(341.99, 8),
                        _makeBarGroup(320.35, 9),
                      ],
                      bottomLabels: {
                        0: 'Siemens Healthcare',
                        1: 'Human Corporis',
                        2: 'GE Sistemas Médicos',
                        3: 'Insumos Especiali',
                        4: 'Dräger Medical',
                        5: 'Electrónica y Med.',
                        6: 'Cyber Robotic',
                        7: 'AMC Biomedical',
                        8: 'Eureka Salud',
                        9: 'Maro Health',
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              Text(
                'Los 10 contratos más grandes',
                style: const TextStyle(color: Colors.white, fontSize: 28),
              ),
              const SizedBox(height: 30),
              if (!showTable)
                _buildLoadingMessage()
              else
                FutureBuilder<List<List<dynamic>>>(
                  future: contratos2022,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return _buildLoadingMessage();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text(
                        'No hay datos disponibles',
                        style: TextStyle(color: Colors.white),
                      );
                    } else {
                      return _buildTopContractsTable(snapshot.data!);
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
        color: const Color(0xFF1A2B4C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.orange, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
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
        Text(
          chartTitle,
          style: const TextStyle(color: Colors.white, fontSize: 28),
        ),
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
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final label = (bottomLabels[value.toInt()] ?? '');
                        final shortLabel = label.length > 14
                            ? label.substring(0, 14)
                            : label;
                        return Transform.rotate(
                          angle: -0.4,
                          child: Text(
                            shortLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        value >= 1000000
                            ? '${(value / 1000000).toStringAsFixed(1)}M'
                            : value.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /*static BarChartGroupData _makeBarGroup(double value, int x) {
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
*/
  Widget _buildTopContractsTable(List<List<dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.white),
        columnWidths: const {
          0: FixedColumnWidth(88), // Institución
          1: FixedColumnWidth(150), // Proveedor
          2: FixedColumnWidth(85), // Importe
          3: FixedColumnWidth(100), // Producto
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
          for (
            var i = 0;
            i < data.length;
            i++
          ) // Comienza desde 1 para omitir encabezados
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
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
