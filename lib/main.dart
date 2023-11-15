// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, override_on_non_overriding_member, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:cpad_assignment/login.dart';
import 'package:cpad_assignment/editscreen.dart';
import 'package:provider/provider.dart';
import 'package:cpad_assignment/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Parse().initialize(AppConfig.keyApplicationId, AppConfig.keyParseServerUrl, clientKey: AppConfig.keyClientKey, autoSendSessionId: true, debug: true);

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState(),
      child: MaterialApp(
        initialRoute: 'login', // Set the initial route to '/login'
        routes: {
          'login': (context) => LoginScreen(),
          'main': (context) => MyApp(),
          'editscreen':(context) => EditTaskScreen(name: '', details: '', assignedTo: ''),
        },
      ),
    ),
  );
}

class Task {
  final String name;
  final String details;
  final String assignedTo;
  final String assignedBy;

  Task(this.name, this.details, this.assignedTo, this.assignedBy);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Task> tasks = [];
  final taskNameController = TextEditingController();
  final taskDetailsController = TextEditingController();
  final assignedToController = TextEditingController();
  final currentUser = ParseUser.currentUser;
  
  Future<void> saveTaskToBack4App(Task task) async {
    final parseObject = ParseObject('CPAD_Task')
      ..set('TaskName', task.name)
      ..set('TaskDetails', task.details)
      ..set('AssignedTo', task.assignedTo)
      ..set('AssignedBy', task.assignedBy);
    final response = await parseObject.save();
    if (response.success) {
      print('Task saved to Back4App');
    } else {
      print('Failed to save task: ${response.error?.message}');
    }
  }

  Future<void> fetchTasksFromBack4App() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('CPAD_Task'))
      ..orderByAscending('createdAt');
    final response = await queryBuilder.query();
    if (response.success) {
      final tasksFromServer = response.results;
      tasks.clear();
      if (tasksFromServer != null)
      {
        for (var taskObject in tasksFromServer) {
          tasks.add(Task(
            taskObject.get('TaskName'),
            taskObject.get('TaskDetails'),
            taskObject.get('AssignedTo'),
            taskObject.get('AssignedBy'),
          ));
        }
      }
      print('Fetched ${tasks.length} tasks from Back4App');
      setState(() {
        tasks = tasks;
      });
    } else {
      print('Failed to fetch tasks: ${response.error?.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70.0,
          title: Text(
            "Task App",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue, // Background color of the AppBar
          elevation: 4.0, // Elevation shadow
          centerTitle: true, // Center the title
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: taskNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Task Name'),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: taskDetailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Task Details'),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: assignedToController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Assigned To'),
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    final taskName = taskNameController.text;
                    final taskDetails = taskDetailsController.text;
                    final assignedTo = assignedToController.text;
                    final ParseUser currentUser = await ParseUser.currentUser();
                    final username = currentUser.get('username') as String;

                    if (taskName.isNotEmpty && taskDetails.isNotEmpty && assignedTo.isNotEmpty) {
                      final newTask = Task(taskName, taskDetails, assignedTo, username);
                      tasks.add(newTask);
                      saveTaskToBack4App(newTask);
                      taskNameController.clear();
                      taskDetailsController.clear();
                      assignedToController.clear();

                      // Show a dialog with two buttons
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Task Saved'),
                            content: Text('What would you like to do next?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  // Close the dialog and navigate back to the task screen
                                  Navigator.pop(context);
                                },
                                child: Text('Add More Task'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Close the dialog and navigate back to the task screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyApp()),
                                  );
                                },
                                child: Text('Back'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Close the dialog and navigate back to the login screen
                                  Navigator.pop(context);
                                  // Navigate to the login screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  );
                                },
                                child: Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else {
                      // Show a validation message if any field is empty
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('OOPS!! Cannot Save.'),
                            content: Text('Please fill in all the required fields.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  // Close the validation dialog
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Save'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    fetchTasksFromBack4App();
                  },
                  child: Text('Refresh'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to the login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Recent Tasks:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(name: tasks[index].name, details: tasks[index].details, assignedTo: tasks[index].assignedTo),
                          ),
                      );
                    },
                    child: Card (
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(tasks[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        subtitle: Text('Assigned to: ${tasks[index].assignedTo}\nAssigned by: ${tasks[index].assignedBy}\nDetails: ${tasks[index].details}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.5,
                            wordSpacing: 2.0,
                            height: 1.8,
                            backgroundColor: Colors.transparent,
                            decoration: TextDecoration.none,
                            decorationColor: Colors.red,
                            decorationStyle: TextDecorationStyle.solid
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}