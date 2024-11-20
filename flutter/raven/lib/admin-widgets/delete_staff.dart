import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'staff_management.dart';

class DeleteStaffDialog extends StatefulWidget {
  final String token;
  final User userDelete;
  final Function onDelete;

  const DeleteStaffDialog(
      {required this.token, required this.userDelete, required this.onDelete});

  @override
  _DeleteStaffDialog createState() => _DeleteStaffDialog(token: token);
}

class _DeleteStaffDialog extends State<DeleteStaffDialog> {
  bool isLoading = false;

  final String token;

  _DeleteStaffDialog({required this.token});

  Future<void> _handleDelete() async {

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
      if (!mounted) {
        return; // Check if the widget is still mounted
      }

      setState(() {
        isLoading = true;
      });

      final response = await http.delete(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.userDelete.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Handle successful deletion, e.g., show a success message
        print('Staff deleted successfully');

        // Call the onDelete callback to trigger a data refresh in the parent widget
        widget.onDelete();
      } else {
        // Handle error, e.g., show an error message
        print('Error deleting Staff: ${response.statusCode}');
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      // Close the dialog after handling
    } catch (e) {
      // Handle exceptions during deletion, e.g., network error
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error deleting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Staff'),
      content: Text(
          'Are you sure you want to delete staff ${widget.userDelete.username}?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleDelete,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
