import 'package:kanban_flow/src/common/enums/task_status_enum.dart';

class KanbanModel {
  final List<TaskModel> todo;
  final List<TaskModel> inProgress;
  final List<TaskModel> analise;
  final List<TaskModel> done;

  KanbanModel({
    this.todo = const [],
    this.inProgress = const [],
    this.analise = const [],
    this.done = const [],
  });

  KanbanModel copyWith({
    List<TaskModel>? todo,
    List<TaskModel>? inProgress,
    List<TaskModel>? analise,
    List<TaskModel>? done,
  }) => KanbanModel(
    todo: todo ?? this.todo,
    inProgress: inProgress ?? this.inProgress,
    analise: analise ?? this.analise,
    done: done ?? this.done,
  );
}

class TaskModel {
  final String id;
  final String title;
  TaskStatusEnum status;

  TaskModel({
    required this.id,
    required this.title,
    this.status = TaskStatusEnum.todo,
  });

  TaskModel copyWith({String? id, String? title, TaskStatusEnum? status}) =>
      TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        status: status ?? this.status,
      );
}
