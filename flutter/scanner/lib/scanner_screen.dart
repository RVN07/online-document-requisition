import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
class ScannerScreen extends StatefulWidget {
  final String token;

  ScannerScreen({required this.token});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  late QRViewController controller;
  final encrypt.Key generatedKey = encrypt.Key.fromBase64(
      'aX+8tq5AAVfbQbehfMTQPebrPyH+Cq/y+ysJcL5OJz4=');
  bool _isMounted = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    _isDisposed = true;
    super.dispose();
  }

  Future<bool> logout(String token, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> requestBody = {
      "email": email,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/auth/logout'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
              child: SizedBox(
                width: 200.0,
                height: 200.0,
              ),
            ),
          ),
         Positioned(
  left: 0,
  right: 0,
  bottom: 20,
  child: Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: 200, // Set a fixed width or adjust as needed
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Show the scanned QR
                  if (result != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Scanned QR"),
                        content: Text(result!.code!),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              // Show the decrypted data
                              if (result != null) {
                                String decryptedData = decodeBase64Data(result!.code!);
                                // Transform JSON to form format
                                Map<String, String> formData = transformToFormFormat(jsonDecode(decryptedData));
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Form Data"),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: formData.entries
                                            .map((entry) => ListTile(
                                                  title: Text(entry.key),
                                                  subtitle: Text(entry.value),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Send the form data to your Laravel API
                                          sendDataToAPI(formData);
                                        },
                                        child: Text("Verify Data"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Text("Show Form Data"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Close"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text("Show Scanned QR"),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    ),
  ),
),

      ),],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (scanData.code != null) {
          result = scanData;
        }
      });
    });
  }

  String decodeBase64Data(String base64Data) {
    try {
      final decodedBytes = base64.decode(base64Data);
      String decodedString = utf8.decode(decodedBytes);
      return decodedString.trim();
    } catch (error) {
      print("Error decoding base64 data: $error");
      return "Failed to decode base64 data";
    }
  }

  Map<String, String> transformToFormFormat(Map<String, dynamic> jsonData) {
    // Transform JSON data to form format (key-value pairs)
    Map<String, String> formData = {};
    jsonData.forEach((key, value) {
      formData[key] = value.toString();
    });
    return formData;
  }

void sendDataToAPI(Map<String, String?> formData) async {
  try {
    // Handle null values for the formData field
    formData['firstName'] ??= '';
    formData['middleName'] ??= '';
    formData['lastName'] ??= '';
    formData['suffix'] ??= ''; // Provide a default value if 'suffix' is null
    formData['gender'] ??= '';
    formData['age'] ??= '';
    formData['address'] ??= '';
    formData['documenttype'] ??= '';
    formData['email'] ??= '';
    formData['contact'] ??= '';
    formData['reason'] ??= '';

    final response = await http.post(
      Uri.parse('https://ecensusonlinerequest.online/api/v1/verify-documentrequest'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({"data": formData}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Data verification successful
      Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody.containsKey('error')) {
        // Check for the specific error message indicating scanning own QR code
        if (responseBody['error'] == 'Scanning your own QR code is not allowed.') {
          _showFailureAlertDialog('Scanning Error', errorDetails: responseBody['error']);
        } else {
          _showFailureAlertDialog('Unknown Error: ${responseBody['error']}');
        }
      } else if (responseBody.containsKey('action')) {
        String action = responseBody['action'];

        switch (action) {
          case 'show_verification':
            _showSuccessAlertDialog('Verification Successful');
            break;
          // Add more cases for additional actions if needed
          default:
            _showFailureAlertDialog('Unknown Action: $action');
            break;
        }
      } else {
        // Handle missing 'action' key in the response
        print('Error: Missing "action" key in the response.');
      }
    } else {
      // Show failure AlertDialog with error details
      _showFailureAlertDialog('Server Error', errorDetails: response.body);
      print('Server Error: ');
      print('Failed to send data to API. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Show failure AlertDialog with error details
    _showFailureAlertDialog('Error Sending Data', errorDetails: '$e');
    print('Error sending data to API: $e');
  }
}

void _showSuccessAlertDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Verification Successful"),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        ),
      ],
    ),
  );
}

void _showFailureAlertDialog(String status, {String? errorDetails}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Verification Failed"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Data verification failed. Status: $status"),
          if (errorDetails != null) Text("Error Details: $errorDetails"),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        ),
      ],
    ),
  );
}
}