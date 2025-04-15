import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:todo_app/glassmorphism.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 240, 156, 117)),
      ),
      home: const TodoListPage(),
    );
  }
}

class Todo {
  String text;
  bool isCompleted;

  Todo({
    required this.text,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      text: json['text'],
      isCompleted: json['isCompleted'],
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _todoController = TextEditingController();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todosString = prefs.getString('todos');
    if (todosString != null) {
      List<dynamic> todosJson = jsonDecode(todosString);
      setState(() {
        _todos = todosJson.map((json) => Todo.fromJson(json)).toList();
      });
    }
  }

  void _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todosString =
        jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    prefs.setString('todos', todosString);
  }

  void _addTodo() {
    final taskText = _todoController.text;
    if (taskText.isNotEmpty) {
      setState(() {
        _todos.add(Todo(text: taskText));
        _saveTodos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        _todoController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleCompletion(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      _saveTodos();
    });
  }

  void _editTodoDialog(int index) {
    final task = _todos[index];
    _todoController.text = task.text;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Task',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(
              labelText: 'Task',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _todoController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              child: const Text('Save'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 246, 104, 9),
                maximumSize:
                    const Size(double.infinity, 50), // Set text color to white
              ),
              onPressed: () {
                if (_todoController.text.isNotEmpty) {
                  setState(() {
                    task.text = _todoController.text;
                    _saveTodos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task updated successfully!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _todoController.clear();
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a task!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTodoDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Task',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 246, 45, 9),
                maximumSize:
                    const Size(double.infinity, 50), // Set text color to white
              ),
              onPressed: () {
                setState(() {
                  _todos.removeAt(index);
                  _saveTodos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted successfully!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _resetTodosDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reset All Tasks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'Are you sure you want to reset all tasks? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 246, 45, 9),
                maximumSize:
                    const Size(double.infinity, 50), // Set text color to white
              ),
              onPressed: () {
                setState(() {
                  _todos.clear();
                  _saveTodos();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All tasks reset successfully!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 242, 43, 29),
        foregroundColor: Colors.white,
        onPressed: _resetTodosDialog,
        child: const Icon(Icons.refresh),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/background.jpg"), fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Todo App",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: _todoController,
                        decoration: InputDecoration(
                          labelText: 'Add a task',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional for rounded corners
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.format_list_bulleted_add,
                              color: Colors.black),
                          labelStyle: TextStyle(
                              color: Colors.black), // Optional: label color
                        ),
                        style: TextStyle(
                            color: Colors
                                .black), // Optional: text color inside input
                      )),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color.fromARGB(255, 246, 104, 9),
                          border: Border.all(
                              color: Color.fromARGB(255, 245, 243, 241),
                              width: 3),
                        ),
                        child: IconButton(
                          onPressed: _addTodo,
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: Glassmorphism(
                      blur: 10,
                      opacity: 0.1,
                      radius: 16,
                      child: _todos.isEmpty
                          ? Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  // color: Color.fromARGB(255, 9, 9, 9).withAlpha(
                                  //     (0.5 * 255)
                                  //         .toInt()), // Apply opacity using withAlpha
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                height: 50,
                                child: const Center(
                                  child: Text(
                                    'No tasks yet. Add a task to get started!',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                // color: const Color.fromARGB(255, 240, 237, 237)
                                //     .withAlpha((0.5 * 255)
                                //         .toInt()), // Apply opacity using withAlpha
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _todos.length,
                                itemBuilder: (context, index) {
                                  final task = _todos[index];
                                  return Card(
                                    color: Colors.white,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      horizontalTitleGap: 1,
                                      leading: Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (_) =>
                                            _toggleCompletion(index),
                                      ),
                                      title: Text(
                                        task.text,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Color.fromARGB(
                                                    255, 54, 167, 237)),
                                            onPressed: () =>
                                                _editTodoDialog(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deleteTodoDialog(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
