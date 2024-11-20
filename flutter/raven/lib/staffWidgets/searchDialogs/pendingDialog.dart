import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:raven/staffWidgets/dashboard_table.dart';
import 'package:connectivity/connectivity.dart';

class PendingDialogModal extends StatefulWidget {
  final String token;
  final List<PendingDocumentRequest> documentList;

  const PendingDialogModal(
    this.token,
    this.documentList,
  );

  @override
  _PendingDialogModalState createState() => _PendingDialogModalState(token: token, initialDocumentList: documentList);
}

class _PendingDialogModalState extends State<PendingDialogModal> {
  List<PendingDocumentRequest> documentList = [];
  List<PendingDocumentRequest> pendingRequests = [];
  bool _isMounted = false;
  bool _isDisposed = false;
  TextEditingController searchTextController = TextEditingController();
  final String token;
  DateTime? selectedDate;
  bool showDatePickerOverlay = false;
  PendingDocumentRequest? _selectedRequest;
  final ScrollController _scrollController = ScrollController();

  _PendingDialogModalState({required this.token, required List<PendingDocumentRequest> initialDocumentList}) {
    documentList = initialDocumentList;
  }

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

  void showSnackBar(String message) {
    if (!_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  void filterSearchResults(String query) {
    setState(() {
      // Filter the documentList based on the search query
      documentList = widget.documentList
          .where((request) =>
              request.status == 'pending' &&
              (request.firstName.toLowerCase().contains(query.toLowerCase()) ||
                  request.lastName.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  Future<void> fetchData() async {

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
      final Uri uri = Uri.parse('https://ecensusonlinerequest.online/api/v1/documentrequests');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('data')) {
          final List<dynamic> data = jsonData['data'];
          final List<PendingDocumentRequest> tempList = [];

          for (var item in data) {
            tempList.add(PendingDocumentRequest.fromJson(item));
          }

          if (_isMounted) {
            setState(() {
              documentList = tempList;
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

  void toggleDatePickerOverlay(PendingDocumentRequest request) {
    setState(() {
      _selectedRequest = request;
      showDatePickerOverlay = !showDatePickerOverlay;
    });
  }

  Future<void> _selectDate(BuildContext context, PendingDocumentRequest request) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _selectedRequest = request;
      });
    }
  }

  void handleDateSelection(DateTime pickedDate) {
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> approveRequestWithDate(PendingDocumentRequest request, DateTime pickedDate) async {

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

    if (request == null) {
      return;
    }

    try {
      final apiUrl =
          'https://ecensusonlinerequest.online/api/v1/documentrequests/${request.id}/approve';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'claim_date': pickedDate.toIso8601String(),
        }),
      );

      print('Request Body: ${jsonEncode({'claim_date': pickedDate.toIso8601String()})}');
      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        showSnackBar('Document request approved successfully.');
        fetchData();
      } else {
        showSnackBar('Failed to approve document request.');
      }
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  Future<void> rejectRequest(int requestId) async {

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
      final response = await http.post(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/documentrequests/$requestId/reject'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        print('Failed to reject request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var pendingRequests = documentList; // Use filtered documentList

final scrollController1 = ScrollController();
  final scrollController2 = ScrollController();
  pendingRequests.sort((a, b) => int.parse(b.id as String).compareTo(int.parse(a.id as String)));
    return AlertDialog(
      content: Container(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [

        SizedBox(
          width: 1000,
          height: 250,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,

            controller: _scrollController,
child: SizedBox(

            child: Column(
              children: [
                if (pendingRequests.isEmpty)
                  const Center(
                    child: Text(
                      'No pending requests available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  )
                else
                Scrollbar(
                  thumbVisibility: true,
                  thickness: 15.0, // Set this to true to always show the scrollbar
                  controller: scrollController2, // Assign the second ScrollController to the second Scrollbar
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController2, // Assign the second ScrollController to the second scrollable widget
                    child: Column(
                      children: [
                        DataTable(
                          columnSpacing: 20.0,
                          columns: [
                            const DataColumn(label: Text('ID')),
                            const DataColumn(
                              label: Text('FIRST NAME', style: TextStyle(fontSize: 10)),
                            ),
                            const DataColumn(
                                label: Text('MIDDLE NAME', style: TextStyle(fontSize: 10))),
                            const DataColumn(
                                label: Text('LAST NAME', style: TextStyle(fontSize: 10))),
                            const DataColumn(
                                label: Text('SUFFIX', style: TextStyle(fontSize: 10))),
                            const DataColumn(label: Text('GENDER', style: TextStyle(fontSize: 10))),
                            const DataColumn(label: Text('AGE', style: TextStyle(fontSize: 10))),
                            const DataColumn(
                                label: SizedBox(
                                    width: 150, child: Text('ADDRESS', style: TextStyle(fontSize: 10)))),
                            const DataColumn(
                                label: Text('DOCUMENT TYPE', style: TextStyle(fontSize: 10))),
                            const DataColumn(label: Text('EMAIL', style: TextStyle(fontSize: 10))),
                            const DataColumn(label: Text('CONTACT', style: TextStyle(fontSize: 10))),
                            const DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10))),
                            const DataColumn(label: Text('REASON', style: TextStyle(fontSize: 10))),
                            const DataColumn(
                                label: Text('TIME REQUEST', style: TextStyle(fontSize: 10))),
                            const DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 10))),
                          ],
                          rows: pendingRequests.map((request) {
                            return DataRow(cells: [
                              DataCell(Center(child: Text(obscureID(request.id), style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.firstName, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.middleName, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.lastName, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.suffix, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.gender, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.age, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.address, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.documentType, style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(obscureEmail(request.email), style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(obscureContact(request.contact), style: const TextStyle(fontSize: 10)))),
                              DataCell(Center(child: Text(request.status, style: const TextStyle(fontSize: 10)))),
                              DataCell(
                                Center(
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          print('Reason: ${request.reason}');
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Request Reason'),
                                                content: Text(
                                                  request.reason ?? 'No reason provided',
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Show Reason', style: TextStyle(fontSize: 10))),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    request.submittedTime ?? '??',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _selectDate(context, request);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange),
                                        child: const Text('Set Date',
                                            style: TextStyle(fontSize: 11, color: Colors.white))),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await rejectRequest(int.parse(request.id));
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Text('Reject',
                                            style: TextStyle(fontSize: 11, color: Colors.white))),
                                      if (selectedDate != null && _selectedRequest == request)
                                        ElevatedButton(
                                          onPressed: () {
                                            approveRequestWithDate(_selectedRequest!, selectedDate!);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          child: const Text('Approve',
                                              style: TextStyle(fontSize: 11, color: Colors.white))),
                                    ],
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ],
    ),),);
  }

  String obscureID(String id) {
    return '*';
  }

  String obscureEmail(String email) {
    if (email != null && email.isNotEmpty) {
      final parts = email.split('@');
      if (parts.length == 2) {
        final username = parts[0];
        final domain = parts[1];
        final obscuredUsername = '*' * username.length;
        return '$obscuredUsername@$domain';
      }
    }
    return email;
  }

  String obscureContact(String contact) {
    if (contact != null && contact.isNotEmpty) {
      return '****';
    }
    return contact;
  }
}