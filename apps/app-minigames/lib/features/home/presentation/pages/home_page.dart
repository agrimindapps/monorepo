import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// HomePage - Game selection menu
/// Displays grid of available minigames
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniGames'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid
            final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _GameCard(
                  title: 'Tower of Hanoi',
                  icon: Icons.layers,
                  color: Colors.blue,
                  onTap: () => context.go('/tower'),
                ),
                _GameCard(
                  title: 'Tic Tac Toe',
                  icon: Icons.grid_3x3,
                  color: Colors.green,
                  onTap: () => context.go('/tictactoe'),
                ),
                _GameCard(
                  title: 'Campo Minado',
                  icon: Icons.flag,
                  color: Colors.orange,
                  onTap: () => context.go('/campo-minado'),
                ),
                // TODO: Add more games as they are migrated
                // _GameCard(title: 'Sudoku', icon: Icons.grid_4x4, color: Colors.purple, onTap: () => context.go('/sudoku')),
                // _GameCard(title: 'Snake', icon: Icons.pets, color: Colors.teal, onTap: () => context.go('/snake')),
                // _GameCard(title: 'Memory', icon: Icons.memory, color: Colors.pink, onTap: () => context.go('/memory')),
                // _GameCard(title: '2048', icon: Icons.grid_on, color: Colors.amber, onTap: () => context.go('/2048')),
                // _GameCard(title: 'Flappy Bird', icon: Icons.flight, color: Colors.cyan, onTap: () => context.go('/flappbird')),
                // _GameCard(title: 'Ping Pong', icon: Icons.sports_tennis, color: Colors.lime, onTap: () => context.go('/pingpong')),
                // _GameCard(title: 'Quiz', icon: Icons.quiz, color: Colors.indigo, onTap: () => context.go('/quiz')),
                // _GameCard(title: 'Caça Palavra', icon: Icons.abc, color: Colors.deepOrange, onTap: () => context.go('/caca-palavra')),
                // _GameCard(title: 'Soletrando', icon: Icons.spellcheck, color: Colors.deepPurple, onTap: () => context.go('/soletrando')),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
