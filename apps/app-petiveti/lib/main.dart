import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection (includes Hive initialization)
  await di.init();
  
  runApp(
    const ProviderScope(
      child: PetiVetiApp(),
    ),
  );
}