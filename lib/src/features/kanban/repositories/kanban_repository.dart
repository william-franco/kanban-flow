import 'package:kanban_flow/src/common/enums/task_status_enum.dart';
import 'package:kanban_flow/src/features/kanban/models/task_model.dart';

abstract interface class KanbanRepository {
  KanbanModel findAllTasks();
  void updateTaskStatus(String taskId, TaskStatusEnum newStatus);
  void addTask(String title, TaskStatusEnum initialStatus);
}

class KanbanRepositoryImpl implements KanbanRepository {
  final List<TaskModel> _tasks = [];

  @override
  KanbanModel findAllTasks() {
    return KanbanModel(
      todo: _tasks.where((task) => task.status == TaskStatusEnum.todo).toList(),
      inProgress: _tasks
          .where((task) => task.status == TaskStatusEnum.inProgress)
          .toList(),
      analise: _tasks
          .where((task) => task.status == TaskStatusEnum.inAnalise)
          .toList(),
      done: _tasks.where((task) => task.status == TaskStatusEnum.done).toList(),
    );
  }

  @override
  void updateTaskStatus(String taskId, TaskStatusEnum newStatus) {
    final task = _tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task with id $taskId not found'),
    );

    task.status = newStatus;
  }

  @override
  void addTask(String title, TaskStatusEnum initialStatus) {
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      status: initialStatus,
    );
    _tasks.add(newTask);
  }
}
