import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DrawingValidationResult {
  final double coverage;
  final double precision;

  const DrawingValidationResult({
    required this.coverage,
    required this.precision,
  });
}

class DrawingValidationService {
  static const int _threshold = 50;
  static const int _normalizedSize = 220;

  static Future<DrawingValidationResult?> compareDrawingToText({
    required Size canvasSize,
    required String targetText,
    required TextStyle targetStyle,
    required List<List<Offset?>> strokes,
    double userStrokeWidth = 15,
    int sampleStep = 2,
  }) async {
    final int width = canvasSize.width.toInt();
    final int height = canvasSize.height.toInt();
    if (width <= 0 || height <= 0) return null;

    final targetData = await _rasterizeTargetText(
      width: width,
      height: height,
      text: targetText,
      style: targetStyle,
    );
    final userData = await _rasterizeUserStrokes(
      width: width,
      height: height,
      strokes: strokes,
      strokeWidth: userStrokeWidth,
    );

    if (targetData == null || userData == null) return null;

    final targetBounds = _findBounds(targetData, width, height);
    final userBounds = _findBounds(userData, width, height);
    if (targetBounds == null || userBounds == null) return null;

    final normalizedTarget = _normalizeToMask(
      source: targetData,
      sourceWidth: width,
      sourceHeight: height,
      bounds: targetBounds,
      normalizedSize: _normalizedSize,
    );
    final normalizedUser = _normalizeToMask(
      source: userData,
      sourceWidth: width,
      sourceHeight: height,
      bounds: userBounds,
      normalizedSize: _normalizedSize,
    );

    int intersectionCount = 0;
    int targetCount = 0;
    int userCount = 0;

    for (int y = 0; y < _normalizedSize; y += sampleStep) {
      for (int x = 0; x < _normalizedSize; x += sampleStep) {
        final int index = y * _normalizedSize + x;
        final bool isTarget = normalizedTarget[index] == 1;
        final bool isUser = normalizedUser[index] == 1;

        if (isTarget) targetCount++;
        if (isUser) userCount++;
        if (isTarget && isUser) intersectionCount++;
      }
    }

    if (targetCount == 0 || userCount == 0) return null;

    return DrawingValidationResult(
      coverage: intersectionCount / targetCount,
      precision: intersectionCount / userCount,
    );
  }

  static Future<ByteData?> _rasterizeTargetText({
    required int width,
    required int height,
    required String text,
    required TextStyle style,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: width.toDouble());
    final offset = Offset(
      (width - textPainter.width) / 2,
      (height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
    final image = await recorder.endRecording().toImage(width, height);
    return image.toByteData(format: ui.ImageByteFormat.rawRgba);
  }

  static Future<ByteData?> _rasterizeUserStrokes({
    required int width,
    required int height,
    required List<List<Offset?>> strokes,
    required double strokeWidth,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      final path = Path();
      bool started = false;
      for (final point in stroke) {
        if (point == null) {
          started = false;
          continue;
        }
        if (!started) {
          path.moveTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    final image = await recorder.endRecording().toImage(width, height);
    return image.toByteData(format: ui.ImageByteFormat.rawRgba);
  }

  static Rect? _findBounds(ByteData data, int width, int height) {
    int minX = width;
    int minY = height;
    int maxX = -1;
    int maxY = -1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;
        final alpha = data.getUint8(index + 3);
        if (alpha > _threshold) {
          if (x < minX) minX = x;
          if (y < minY) minY = y;
          if (x > maxX) maxX = x;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX < minX || maxY < minY) return null;
    return Rect.fromLTRB(
      minX.toDouble(),
      minY.toDouble(),
      (maxX + 1).toDouble(),
      (maxY + 1).toDouble(),
    );
  }

  static Uint8List _normalizeToMask({
    required ByteData source,
    required int sourceWidth,
    required int sourceHeight,
    required Rect bounds,
    required int normalizedSize,
  }) {
    final mask = Uint8List(normalizedSize * normalizedSize);
    final double boxWidth = bounds.width <= 0 ? 1 : bounds.width;
    final double boxHeight = bounds.height <= 0 ? 1 : bounds.height;

    for (int y = 0; y < normalizedSize; y++) {
      for (int x = 0; x < normalizedSize; x++) {
        final double sourceX = bounds.left + ((x + 0.5) / normalizedSize) * boxWidth;
        final double sourceY = bounds.top + ((y + 0.5) / normalizedSize) * boxHeight;

        final int px = sourceX.floor().clamp(0, sourceWidth - 1);
        final int py = sourceY.floor().clamp(0, sourceHeight - 1);
        final int sourceIndex = (py * sourceWidth + px) * 4;
        final int alpha = source.getUint8(sourceIndex + 3);
        mask[y * normalizedSize + x] = alpha > _threshold ? 1 : 0;
      }
    }

    return mask;
  }
}
