import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Histogram extends StatelessWidget {
  static const length = 256;

  final ImageProvider image;

  const Histogram({Key key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final redData = List.filled(length, 0.0);
    final greenData = List.filled(length, 0.0);
    final blueData = List.filled(length, 0.0);
    final completer = Completer();
    final imageStream = image.resolve(const ImageConfiguration());
    imageStream.addListener(ImageStreamListener((image, _) async {
      final width = image.image.width;
      final height = image.image.height;
      final byteData = await image.image.toByteData();
      for (var x = 0; x < width; x += 1) {
        for (var y = 0; y < height; y += 1) {
          final color = Color(byteData.getInt32(4 * (x + (y * width))) >> 8);
          redData[color.red] += 1;
          greenData[color.green] += 1;
          blueData[color.blue] += 1;
        }
      }
      completer.complete();
    }));
    return FutureBuilder(
      future: completer.future,
      builder: (_, snapshot) {
        if (redData[0] == 0 && greenData[0] == 0 && blueData[0] == 0) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return LineChart(LineChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            lineData(redData, const [Colors.redAccent]),
            lineData(greenData, const [Colors.greenAccent]),
            lineData(blueData, const [Colors.blueAccent]),
          ],
        ));
      },
    );
  }

  LineChartBarData lineData(List<double> data, List<Color> colors) {
    return LineChartBarData(
      barWidth: 0.5,
      spots: List.generate(length, (i) => FlSpot(i.toDouble(), data[i])),
      colors: colors,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        colors: colors.map((color) => color.withOpacity(0.5)).toList(),
      ),
    );
  }
}
