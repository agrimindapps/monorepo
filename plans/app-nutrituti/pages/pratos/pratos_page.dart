// Flutter imports:
import 'package:flutter/material.dart';

class PratosPage extends StatefulWidget {
  const PratosPage({super.key});

  @override
  State<PratosPage> createState() => _PratosPageState();
}

class _PratosPageState extends State<PratosPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratos'),
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 1020,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
