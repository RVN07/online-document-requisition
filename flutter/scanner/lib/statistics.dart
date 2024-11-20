import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scanner/scanner_screen.dart';
import 'package:scanner/staffProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

//to be fixed. Graphs na naka Card tas Data Table sa Ilalim


class StatusDocumentRequest {
 final int id;
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
  final String submitted_time;
  final String claim_date;



  StatusDocumentRequest({
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
    required this.submitted_time,
    required this.claim_date,
  });

  factory StatusDocumentRequest.fromJson(Map<String, dynamic> json) {
    return StatusDocumentRequest(
      id: json['id'] as int,
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
      submitted_time: json['submitted_time'] ?? '',
      claim_date: json['claim_date'] ?? '',
    );
  }
}

class TableDashboardList extends StatefulWidget {

    final String token;
  final String email;
  final String password;
  final List<StatusDocumentRequest> documentList;
  final Function fetchData;
 

  const TableDashboardList(
    this.token,
    this.email,
    this.password, 
    this.documentList, 
    this.fetchData,
  //  this.onSearchPressed,
  //  this.onSearchAddressPressed,
  );

  @override
  _TableDashboardListState createState() => _TableDashboardListState(token: token,
  email: email, // Add this line
  password: password);
}

class _TableDashboardListState extends State<TableDashboardList> {
  List<StatusDocumentRequest> documentList = [];
  List<StatusDocumentRequest> approvedRejectedRequests = [];
    //String _searchText = "";
  bool _isMounted = false;
    bool _isDisposed = false;

  final String token;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

    DateTime? selectedDate;
  bool showDatePickerOverlay = false;
  StatusDocumentRequest?
      _selectedRequest; // Track whether to show the calendar overlay

      final ScrollController _scrollController = ScrollController();
      final ScrollController _scrollController3 = ScrollController();
      final ScrollController _scrollController4 = ScrollController();
      
        String password;

          int selectedIndex = 0;

  void toggleContent(int index, GlobalKey<ScaffoldState> scaffoldKey) {
    setState(() {
      selectedIndex = index;
    });
  }

  _TableDashboardListState({required this.token, required String email, required this.password});


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

