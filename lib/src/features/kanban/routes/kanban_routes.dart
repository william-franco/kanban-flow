import 'package:go_router/go_router.dart';
import 'package:kanban_flow/src/common/dependency_injectors/dependency_injector.dart';
import 'package:kanban_flow/src/features/kanban/view_models/kanban_view_model.dart';
import 'package:kanban_flow/src/features/kanban/views/add_task_view.dart';
import 'package:kanban_flow/src/features/kanban/views/kanban_view.dart';

class KanbanRoutes {
  static String get kanbans => '/kanbans';
  static String get addKanban => '/add-kanban';

  List<GoRoute> get routes => _routes;

  final List<GoRoute> _routes = [
    GoRoute(
      path: kanbans,
      builder: (context, state) {
        return KanbanView(kanbanViewModel: locator<KanbanViewModel>());
      },
    ),
    GoRoute(
      path: addKanban,
      builder: (context, state) {
        return AddTaskView(kanbanViewModel: locator<KanbanViewModel>());
      },
    ),
  ];
}
