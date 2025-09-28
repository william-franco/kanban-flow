enum TaskStatusEnum {
  todo,
  inProgress,
  inAnalise,
  done;

  String get name {
    return switch (this) {
      TaskStatusEnum.todo => 'To do',
      TaskStatusEnum.inProgress => 'Progress',
      TaskStatusEnum.inAnalise => 'Analise',
      TaskStatusEnum.done => 'Completed',
    };
  }
}
