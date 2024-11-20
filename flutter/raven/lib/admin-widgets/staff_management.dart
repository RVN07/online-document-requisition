import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:raven/admin-widgets/add_staff.dart';
import 'package:raven/admin-widgets/delete_staff.dart';
import 'package:raven/admin-widgets/edit_staff.dart';
import 'package:raven/admin-widgets/manage_residents/resident_acc_table.dart';

class User {
  int id;
  final int roleId;
  final String firstname;
  final String middlename;
  final String lastname;
  final String suffix;
  final String gender;
  final String age;
  final String address;
  final String birthDate;
  final String contactNumber;
  final String username;
  final String email;
  final String password;
  final String imageUrl;

  User({
    required this.id,
    required this.roleId,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.suffix,
    required this.gender,
    required this.age,
    required this.address,
    required this.birthDate,
    required this.contactNumber,

    
    required this.username,
    required this.email,
    required this.password,
    required this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      roleId: json['role_id'],
      firstname: json['firstname'] ?? '',
      middlename: json['middlename'] ?? '',
      lastname: json['lastname'] ?? '',
      suffix: json['suffix'] ?? '',
      gender: json['gender'] ?? '',
       age: json['age']?.toString() ?? '',
             address: json['address']?.toString() ?? '',
      birthDate: json['birthDate'] ?? '',
      contactNumber: json['contactnumber']?.toString() ?? '',

      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? '',
    );
  }
}

class StaffManagement extends StatefulWidget {
  final String token;
  final List<User> usersList;
  final List<User> residentsList;
  final Function fetchData;

  const StaffManagement(
      this.token, this.usersList, this.residentsList, this.fetchData);

  @override
  _StaffManagementState createState() => _StaffManagementState(token: token);
}

class _StaffManagementState extends State<StaffManagement> {
  List<User> usersList = [];
  List<User> residentsList = [];
  bool _isMounted = false;
  User? _selectedUser;

  final String token;

  _StaffManagementState({required this.token});

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    fetchData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
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
      final Uri uri =
          Uri.parse('https://ecensusonlinerequest.online/api/v1/users');
      // Use the correct API endpoint
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'];
        final List<User> tempList = [];
        for (var item in jsonData) {
          final user = User.fromJson(item);
          // Check if the user has a Staff role. which is 2)
          if (user.roleId == 4) {
            tempList.add(user);
          }
        }

        // Update the state with the fetched staff data
        setState(() {
          usersList = tempList;
        });
      } else {
        // Handle error when the request fails
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
        ),
      );
    }
  }

  void filterResidents() {
    final staffUsers = usersList.where((user) => user.roleId == 1).toList();
    setState(() {
      usersList = staffUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'STAFF',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  // button when clicked, it fetches data again
                  widget.fetchData();
                },
                child: const Text('Refresh - Staff Table'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => AddStaffModal(token: token),
    );
  },
  child: Row(
    children: [
      Icon(
        Icons.person_add_alt,
        size: 20,
        color: Colors.blueGrey,
      ),const SizedBox(width: 8),
      const Text('Add Staff'),
    ],
  ),
),

              const SizedBox(width: 8),
       //       ElevatedButton(
        //        onPressed: () {
        //          showDialog(
         //           context: context,
        //            builder: (context) => ResidentAccTable(token, fetchData),
         //         );
        //        },
       //         child: const Text('Resident Accounts'),
       //       ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
                scrollDirection: Axis.vertical,
                child: FittedBox(
                  // Wrap the DataTable with FittedBox
                  child: DataTable(
                    columnSpacing: 30,
                    dataRowHeight: 70,
                    headingRowHeight: 30,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'First Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Middle Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Last Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                        DataColumn(
                        label: Text(
                          'Suffix',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                        DataColumn(
                        label: Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                        DataColumn(
                        label: Text(
                          'Age',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    
                      DataColumn(
                        label: Text(
                          'Birth Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Action',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                    rows: [
                      for (var users in widget.usersList)
                        DataRow(cells: [
                          DataCell(Text(users.firstname)),
                          DataCell(Text(users.middlename)),
                          DataCell(Text(users.lastname)),
                          DataCell(Text(users.suffix)),
                          DataCell(Text(users.gender)),
                          DataCell(Text(users.age)),
                          DataCell(Text(obscureAddress(users.address))),           
                          DataCell(Text(users.birthDate)),
                          DataCell(Text(obscureContact(users.contactNumber))),
                          DataCell(Text(users.username)),
                          DataCell(Text(obscureContact(users.email))),
                          DataCell(
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_isMounted) {
                                      setState(() {
                                        _selectedUser = users;
                                      });

                                      if (_selectedUser != null) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => EditStaffModal(
                                            token: token,
                                            userData: _selectedUser!,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.orange),
                                  ),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_isMounted) {
                                      // Check if the widget is still mounted
                                      showDialog(
                                        context: context,
                                        builder: (context) => DeleteStaffDialog(
                                          token: token,
                                          userDelete:
                                              users, // Corrected variable name from user to users
                                          onDelete: () async {
                                            // Close the DeleteResidentModal
                                            Navigator.of(context).pop();
                                            // Wait for the modal to be popped
                                            await Future.delayed(const Duration(
                                                milliseconds: 100));
                                            // Refresh the data when a resident is deleted
                                            fetchData();
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
