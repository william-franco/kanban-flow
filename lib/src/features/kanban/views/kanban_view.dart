import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kanban_flow/src/common/enums/task_status_enum.dart';
import 'package:kanban_flow/src/features/kanban/models/task_model.dart';
import 'package:kanban_flow/src/features/kanban/routes/kanban_routes.dart';
import 'package:kanban_flow/src/features/kanban/view_models/kanban_view_model.dart';
import 'package:kanban_flow/src/features/kanban/widgets/kanban_column_widget.dart';
import 'package:kanban_flow/src/features/settings/routes/setting_routes.dart';

class KanbanView extends StatefulWidget {
  final KanbanViewModel kanbanViewModel;

  const KanbanView({super.key, required this.kanbanViewModel});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAllTasks();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getAllTasks() {
    widget.kanbanViewModel.getAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () async {
              _getAllTasks();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push(SettingRoutes.setting);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: ListenableBuilder(
                listenable: widget.kanbanViewModel,
                builder: (context, child) {
                  return isWideScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildKanbanColumns(isWideScreen),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _buildKanbanColumns(isWideScreen),
                        );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(KanbanRoutes.addKanban);
          if (result == true) {
            _getAllTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildKanbanColumns(bool isWideScreen) {
    final columns = [
      _buildColumnWidget(
        color: Colors.brown,
        title: 'To do',
        items: widget.kanbanViewModel.kanbanModel.todo,
        status: TaskStatusEnum.todo,
      ),
      _buildColumnWidget(
        color: Colors.green,
        title: 'In progress',
        items: widget.kanbanViewModel.kanbanModel.inProgress,
        status: TaskStatusEnum.inProgress,
      ),
      _buildColumnWidget(
        color: Colors.red,
        title: 'Under Analysis',
        items: widget.kanbanViewModel.kanbanModel.analise,
        status: TaskStatusEnum.inAnalise,
      ),
      _buildColumnWidget(
        color: Colors.blue,
        title: 'Completed',
        items: widget.kanbanViewModel.kanbanModel.done,
        status: TaskStatusEnum.done,
      ),
    ];

    return isWideScreen
        ? columns.map((col) => Expanded(child: col)).toList()
        : columns;
  }

  Widget _buildColumnWidget({
    required Color color,
    required String title,
    required List<TaskModel> items,
    required TaskStatusEnum status,
  }) {
    return KanbanColumnWidget(
      color: color,
      title: title,
      items: items,
      onItemDropped: (details) {
        widget.kanbanViewModel.updateTaskStatus(details.data.id, status);
      },
    );
  }
}
