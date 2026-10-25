import 'package:flutter/material.dart';
import 'package:habit_tracker/app.dart';
import 'package:habit_tracker/bootstrap.dart';
import 'package:habit_tracker/core/platform/firebase_platform.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BootstrapGate(
      bootstrap: () =>
          bootstrap(createPlatform: createFirebasePlatformServices),
    ),
  );
}
