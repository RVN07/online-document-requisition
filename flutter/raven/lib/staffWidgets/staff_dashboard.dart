import 'package:flutter/material.dart';
import 'package:raven/residentui/profile.dart';
import 'package:raven/staffWidgets/dashboard_requests_list.dart';
import 'package:raven/staffWidgets/dashboard_table.dart';
import 'package:raven/staffWidgets/reports_dashboard.dart';
import 'package:raven/staffWidgets/searchDialogs/pendingDialog.dart';
import 'package:raven/staffWidgets/searchDialogs/searchreportDialog.dart';
import 'package:raven/staffWidgets/staffProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:connectivity/connectivity.dart';

class StaffDashboardPage extends StatefulWidget {
  final String token;
  final String email;
  final String password;

  StaffDashboardPage({
    required this.token,
    required this.email,
    required this.password,
  });

  @override
  _StaffDashboardPageState createState() =>
      _StaffDashboardPageState(token: token);
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  //List<UserData> userData = [];
  List<StaffUserData> staffData = [];
  List<PendingDocumentRequest> documentList = [];
  List<StatusDocumentRequest> statusList = [];
  List<ReportDocumentRequest> reportsList = [];
  bool _isMounted = false;
  TextEditingController searchTextController =
      TextEditingController();
  final String token;

  _StaffDashboardPageState({required this.token});

  bool showUserProfile = true;
  bool isPendingTableVisible = true;
  bool isApproveRejectedTableVisible = false;
  bool isAnalyticsTableVisible = true;

  int selectedIndex = 0;

  void toggleContent(int index) {
    setState(() {
      selectedIndex = index;
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

          // Update the state with the fetched census data
          setState(() {
            documentList = tempList;
          });
        } else {
          // Handle error when the response does not contain 'data'
          print('Failed to fetch data: Response does not contain "data"');
        }
      } else {
        // Handle error when the request fails with a non-200 status code
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error fetching data: $e');
    }
  }

     Future<void> fetchReportData() async {
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
          final List<ReportDocumentRequest> temporaryList = [];

          for (var item in data) {
            temporaryList.add(ReportDocumentRequest.fromJson(item));
          }

          // Update the state with the fetched census data
          setState(() {
            reportsList = temporaryList;
          });
        } else {
          // Handle error when the response does not contain 'data'
          print('Failed to fetch data: Response does not contain "data"');
        }
      } else {
        // Handle error when the request fails with a non-200 status code
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error fetching data: $e');
    }
  }

void showPendingDialog(List<PendingDocumentRequest> searchResults) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PendingDialogModal(
        token, // Replace with your actual token
        searchResults,
      );
    },
  );
}

