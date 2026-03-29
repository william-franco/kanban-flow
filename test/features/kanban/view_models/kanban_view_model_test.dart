import 'package:flutter_test/flutter_test.dart';
import 'package:kanban_flow/src/common/enums/task_status_enum.dart';
import 'package:kanban_flow/src/features/kanban/models/task_model.dart';
import 'package:kanban_flow/src/features/kanban/view_models/kanban_view_model.dart';
import 'package:mockito/mockito.dart';

import '../kanban_mocks.mocks.dart';

void main() {
  group('KanbanViewModel Test', () {
    late MockKanbanRepository mockKanbanRepository;
    late KanbanViewModel viewModel;

    // Reusable stub data
    final tTodoTask = TaskModel(
      id: '1',
      title: 'Todo task',
      status: TaskStatusEnum.todo,
    );
    final tProgressTask = TaskModel(
      id: '2',
      title: 'Progress task',
      status: TaskStatusEnum.inProgress,
    );
    final tKanbanModel = KanbanModel(
      todo: [tTodoTask],
      inProgress: [tProgressTask],
      analise: [],
      done: [],
    );
    final tEmptyKanban = KanbanModel();

    setUpAll(() {
      provideDummy<KanbanModel>(tEmptyKanban);
    });

    setUp(() {
      mockKanbanRepository = MockKanbanRepository();
      viewModel = KanbanViewModelImpl(kanbanRepository: mockKanbanRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    // ---------------------------------------------------------------------------
    // Initial state
    // ---------------------------------------------------------------------------

    test('should start with a default empty KanbanModel', () {
      expect(viewModel.state, isA<KanbanModel>());
      expect(viewModel.state.todo, isEmpty);
      expect(viewModel.state.inProgress, isEmpty);
      expect(viewModel.state.analise, isEmpty);
      expect(viewModel.state.done, isEmpty);
    });

    // ---------------------------------------------------------------------------
    // getAllTasks
    // ---------------------------------------------------------------------------

    group('getAllTasks', () {
      test(
        'should emit the KanbanModel returned by repository.findAllTasks',
        () {
          // arrange
          when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

          final emittedStates = <KanbanModel>[];
          viewModel.addListener(() => emittedStates.add(viewModel.state));

          // act
          viewModel.getAllTasks();

          // assert
          expect(emittedStates.length, equals(1));
          expect(emittedStates.first.todo.length, equals(1));
          expect(emittedStates.first.inProgress.length, equals(1));
          verify(mockKanbanRepository.findAllTasks()).called(1);
        },
      );

      test(
        'should emit an empty KanbanModel when repository returns no tasks',
        () {
          // arrange
          when(mockKanbanRepository.findAllTasks()).thenReturn(tEmptyKanban);

          final emittedStates = <KanbanModel>[];
          viewModel.addListener(() => emittedStates.add(viewModel.state));

          // act
          viewModel.getAllTasks();

          // assert
          expect(emittedStates.first.todo, isEmpty);
          expect(emittedStates.first.done, isEmpty);
        },
      );

      test('should notify listeners exactly once per getAllTasks call', () {
        // arrange
        when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        // act
        viewModel.getAllTasks();

        // assert
        expect(notifyCount, equals(1));
      });
    });

    // ---------------------------------------------------------------------------
    // updateTaskStatus
    // ---------------------------------------------------------------------------

    group('updateTaskStatus', () {
      test(
        'should call repository.updateTaskStatus with the correct arguments',
        () {
          // arrange
          when(
            mockKanbanRepository.updateTaskStatus(any, any),
          ).thenReturn(null);
          when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

          // act
          viewModel.updateTaskStatus('1', TaskStatusEnum.done);

          // assert
          verify(
            mockKanbanRepository.updateTaskStatus('1', TaskStatusEnum.done),
          ).called(1);
        },
      );

      test(
        'should call getAllTasks after updateTaskStatus to refresh state',
        () {
          // arrange
          when(
            mockKanbanRepository.updateTaskStatus(any, any),
          ).thenReturn(null);
          when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

          // act
          viewModel.updateTaskStatus('1', TaskStatusEnum.inProgress);

          // assert — findAllTasks is called as part of getAllTasks refresh
          verify(mockKanbanRepository.findAllTasks()).called(1);
        },
      );

      test('should emit updated state after updateTaskStatus', () {
        // arrange
        final updatedKanban = KanbanModel(
          todo: [],
          inProgress: [],
          analise: [],
          done: [tTodoTask.copyWith(status: TaskStatusEnum.done)],
        );
        when(mockKanbanRepository.updateTaskStatus(any, any)).thenReturn(null);
        when(mockKanbanRepository.findAllTasks()).thenReturn(updatedKanban);

        final emittedStates = <KanbanModel>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        viewModel.updateTaskStatus('1', TaskStatusEnum.done);

        // assert
        expect(emittedStates.length, equals(1));
        expect(emittedStates.first.done.length, equals(1));
        expect(emittedStates.first.todo, isEmpty);
      });

      test(
        'should notify listeners exactly once per updateTaskStatus call',
        () {
          // arrange
          when(
            mockKanbanRepository.updateTaskStatus(any, any),
          ).thenReturn(null);
          when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

          int notifyCount = 0;
          viewModel.addListener(() => notifyCount++);

          // act
          viewModel.updateTaskStatus('1', TaskStatusEnum.inProgress);

          // assert
          expect(notifyCount, equals(1));
        },
      );

      test(
        'should propagate exception when repository.updateTaskStatus throws',
        () {
          // arrange
          when(
            mockKanbanRepository.updateTaskStatus(any, any),
          ).thenThrow(Exception('Task with id 99 not found'));

          // act & assert
          expect(
            () => viewModel.updateTaskStatus('99', TaskStatusEnum.done),
            throwsA(
              predicate<Exception>(
                (e) => e.toString().contains('Task with id 99 not found'),
              ),
            ),
          );
        },
      );
    });

    // ---------------------------------------------------------------------------
    // addTask
    // ---------------------------------------------------------------------------

    group('addTask', () {
      test('should call repository.addTask with the correct arguments', () {
        // arrange
        when(mockKanbanRepository.addTask(any, any)).thenReturn(null);
        when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

        // act
        viewModel.addTask('New task', TaskStatusEnum.todo);

        // assert
        verify(
          mockKanbanRepository.addTask('New task', TaskStatusEnum.todo),
        ).called(1);
      });

      test('should call getAllTasks after addTask to refresh state', () {
        // arrange
        when(mockKanbanRepository.addTask(any, any)).thenReturn(null);
        when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

        // act
        viewModel.addTask('New task', TaskStatusEnum.inProgress);

        // assert
        verify(mockKanbanRepository.findAllTasks()).called(1);
      });

      test('should emit updated state after addTask', () {
        // arrange
        final newTask = TaskModel(
          id: '3',
          title: 'New task',
          status: TaskStatusEnum.todo,
        );
        final updatedKanban = KanbanModel(todo: [tTodoTask, newTask]);
        when(mockKanbanRepository.addTask(any, any)).thenReturn(null);
        when(mockKanbanRepository.findAllTasks()).thenReturn(updatedKanban);

        final emittedStates = <KanbanModel>[];
        viewModel.addListener(() => emittedStates.add(viewModel.state));

        // act
        viewModel.addTask('New task', TaskStatusEnum.todo);

        // assert
        expect(emittedStates.length, equals(1));
        expect(emittedStates.first.todo.length, equals(2));
      });

      test('should notify listeners exactly once per addTask call', () {
        // arrange
        when(mockKanbanRepository.addTask(any, any)).thenReturn(null);
        when(mockKanbanRepository.findAllTasks()).thenReturn(tKanbanModel);

        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        // act
        viewModel.addTask('New task', TaskStatusEnum.todo);

        // assert
        expect(notifyCount, equals(1));
      });

      test('should support adding tasks with each TaskStatusEnum value', () {
        // arrange
        when(mockKanbanRepository.addTask(any, any)).thenReturn(null);

        for (final status in TaskStatusEnum.values) {
          when(mockKanbanRepository.findAllTasks()).thenReturn(tEmptyKanban);

          // act & assert — no exception thrown for any status
          expect(
            () => viewModel.addTask('Task $status', status),
            returnsNormally,
          );
        }

        verify(
          mockKanbanRepository.addTask(any, any),
        ).called(TaskStatusEnum.values.length);
      });
    });
  });
}
