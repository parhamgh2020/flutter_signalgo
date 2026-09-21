import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/candle_entity.dart';

/// Hand-painted OHLC candlestick chart. fl_chart has no native candlestick
/// series, and its gesture model doesn't give the fine control needed for
/// combined pinch-zoom + single-finger scrub, so this is a CustomPainter
/// instead — MA overlay and the sparkline elsewhere still use fl_chart.
class CandlestickChart extends StatefulWidget {
  const CandlestickChart({
    super.key,
    required this.candles,
    required this.maSeries,
    required this.showMA,
  });

  final List<CandleEntity> candles;
  final List<double?>? maSeries;
  final bool showMA;

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  int _visibleCount = 60;
  int _startIndex = 0;
  int? _touchedIndex;

  double? _baseVisibleCount;
  int? _baseStartIndex;

  void _clampWindow(int total) {
    _visibleCount = _visibleCount.clamp(8, total == 0 ? 8 : total);
    _startIndex = _startIndex.clamp(0, (total - _visibleCount).clamp(0, total));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.candles.length;
    if (total == 0) {
      return const SizedBox.shrink();
    }
    _visibleCount = _visibleCount > total ? total : _visibleCount;
    _clampWindow(total);
    final endIndex = (_startIndex + _visibleCount).clamp(0, total);
    final visible = widget.candles.sublist(_startIndex, endIndex);
    final visibleMa = widget.showMA && widget.maSeries != null
        ? widget.maSeries!.sublist(_startIndex, endIndex)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onScaleStart: (details) {
            _baseVisibleCount = _visibleCount.toDouble();
            _baseStartIndex = _startIndex;
          },
          onScaleUpdate: (details) {
            setState(() {
              if (details.pointerCount >= 2) {
                final newVisible = (_baseVisibleCount! / details.scale).round();
                _visibleCount = newVisible;
                final dxCandles =
                    -(details.focalPointDelta.dx / constraints.maxWidth * _visibleCount).round();
                _startIndex = (_baseStartIndex ?? _startIndex) + dxCandles;
                _touchedIndex = null;
                _clampWindow(total);
              } else {
                final localX = details.localFocalPoint.dx.clamp(0, constraints.maxWidth);
                final idx = _startIndex + (localX / constraints.maxWidth * _visibleCount).floor();
                _touchedIndex = idx.clamp(_startIndex, endIndex - 1);
              }
            });
          },
          onTapDown: (details) {
            setState(() {
              final localX = details.localPosition.dx.clamp(0, constraints.maxWidth);
              final idx = _startIndex + (localX / constraints.maxWidth * _visibleCount).floor();
              _touchedIndex = idx.clamp(_startIndex, endIndex - 1);
            });
          },
          onLongPressEnd: (_) => setState(() => _touchedIndex = null),
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _CandlestickPainter(
              candles: visible,
              maSeries: visibleMa,
              touchedIndex: _touchedIndex == null ? null : _touchedIndex! - _startIndex,
              brightness: Theme.of(context).brightness,
            ),
          ),
        );
      },
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.candles,
    required this.maSeries,
    required this.touchedIndex,
    required this.brightness,
  });

  final List<CandleEntity> candles;
  final List<double?>? maSeries;
  final int? touchedIndex;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    var minPrice = candles.first.low;
    var maxPrice = candles.first.high;
    for (final c in candles) {
      if (c.low < minPrice) minPrice = c.low;
      if (c.high > maxPrice) maxPrice = c.high;
    }
    final pad = (maxPrice - minPrice) * 0.08 + 0.0001;
    minPrice -= pad;
    maxPrice += pad;

    final slotWidth = size.width / candles.length;
    final bodyWidth = (slotWidth * 0.6).clamp(1.0, 20.0);

    double yFor(double price) =>
        size.height - (price - minPrice) / (maxPrice - minPrice) * size.height;

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final cx = slotWidth * i + slotWidth / 2;
      final color = c.isBullish ? AppColors.gain : AppColors.loss;
      final wickPaint = Paint()..color = color..strokeWidth = 1;
      canvas.drawLine(Offset(cx, yFor(c.high)), Offset(cx, yFor(c.low)), wickPaint);

      final bodyTop = yFor(c.isBullish ? c.close : c.open);
      final bodyBottom = yFor(c.isBullish ? c.open : c.close);
      final bodyRect = Rect.fromLTRB(
        cx - bodyWidth / 2,
        bodyTop,
        cx + bodyWidth / 2,
        (bodyBottom - bodyTop).abs() < 1 ? bodyTop + 1 : bodyBottom,
      );
      canvas.drawRect(bodyRect, Paint()..color = color);
    }

    if (maSeries != null) {
      final path = Path();
      var started = false;
      for (var i = 0; i < maSeries!.length; i++) {
        final value = maSeries![i];
        if (value == null) continue;
        final point = Offset(slotWidth * i + slotWidth / 2, yFor(value));
        if (!started) {
          path.moveTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    final idx = touchedIndex;
    if (idx != null && idx >= 0 && idx < candles.length) {
      final c = candles[idx];
      final cx = slotWidth * idx + slotWidth / 2;
      final crosshair = Paint()
        ..color = (brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.3)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), crosshair);

      final label =
          '${DateFormat.MMMd().add_Hm().format(c.timestamp)}\n${c.close.toStringAsFixed(2)}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: brightness == Brightness.dark ? Colors.white : Colors.black,
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      var boxLeft = cx - tp.width / 2 - 6;
      if (boxLeft < 0) boxLeft = 0;
      if (boxLeft + tp.width + 12 > size.width) boxLeft = size.width - tp.width - 12;
      final boxRect = Rect.fromLTWH(boxLeft, 4, tp.width + 12, tp.height + 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
        Paint()..color = (brightness == Brightness.dark ? Colors.black : Colors.white).withValues(alpha: 0.85),
      );
      tp.paint(canvas, Offset(boxRect.left + 6, boxRect.top + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.maSeries != maSeries;
  }
}
