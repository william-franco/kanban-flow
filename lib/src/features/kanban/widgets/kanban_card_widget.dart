import 'package:flutter/material.dart';
import 'package:kanban_flow/src/features/kanban/models/task_model.dart';

class KanbanCardWidget extends StatelessWidget {
  final TaskModel item;

  const KanbanCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(item.title),
            subtitle: Text.rich(
              TextSpan(
                text: 'Status: ',
                children: [
                  TextSpan(
                    text: item.status.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }
}
