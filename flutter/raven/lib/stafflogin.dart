import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raven/admin-dashboard.dart';
import 'package:raven/staffWidgets/staff_dashboard.dart';
import 'package:connectivity/connectivity.dart';
void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChangeNotifierProvider(
        create: (context) => AuthProvider(), // Create AuthProvider instance
        child: StaffLoginPage(),
      ),
    );
  }
}

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  Future<void> login(String email, String password) async {
    const String apiUrl =
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

class StaffLoginPage extends StatefulWidget {
  @override
  _StaffLoginPageState createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
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

    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both email and password fields.'),
        ),
      );
      setState(() {
        _isLoggingIn = false;
      });
      return null; // Return early to prevent further execution
    }

    const String apiUrl = 'https://ecensusonlinerequest.online/api/v1/auth/login-staff';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['token'];
      final int role =
          responseData['role']; // Adjust this based on your API response

      print('Login successfully with role: $role');

      // Navigate based on the user's role
      if (role == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffDashboardPage(
              token: token,
              email: email,
              password: password,
            ),
          ),
        );
      } else if (role == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardPage(
              token: token,
              email: email,
              password: password,
            ),
          ),
        );
      } else {
        // Handle other roles or show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid role. Please contact your administrator.'),
          ),
        );
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage = errorData['message'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(errorMessage),
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

    setState(() {
      _isLoggingIn = false;
    });
    return null;
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/central_bicutan.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  width: 250.0, // Adjusted width
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',

                      border: OutlineInputBorder(),
                      fillColor: Colors.white, // Set the background color
                      filled: true, // Fill the background
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  width: 250.0, // Adjusted width
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white, // Set the background color
                      filled: true, // Fill the background
                    ),
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
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
