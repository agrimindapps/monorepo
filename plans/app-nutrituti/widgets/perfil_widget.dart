// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../pages/perfil_cadastro_page.dart';

class PerfilWidget extends StatefulWidget {
  const PerfilWidget({super.key});

  @override
  State<PerfilWidget> createState() => _PerfilWidgetState();
}

class _PerfilWidgetState extends State<PerfilWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 40,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 120,
                child: const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CadastroPerfilPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/user.png'),
          ),
          const SizedBox(height: 15),
          const Text(
            'Nome do usuário',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Idade'),
                  subtitle: Text('-/-'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: const ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Altura'),
                  subtitle: Text('-/-'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: const ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Peso'),
                  subtitle: Text('-/-'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: const ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('IMC'),
                  subtitle: Text('-/-'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
