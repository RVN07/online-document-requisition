import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:raven/staffWidgets/searchDialogs/pendingDialog.dart';
import 'package:connectivity/connectivity.dart';

class PendingDocumentRequest {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String gender;
  final String age;
  final String address;
  final String documentType;
  final String email;
  final String contact;
  final String status;
  final String reason;
  final String submittedTime;
  final String claimDate;

  PendingDocumentRequest({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.gender,
    required this.age,
    required this.address,
    required this.documentType,
    required this.email,
    required this.contact,
    required this.status,
    required this.reason,
    required this.submittedTime,
    required this.claimDate,
  });

  factory PendingDocumentRequest.fromJson(Map<String, dynamic> json) {
    return PendingDocumentRequest(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      suffix: json['suffix'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      documentType: json['documenttype'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      submittedTime: json['submitted_time'] ?? '',
      claimDate: json['claim_date'] ?? '',
    );
  }
}

class TableDashboardModal extends StatefulWidget {
  final String token;
  final List<PendingDocumentRequest> documentList;
  final Function fetchData;
  final Function(String searchText) onSearchPendingPressed;

  const TableDashboardModal(
    this.token,
    this.documentList,
    this.fetchData,
    this.onSearchPendingPressed,
  );

  @override
  _TableDashboardModalState createState() => _TableDashboardModalState(token: token);
}

class _TableDashboardModalState extends State<TableDashboardModal> {
  List<PendingDocumentRequest> documentList = [];
  List<PendingDocumentRequest> pendingRequests = [];
  String _searchText = "";
  bool _isMounted = false;
  bool _isDisposed = false;
  TextEditingController searchTextController = TextEditingController();
  final String token;
  DateTime? selectedDate;
  bool showDatePickerOverlay = false;
  PendingDocumentRequest? _selectedRequest;
  final ScrollController _scrollController = ScrollController();

  _TableDashboardModalState({required this.token});

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    fetchData();
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
        showSnackBar('Failed to approve document request: ${response.statusCode}');
    //    showSnackBar('Failed to approve document request.');
      }
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  Future<void> rejectRequest(int requestId) async {
    try {
      final response = await http.post(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/documentrequests/$requestId/reject'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        showSnackBar('Document request rejected successfully.');
        fetchData();
      } else {
        showSnackBar('Failed to reject request: ${response.statusCode}');
        print('Failed to reject request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

@override
Widget build(BuildContext context) {
  var pendingRequests =
      documentList.where((request) => request.status == 'pending').toList();

  final scrollController1 = ScrollController();
  final scrollController2 = ScrollController();
 // pendingRequests
    //  .sort((a, b) => int.parse(b.id as String).compareTo(int.parse(a.id as String)));

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Expanded(
        flex: 3,
        child: DocumentAnalyticsOverlay(
          token: token,
          documentList: documentList,
        ),
      ),
      SizedBox(height: 10),
      Row(
        children: [
          ElevatedButton(
  onPressed: () async {
    await fetchData(); // Assuming there's an async function to load data
  },
  child: const Text('Refresh'),
),
SizedBox(width: 10),
          Flexible(
            flex: 2,
            child: Container(
              width: 200.0,
              height: 40.0,
              child: TextFormField(
                controller: searchTextController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Firstname, Lastname...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onSearchPendingPressed(_searchText);
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        ],
      ),
      SizedBox(height: 10),
      SizedBox(
  width: 1000,
  height: 208,
  
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    controller: _scrollController,
    child: Scrollbar(
      thumbVisibility: true,
      thickness: 15.0,
      controller: scrollController2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController2,
        
        child: DataTable(
          columnSpacing: 20.0,
          headingRowHeight: 30.0, 
  headingRowColor:
        MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 220, 224, 218)),
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('LAST NAME', style: TextStyle(fontSize: 10))),
            DataColumn(label: Text('FIRST NAME', style: TextStyle(fontSize: 10))),
            DataColumn(label: Text('MIDDLE NAME', style: TextStyle(fontSize: 10))),
            DataColumn(label: SizedBox( child: Center(child: Text('DETAILS', style: TextStyle(fontSize: 10)),),)),
            DataColumn(label: Text('DOCUMENT TYPE', style: TextStyle(fontSize: 10))),
            DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10))),
            DataColumn(label: Text('REASON', style: TextStyle(fontSize: 10))),
            DataColumn(label: Text('TIME REQUEST', style: TextStyle(fontSize: 10))),
            DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 10))),
          ],
          rows: pendingRequests.map((request) {
            return DataRow(cells: [
      DataCell(Center(child: Text(obscureID(request.id), style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(request.lastName, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(request.firstName, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(request.middleName, style: const TextStyle(fontSize: 10)))),
      DataCell(
        Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('User Details'),
                    content: SingleChildScrollView(
                      child: DataTable(
                         headingRowColor:
        MaterialStateColor.resolveWith((states) => Colors.grey),
                        columnSpacing: 20.0,
                        columns: [
                          const DataColumn(label: Text('ID')),
                          const DataColumn(label: Text('FIRST NAME', style: TextStyle(fontSize: 10))),
                          const DataColumn(label: Text('MIDDLE NAME', style: TextStyle(fontSize: 10))),
                          const DataColumn(label: Text('LAST NAME', style: TextStyle(fontSize: 10))),
                          const DataColumn(label: Text('SUFFIX', style: TextStyle(fontSize: 10))),
                          const DataColumn(label: Text('GENDER', style: TextStyle(fontSize: 10))),
                          const DataColumn(label: Text('AGE', style: TextStyle(fontSize: 10))),
                          const DataColumn(label: SizedBox(width: 150, child: Center(child: Text('ADDRESS', style: TextStyle(fontSize: 10)),),)),
                              const DataColumn(label: Center(child: Text('EMAIL', style: TextStyle(fontSize: 10)),),),
                                  const DataColumn(label: Text('CONTACT', style: TextStyle(fontSize: 10))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Center(child: Text(obscureID(request.id), style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(request.firstName, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(request.middleName, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(request.lastName, style: const TextStyle(fontSize: 10)))),
                           DataCell(Center(child: Text(request.suffix, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(request.gender, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(request.age, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(request.address, style: const TextStyle(fontSize: 10)))),
                                  DataCell(Center(child: Text(request.email, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(request.contact, style: const TextStyle(fontSize: 10)))),
                          ]),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: const Text('Show Details', style: TextStyle(fontSize: 10)),
          ),
        ),
      ),
      DataCell(Center(child: Text(request.documentType, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(request.status, style: const TextStyle(fontSize: 10)))),
      DataCell(
        Center(
          child: ElevatedButton(
            onPressed: () {
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
            child: const Text('Show Reason', style: TextStyle(fontSize: 10)),
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
                    backgroundColor: const Color.fromARGB(255, 255, 167, 34)),
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
                    const SizedBox(width: 8),
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

            ),
          ),
        ),
      ),
    ],
  );
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

class DocumentAnalyticsOverlay extends StatefulWidget {
  final List<PendingDocumentRequest> documentList;
  final String token;
  Map<String, Color> documentTypeColors = {};

  DocumentAnalyticsOverlay({required this.token, required this.documentList});

  @override
  _DocumentAnalyticsOverlayState createState() =>
      _DocumentAnalyticsOverlayState();
}

class _DocumentAnalyticsOverlayState extends State<DocumentAnalyticsOverlay> {
  bool _isVisible = false;
 //final List<PendingDocumentRequest> documentList;

 List<Color> fixedColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
];
  @override
  void initState() {
    super.initState();
    // Trigger animation after the widget is built
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<PendingDocumentRequest> pendingRequests =
        widget.documentList.where((request) => request.status == 'pending').toList();

    if (pendingRequests.isEmpty) {
      return _buildEmptyRequestsCard();
    }

    List<PieChartSectionData> pieChartData = getDocumentTypeDistribution();
    List<String> PendingDocumentTypes = pendingRequests
        .map((request) => request.documentType)
        .toSet()
        .toList();

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: Duration(seconds: 1),
      child: SizedBox(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(1.0),
          child: Container(
            width: double.infinity,
            height: 460,
            padding: const EdgeInsets.all(1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderText('Pending Document Analytics'),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildChartCard(
                      'Overall Document Type Distribution',
                      PieChart(
                        PieChartData(
                          sections: pieChartData,
                          centerSpaceRadius: 0,
                          sectionsSpace: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildChartCard(
                      'Pending Document Requests Count',
                      _buildBarChart(pendingRequests),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 5),
 //Row(
 ///       mainAxisAlignment: MainAxisAlignment.center,
 //       children: [
 //         for (int i = 0; i < PendingDocumentTypes.length; i++)
  //          _buildLegendItem(
  //            PendingDocumentTypes[i],
  //            widget.documentTypeColors[PendingDocumentTypes[i]] ?? Colors.grey,
  //          )
    //    ],
   //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
Widget _buildLegendItem(String documentType, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 16),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color, // Use the color directly from the parameter
        ),
        const SizedBox(width: 8),
        Text(
          documentType,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}


  Widget _buildEmptyRequestsCard() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: const Center(
          child: Text(
            'No pending requests available for analytics.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChartTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

Widget _buildChartCard(String title, Widget chart) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.all(5.0),
    child: Container(
      width: 450,
      // Make the height flexible to accommodate the content
      height: 253,
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildChartTitle(title),
          const SizedBox(height: 20),
          Expanded(
            // Use an Expanded widget to allow the chart to take up the remaining space
            child: Container(
              child: chart,
            ),
          ),
        ],
      ),
    ),
  );
}

  

Widget _buildBarChart(List<PendingDocumentRequest> pendingRequests) {
  final Map<String, int> documentTypeCounts = {};
  int barangayIDCount = 0;
  int barangayClearanceCount = 0;
  int barangayCertificateCount = 0;
  int certificateOfIndigencyCount = 0;

  for (final request in pendingRequests) {
    if (request.documentType == 'Barangay ID') {
      barangayIDCount++;
    } else if (request.documentType == 'Barangay Clearance') {
      barangayClearanceCount++;
    } else if (request.documentType == 'Barangay Certificate') {
      barangayCertificateCount++;
    } else if (request.documentType == 'Certificate of Indigency') {
      certificateOfIndigencyCount++;
    }
  }

  final topTitlesTextStyle = TextStyle(
    fontSize: 15,
   // color: getRandomColor(),
    fontWeight: FontWeight.bold,
  );

  final barChart = BarChart(
    BarChartData(
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              y: barangayIDCount.toDouble(),
              width: 30,
              colors: [getFixedColor(0)],
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              y: barangayClearanceCount.toDouble(),
              width: 30,
              colors: [getFixedColor(1)],
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              y: certificateOfIndigencyCount.toDouble(),
              width: 30,
              colors: [getFixedColor(2)],
            ),
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              y: barangayCertificateCount.toDouble(),
              width: 30,
              colors: [getFixedColor(3)],
            ),
          ],
        ),
      ],
      titlesData: FlTitlesData(
        topTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '$barangayIDCount';
              case 1:
                return '$barangayClearanceCount';
              case 2:
                return '$certificateOfIndigencyCount';
              case 3:
                return '$barangayCertificateCount';
              default:
                return '';
            }
          },
          getTextStyles: (context, value) => topTitlesTextStyle,
        ),
        leftTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'Barangay ID';
              case 1:
                return 'Brgy Clearance';
              case 2:
                return 'Certificate of Indigency';
              case 3:
                return 'Brgy Certificate';
              default:
                return '';
            }
          },
          getTextStyles: (context, value) => const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          interval: 1.0,
        ),
      ),
    ),
  );

  return Container(
    child: Column(
      children: [
        Container(
          width: 430,
          height: 200,
          child: barChart,
        ),
      ],
    ),
  );
}

Color getRandomColor() {
  final Random random = Random();
  final int r = 150 + random.nextInt(56); // Adjust the range for red
  final int g = 150 + random.nextInt(56); // Adjust the range for green
  final int b = 150 + random.nextInt(56); // Adjust the range for blue

  return Color.fromRGBO(r, g, b, 1);
}

Color getFixedColor(int index) {
  if (index >= 0 && index < fixedColors.length) {
    return fixedColors[index];
  } else {
    // If the index is out of bounds, return a default color
    return Colors.grey;
  }
}



List<PieChartSectionData> getDocumentTypeDistribution() {
  Map<String, Color> documentTypeColors = {};
  Map<String, int> documentTypeCount = {};

  for (var request in widget.documentList) {
    documentTypeCount[request.documentType] =
        (documentTypeCount[request.documentType] ?? 0) + 1;
  }

  final totalRequests = widget.documentList.length;

  int colorIndex = 0;
  return documentTypeCount.entries.map((entry) {
    final documentType = entry.key;
    final count = entry.value.toDouble();
    final percentage = (count / totalRequests) * 100;

    // Check if the document type already has a color assigned, otherwise assign a new color
    documentTypeColors[documentType] ??= fixedColors[colorIndex];

    colorIndex = (colorIndex + 1) % fixedColors.length; // Move to the next color, cyclically

    return PieChartSectionData(
      title: '$documentType\n${percentage.toStringAsFixed(2)}%',
      value: count,
      color: documentTypeColors[documentType],
      radius: 100,
      titleStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 93, 35, 35),
      ),
    );
  }).toList();
}

}
