import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raven/LoginWidgets/forgatpass.dart';
import 'package:raven/LoginWidgets/resident-register.dart';
import 'package:http/http.dart' as http;
import 'package:raven/residentui/chatbotv1.dart';
import 'package:connectivity/connectivity.dart';
import 'package:raven/residentui/resident-dashboard.dart';

import 'dart:convert';

import 'package:raven/stafflogin.dart';

void main() {
  runApp(MainLoginApp());
}

class MainLoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'System',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Wrap your app with a ChangeNotifierProvider
      home: ChangeNotifierProvider(
        create: (context) => AuthProvider(), // Create AuthProvider instance
        child: LoginPage(),
      ),
    );
  }
}

// Define an AuthProvider class to manage user authentication state
class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  Future<void> login(String email, String password) async {
    final String apiUrl =
        'ecensusonlinerequest.online/api/v1/auth/login'; // Replace with your API endpoint for login

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      _token = responseData['token'];

      // Notify listeners of the change in authentication state
      notifyListeners();
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage = errorData['message'];
      throw Exception(errorMessage);
    }
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late Future<String?> _loginFuture;

  bool _isLoggingIn = false;
Future<String?> _performLogin() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // No internet connection
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return null;
  }

  setState(() {
    _isLoggingIn = true;
  });

  const String apiUrl = 'https://ecensusonlinerequest.online/api/v1/auth/login';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String? token = responseData['token'] ?? null;

      if (token != null) {
        print('Login successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardPage(
              token: token,
              email: emailController.text,
              password: passwordController.text,
            ),
          ),
        );
      } else {
        _showErrorDialog('Token not found in response');
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage = errorData['message'];
      _showErrorDialog(errorMessage);
    }
  } catch (error) {
    _showErrorDialog('An error occurred: $error');
  }

  setState(() {
    _isLoggingIn = false;
  });
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  void initState() {
    super.initState();
    _loginFuture = Future.value(null);
  }

  void _onLoginPressed() {
    setState(() {
      _loginFuture = _performLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          // Background Image
          //  Container(
          //      height: MediaQuery.of(context).size.height,
          //     width: MediaQuery.of(context).size.width,
          //      decoration: const BoxDecoration(
          //        image: DecorationImage(
          //          image: AssetImage('images/central_bic_wallpaper.jpg'),
          //           fit: BoxFit.cover,
          //        ),
          //      ),
          //    ),
          // Logo Button in the Top Right Corner
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Redirect to the staff login page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffLoginPage(),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[700],
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          // Column for System Information and Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // System Information Column
                  Container(
                    width: 200.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('images/central_bicutan.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Login Form Column
                  Card(
                    margin: EdgeInsets.all(10.0), // Add margin as needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          15.0), // Add border radius for rounded corners
                    ),
                    elevation: 4, // Add elevation for a shadow effect
                    child: Container(
                      width: 250.0, // Adjusted width
                      padding:
                          EdgeInsets.all(16.0), // Add padding within the card
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              fillColor:
                                  Colors.white, // Set the background color
                              filled: true, // Fill the background
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              fillColor:
                                  Colors.white, // Set the background color
                              filled: true, // Fill the background
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          if (_isLoggingIn)
                            const Column(
                              children: [
                                Text(
                                  'Loading...',
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(height: 10.0),
                                CircularProgressIndicator(),
                              ],
                            )
                          else
                            ElevatedButton(
                              onPressed: _performLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          // Use a FutureBuilder to show loading or navigate to ChatbotPage
                          const SizedBox(height: 10.0),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordDialog(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
