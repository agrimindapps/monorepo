import 'package:flutter/material.dart';

class TaskListWidget extends StatelessWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Placeholder
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Checkbox(
              value: false,
              onChanged: (value) {
                // TODO: Update task status
              },
            ),
            title: Text('Task ${index + 1}'),
            subtitle: const Text('Task description'),
            trailing: IconButton(
              icon: const Icon(Icons.star_border),
              onPressed: () {
                // TODO: Toggle star
              },
            ),
          ),
        );
      },
    );
  }
}