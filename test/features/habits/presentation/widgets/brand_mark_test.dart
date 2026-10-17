import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/brand_mark.dart';

const AppTokens _t = AppTokens.light;

BrandMarkPainter _painter(double progress) => BrandMarkPainter(
  progress: progress,
  ring: _t.accent,
  tint: _t.accentTint,
  check: _t.accentInk,
  empty: _t.track,
  filled: _t.accent,
);

/// Pixels of the mark rendered at 1:1 (560 x 620), so design-box coordinates
/// are pixel coordinates. No text is involved, so this is font independent.
class _Pixels {
  _Pixels(this._data);
  final ByteData _data;

  static const int width = 560;
  static const int height = 620;

  Color at(int x, int y) {
    final i = (y * width + x) * 4;
    return Color.fromARGB(
      _data.getUint8(i + 3),
      _data.getUint8(i),
      _data.getUint8(i + 1),
      _data.getUint8(i + 2),
    );
  }
}

Future<_Pixels> _render(WidgetTester tester, double progress) async {
  final data = await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    _painter(progress).paint(
      Canvas(recorder),
      const Size(BrandMarkPainter.boxWidth, BrandMarkPainter.boxHeight),
    );
    final image = await recorder.endRecording().toImage(
      _Pixels.width,
      _Pixels.height,
    );
    return (await image.toByteData())!;
  });
  return _Pixels(data!);
}

Color _opaque(Color c) => Color.fromARGB(
  255,
  (c.r * 255).round(),
  (c.g * 255).round(),
  (c.b * 255).round(),
);

void main() {
  group('BrandMark widget', () {
    for (final progress in [0.0, 0.5, 1.0]) {
      testWidgets('builds at progress $progress', (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: BrandMark(progress: progress)),
          ),
        );
        expect(tester.takeException(), isNull);
        final size = tester.getSize(find.byType(BrandMark));
        expect(size.width, 112);
        expect(size.height, closeTo(112 * 620 / 560, 0.001));
      });
    }

    testWidgets('is hidden from semantics unless given a label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: BrandMark()),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: BrandMark(semanticLabel: 'Mark')),
        ),
      );
      expect(find.bySemanticsLabel('Mark'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('BrandMarkPainter', () {
    testWidgets('progress 0 paints nothing', (tester) async {
      final px = await _render(tester, 0);
      for (final (x, y) in [(280, 30), (280, 100), (236, 374), (34, 599)]) {
        expect(px.at(x, y).a, 0, reason: '($x, $y)');
      }
    });

    testWidgets('progress 1 paints the ring, check and seven segments', (
      tester,
    ) async {
      final px = await _render(tester, 1);
      expect(px.at(280, 30), _opaque(_t.accent), reason: 'ring stroke');
      expect(px.at(280, 100), _opaque(_t.accentTint), reason: 'ring fill');
      expect(px.at(236, 374), _opaque(_t.accentInk), reason: 'check vertex');
      expect(px.at(5, 5).a, 0, reason: 'outside the ring');
      for (var i = 0; i < 7; i++) {
        final rect = BrandMarkPainter.segmentRect(i);
        final expected = i < 4 ? _t.track : _t.accent;
        expect(
          px.at(rect.center.dx.round(), rect.center.dy.round()),
          _opaque(expected),
          reason: 'segment $i',
        );
        // Square ends: just outside the rect is empty.
        expect(px.at(rect.left.round(), rect.top.round() - 2).a, 0);
      }
    });

    testWidgets('progress above 1 is the same as 1', (tester) async {
      final a = await _render(tester, 1);
      final b = await _render(tester, 1.7);
      for (final (x, y) in [(280, 30), (280, 100), (236, 374), (500, 599)]) {
        expect(b.at(x, y), a.at(x, y));
      }
    });

    testWidgets('progress 0.5 has the ring and part of the check', (
      tester,
    ) async {
      final px = await _render(tester, 0.5);
      expect(px.at(280, 30), _opaque(_t.accent));
      expect(px.at(280, 100), _opaque(_t.accentTint));
      expect(px.at(236, 374), _opaque(_t.accentInk), reason: 'check started');
      expect(
        px.at(414, 176),
        _opaque(_t.accentTint),
        reason: 'check not finished, only the ring fill is there',
      );
      expect(px.at(34, 599).a, 0, reason: 'segments not started');
    });

    testWidgets('segments appear one after another', (tester) async {
      final px = await _render(tester, 0.85);
      expect(px.at(34, 599), _opaque(_t.track), reason: 'first is in');
      expect(px.at(34 + 82 * 6, 599).a, 0, reason: 'last is not yet');
    });

    test('shouldRepaint reacts to progress and colours only', () {
      final base = _painter(0.5);
      expect(base.shouldRepaint(_painter(0.5)), isFalse);
      expect(base.shouldRepaint(_painter(0.6)), isTrue);
      expect(
        base.shouldRepaint(
          BrandMarkPainter(
            progress: 0.5,
            ring: _t.ink,
            tint: _t.accentTint,
            check: _t.accentInk,
            empty: _t.track,
            filled: _t.accent,
          ),
        ),
        isTrue,
      );
    });
  });
}
