import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordDialog extends StatefulWidget {
  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController verificationCodeController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool requestingCode = false;

  Future<void> _requestVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> requestData = {
        'email': emailController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('https://ecensusonlinerequest.online/api/v1/reset-password/request'),
          body: json.encode(requestData),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseJson = json.decode(response.body);
          final role = responseJson['role_id'];
          final error = responseJson['error'];

          if (role == '4' || role == '1') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Staff and Admin users are not eligible for password reset.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                duration: Duration(seconds: 3),
              ),
            );
          } else if (responseJson.containsKey('message')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseJson['message']),
                duration: Duration(seconds: 3),
              ),
            );
            setState(() {
              requestingCode = true;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Verification code request failed. Please try again later.'),
              duration: Duration(seconds: 3),
            ),
          );
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
        if (mounted) {
          print('Error: $e');
        }
      }
    }
  }

  Future<void> _verifyCodeAndResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> requestData = {
        'email': emailController.text,
        'verification_code': verificationCodeController.text,
        'password': newPasswordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('https://ecensusonlinerequest.online/api/v1/verify-code/reset-password'),
          body: json.encode(requestData),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset successful.'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop();
        } else if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid verification code or email.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset failed. Please try again later.'),
              duration: Duration(seconds: 3),
            ),
          );
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
        if (mounted) {
          print('Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Forgot Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to reset your password:'),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            if (requestingCode)
              Column(
                children: [
                  Text('Enter the verification code sent to your email:'),
                  TextFormField(
                    controller: verificationCodeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Text('Set a new password:'),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        if (requestingCode)
          ElevatedButton(
            onPressed: _verifyCodeAndResetPassword,
            child: Text('Reset Password'),
          ),
        if (!requestingCode)
          ElevatedButton(
            onPressed: _requestVerificationCode,
            child: Text('Request Verification Code'),
          ),
      ],
    );
  }
}
