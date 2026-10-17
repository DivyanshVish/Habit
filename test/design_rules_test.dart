import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';

/// Guards the classical design system: outlined buttons only, light only, no
/// icon packs or banned packages, no hard-coded colours outside the tokens
/// file, no em or en dashes, and the bundled serif fonts are really there.
class DesignViolation {
  const DesignViolation(this.file, this.rule);
  final String file;
  final String rule;
  @override
  String toString() => '$file: $rule';
}

const String _emDash = '\u2014';
const String _enDash = '\u2013';

final RegExp _bannedButtons = RegExp(r'\b(FilledButton|ElevatedButton)\b');
final RegExp _darkTheme = RegExp(
  r'darkTheme|ThemeMode\.dark|ThemeData\.dark|ColorScheme\.dark|'
  r'AppTheme\.dark|AppTokens\.dark',
);
final RegExp _bannedImports = RegExp(
  r'''^\s*import\s+['"]package:(phosphor_flutter|google_fonts|flutter_riverpod|intl)/''',
  multiLine: true,
);
final RegExp _phosphor = RegExp('phosphor', caseSensitive: false);
final RegExp _hexColor = RegExp(r'\bColor\(\s*0x');
final RegExp _namedColor = RegExp(r'\bColors\.(?!transparent\b)\w+');
final RegExp _geist = RegExp('geist', caseSensitive: false);

/// `statusBarIconBrightness: Brightness.dark` means dark ICONS on a light
/// bar, which is exactly what a light-only app needs. Anything else that says
/// `Brightness.dark` is a dark theme.
bool _usesDarkBrightness(String source) => source
    .split('\n')
    .any(
      (line) =>
          line.contains('Brightness.dark') && !line.contains('IconBrightness'),
    );

/// [sources] maps a path to its text. Files whose path ends with
/// `app_tokens.dart` may contain hex colours (it is the only place).
List<DesignViolation> findDesignViolations(Map<String, String> sources) {
  final violations = <DesignViolation>[];
  sources.forEach((path, source) {
    if (_bannedButtons.hasMatch(source)) {
      violations.add(DesignViolation(path, 'uses a filled or elevated button'));
    }
    if (_darkTheme.hasMatch(source) || _usesDarkBrightness(source)) {
      violations.add(DesignViolation(path, 'uses a dark theme'));
    }
    if (_bannedImports.hasMatch(source) || _phosphor.hasMatch(source)) {
      violations.add(
        DesignViolation(path, 'uses phosphor, google_fonts, riverpod or intl'),
      );
    }
    if (!path.endsWith('app_tokens.dart') && _hexColor.hasMatch(source)) {
      violations.add(DesignViolation(path, 'hard-coded Color(0x...)'));
    }
    if (_namedColor.hasMatch(source)) {
      violations.add(DesignViolation(path, 'uses Colors.* instead of tokens'));
    }
    if (source.contains(_emDash) || source.contains(_enDash)) {
      violations.add(DesignViolation(path, 'contains an em or en dash'));
    }
    if (_geist.hasMatch(source)) {
      violations.add(DesignViolation(path, 'mentions the removed Geist font'));
    }
  });
  return violations;
}

/// Font families and files declared in `pubspec.yaml`.
class PubspecFonts {
  const PubspecFonts(this.families, this.fontAssets, this.otherAssets);
  final List<String> families;
  final List<String> fontAssets;
  final List<String> otherAssets;
}

PubspecFonts parsePubspecFonts(String pubspec) {
  final families = RegExp(
    r'^\s*-\s*family:\s*(\S+)',
    multiLine: true,
  ).allMatches(pubspec).map((m) => m.group(1)!).toList();
  final fontAssets = RegExp(
    r'^\s*-\s*asset:\s*(\S+)',
    multiLine: true,
  ).allMatches(pubspec).map((m) => m.group(1)!).toList();
  final otherAssets = RegExp(
    r'^\s*-\s*(assets/\S+)\s*$',
    multiLine: true,
  ).allMatches(pubspec).map((m) => m.group(1)!).toList();
  return PubspecFonts(families, fontAssets, otherAssets);
}

Map<String, String> _readSources() {
  final result = <String, String>{};
  final roots = [
    Directory('lib/features/habits/presentation'),
    Directory('lib/core/router'),
    Directory('lib/core/theme'),
  ];
  for (final root in roots) {
    for (final entity in root.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        result[entity.path] = entity.readAsStringSync();
      }
    }
  }
  result['lib/app.dart'] = File('lib/app.dart').readAsStringSync();
  return result;
}

