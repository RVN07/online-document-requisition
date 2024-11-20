import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:raven/staffWidgets/reports_dashboard.dart';
import 'package:connectivity/connectivity.dart';

class DeleteDocumentDialog extends StatefulWidget {
  final String token;
  final ReportDocumentRequest documentDelete;
  final Function onDelete;

  DeleteDocumentDialog({
    required this.token,
    required this.documentDelete,
    required this.onDelete,
  });

  @override
  _DeleteDocumentDialog createState() => _DeleteDocumentDialog(token: token);
}

class _DeleteDocumentDialog extends State<DeleteDocumentDialog> {
  bool isLoading = true;
  final String token;

  _DeleteDocumentDialog({required this.token});

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
      final response = await http.delete(
        Uri.parse(
            'https://ecensusonlinerequest.online/api/v1/documentrequests/${widget.documentDelete.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Handle successful deletion, e.g., show a success message
        print('Document Request deleted successfully');

        // Call the onDelete callback to trigger a data refresh in the parent widget
        widget.onDelete();
      } else {
        // Handle error, e.g., show an error message
        print('Error deleting request: ${response.statusCode}');
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      // Close the dialog after handling
    } catch (e) {
      // Handle exceptions during deletion, e.g., network error
      print('Error deleting document request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Request'),
      content:
      Column(mainAxisSize: MainAxisSize.min,children : [const Text('Are you sure you want to delete this document request?'),const Text('It will be gone forever! (For a long time!)')],),          
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          child: const Text('Delete'),
          onPressed: _handleDelete,
        ),
      ],
    );
  }
}
