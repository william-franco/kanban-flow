import 'package:flutter/material.dart';
import 'package:kanban_flow/src/common/enums/task_status_enum.dart';
import 'package:kanban_flow/src/features/kanban/view_models/kanban_view_model.dart';

class AddTaskView extends StatefulWidget {
  final KanbanViewModel kanbanViewModel;

  const AddTaskView({super.key, required this.kanbanViewModel});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final _formKey = GlobalKey<FormState>();
  String _taskTitle = '';
  TaskStatusEnum _selectedStatus = TaskStatusEnum.todo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Task')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: isWideScreen ? 4 : 0,
                  child: Container(
                    width: isWideScreen ? 500 : double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Task Title',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _taskTitle = value!;
                            },
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<TaskStatusEnum>(
                            decoration: const InputDecoration(
                              labelText: 'Initial Status',
                            ),
                            initialValue: _selectedStatus,
                            items: TaskStatusEnum.values.map((status) {
                              return DropdownMenuItem<TaskStatusEnum>(
                                value: status,
                                child: Text(status.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (status) {
                              setState(() {
                                _selectedStatus = status!;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                widget.kanbanViewModel.addTask(
                                  _taskTitle,
                                  _selectedStatus,
                                );
                                Navigator.pop(context, true);
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