   Future<bool> logout(
      String token, String email, String password) async {
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


  Future<void> fetchData() async {
    try {
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

  // Function to
  
  // Function to show/hide the date picker overlay
  void toggleDatePickerOverlay(StatusDocumentRequest request) {
    setState(() {
      _selectedRequest = request; // Store the selected request
      showDatePickerOverlay = !showDatePickerOverlay;
    });
  }

  // Function to show the date picker dialog
  
  void handleDateSelection(DateTime pickedDate) {
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }


   Future<void> claimDocumentRequest(String token, int requestId) async {
    final apiUrl =
          'https://ecensusonlinerequest.online/api/v1/documentrequests/$requestId/claim';

try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
              );

      if (response.statusCode == 200) {
        // Claim was successful. You can update the UI or perform other actions.
         showSnackBar(
                'User claimed the requested successfully.');
      } else {
        // Handle errors or display an error message.
        print('Failed to claim document request: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request.
      print('Error claiming document request: $e');
    }
  }


Widget _buildDrawerContent() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 4, 118, 32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Profile', style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),),
                leading: Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffUserProfile(token: widget.token, staffEmail: widget.email),
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text('Reload Table'),
          leading: Icon(Icons.refresh),
          onTap: () {
            // Reload TableDashboardList
            fetchData();
            Navigator.pop(context); // Close the drawer
          },
        ),
        ListTile(
          title: Text('Use QR Scanner'),
          leading: Icon(Icons.qr_code_scanner),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerScreen(token: widget.token),
              ),
            );
          },
        ),
        Divider(), // Add a divider for visual separation
        ListTile(
          title: Text('Logout'),
          leading: Icon(Icons.logout),
          onTap: () {
            // Implement your logout logic here
            logout(widget.token, widget.email, widget.password);
            Navigator.pop(context); // Close the drawer
          },
        ),
      ],
    ),
  );
}

    @override
  Widget build(BuildContext context) {
  
final approvedRejectedRequests = documentList
      .where((approved) => approved.status == 'approved')
      .toList();
      final scrollController2 = ScrollController();
      final scrollController3 = ScrollController();
      final scrollController4 = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: MediaQuery.of(context).size.width < 600
          ? Drawer(
              child: _buildDrawerContent(),
            )
          : null,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchData,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: DocumentAnalyticsOverlay(
                statusList: documentList,
                token: widget.token,
              ),
            ),
          SizedBox(
            width: 1000,
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              child: SizedBox(
                child: Column(

        children: [
          if (approvedRejectedRequests.isEmpty)
            const Center(
              child: Text(
                'No requests available',
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
    const DataColumn(label: Text('LAST NAME', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('FIRST NAME', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('MIDDLE NAME', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('DETAILS', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('DOCUMENT TYPE', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('REASON', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('TIME REQUEST', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('CLAIM DATE', style: TextStyle(fontSize: 10))),
  ],
  rows: approvedRejectedRequests.map((approved) {
    return DataRow(cells: [
      DataCell(Center(child: Text(approved.id.toString(), style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(approved.lastName, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(approved.firstName, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(approved.middleName, style: const TextStyle(fontSize: 10)))),
DataCell(
  Center(
    child: ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('User Details'),
              content: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  child: Scrollbar(
                    thickness: 9.0,
                    thumbVisibility: true,
                    controller: scrollController3,
                    child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController3,
                  
                  child: DataTable(
                    columnSpacing: 20.0,
                    columns: [
                      const DataColumn(label: Text('ID')),
                      const DataColumn(label: Text('FIRST NAME', style: TextStyle(fontSize: 10))),
                      const DataColumn(label: Text('MIDDLE NAME', style: TextStyle(fontSize: 10))),
                      const DataColumn(label: Text('LAST NAME', style: TextStyle(fontSize: 10))),
                      const DataColumn(label: Text('SUFFIX', style: TextStyle(fontSize: 10))),
                      const DataColumn(label: Text('GENDER', style: TextStyle(fontSize: 10))),
                      const DataColumn(label: Text('AGE', style: TextStyle(fontSize: 10))),
                      const DataColumn(label: SizedBox(width: 150, child: Center(child: Text('ADDRESS', style: TextStyle(fontSize: 10)),))),
                      const DataColumn(label: Center(child: Text('EMAIL', style: TextStyle(fontSize: 10)),)),
                      const DataColumn(label: Text('CONTACT', style: TextStyle(fontSize: 10))),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Center(child: Text(approved.id.toString(), style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.firstName, style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.middleName, style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.lastName, style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.suffix ?? '', style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.gender ?? '', style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.age ?? '', style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.address ?? '', style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.email ?? '', style: const TextStyle(fontSize: 10)))),
                        DataCell(Center(child: Text(approved.contact ?? '', style: const TextStyle(fontSize: 10)))),
                      ]),
                    ],
                  ),
                ),
              ),
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
      DataCell(Center(child: Text(approved.documentType ?? '', style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(approved.status ?? '', style: const TextStyle(fontSize: 10)))),
      DataCell(
        Center(
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  print('Reason: ${approved.reason}');
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Request Reason'),
                        content: Text(
                          approved.reason ?? 'No reason provided',
                        ),
                      );
                    },
                  );
                },
                child: const Text('Show Reason', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
      DataCell(
        Center(
          child: Text(
            approved.submitted_time ?? '??',
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
      DataCell(Center(child: Text(approved.claim_date ?? '', style: const TextStyle(fontSize: 10)))),
      
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
      ),
  )
    );
}


String obscureID(String id) {
  // Replace each digit in the ID with '*'
  return id.replaceAll(RegExp(r'\d'), '*');
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

  String obscureAddress(String address) {
    // Check if the address is not null or empty
    if (address != null && address.isNotEmpty) {
      // Split the address into parts (e.g., street, city, zip code, etc.)
      final parts = address.split(',');

      // Obscure each part separately
      final obscuredParts = parts.map((part) {
        // You can choose how to obscure each part, for example, replacing it with '****'
        return '****';
      });

      // Join the obscured parts back into a single string
      return obscuredParts.join(',');
    }

    // Return the original address if it's null or empty
    return address;
  }

  String obscureContact(String contact) {
    // Check if the contact is not null or empty
    if (contact != null && contact.isNotEmpty) {
      // You can choose how to obscure the contact information, for example, replacing it with '****'
      return '****';
    }

    // Return the original contact if it's null or empty
    return contact;
  }
}

class DocumentAnalyticsOverlay extends StatelessWidget {
  final List<StatusDocumentRequest> statusList;
  final String token;
  Map<String, Color> documentTypeColors = {};

  DocumentAnalyticsOverlay({required this.token, required this.statusList});

     List<Color> fixedColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
];


 @override
  Widget build(BuildContext context) {
    final List<StatusDocumentRequest> approvedRejectedRequests =
        statusList.where((approved) => approved.status == 'approved').toList();

    if (approvedRejectedRequests.isEmpty) {
      return _buildEmptyRequestsCard();
    }

    List<PieChartSectionData> pieChartData = getDocumentTypeDistribution();

    List<String> StatusDocumentTypes = approvedRejectedRequests
        .map((approved) => approved.documentType)
        .toSet()
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 500;

        return Card(
          elevation: 6,
          margin: const EdgeInsets.all(1.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(1.0),
            child: isMobile
                ? _buildMobileLayout(pieChartData, approvedRejectedRequests, StatusDocumentTypes)
                : _buildDesktopLayout(pieChartData, approvedRejectedRequests),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    List<PieChartSectionData> pieChartData,
    List<StatusDocumentRequest> approvedRejectedRequests,
    List<String> StatusDocumentTypes,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderText('Approved Analytics'),
          const SizedBox(height: 5),
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
          const SizedBox(height: 10),
          _buildChartCard(
            'Approved Document Requests Count',
            _buildBarChart(approvedRejectedRequests),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < StatusDocumentTypes.length; i++)
                _buildLegendItem(
                  StatusDocumentTypes[i],
                  documentTypeColors[StatusDocumentTypes[i]] ?? Colors.grey,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(List<PieChartSectionData> pieChartData, List<StatusDocumentRequest> approvedRejectedRequests) {
    return Row(
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
          'Approved Document Requests Count',
          _buildBarChart(approvedRejectedRequests),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

Widget _buildLegendItem(String documentType, Color color) {
Map<String, Color> documentTypeColors = {};
  return Container(
    margin: const EdgeInsets.only(right: 16),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: documentTypeColors[documentType] ?? Colors.grey, // Use grey as the default color
        ),
        const SizedBox(width: 4),
        Text(
          documentType,
          style: const TextStyle(fontSize: 8),
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
        height: 460,
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
        width: 460,
        height: 253,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildChartTitle(title),
            const SizedBox(height: 20),
            Container(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

Widget _buildBarChart(List<StatusDocumentRequest> approvedRejectedRequests) {
  final Map<String, int> documentTypeCounts = {};
  int barangayIDCount = 0;
  int barangayClearanceCount = 0;
  int barangayCertificateCount = 0;
  int certificateOfIndigencyCount = 0;

  for (final approved in approvedRejectedRequests) {
    if (approved.documentType == 'Barangay ID') {
      barangayIDCount++;
    } else if (approved.documentType == 'Barangay Clearance') {
      barangayClearanceCount++;
    } else if (approved.documentType == 'Barangay Certificate') {
      barangayCertificateCount++;
    } else if (approved.documentType == 'Certificate of Indigency') {
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
            fontSize: 7,
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

    final List<StatusDocumentRequest> approvedRejectedRequests =
        statusList.where((approved) => approved.status == 'approved').toList();

    for (var approved in statusList) {
      documentTypeCount[approved.documentType] =
          (documentTypeCount[approved.documentType] ?? 0) + 1;
    }

    final totalRequests = statusList.length;
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
        titleStyle: const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 93, 35, 35),
        ),
      );
    }).toList();
  }
}
