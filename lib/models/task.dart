class Task {
    final String id;
    String title;
    String subtitle;
    bool isCompleted;

Task({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
});

  void operator [](String other) {}
}
