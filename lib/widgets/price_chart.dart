// lib/widgets/price_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/alpha_vantage_service.dart';
import '../utils/theme.dart';

class PriceChart extends StatefulWidget {
  final List<ChartPoint> points;
  final bool isPositive;

  const PriceChart({
    super.key,
    required this.points,
    required this.isPositive,
  });

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  int _touchedIndex = -1;
  double? _touchedPrice;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return const Center(
        child: Text('No chart data', style: TextStyle(color: AppTheme.textTertiary)),
      );
    }

    final lineColor = widget.isPositive ? AppTheme.green : AppTheme.red;
    final gradientColor = widget.isPositive
        ? AppTheme.green.withOpacity(0.3)
        : AppTheme.red.withOpacity(0.3);

    final spots = widget.points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price))
        .toList();

    final prices = widget.points.map((p) => p.price).toList();
    final minY = prices.reduce((a, b) => a < b ? a : b);
    final maxY = prices.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return Column(
      children: [
        // Touch price display
        if (_touchedPrice != null)
          Text(
            '\$${_touchedPrice!.toStringAsFixed(2)}',
            style: TextStyle(
              color: lineColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 8),

        Expanded(
          child: LineChart(
            LineChartData(
              minY: minY - padding,
              maxY: maxY + padding,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppTheme.border.withOpacity(0.5),
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, _) => Text(
                      '\$${value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (response?.lineBarSpots?.isNotEmpty == true) {
                      _touchedIndex =
                          response!.lineBarSpots!.first.spotIndex;
                      _touchedPrice = response.lineBarSpots!.first.y;
                    } else {
                      _touchedIndex = -1;
                      _touchedPrice = null;
                    }
                  });
                },
                getTouchedSpotIndicator: (_, spotIndexes) {
                  return spotIndexes.map((i) {
                    return TouchedSpotIndicatorData(
                      FlLine(color: lineColor, strokeWidth: 1.5),
                      FlDotData(
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(
                          radius: 5,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: AppTheme.background,
                        ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: AppTheme.surfaceVariant,
                  getTooltipItems: (spots) => spots.map((s) {
                    final idx = s.spotIndex.clamp(
                        0, widget.points.length - 1);
                    final time = widget.points[idx].time;
                    final label = time.length >= 10
                        ? time.substring(5, 10)
                        : time;
                    return LineTooltipItem(
                      label,
                      const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: lineColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [gradientColor, Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
