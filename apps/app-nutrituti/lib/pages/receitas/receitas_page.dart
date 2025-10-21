// Flutter imports:
import 'package:flutter/material.dart';

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
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
        title: const Text('Receitas'),
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
