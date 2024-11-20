import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:raven/admin-widgets/manage_residents/edit_user_account.dart';
import 'dart:convert';

import 'package:raven/residentui/mng_residents/resident-manage-account.dart';

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

class ResidentAccTable extends StatefulWidget {
  //final List<User> residentsList;
  final String token;
  final Function fetchData;

  const ResidentAccTable(this.token, this.fetchData);

  @override
  _ResidentAccTableState createState() => _ResidentAccTableState(token: token);
}

class _ResidentAccTableState extends State<ResidentAccTable> {
  List<User> residentsList = [];
  bool _isMounted = false;
  User? _selectedUserID;
  final String token;

  _ResidentAccTableState({required this.token});

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    filterResidents();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final Uri uri =
          Uri.parse('https://ecensusonlinerequest.online/api/v1/users');
      // Use the correct API endpoint
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (_isMounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = json.decode(response.body)['data'];
          final List<User> tempList = [];
          for (var item in jsonData) {
            final user = User.fromJson(item);
            // Check if the user has a Resident role (roleId 4)
            if (user.roleId == 3) {
              tempList.add(user);
            }
          }

          // Update the state with the fetched resident data
          setState(() {
            residentsList = tempList;
          });
        } else {
          // Handle error when the request fails
          print('Failed to fetch data: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (_isMounted) {
        // Check if the widget is still mounted
        // Handle any exceptions that occur during the request
        print('Error fetching data: $e');
      }
    }
  }

  void filterResidents() {
    final residentUsers =
        residentsList.where((user) => user.roleId == 2).toList();
    setState(() {
      residentsList = residentUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Wrap the table in a Dialog widget
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Resident Accounts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Refresh button clicked, fetch data again
                  fetchData();
                },
                child: const Text('Refresh - Resident Account Table'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SizedBox(height: 10),
          FittedBox(
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
                for (var users in residentsList)
                  DataRow(cells: [
                    DataCell(Text(users.firstname)),
                    DataCell(Text(users.middlename)),
                    DataCell(Text(users.lastname)),
                    DataCell(Text(obscureAddress(users.address))),
                    DataCell(Text(users.age)),
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
                                  _selectedUserID = users;
                                });

                                if (_selectedUserID != null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EditResidentAccountModal(
                                      token: token,
                                      userData: _selectedUserID!,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.orange),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Implement Delete functionality here
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
