import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:raven/residentui/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


//DateTime? selectedDate;
//bool showDatePickerOverlay = false;

class EditPasswordAccountModal extends StatefulWidget {
  final String token;
  final UserData userData; // Add this line to accept the Users object

  EditPasswordAccountModal({required this.token, required this.userData});

  @override
  _EditPasswordAccountModalState createState() =>
      _EditPasswordAccountModalState(token: token);
}

class _EditPasswordAccountModalState extends State<EditPasswordAccountModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

      
  List<String> genderItems = [
    'Male',
    'Female',
  ]; // Define dropdown items
  final List<String> validSuffixes = ['Jr.','Sr.','Jr', 'Sr', 'II', 'III', 'IV'];
  late String selectedGender;

  bool isValidPhoneNumber(String phoneNumber) {
  // Regular expression for a valid Philippine mobile number format
  // Change the regex pattern according to your specific requirements
  final RegExp regex = RegExp(r'^\+?63[0-9]{10}$');

  return regex.hasMatch(phoneNumber);
}

    bool isValidSuffix(String suffix) {
    return validSuffixes.contains(suffix);
  }

  final String token;

  _EditPasswordAccountModalState({required this.token});

  @override
  void initState() {
    super.initState();
    // Populate the form fields with existing user data when the widget is created
    selectedGender = genderItems[0]; 
  //  populateFormFields(widget.userData);
  }

  @override
  void dispose() {
    // Cancel any pending operations or timers here
    super.dispose();
  }

  void populateFormFields(UserData userData) {
    passwordController.text = userData.password;
  }

  Future<void> fetchUserData() async {

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

    try {
      final response = await http.get(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.userData.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        // Populate the form fields with fetched resident data
        populateFormFields(userData);
      } else {
        // Handle error, show an error message
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions, e.g., network error
      print('Error: $e');
    }
  }

  void _updatePassword() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
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
    return;
  }

  if (_formKey.currentState!.validate()) {
    final Map<String, dynamic> userData = {
      
'password': passwordController.text,
    };

    try {
      final response = await http.patch(
        Uri.parse(
            'https://ecensusonlinerequest.online/api/v1/users/${widget.userData.id}'),
        body: json.encode(userData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Update the stored password in preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userPassword', passwordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User Password updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        print('Password updated successfully!');
        // Now, you can call the logout function with the updated password
        _logout(passwordController.text);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        print('Error: $e');
      }
    }
  }
}

Future<bool> _logout(String newPassword) async {
  final prefs = await SharedPreferences.getInstance();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final Map<String, String> requestBody = {
    "email": widget.userData.email,
    "password": newPassword,
  };

  try {
    final response = await http.post(
      Uri.parse(
          'https://ecensusonlinerequest.online/api/v1/auth/logout'),
      headers: headers,
      body: json.encode(requestBody),
    );

    print('Logout Response Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      await prefs.remove('userData');
      await prefs.remove('userId');
      await prefs.remove('token');
      await prefs.remove('userEmail');
      await prefs.remove('userPassword');
      print('Logging Out, Deleting Previous User');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      return true;
    } else {
      print('Logout Error: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Logout Exception: $e');
    return false;
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      iconPadding: const EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey, // Add the Form widget here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
          
const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Password must be at a minimum of 6 characters.'
                ),
                validator: (value) {
                 if (value!.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              //  obscureText: true, // Hide the password
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                 }
                  return null;
                },
                obscureText: true, // Hide the password
             ),
              const SizedBox(height: 20),
              Text('''Changing your password makes your account log out of the system,
               in order for your new password to take effect''', style: TextStyle(fontSize: 10)),
              ElevatedButton(
                onPressed: _updatePassword,
                child: const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInputContainer({label, child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 5),
      SizedBox(
        width: double.infinity, // Controls the width
        child: child,
      ),
      const SizedBox(height: 5), // Adjusted height
    ],
  );
}
}
