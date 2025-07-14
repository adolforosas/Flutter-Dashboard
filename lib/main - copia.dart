import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final Color darkBlue = const Color(0xFF0B142D);

  const DashboardPage({super.key});

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
                children: [
                  Expanded(
                    child: _buildIndicator('Contratado', '\$9,731,675,758'),
                  ),
                  Expanded(child: _buildIndicator('Contratos', '8104')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildIndicator('Empresas', '151')),
                  Expanded(child: _buildIndicator('Instituciones', '116')),
                ],
              ),
              const SizedBox(height: 20),
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
                  _makeBarGroup(1162.845437, 0),
                  _makeBarGroup(1048.33051, 1),
                  _makeBarGroup(963.4382813, 2),
                  _makeBarGroup(636.0526559, 3),
                  _makeBarGroup(549.2869165, 4),
                  _makeBarGroup(526.2142145, 5),
                  _makeBarGroup(409.4746187, 6),
                  _makeBarGroup(350.7160624, 7),
                  _makeBarGroup(341.985, 8),
                  _makeBarGroup(320.34517, 9),
                ],
                bottomLabels: {
                  0: 'Siemens Healthcare Diagnostics S De Rl De Cv',
                  1: 'Human Corporis Sa De Cv',
                  2: 'Ge Sistemas Medicos De Mexico Sa De Cv',
                  3: 'Servicio Y Venta De Insumos Medicos Especiali',
                  4: 'Drager Medical Mexico Sa De Cv',
                  5: 'Electronica Y Medicina Sa',
                  6: 'Cyber Robotic Solutions Sa De Cv',
                  7: 'Amc Biomedical Sa De Cv',
                  8: 'Eureka Salud Sa De Cv',
                  9: 'Maro Health Sa De Cv',
                },
              ),
              Text(
                'Los 10 contratos más grandes',
                style: TextStyle(color: Colors.white, fontSize: 28),
                textAlign: TextAlign
                    .left, // Alineación del texto a la izquierda (opcional)
              ),
              const SizedBox(height: 30),
              _buildTopContractsTable(),
            ],
          ),
        ),
      ),
    );
  }

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
                        final shortLabel = label.length > 17
                            ? label.substring(0, 17)
                            : label;
                        return Transform.rotate(
                          angle: -0.12,
                          child: Text(
                            shortLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value >= 1000000
                              ? '${(value / 1000000).toStringAsFixed(1)}M'
                              : value.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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

  static Widget _buildTopContractsTable() {
    return Table(
      border: TableBorder.all(color: Colors.white),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
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
        _tableRow(
          'IMSS',
          'HUMAN CORPORIS SA DE CV',
          '\$400.77 M',
          'Radioterapia',
        ),
        _tableRow(
          'IMSS',
          'GE SISTEMAS MEDICOS DE MEXICO SA DE CV',
          '\$260.11 M',
          'Resonancia magnética',
        ),
        _tableRow(
          'IMSS',
          'ENERLOGIC S A P I DE CV',
          '\$254.77 M',
          'Refrigeración',
        ),
        _tableRow(
          'SEDENA',
          'SIEMENS HEALTHCARE DIAGNOSTICS S DE RL DE CV',
          '\$223.38 M',
          'Servicios',
        ),
        _tableRow(
          'INSABI',
          'BIOSYSTEMS HLS SA DE CV',
          '\$179.30 M',
          'Cuidado materno infantil',
        ),
        _tableRow(
          'INSABI',
          'CASONATO STEELCO SPA SA DE CV',
          '\$172.67 M',
          'Esterilizador',
        ),
        _tableRow(
          'MICH',
          'MOVIL INFRA TECHNOLOGY S A P I DE CV',
          '\$172.13 M',
          'Varios',
        ),
        _tableRow(
          'IMSSBIENESTAR',
          'SERVICIO Y VENTA DE INSUMOS MEDICOS ESPECIALI',
          '\$170.39 M',
          'Tomografía',
        ),
        _tableRow(
          'IMSS',
          'CASONATO STEELCO SPA SA DE CV',
          '\$160.06 M',
          'Esterilizador',
        ),
      ],
    );
  }

  static TableRow _tableRow(String inst, String prov, String imp, String prod) {
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
          child: Text(imp, style: TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(prod, style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
