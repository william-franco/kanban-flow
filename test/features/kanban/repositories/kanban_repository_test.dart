import 'package:flutter_test/flutter_test.dart';
import 'package:kanban_flow/src/common/enums/task_status_enum.dart';
import 'package:kanban_flow/src/features/kanban/models/task_model.dart';
import 'package:kanban_flow/src/features/kanban/repositories/kanban_repository.dart';

void main() {
  group('KanbanRepository Test', () {
    late KanbanRepository repository;

    setUp(() {
      // A fresh instance resets the internal _tasks list for every test.
      repository = KanbanRepositoryImpl();
    });

    // ---------------------------------------------------------------------------
    // findAllTasks
    // ---------------------------------------------------------------------------

    group('findAllTasks', () {
      test(
        'should return an empty KanbanModel when no tasks have been added',
        () {
          // act
          final result = repository.findAllTasks();

          // assert
          expect(result, isA<KanbanModel>());
          expect(result.todo, isEmpty);
          expect(result.inProgress, isEmpty);
          expect(result.analise, isEmpty);
          expect(result.done, isEmpty);
        },
      );

      test('should place a todo task only in the todo list', () {
        // arrange
        repository.addTask('Task A', TaskStatusEnum.todo);

        // act
        final result = repository.findAllTasks();

        // assert
        expect(result.todo.length, equals(1));
        expect(result.todo.first.title, equals('Task A'));
        expect(result.inProgress, isEmpty);
        expect(result.analise, isEmpty);
        expect(result.done, isEmpty);
      });

      test('should place an inProgress task only in the inProgress list', () {
        // arrange
        repository.addTask('Task B', TaskStatusEnum.inProgress);

        // act
        final result = repository.findAllTasks();

        // assert
        expect(result.inProgress.length, equals(1));
        expect(result.inProgress.first.title, equals('Task B'));
        expect(result.todo, isEmpty);
        expect(result.analise, isEmpty);
        expect(result.done, isEmpty);
      });

      test('should place an inAnalise task only in the analise list', () {
        // arrange
        repository.addTask('Task C', TaskStatusEnum.inAnalise);

        // act
        final result = repository.findAllTasks();

        // assert
        expect(result.analise.length, equals(1));
        expect(result.analise.first.title, equals('Task C'));
        expect(result.todo, isEmpty);
        expect(result.inProgress, isEmpty);
        expect(result.done, isEmpty);
      });

      test('should place a done task only in the done list', () {
        // arrange
        repository.addTask('Task D', TaskStatusEnum.done);

        // act
        final result = repository.findAllTasks();

        // assert
        expect(result.done.length, equals(1));
        expect(result.done.first.title, equals('Task D'));
        expect(result.todo, isEmpty);
        expect(result.inProgress, isEmpty);
        expect(result.analise, isEmpty);
      });

      test('should correctly distribute tasks across all four lists', () {
        // arrange
        repository.addTask('Todo task', TaskStatusEnum.todo);
        repository.addTask('Progress task', TaskStatusEnum.inProgress);
        repository.addTask('Analise task', TaskStatusEnum.inAnalise);
        repository.addTask('Done task', TaskStatusEnum.done);

        // act
        final result = repository.findAllTasks();

        // assert
        expect(result.todo.length, equals(1));
        expect(result.inProgress.length, equals(1));
        expect(result.analise.length, equals(1));
        expect(result.done.length, equals(1));
      });

      test(
        'should reflect status changes after updateTaskStatus is called',
        () {
          // arrange
          repository.addTask('Movable task', TaskStatusEnum.todo);
          final taskId = repository.findAllTasks().todo.first.id;

          repository.updateTaskStatus(taskId, TaskStatusEnum.done);

          // act
          final result = repository.findAllTasks();

          // assert
          expect(result.todo, isEmpty);
          expect(result.done.length, equals(1));
          expect(result.done.first.title, equals('Movable task'));
        },
      );
    });

    // ---------------------------------------------------------------------------
    // addTask
    // ---------------------------------------------------------------------------

    group('addTask', () {
      test('should add a task with the given title and initial status', () {
        // act
        repository.addTask('New task', TaskStatusEnum.todo);

        // assert
        final result = repository.findAllTasks();
        expect(result.todo.length, equals(1));
        expect(result.todo.first.title, equals('New task'));
        expect(result.todo.first.status, equals(TaskStatusEnum.todo));
      });

      test('should generate a non-empty id for each added task', () {
        // act
        repository.addTask('Task with id', TaskStatusEnum.todo);

        // assert
        final task = repository.findAllTasks().todo.first;
        expect(task.id, isNotEmpty);
      });

      test('should generate unique ids for tasks added sequentially', () async {
        // Small delay ensures millisecondsSinceEpoch differs between calls.
        repository.addTask('First', TaskStatusEnum.todo);
        await Future<void>.delayed(const Duration(milliseconds: 5));
        repository.addTask('Second', TaskStatusEnum.todo);

        // act
        final tasks = repository.findAllTasks().todo;

        // assert
        expect(tasks[0].id, isNot(equals(tasks[1].id)));
      });

      test('should accumulate multiple tasks in the same status list', () {
        // act
        repository.addTask('First todo', TaskStatusEnum.todo);
        repository.addTask('Second todo', TaskStatusEnum.todo);
        repository.addTask('Third todo', TaskStatusEnum.todo);

        // assert
        final result = repository.findAllTasks();
        expect(result.todo.length, equals(3));
      });

      test(
        'should not affect tasks in other status lists when adding a new task',
        () {
          // arrange
          repository.addTask('Existing done task', TaskStatusEnum.done);

          // act
          repository.addTask('New todo task', TaskStatusEnum.todo);

          // assert
          final result = repository.findAllTasks();
          expect(result.done.length, equals(1));
          expect(result.todo.length, equals(1));
        },
      );
    });

    // ---------------------------------------------------------------------------
    // updateTaskStatus
    // ---------------------------------------------------------------------------

    group('updateTaskStatus', () {
      test('should move a task from todo to inProgress', () {
        // arrange
        repository.addTask('Task to move', TaskStatusEnum.todo);
        final taskId = repository.findAllTasks().todo.first.id;

        // act
        repository.updateTaskStatus(taskId, TaskStatusEnum.inProgress);

        // assert
        final result = repository.findAllTasks();
        expect(result.todo, isEmpty);
        expect(result.inProgress.length, equals(1));
        expect(result.inProgress.first.title, equals('Task to move'));
      });

      test('should move a task through all statuses in sequence', () {
        // arrange
        repository.addTask('Pipeline task', TaskStatusEnum.todo);
        final taskId = repository.findAllTasks().todo.first.id;

        // act & assert — todo → inProgress
        repository.updateTaskStatus(taskId, TaskStatusEnum.inProgress);
        expect(repository.findAllTasks().inProgress.length, equals(1));

        // inProgress → inAnalise
        repository.updateTaskStatus(taskId, TaskStatusEnum.inAnalise);
        expect(repository.findAllTasks().analise.length, equals(1));
        expect(repository.findAllTasks().inProgress, isEmpty);

        // inAnalise → done
        repository.updateTaskStatus(taskId, TaskStatusEnum.done);
        expect(repository.findAllTasks().done.length, equals(1));
        expect(repository.findAllTasks().analise, isEmpty);
      });

      test(
        'should only update the targeted task and leave others unchanged',
        () {
          // arrange
          repository.addTask('Target', TaskStatusEnum.todo);
          repository.addTask('Bystander', TaskStatusEnum.todo);

          final tasks = repository.findAllTasks().todo;
          final targetId = tasks.first.id;

          // act
          repository.updateTaskStatus(targetId, TaskStatusEnum.done);

          // assert
          final result = repository.findAllTasks();
          expect(result.todo.length, equals(1));
          expect(result.todo.first.title, equals('Bystander'));
          expect(result.done.length, equals(1));
          expect(result.done.first.title, equals('Target'));
        },
      );

      test('should throw Exception when taskId does not exist', () {
        // act & assert
        expect(
          () => repository.updateTaskStatus(
            'non-existent-id',
            TaskStatusEnum.done,
          ),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains(
                'Task with id non-existent-id not found',
              ),
            ),
          ),
        );
      });

      test(
        'should allow updating a task to the same status it already has',
        () {
          // arrange
          repository.addTask('Same status task', TaskStatusEnum.todo);
          final taskId = repository.findAllTasks().todo.first.id;

          // act — idempotent update
          repository.updateTaskStatus(taskId, TaskStatusEnum.todo);

          // assert — task remains in todo
          final result = repository.findAllTasks();
          expect(result.todo.length, equals(1));
        },
      );
    });
  });
}
