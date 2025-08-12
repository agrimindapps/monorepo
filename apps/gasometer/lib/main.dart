import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize Core services when available
  // await CoreServices.initialize();
  
  runApp(const GasOMeterApp());
}

