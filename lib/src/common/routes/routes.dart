import 'package:go_router/go_router.dart';
import 'package:kanban_flow/src/features/kanban/routes/kanban_routes.dart';
import 'package:kanban_flow/src/features/settings/routes/setting_routes.dart';

class Routes {
  static String get home => KanbanRoutes.kanbans;

  GoRouter get routes => _routes;

  final GoRouter _routes = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: home,
    routes: [...KanbanRoutes().routes, ...SettingRoutes().routes],
  );
}
