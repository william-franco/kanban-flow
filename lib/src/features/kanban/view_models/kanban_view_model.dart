import 'package:flutter/foundation.dart';
import 'package:kanban_flow/src/common/enums/task_status_enum.dart';
import 'package:kanban_flow/src/common/state_management/state_management.dart';
import 'package:kanban_flow/src/features/kanban/models/task_model.dart';
import 'package:kanban_flow/src/features/kanban/repositories/kanban_repository.dart';

typedef _ViewModel = StateManagement<KanbanModel>;

abstract interface class KanbanViewModel extends _ViewModel {
  void getAllTasks();
  void updateTaskStatus(String taskId, TaskStatusEnum newStatus);
  void addTask(String title, TaskStatusEnum initialStatus);
}

class KanbanViewModelImpl extends _ViewModel implements KanbanViewModel {
  final KanbanRepository kanbanRepository;

  KanbanViewModelImpl({required this.kanbanRepository});

  @override
  KanbanModel build() => KanbanModel();

  @override
  void getAllTasks() {
    final model = kanbanRepository.findAllTasks();
    _emit(model);
  }

  @override
  void updateTaskStatus(String taskId, TaskStatusEnum newStatus) {
    kanbanRepository.updateTaskStatus(taskId, newStatus);
    getAllTasks();
  }

  @override
  void addTask(String title, TaskStatusEnum initialStatus) {
    kanbanRepository.addTask(title, initialStatus);
    getAllTasks();
  }

  void _emit(KanbanModel newState) {
    emitState(newState);
    debugPrint('KanbanViewModel: ${state.done.length}');
  }
}
