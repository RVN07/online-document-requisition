import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:raven/staffWidgets/delete_request.dart';
import 'package:connectivity/connectivity.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'dart:js' as js;
import 'dart:async';


class ReportDocumentRequest {
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
  final String submitted_time;
  final String claim_date;



  ReportDocumentRequest({
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

  factory ReportDocumentRequest.fromJson(Map<String, dynamic> json) {
    return ReportDocumentRequest(
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
      submitted_time: json['submitted_time'] ?? '',
      claim_date: json['claim_date'] ?? '',
    );
  }

}



class ReportsDashboardList extends StatefulWidget {
  final String token;
  final List<ReportDocumentRequest> documentList;
  
  final Function fetchData;
   final Function(String searchText) onSearchStatusPressed;


  const ReportsDashboardList(
    this.token,
    this.documentList,
    this.fetchData,
    this.onSearchStatusPressed,
  //  this.onSearchAddressPressed,
  );

  @override
  _ReportsDashboardListState createState() => _ReportsDashboardListState(token: token);
}

class _ReportsDashboardListState extends State<ReportsDashboardList> {
  List<ReportDocumentRequest> documentList = [];
  List<ReportDocumentRequest> reportsRequest = [];
  List<ReportDocumentRequest> reportList = [];
  String _searchText = "";
  bool _isMounted = false;
    bool _isDisposed = false;
  TextEditingController searchTextController = TextEditingController();
  final String token;

    DateTime? selectedDate;
  bool showDatePickerOverlay = false;
  ReportDocumentRequest?
      _selectedRequest; // Track whether to show the calendar overlay

      final ScrollController _scrollController = ScrollController();

  _ReportsDashboardListState({required this.token});

  

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
          final List<ReportDocumentRequest> tempList = [];

          for (var item in data) {
            tempList.add(ReportDocumentRequest.fromJson(item));
          }

          if (_isMounted) {
            setState(() {
              documentList = tempList;
              reportList = tempList;
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
  void toggleDatePickerOverlay(ReportDocumentRequest request) {
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
        print('Document request claimed successfully.');
      } else {
        // Handle errors or display an error message.
        print('Failed to claim document request: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request.
      print('Error claiming document request: $e');
    }
  }


  List<DataColumn> columns = [
    DataColumn(label: Text('ID')),
    DataColumn(label: Text('FIRST NAME', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('MIDDLE NAME', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('LAST NAME', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('SUFFIX', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('GENDER', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('AGE', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('ADDRESS', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('DOCUMENT TYPE', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('EMAIL', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('CONTACT', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('REASON', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('TIME REQUEST', style: TextStyle(fontSize: 10))),
    DataColumn(label: Text('CLAIM DATE', style: TextStyle(fontSize: 10))),
  ];
List<DataRow> convertToDataRows(List<ReportDocumentRequest> data) {
  return data.map((reports) {
    return DataRow(
      cells: [
        DataCell(Center(child: Text(reports.id))),
        DataCell(Center(child: Text(reports.firstName))),
        DataCell(Center(child: Text(reports.middleName))),
        DataCell(Center(child: Text(reports.lastName))),
        DataCell(Center(child: Text(reports.suffix))),
        DataCell(Center(child: Text(reports.gender))),
        DataCell(Center(child: Text(reports.age))),
        DataCell(Center(child: Text(reports.address))),
        DataCell(Center(child: Text(reports.documentType))),
        DataCell(Center(child: Text(reports.email))),
        DataCell(Center(child: Text(reports.contact))),
        DataCell(Center(child: Text(reports.status))),
        DataCell(Center(child: Text(reports.reason))),
        DataCell(Center(child: Text(reports.submitted_time))),
        DataCell(Center(child: Text(reports.claim_date))),
      ],
    );
  }).toList();
}



 Future<void> exportToExcel(List<DataRow> rows) async {
  final excel = Excel.createExcel();
  final sheet = excel['Sheet1'];

  // Add header row
  for (int i = 0; i < columns.length; i++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
      ..value = columns[i].label.toString();
  }

  // Add data rows with actual data from reportsRequest
  for (int i = 0; i < rows.length; i++) {
    final dataRow = rows[i];
    final cells = dataRow.cells.toList();
    for (int j = 0; j < columns.length; j++) {
      final cellValue = reportsValue(cells[j]);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
        ..value = cellValue;
    }
  }

  // Save the Excel file
  final excelBytes = excel.encode();
  final blob = html.Blob([Uint8List.fromList(excelBytes!)], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Create an anchor element and trigger a download
  final anchor = html.AnchorElement(href: url)
    ..target = 'webbrowser'
    ..download = 'exported_data.xlsx'
    ..click();

  // Clean up resources
  html.Url.revokeObjectUrl(url);
}
dynamic reportsValue(DataCell cell) {
  final child = (cell.child as Center).child;

  print('Child type: ${child.runtimeType}');

  if (child is RichText) {
    return (child as RichText).text.toString();
  } else if (child is Text) {
    final textData = child.data;
    print('TextData: $textData');
    if (textData != null) {
      // Check if the data is numeric and convert it if needed
      return double.tryParse(textData) ?? textData;
    }
  }
  return null;
}

@override
Widget build(BuildContext context) {
final reportsRequest = documentList
      .where((request) => request.status == 'rejected' || request.status == 'claimed')
      .toList();

    final scrollController2 = ScrollController();
   reportsRequest.sort((a, b) => int.parse(b.id as String).compareTo(int.parse(a.id as String)));
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      Expanded(
        flex: 3,
        child: DocumentAnalyticsOverlay(reportsList: documentList, token: token,),
      ),
       Row(
                    children: [
             ElevatedButton(
  onPressed: () async {
    await fetchData(); // Assuming there's an async function to load data
    final dataRows = convertToDataRows(reportsRequest);
    exportToExcel(dataRows);
  },
  child: const Text('Export to Excel'),
),


SizedBox(width: 10),
                      Flexible(
  flex: 2, // Adjust the flex value to make it smaller or larger
  child: Container(
    width: 250.0, // Adjust the width as needed
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
       contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Adjust the vertical padding
      ),
    ),
  ),
),
                      IconButton(
                        onPressed: () {
                          widget.onSearchStatusPressed(_searchText);
                        },
                        icon: const Icon(Icons.search),
                        tooltip: 'Search',
                      ),
                    ],
                  ),
      SizedBox(
        width: 1000, // Set a specific width
      height: 208,
  child: SingleChildScrollView(
    
    scrollDirection: Axis.vertical,
    
    controller: _scrollController,
    child: SizedBox(

      child: Column(
        children: [
          if (reportsRequest.isEmpty)
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
  headingRowColor:
        MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 220, 224, 218)),
  columns: [
    const DataColumn(label: Text('ID')),
    const DataColumn(label: Text('LAST NAME', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('FIRST NAME', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('MIDDLE NAME', style: TextStyle(fontSize: 10))),
    const DataColumn(label: SizedBox(width: 50, child: Center(child: Text('DETAILS', style: TextStyle(fontSize: 10)),),)),
    const DataColumn(label: Text('DOCUMENT TYPE', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('REASON', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('TIME REQUEST', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('CLAIM DATE', style: TextStyle(fontSize: 10))),
    const DataColumn(label: Text('ACTION', style: TextStyle(fontSize: 10))),
  ],
  rows: reportsRequest.map((reports) {
    return DataRow(cells: [
     DataCell(Center(child: Text(obscureID(reports.id as String), style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(reports.lastName, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(reports.firstName, style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(reports.middleName, style: const TextStyle(fontSize: 10)))),
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
                          const DataColumn(label: Center(child: Text('EMAIL', style: TextStyle(fontSize: 10)),)),
                          const DataColumn(label: Text('CONTACT', style: TextStyle(fontSize: 10))),
                        ],
                        rows: [
                          DataRow(cells: [
                           DataCell(Center(child: Text(obscureID(reports.id as String), style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.firstName, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.middleName, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.lastName, style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.suffix ?? '', style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.gender ?? '', style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.age ?? '', style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.address ?? '', style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.email ?? '', style: const TextStyle(fontSize: 10)))),
                            DataCell(Center(child: Text(reports.contact ?? '', style: const TextStyle(fontSize: 10)))),
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
      DataCell(Center(child: Text(reports.documentType ?? '', style: const TextStyle(fontSize: 10)))),
      DataCell(Center(child: Text(reports.status ?? '', style: const TextStyle(fontSize: 10)))),
      DataCell(
        Center(
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  print('Reason: ${reports.reason}');
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Request Reason'),
                        content: Text(
                          reports.reason ?? 'No reason provided',
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
            reports.submitted_time ?? '??',
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
DataCell(Center(child: Text(reports.claim_date))),
                       DataCell(
  Center(
    child: Row(
            children: [
                TextButton(
          onPressed: () {
            if (reports.status == 'rejected' || reports.status == 'claimed')
                                                        showDialog(
                                        context: context,
                                        builder: (context) =>
                                            DeleteDocumentDialog(
                                          token: token,
                                          documentDelete: reports,
                                          // Pass the correct document to delete
                                          onDelete: () async {
                                            // Close the DeleteDocumentDialog
                                            Navigator.of(context).pop();

                                            // Wait for the modal to be popped
                                            await Future.delayed(const Duration(
                                                milliseconds: 100));

                                            // Refresh the data when a document request is deleted
                                            fetchData();
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text('Delete Request'),
                                  ),
      ],
    ),
  ),
)
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
  );
}


String obscureID(String id) {
  // Always replace the ID with '*'
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
  final List<ReportDocumentRequest> reportsList;
  final String token;
  Map<String, Color> documentTypeColors = {};

  DocumentAnalyticsOverlay({required this.token, required this.reportsList});

   List<Color> fixedColors = [
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
];

@override
Widget build(BuildContext context) {
  List<ReportDocumentRequest> reportsRequest =
      reportsList.where((reports) => reports.status == 'claimed' || reports.status == 'rejected').toList();

  if (reportsRequest.isEmpty) {
    return _buildEmptyRequestsCard();
  }

  List<PieChartSectionData> pieChartData = getDocumentTypeDistribution();
  List<String> ReportDocumentTypes = reportsRequest
      .map((reports) => reports.documentType)
      .toSet()
      .toList();

  final scrollController2 = ScrollController();
  return SizedBox(
    child:   Scrollbar(
          thumbVisibility: true,
          thickness: 15.0, // Set this to true to always show the scrollbar
          controller: scrollController2, // Assign the second ScrollController to the second Scrollbar
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: scrollController2, // Assign the second ScrollController to the second scrollable widget
            child: Card(
        elevation: 1,
        margin: const EdgeInsets.all(1.0),
        child: Container(
          width: 2400,
          height: 460,
          padding: const EdgeInsets.all(1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderText('Monthly / Weekly Analytics'),
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
                    'Document Report Count',
                    _buildBarChart(reportsRequest),
                  ),
                  const SizedBox(width: 10),
                  _buildChartCard('Status Report Count', _buildReportBarChart(reportsRequest),),
                  const SizedBox(width: 10),
                  _buildLineChartCard(WeeklyBarChartWidget(reportList: reportsList, currentDate: DateTime.now().toLocal())),
                  const SizedBox(width: 10),
                  _buildLineChartCard(MonthlyLineChartWidget(reportList: reportsList)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < ReportDocumentTypes.length; i++)
                    _buildLegendItem(ReportDocumentTypes[i],
                        documentTypeColors[ReportDocumentTypes[i]] ?? Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    ),
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
        margin: const EdgeInsets.all(5.0),
        child: Container(
          width: double.infinity,
          height: 460,
          padding: const EdgeInsets.all(5.0),
        child: const Center(
          child: Text(
            'No requests available for analytics.',
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

Widget _buildLineChartCard(Widget chart) {
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
          Container(
            height: 200,
            child: chart,
          ),
        ],
      ),
    ),
  );
}


Widget _buildBarChart(List<ReportDocumentRequest> reportsRequests) {
  final Map<String, int> documentTypeCounts = {};
  int barangayIDCount = 0;
  int barangayClearanceCount = 0;
  int barangayCertificateCount = 0;
  int certificateOfIndigencyCount = 0;

  for (final reports in reportsRequests) {
    if (reports.documentType == 'Barangay ID') {
      barangayIDCount++;
    } else if (reports.documentType == 'Barangay Clearance') {
      barangayClearanceCount++;
    } else if (reports.documentType == 'Barangay Certificate') {
      barangayCertificateCount++;
    } else if (reports.documentType == 'Certificate of Indigency') {
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

Widget _buildReportBarChart(List<ReportDocumentRequest> reportsRequests) {
  final Map<String, int> documentTypeCounts = {};
  int rejectedCount = 0;
  int claimedCount = 0;

  for (final reports in reportsRequests) {
    if (reports.status == 'rejected') {
      rejectedCount++;
    } else if (reports.status == 'claimed') {
      claimedCount++;
  
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
              y: rejectedCount.toDouble(),
              width: 30,
              colors: [getFixedColor(1)],
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              y: claimedCount.toDouble(),
              width: 30,
              colors: [getFixedColor(2)],
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
                return '$rejectedCount';
              case 1:
                return '$claimedCount';
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
                return 'Rejected';
              case 1:
                return 'Claimed';
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

  final List<ReportDocumentRequest> reportsRequest =
      reportsList.where((reports) => reports.status == 'rejected' || reports.status == 'claimed').toList();

  for (var reports in reportsList) {
    documentTypeCount[reports.documentType] =
        (documentTypeCount[reports.documentType] ?? 0) + 1;
  }

  final totalRequests = reportsList.length;

  // Assign a unique color to each document type
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
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 93, 35, 35),
      ),
    );
  }).toList();
}
}

// to be modified for the reports.submitted_time and reports.claim_date....

  Widget _buildLineChart(String title, List<FlSpot> data) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: data.length.toDouble() - 1,
              minY: 0,
          //    maxY: getMaxYValue(data),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  colors: [Colors.blue],
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
class WeeklyBarChartWidget extends StatefulWidget {
  final List<ReportDocumentRequest> reportList;
  final DateTime currentDate;

  WeeklyBarChartWidget({required this.reportList, required this.currentDate});

  @override
  _WeeklyBarChartWidgetState createState() => _WeeklyBarChartWidgetState();
}

class _WeeklyBarChartWidgetState extends State<WeeklyBarChartWidget> {
  List<double> submissionCounts = List.filled(7, 0);
  List<double> claimCounts = List.filled(7, 0);

  @override
  void didUpdateWidget(covariant WeeklyBarChartWidget oldWidget) {
    if (oldWidget.currentDate != widget.currentDate) {
      updateChartData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    updateChartData();
  }

  void updateChartData() {
    // Always clear data when updating
    submissionCounts = List.filled(7, 0);
    claimCounts = List.filled(7, 0);

    // Update data for the current week
    _updateCountsForCurrentWeek();
  }

void _updateCountsForCurrentWeek() {
  final dateFormatSubmittedTime = DateFormat("yyyy-MM-dd HH:mm:ss");
  final dateFormatClaimDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");

  final currentDate = widget.currentDate;
  final startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));
  final endOfWeek = startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  print("Start of Week: $startOfWeek");
  print("End of Week: $endOfWeek");

  // Update counts for the current week
  for (var report in widget.reportList) {
     try {
    // Check if submitted_time is not null or empty
    if (report.submitted_time?.isNotEmpty ?? false) {
      // Parse submitted_time directly
      DateTime submittedTime = dateFormatSubmittedTime.parse(report.submitted_time!);

      print("Submitted Time: $submittedTime");

      // Check if submittedTime falls within the current week
      if (submittedTime.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
          submittedTime.isBefore(endOfWeek.add(Duration(days: 1)))) {
        // Adjust for Dart's week starting from Monday
        int dayOfWeekSubmitted = (submittedTime.weekday - DateTime.monday + 7) % 7;

        // Check if the submittedTime is within the same day
        if (submittedTime.day == widget.currentDate.day) {
          submissionCounts[dayOfWeekSubmitted]++;
          print("Submitted Time added to day $dayOfWeekSubmitted");
        } else {
          // You can handle cases where submittedTime is within the week but on a different day
          // For example, you might want to count these in a separate variable
          submissionCounts[dayOfWeekSubmitted]++;
          print("Submitted Time within the week but on a different day:  $dayOfWeekSubmitted");
        }
      } else {
        print("Submitted Time not within the current week");
        print("Start of Week: $startOfWeek");
        print("End of Week: $endOfWeek");
      }
    } else {
      print("Submitted Time is null or empty");
    }
  } catch (e) {
    print('Error parsing submitted_time: $e');
  }


    // Check if claim_date is not empty or null before parsing
    if (report.claim_date?.isNotEmpty ?? false) {
      DateTime claimDate = dateFormatClaimDate.parse(report.claim_date!);

      print("Claim Date: $claimDate");

      // Check if claimDate falls within the current week
      if (claimDate.isAfter(startOfWeek) && claimDate.isBefore(endOfWeek)) {
        int dayOfWeekClaim = (claimDate.weekday - DateTime.monday + 7) % 7; // Adjust for Dart's week starting from Monday
        claimCounts[dayOfWeekClaim]++;
        print("Claim Date added to day $dayOfWeekClaim");
      }
    }
  }

  // Trigger a rebuild
  setState(() {});
}

  Widget _buildBarChart() {
    final List<String> weekdays = [];

    // Assuming that Monday is the first day of the week
    final DateTime startOfWeek =
        widget.currentDate.subtract(Duration(days: widget.currentDate.weekday - 1));

    // Generate weekdays
    weekdays.addAll(List.generate(7, (index) {
      final DateTime date = startOfWeek.add(Duration(days: index));
      return DateFormat.E().format(date);
    }));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        groupsSpace: 16,
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true, margin: 10),
          bottomTitles: SideTitles(
            showTitles: true,
            margin: 10,
            getTitles: (double value) {
              int index = value.toInt();
              if (index >= 0 && index < weekdays.length) {
                return weekdays[index];
              }
              return '';
            },
          ),
        ),
        borderData: FlBorderData(show: true),
        barGroups: List.generate(
          weekdays.length,
          (index) => BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                y: submissionCounts[index],
                colors: [Colors.blue],
              ),
              BarChartRodData(
                y: claimCounts[index],
                colors: [Colors.red],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.blue, 'Submitted Time'),
        SizedBox(width: 16),
        _buildLegendItem(Colors.red, 'Claim Date'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
          margin: EdgeInsets.only(right: 8),
        ),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Weekly Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              constraints: BoxConstraints(
                minWidth: 200,
                maxWidth: 400,
                minHeight: 0,
                maxHeight: 116,
              ),
              child: _buildBarChart(),
            ),
            SizedBox(height: 10),
            _buildLegend(),
          ],
        ),
      ),
    );
  }
}


class MonthlyLineChartWidget extends StatelessWidget {
  final List<ReportDocumentRequest> reportList;

  MonthlyLineChartWidget({required this.reportList});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: 
      Column(
        children: [
          Text(
            'Monthly Report of ${DateFormat.MMMM().format(DateTime.now())}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 134,
            child: _buildLineChart(),
          ),
          SizedBox(height: 10),
          _buildLegend(),
        ],
      ),
    );
  }
  

Widget _buildLineChart() {
  final dateFormatSubmittedTime = DateFormat("yyyy-MM-dd HH:mm:ss");
  final dateFormatClaimDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");

  final DateTime now = DateTime.now();
  final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

  List<String> monthDays = List.generate(daysInMonth, (index) => (index + 1).toString());
  List<int> submissionCounts = List.filled(daysInMonth, 0);
  List<int> claimCounts = List.filled(daysInMonth, 0);

  for (var report in reportList) {
    try {
      DateTime submittedTime = dateFormatSubmittedTime.parse(report.submitted_time);

      if (report.claim_date != null && report.status != 'rejected') {
        DateTime claimDate = dateFormatClaimDate.parse(report.claim_date!);

        // Only consider reports within the current month
        if (submittedTime.month == now.month && submittedTime.year == now.year) {
          submissionCounts[submittedTime.day - 1]++;
        }

        if (claimDate.month == now.month && claimDate.year == now.year) {
          claimCounts[claimDate.day - 1]++;
        }
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
  }

  return LineChart(
    LineChartData(
      titlesData: FlTitlesData(
        leftTitles: SideTitles(showTitles: true, margin: 10),
        bottomTitles: SideTitles(
          showTitles: true,
          margin: 10,
          getTitles: (value) {
            int index = value.toInt();
            if (index >= 0 && index < monthDays.length) {
              return monthDays[index];
            }
            return '';
          },
        ),
        topTitles: SideTitles(
          showTitles: true,
          margin: 10,
          getTitles: (value) {
            int index = value.toInt();
            if (index >= 0 && index < monthDays.length) {
              return submissionCounts[index].toString();
            }
            return '';
          },
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            monthDays.length,
            (index) => FlSpot(index.toDouble(), submissionCounts[index].toDouble()),
          ),
          isCurved: true,
          colors: [Colors.blue],
          belowBarData: BarAreaData(show: false),
          aboveBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: List.generate(
            monthDays.length,
            (index) => FlSpot(index.toDouble(), claimCounts[index].toDouble()),
          ),
          isCurved: true,
          colors: [Colors.red],
          belowBarData: BarAreaData(show: false),
          aboveBarData: BarAreaData(show: false),
        ),
      ],
    ),
  );
}

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.blue, 'Submitted Time'),
        SizedBox(width: 16),
        _buildLegendItem(Colors.red, 'Claim Date'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
          margin: EdgeInsets.only(right: 8),
        ),
        Text(text),
      ],
    );
  }
}
