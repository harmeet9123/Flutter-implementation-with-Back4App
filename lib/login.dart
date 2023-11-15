// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, override_on_non_overriding_member, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:cpad_assignment/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Parse().initialize(
      AppConfig.keyApplicationId, AppConfig.keyParseServerUrl,
      clientKey: AppConfig.keyClientKey, autoSendSessionId: true, debug: true);

  runApp(
    ChangeNotifierProvider(
      // Use ChangeNotifierProvider to provide the UserState
      create: (context) => UserState(),
      child: LoginScreen(),
    ),
  );
}

class UserState with ChangeNotifier {
  ParseUser _currentUser = ParseUser(null, null, null);

  ParseUser get currentUser => _currentUser;

  UserState() {
    // Initialize _currentUser to a valid ParseUser instance or set it to null initially.
    _currentUser = ParseUser(null, null, null);
  }

  Future<bool> registerUser(String username, String password) async {
    final user = ParseUser(username, password, null);
    final response = await user.signUp(allowWithoutEmail: true);
    if (response.success) {
      _currentUser = user;
      notifyListeners();
      print('User registered: ${user.get('username')}');
      return true;
    } else {
      print('Registration failed: ${response.error?.message}');
      return false;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    final user = ParseUser(username, password, null);
    final response = await user.login();
    if (response.success) {
      _currentUser = user;
      notifyListeners(); // Notify listeners of the change in user state
      print('User logged in: ${user.get('username')}');
      return true;
    } else {
      print('Login failed: ${response.error?.message}');
      return false;
    }
  }

  void _showErrorDialog(BuildContext context, List<String> errorMessages,
      int currentIndex, String source) {
    String title = source == 'login' ? 'Login Failed' : 'Registration Failed';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(errorMessages[currentIndex]),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (currentIndex < errorMessages.length - 1) {
                // Show the next error message
                _showErrorDialog(
                    context, errorMessages, currentIndex + 1, source);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessfulDialog(BuildContext context, String successMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Successful'),
        content: Text(successMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true; // Initially, password is hidden

  @override
  Widget build(BuildContext context) {
    // Use a Consumer widget to access the UserState and perform login
    return Consumer<UserState>(
      builder: (context, userState, child) {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Login Screen'),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Login.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 100.0),
                  // Container(
                  //   width: 150,
                  //   height: 150,
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //       image: AssetImage('assets/Login.png'),
                  //       fit: BoxFit.cover,
                  //       ),
                  //     ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: usernameController,
                      style: TextStyle(fontSize: 25, color: Colors.black),
                      decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          hintText: 'Username',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 69, 54, 54)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: passwordController,
                      style: TextStyle(fontSize: 25, color: Colors.black),
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 65, 61, 61)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          )),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          List<String> errorMessages = [];
                          final username = usernameController.text;
                          final password = passwordController.text;
                          if (username.isEmpty) {
                            errorMessages.add('Username cannot be blank..');
                          }
                          if (password.isEmpty) {
                            errorMessages.add('Password cannot be blank..');
                          }
                          if (errorMessages.isNotEmpty) {
                            // Show the first error message
                            userState._showErrorDialog(
                                context, errorMessages, 0, 'login');
                          } else {
                            bool login = await userState.loginUser(
                                username, password); // Call loginUser method
                            if (login) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Login Successful'),
                                  content: const Text(
                                      'Now you can work on Task Details!!'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        Navigator.pushNamed(context, 'main');
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              List<String> errorMessages = [];
                              errorMessages.add('Invalid Username/Password');
                              userState._showErrorDialog(
                                  context, errorMessages, 0, 'login');
                              usernameController.clear();
                              passwordController.clear();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Log In'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          List<String> errorMessages = [];
                          final username = usernameController.text;
                          final password = passwordController.text;
                          if (username.isEmpty) {
                            errorMessages.add('Username cannot be blank..');
                          }
                          if (password.isEmpty) {
                            errorMessages.add('Password cannot be blank..');
                          }
                          if (password.length < 3) {
                            errorMessages.add(
                                'Password must be at least 3 characters long..');
                          }
                          if (errorMessages.isNotEmpty) {
                            // Show the first error message
                            userState._showErrorDialog(
                                context, errorMessages, 0, 'signup');
                          } else {
                            bool register = await userState.registerUser(
                                username, password); // Call registration method
                            if (register) {
                              const registerMessage =
                                  'Please Proceed to Log In.';
                              userState._showSuccessfulDialog(
                                  context, registerMessage);
                              usernameController.clear();
                              passwordController.clear();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}