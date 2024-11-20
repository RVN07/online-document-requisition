import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner/scanner_screen.dart';
import 'package:scanner/statistics.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Other providers if needed
      ],
      child: LoginApp(),
    ),
  );
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
        child: StaffLoginPage(), // Set StaffLoginPage as the default login page
      ),
    );
  }
}

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  Future<void> login(String email, String password) async {
    const String apiUrl =
        'localhost:8000/api/v1/auth/login'; // Replace with your API endpoint for login

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
  List<StatusDocumentRequest> statusList = [];
class _StaffLoginPageState extends State<StaffLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _isMounted => mounted;

  late Future<String?> _loginFuture;

  bool _isLoggingIn = false;

    Future<void> fetchData() async {

      final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? token = authProvider.token;

    try {
      // Check if the token is null or empty before making the API request
      if (token == null || token.isEmpty) {
        print('Token is null or empty. Please log in first.');
        return;
      }

      final Uri uri = Uri.parse(
          'https://ecensusonlinerequest.online/api/v1/documentrequests');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data')) {
          final List<dynamic> data = jsonData['data'];
          final List<StatusDocumentRequest> tempList = [];

          for (var item in data) {
            tempList.add(StatusDocumentRequest.fromJson(item));
          }

          if (_isMounted) {
            setState(() {
              statusList = tempList;
            });
          }
        } else {
          print('Failed to fetch data: Response does not contain "data"');
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


 Future<String?> _performLogin() async {
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
    final int role = responseData['role']; // Adjust this based on your API response

    print('Login successfully with role: $role');

    // Navigate based on the user's role
    if (role == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TableDashboardList(
            token,
            email,
            password,
            statusList,
            fetchData,
        //    _scaffoldKey,
          ),
        ),
      );
    } else if (role == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TableDashboardList(
            token,
            email,
            password,
            statusList,
            fetchData,
        //    _scaffoldKey,
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
    image: DecorationImage(
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
                    onPressed: _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.black),
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