void onSearchPendingPressed(String fullName) async {
if (fullName.isEmpty) {
    // Show a pop-up overlay when the search bar is empty
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Empty Search Field'),
          content: const Text('Please enter a name to search.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return; // Exit the function to prevent further processing
  }

  try {
    final Uri uri = Uri.parse(
      'https://ecensusonlinerequest.online/api/v1/searchNamePending?full_name=$fullName',
    );

    final response = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('users')) {
        final List<dynamic> jsonData = responseData['users'];
        final List<PendingDocumentRequest> searchResults = [];

        for (var item in jsonData) {
          searchResults.add(PendingDocumentRequest.fromJson(item));
        }

        // Show the pending dialog with the search results
        showPendingDialog(searchResults);
      } else {
        // Show a pop-up overlay when the user is not found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('User Not Found'),
              content: const Text(
                'The user with the specified name was not found.',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle error when the request fails
      print('Failed to fetch search results: ${response.statusCode}');
    }
  } catch (e) {
    // Show a pop-up overlay when an exception occurs
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error Searching Data'),
          content: Text('An error occurred while searching data: $e'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    print('Error searching data: $e');
  }
}

void showReportDialog(List<ReportDocumentRequest> searchResults) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ReportDialogModal(
        token, // Replace with your actual token
        searchResults,
      );
    },
  );
}


  void onSearchStatusPressed(String fullName) async {
if (fullName.isEmpty) {
    // Show a pop-up overlay when the search bar is empty
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Empty Search Field'),
          content: const Text('Please enter a name to search.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return; // Exit the function to prevent further processing
  }

  try {
    final Uri uri = Uri.parse(
      'https://ecensusonlinerequest.online/api/v1/searchNameReport?full_name=$fullName',
    );

    final response = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('users')) {
        final List<dynamic> jsonData = responseData['users'];
        final List<ReportDocumentRequest> searchResults = [];

        for (var item in jsonData) {
          searchResults.add(ReportDocumentRequest.fromJson(item));
        }

        // Show the pending dialog with the search results
        showReportDialog(searchResults);
      } else {
        // Show a pop-up overlay when the user is not found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('User Not Found'),
              content: const Text(
                'The user with the specified name was not found.',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle error when the request fails
      print('Failed to fetch search results: ${response.statusCode}');
    }
  } catch (e) {
    // Show a pop-up overlay when an exception occurs
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error Searching Data'),
          content: Text('An error occurred while searching data: $e'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    print('Error searching data: $e');
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

  


  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_2),
            title: Text('User'),
            onTap: () {
              toggleContent(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.pending),
            title: Text('Pending Requests'),
            onTap: () {
              toggleContent(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.label_important),
            title: Text('Approved Requests'),
            onTap: () {
              toggleContent(2);
              Navigator.pop(context);
            },
          ),
                    ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Reports'),
            onTap: () {
              toggleContent(2);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

Widget buildOption({
  required IconData icon,
  required String label,
  required int index,
}) {
  return Material(
    color: Colors.transparent,
    child: InkResponse(
      onTap: () {
        toggleContent(index);
      },
      borderRadius: BorderRadius.circular(8),
      highlightShape: BoxShape.rectangle,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.grey.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color.fromARGB(255, 57, 57, 57),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color.fromARGB(255, 69, 69, 69),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



      Widget buildMobileLayout() {
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


  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_2),
            title: Text('User'),
            onTap: () {
              toggleContent(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.pending),
            title: Text('Pending Requests'),
            onTap: () {
              toggleContent(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.label_important),
            title: Text('Approved Requests'),
            onTap: () {
              toggleContent(2);
              Navigator.pop(context);
            },
          ),
                    ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Reports'),
            onTap: () {
              toggleContent(2);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              logout(token, widget.email, widget.password);
            },
          ),
        ],
      ),
      drawer: buildDrawer(),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          StaffUserProfile(
            token: token,
            staffEmail: widget.email, // Pass the email here
          ),
          TableDashboardModal(token, documentList, fetchData, onSearchPendingPressed
                  ),
          TableDashboardList(token, statusList, fetchData,
                  ),
          ReportsDashboardList(token, reportsList, fetchData, onSearchStatusPressed
                  ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: toggleContent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending),
            label: 'Pending Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label_important),
            label: 'Approved Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
  
  Scaffold buildDesktopLayout() {

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
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Color.fromARGB(255, 233, 237, 233),
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: Colors.green, // Set your desired background color
    shape: BoxShape.circle, // Specify the circular shape
  ),
  child: Center(
    child: Icon(
      Icons.person_2_sharp,
      size: 70,
      color: Colors.white,
    ),
  ),
),
const SizedBox(height: 12), // Add SizedBox for spacing

                          ],
                        ),
                      ),
                      buildOption(
                        icon: Icons.person_2,
                        label: 'User',
                        index: 0,
                      ),
                      buildOption(
                        icon: Icons.pending,
                        label: 'Pending Requests',
                        index: 1,
                      ),
                      buildOption(
                        icon: Icons.label_important,
                        label: 'Approved Requests',
                        index: 2,
                      ),
                       buildOption(
                        icon: Icons.analytics,
                        label: 'Reports',
                        index: 3,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      logout(token, widget.email, widget.password);
                    },
                     icon: Icon(
                    Icons.logout_outlined,

                  ),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: IndexedStack(
              index: selectedIndex,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedIndex == 0
                      ? StaffUserProfile(
                          token: token,
                          staffEmail: widget.email, // Pass the email here
                        )
                      : const CircularProgressIndicator(),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedIndex == 1
                      ? TableDashboardModal(token, documentList, fetchData, onSearchPendingPressed
                  )
                      : const CircularProgressIndicator(),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedIndex == 2
                      ? TableDashboardList(token, statusList, fetchData,
                  )
                      : const CircularProgressIndicator(),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedIndex == 3
                      ? ReportsDashboardList(token, reportsList, fetchReportData, onSearchStatusPressed
                  )
                      : const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return buildMobileLayout();
    } else {
      return buildDesktopLayout();
    }
  }


}
