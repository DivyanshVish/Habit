import 'package:flutter/material.dart';
import 'package:habit_tracker/app.dart';
import 'package:habit_tracker/bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapGate(bootstrap: bootstrap));
}
