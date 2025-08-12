import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_gas_station,
              size: 80,
              color: Color(0xFFFF5722),
            ),
            const SizedBox(height: 24),
            Text(
              'GasOMeter',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: const Color(0xFFFF5722),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Controle pessoal de veículos',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            const Text('Login Page - Em desenvolvimento'),
          ],
        ),
      ),
    );
  }
}