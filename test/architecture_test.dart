import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the clean architecture dependency rule by scanning import lines:
///
///   presentation -> domain <- data
///
/// * domain is pure Dart: no Flutter, Firebase, bloc, data or presentation.
/// * presentation never imports data or Firebase.
/// * data never imports presentation.
class Violation {
  const Violation(this.file, this.import, this.rule);

  final String file;
  final String import;
  final String rule;

  @override
  String toString() => '$file imports "$import" ($rule)';
}

final RegExp _importLine = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
);

const List<String> _frameworkPrefixes = [
  'package:flutter/',
  'package:flutter_bloc/',
  'package:cloud_firestore/',
  'package:firebase_core/',
  'package:firebase_auth/',
  'dart:ui',
  'dart:io',
];

bool _isFirebase(String import) =>
    import.startsWith('package:cloud_firestore/') ||
    import.startsWith('package:firebase_core/') ||
    import.startsWith('package:firebase_auth/');

bool _inLayer(String path, String layer) => path.contains('/$layer/');

List<Violation> findViolations(Map<String, String> sourcesByPath) {
  final violations = <Violation>[];
  sourcesByPath.forEach((path, source) {
    final normalized = path.replaceAll(r'\', '/');
    final isDomain =
        _inLayer(normalized, 'domain') ||
        normalized.contains('lib/core/error/') ||
        normalized.contains('lib/core/time/') ||
        normalized.contains('lib/core/usecase/');
    final isData = _inLayer(normalized, 'data');
    final isPresentation = _inLayer(normalized, 'presentation');

    for (final line in source.split('\n')) {
      final match = _importLine.firstMatch(line);
      if (match == null) continue;
      final import = match.group(1)!;

      if (isDomain) {
        if (_frameworkPrefixes.any(import.startsWith)) {
          violations.add(
            Violation(normalized, import, 'domain must stay framework-free'),
          );
        }
        if (import.contains('/data/') || import.contains('/presentation/')) {
          violations.add(
            Violation(
              normalized,
              import,
              'domain must not depend on outer layers',
            ),
          );
        }
      }
      if (isPresentation) {
        if (import.contains('/data/')) {
          violations.add(
            Violation(normalized, import, 'presentation must not import data'),
          );
        }
        if (_isFirebase(import)) {
          violations.add(
            Violation(
              normalized,
              import,
              'presentation must not import Firebase',
            ),
          );
        }
      }
      if (isData && import.contains('/presentation/')) {
        violations.add(
          Violation(normalized, import, 'data must not import presentation'),
        );
      }
    }
  });
  return violations;
}

Map<String, String> _readLib() {
  final result = <String, String>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      result[entity.path] = entity.readAsStringSync();
    }
  }
  return result;
}

void main() {
  group('architecture rules', () {
    test('the real codebase has no layer violations', () {
      final violations = findViolations(_readLib());
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('the checker catches violations', () {
    test('domain importing Firebase or Flutter', () {
      final violations = findViolations({
        'lib/features/habits/domain/entities/x.dart': '''
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
''',
      });
      expect(violations, hasLength(2));
    });

    test('domain importing data or presentation', () {
      final violations = findViolations({
        'lib/features/habits/domain/usecases/x.dart': '''
import 'package:habit_tracker/features/habits/data/models/m.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/b.dart';
''',
      });
      expect(violations, hasLength(2));
    });

    test('presentation importing data or Firebase', () {
      final violations = findViolations({
        'lib/features/habits/presentation/bloc/x.dart': '''
import 'package:habit_tracker/features/habits/data/repositories/r.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
''',
      });
      expect(violations, hasLength(2));
    });

    test('data importing presentation', () {
      final violations = findViolations({
        'lib/features/habits/data/models/x.dart':
            "import 'package:habit_tracker/features/habits/presentation/pages/p.dart';",
      });
      expect(violations, hasLength(1));
    });

    test('allowed imports pass', () {
      final violations = findViolations({
        'lib/features/habits/domain/usecases/x.dart': '''
import 'package:fpdart/fpdart.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
''',
        'lib/features/habits/data/repositories/r.dart': '''
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
''',
        'lib/features/habits/presentation/bloc/b.dart': '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/features/habits/domain/usecases/x.dart';
''',
      });
      expect(violations, isEmpty);
    });
  });
}