void main() {
  test('the UI source follows the design rules', () {
    final violations = findDesignViolations(_readSources());
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('hex colours live only in app_tokens.dart', () {
    final withHex = [
      for (final entry in Directory('lib').listSync(recursive: true))
        if (entry is File &&
            entry.path.endsWith('.dart') &&
            !entry.path.endsWith('.freezed.dart') &&
            !entry.path.endsWith('firebase_options.dart') &&
            _hexColor.hasMatch(entry.readAsStringSync()))
          entry.path,
    ];
    expect(withHex, ['lib/core/theme/app_tokens.dart']);
  });

  group('fonts', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final fonts = parsePubspecFonts(pubspec);

    test('pubspec declares the two serif families and no Geist', () {
      expect(fonts.families, containsAll(['CormorantGaramond', 'Lora']));
      expect(pubspec, isNot(matches(_geist)));
      expect(pubspec.toLowerCase(), isNot(contains('phosphor')));
    });

    test('the token family constants match the pubspec families', () {
      expect(fonts.families, contains(AppTextTokens.headingFamily));
      expect(fonts.families, contains(AppTextTokens.bodyFamily));
      expect(AppTextTokens.headingFamily, 'CormorantGaramond');
      expect(AppTextTokens.bodyFamily, 'Lora');
    });

    test('every declared font file exists and is a TrueType font', () {
      expect(fonts.fontAssets, hasLength(6));
      for (final path in fonts.fontAssets) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path is missing');
        final head = file.openSync().readSync(4);
        expect(head, [0x00, 0x01, 0x00, 0x00], reason: '$path is not TrueType');
      }
    });

    test('both OFL licences are bundled', () {
      for (final path in [
        'assets/fonts/OFL-CormorantGaramond.txt',
        'assets/fonts/OFL-Lora.txt',
      ]) {
        expect(fonts.otherAssets, contains(path));
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path is missing');
        expect(file.readAsStringSync(), contains('SIL OPEN FONT LICENSE'));
      }
    });

    test('no Geist file is left in assets', () {
      final leftovers = [
        for (final entity in Directory('assets').listSync(recursive: true))
          if (_geist.hasMatch(entity.path)) entity.path,
      ];
      expect(leftovers, isEmpty);
    });
  });

  group('the checker catches violations', () {
    test('filled and elevated buttons', () {
      expect(findDesignViolations({'a.dart': 'FilledButton()'}), hasLength(1));
      expect(
        findDesignViolations({'a.dart': 'ElevatedButton()'}),
        hasLength(1),
      );
      expect(findDesignViolations({'a.dart': 'OutlinedButton()'}), isEmpty);
    });

    test('dark themes', () {
      expect(
        findDesignViolations({'a.dart': 'darkTheme: AppTheme.dark()'}),
        hasLength(1),
      );
      expect(
        findDesignViolations({'a.dart': 'themeMode: ThemeMode.dark'}),
        hasLength(1),
      );
      expect(
        findDesignViolations({'a.dart': 'brightness: Brightness.dark,'}),
        hasLength(1),
      );
    });

    test('allows dark icons on the light system bars', () {
      expect(
        findDesignViolations({
          'a.dart': 'statusBarIconBrightness: Brightness.dark,',
        }),
        isEmpty,
      );
      expect(
        findDesignViolations({'a.dart': 'themeMode: ThemeMode.light'}),
        isEmpty,
      );
    });

    test('banned packages', () {
      for (final package in [
        'phosphor_flutter/phosphor_flutter.dart',
        'google_fonts/google_fonts.dart',
        'flutter_riverpod/flutter_riverpod.dart',
        'intl/intl.dart',
      ]) {
        expect(
          findDesignViolations({'a.dart': "import 'package:$package';"}),
          isNotEmpty,
          reason: package,
        );
      }
      expect(
        findDesignViolations({'a.dart': 'PhosphorIconsRegular.x'}),
        hasLength(1),
      );
    });

    test('allows Material icons', () {
      expect(findDesignViolations({'a.dart': 'Icon(Icons.add)'}), isEmpty);
    });

    test('hard-coded colours, except in the tokens file', () {
      expect(
        findDesignViolations({
          'a.dart': 'const c = Color(0xFF000000); final d = Colors.red;',
        }),
        hasLength(2),
      );
      expect(
        findDesignViolations({
          'lib/core/theme/app_tokens.dart': 'const c = Color(0xFF000000);',
        }),
        isEmpty,
      );
    });

    test('dashes in copy', () {
      expect(
        findDesignViolations({
          'a.dart': "Text('a $_emDash b'); Text('1 $_enDash 2');",
        }),
        hasLength(1),
      );
    });

    test('the removed Geist font', () {
      expect(
        findDesignViolations({'a.dart': "fontFamily: 'Geist'"}),
        hasLength(1),
      );
    });

    test('allows Colors.transparent and tokens', () {
      expect(
        findDesignViolations({
          'a.dart': 'final c = Colors.transparent; final d = tokens.ink;',
        }),
        isEmpty,
      );
    });
  });

  group('the pubspec parser', () {
    test('reads families, font files and other assets', () {
      const sample = '''
flutter:
  fonts:
    - family: A
      fonts:
        - asset: assets/fonts/A.ttf
          weight: 600
    - family: B
      fonts:
        - asset: assets/fonts/B.ttf
  assets:
    - assets/fonts/OFL-A.txt
''';
      final fonts = parsePubspecFonts(sample);
      expect(fonts.families, ['A', 'B']);
      expect(fonts.fontAssets, ['assets/fonts/A.ttf', 'assets/fonts/B.ttf']);
      expect(fonts.otherAssets, ['assets/fonts/OFL-A.txt']);
    });
  });
}
