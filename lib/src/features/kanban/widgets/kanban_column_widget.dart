import 'package:flutter/material.dart';
import 'package:kanban_flow/src/features/kanban/models/task_model.dart';
import 'package:kanban_flow/src/features/kanban/widgets/kanban_card_widget.dart';

class KanbanColumnWidget extends StatelessWidget {
  final String title;
  final Color color;
  final List<TaskModel> items;
  final void Function(DragTargetDetails<TaskModel>)? onItemDropped;

  const KanbanColumnWidget({
    super.key,
    required this.title,
    required this.color,
    required this.items,
    this.onItemDropped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          color: color,
          child: SizedBox(
            height: 75,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        Flexible(
          fit: FlexFit.loose,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: DragTarget<TaskModel>(
              onAcceptWithDetails: onItemDropped,
              builder: (context, candidateData, rejectedData) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 200),
                  width: double.infinity,
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'No task',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final task = items[index];
                            return Draggable<TaskModel>(
                              data: task,
                              feedback: Material(
                                child: SizedBox(
                                  width: 300,
                                  child: KanbanCardWidget(item: task),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: KanbanCardWidget(item: task),
                              ),
                              child: KanbanCardWidget(item: task),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
