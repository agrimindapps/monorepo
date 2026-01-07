import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrimind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3ECF8E), // Supabase Green
          secondary: Color(0xFF66E3CE),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.black,
          onSurface: Color(0xFFEDEDED),
        ),
        textTheme: TextTheme(bodyMedium: TextStyle(color: Color(0xFFEDEDED))),
      ),
      home: const App(),
    );
  }
}
