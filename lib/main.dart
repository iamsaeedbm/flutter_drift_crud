// file: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_drift_crud/database/database.dart';

// یک نمونه از دیتابیس می‌سازیم تا در کل برنامه از آن استفاده کنیم
final AppDatabase database = AppDatabase();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Simple To-Do', home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          // بخش افزودن وظیفه جدید
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New Task Title',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      database.addTask(_controller.text); // CREATE
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),

          // بخش نمایش لیست وظایف
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: database.watchAllTasks(), // READ
              builder: (context, snapshot) {
                final tasks = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      // برای تغییر وضعیت تکمیل شده
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (bool? value) {
                          final updatedTask = task.copyWith(completed: value!);
                          database.updateTaskStatus(updatedTask); // UPDATE
                        },
                      ),
                      // برای حذف کردن
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          database.deleteTask(task.id); // DELETE
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
