
import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final Color primaryColor = const Color.fromARGB(255, 8, 195, 195);

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> tasks = [];

  // Get today's date
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

  int get completedTasks =>
      tasks.where((task) => task['completed'] == true).length;

  List<Map<String, dynamic>> get filteredTasks {
    if (selectedFilter == 'Active') {
      return tasks.where((task) => task['completed'] == false).toList();
    }

    if (selectedFilter == 'Completed') {
      return tasks.where((task) => task['completed'] == true).toList();
    }

    return tasks;
  }

  void toggleTask(int index) {
    setState(() {
      filteredTasks[index]['completed'] =
          !filteredTasks[index]['completed'];
    });
  }

  void addTask() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                decoration: InputDecoration(
                  hintText: 'Enter task title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = controller.text.trim();

                    if (title.isEmpty) return;

                    setState(() {
                      tasks.add({
                        'title': title,
                        'subtitle': 'New task',
                        'completed': false,
                      });
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
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

            // Progress card
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
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

            // Filter buttons
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
                      selectedColor: const Color.fromARGB(255, 222, 251, 254),
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

            // Task list
            ...filteredTasks.map((task) {
              final isCompleted = task['completed'] as bool;

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
                      onChanged: (_) {
                        toggleTask(filteredTasks.indexOf(task));
                      },
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] as String,
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
                            task['subtitle'] as String,
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
                        setState(() {
                          tasks.remove(task);
                        });
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
        onPressed: addTask,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}