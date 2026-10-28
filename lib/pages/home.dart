
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:progressly/models/task.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final Color primaryColor = const Color.fromARGB(255, 8, 195, 195);

  final Box tasksBox = Hive.box('tasksBox');

  String selectedFilter = 'All';

  List<Task> tasks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Load saved tasks from Hive.
  Future<void> loadTasks() async {
    final savedTasks = tasksBox.values.toList();

    final loadedTasks = savedTasks.map((item) {
      final data = Map<String, dynamic>.from(item as Map);

      return Task(
        id: data['id'] as String,
        title: data['title'] as String,
        subtitle: data['subtitle'] as String,
        isCompleted: data['isCompleted'] as bool,
      );
    }).toList();

    if (!mounted) return;

    setState(() {
      tasks = loadedTasks;
      isLoading = false;
    });
  }

  // Save all tasks in Hive.
  Future<void> saveTasks() async {
    await tasksBox.clear();

    for (final task in tasks) {
      await tasksBox.put(task.id, {
        'id': task.id,
        'title': task.title,
        'subtitle': task.subtitle,
        'isCompleted': task.isCompleted,
      });
    }
  }

  // Get today's date.
  String getTodayDate() {
    final now = DateTime.now();

    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];

    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return '${days[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}';
  }

  // Calculate the number of completed tasks.
  int get completedTasks =>
      tasks.where((task) => task.isCompleted).length;

  // Filter tasks according to the selected filter.
  List<Task> get filteredTasks {
    if (selectedFilter == 'Active') {
      return tasks.where((task) => !task.isCompleted).toList();
    }

    if (selectedFilter == 'Completed') {
      return tasks.where((task) => task.isCompleted).toList();
    }

    return tasks;
  }

  // Change a task's completion status and save it.
  Future<void> toggleTask(Task task, bool value) async {
    setState(() {
      task.isCompleted = value;
    });

    await saveTasks();
  }

  // Delete a task and save the changes.
  Future<void> deleteTask(Task task) async {
    setState(() {
      tasks.removeWhere((item) => item.id == task.id);
    });

    await saveTasks();
  }

  // Add a new task and save it.
  Future<void> addTask(String title) async {
    final newTask = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      subtitle: 'New task',
    );

    setState(() {
      tasks.add(newTask);
    });

    await saveTasks();
  }

  // Display the form used to create a task.
  
Future<void> showAddTaskDialog() async {
  final controller = TextEditingController();

  try {
    final title = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Task',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter task title...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.pop(sheetContext, value.trim());
                    }
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final value = controller.text.trim();

                      if (value.isNotEmpty) {
                        Navigator.pop(sheetContext, value);
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || title == null || title.isEmpty) return;

    await addTask(title);
  } finally {
    controller.dispose();
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final progress = tasks.isEmpty
        ? 0.0
        : completedTasks / tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFD),
        elevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: Color(0xFF202235),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 222, 251, 254),
              child: Icon(
                Icons.checklist_rounded,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              getTodayDate(),
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: 1.1,
                color: Color.fromARGB(255, 8, 8, 8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Stay focused and get things done.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF85899B),
              ),
            ),
            const SizedBox(height: 15),

            // Progress card.
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 222, 251, 254),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's progress",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '$completedTasks / ${tasks.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$completedTasks task(s) completed · '
                    '${tasks.length - completedTasks} remaining',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777B91),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Filter buttons.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Active', 'Completed'].map((filter) {
                  final isSelected = selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor:
                          const Color.fromARGB(255, 222, 251, 254),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? const Color.fromARGB(255, 222, 251, 254)
                            : const Color.fromARGB(252, 213, 250, 254),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? primaryColor
                            : const Color(0xFF666A7A),
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Task list.
            ...filteredTasks.map((task) {
              final isCompleted = task.isCompleted;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color.fromARGB(255, 222, 251, 254),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isCompleted,
                      activeColor: primaryColor,
                      shape: const CircleBorder(),
                      onChanged: (value) {
                        if (value != null) {
                          toggleTask(task, value);
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? const Color(0xFF999CAD)
                                  : const Color(0xFF292B3D),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF85899B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFF9699A9),
                      ),
                      onPressed: () {
                        deleteTask(task);
                      },
                    ),
                  ],
                ),
              );
            }),

            if (filteredTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 44,
                      color: Color(0xFFB2B6C7),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No tasks here yet!',
                      style: TextStyle(
                        color: Color(0xFF85899B),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}
