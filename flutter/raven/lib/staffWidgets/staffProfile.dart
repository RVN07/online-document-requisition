import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:raven/residentui/mng_residents/resident-manage-account.dart';
import 'package:raven/staffWidgets/editStaff.dart';

class StaffUserData {
  final int id;
  final int roleId;
  final String firstname;
  final String middlename;
  final String lastname;
  final String? suffix;
  final String gender;
  final int age;
  final String address;
  final String birthDate;
  final String contactNumber;
  final String username;
  final String email;
  final String password;
  final String imageUrl;

  StaffUserData({
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

  factory StaffUserData.fromJson(Map<String, dynamic> json) {
    return StaffUserData(
      id: json['data']['id'],
      roleId: json['data']['role_id'],
      firstname: json['data']['firstname'] ?? '',
      middlename: json['data']['middlename'] ?? '',
      lastname: json['data']['lastname'] ?? '',
      suffix: json['data']['suffix'],
      gender: json['data']['gender'] ?? '',
      age: json['data']['age'],
      address: json['data']['address'] ?? '',
      birthDate: json['data']['birthDate'] ?? '',
      contactNumber: json['data']['contactnumber'] ?? '',
      username: json['data']['username'] ?? '',
      email: json['data']['email'] ?? '',
      password: json['data']['password'] ?? '',
      imageUrl: json['data']['image'] ?? '',
    );
  }
}

class StaffUserProfile extends StatefulWidget {
  final String token;
  final String staffEmail;

  StaffUserProfile({required this.token, required this.staffEmail});

  @override
  _StaffUserProfileState createState() => _StaffUserProfileState();
}

class _StaffUserProfileState extends State<StaffUserProfile> {
  late Future<StaffUserData> userDataFuture;
    bool _isMounted = false;
  StaffUserData? _selectedUser;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    userDataFuture = fetchUserData();
  }


  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<StaffUserData> fetchUserData() async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    final response = await http.get(
      Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.staffEmail}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> userDataMap = json.decode(response.body);
      return StaffUserData.fromJson(userDataMap);
    } else {
      print('Error: ${response.statusCode}');
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StaffUserData>(
      future: userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return Text('No data available');
        } else {
          final userData = snapshot.data!;

          return AlertDialog(
            content: SingleChildScrollView(
              child: UserProfileContent(
                userData: userData,
                isMounted: _isMounted,
                token: widget.token,
              ),
            ),
          );
        }
      },
    );
  }
}

class UserProfileContent extends StatelessWidget {
  final StaffUserData userData;
  final bool isMounted;
  final String token;

  UserProfileContent({required this.userData, required this.isMounted, required this.token});

 @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width > 1200
          ? 1200
          : MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.blue, // Change color as per your design
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData.username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    obscureEmail(userData.email),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (isMounted) {
                        showDialog(
                          context: context,
                          builder: (context) => EditStaffAccountModal(
                            token: token,
                            staffData: userData,
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orange),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(16),
            child: Column(
              children: [
                buildDetailTile('First Name', userData.firstname, Icons.person),
                buildDetailTile('Middle Name', userData.middlename, Icons.person),
                buildDetailTile('Last Name', userData.lastname, Icons.person),
                buildDetailTile('Suffix', userData.suffix ?? '', Icons.person),
                buildDetailTile('Gender', userData.gender, Icons.person),
                buildDetailTile('Age', userData.age.toString(), Icons.person),
                buildDetailTile('Address', obscureAddress(userData.address), Icons.location_on),
                buildDetailTile('Birth Date', userData.birthDate, Icons.calendar_today),
                buildDetailTile('Contact Number', obscureContact(userData.contactNumber), Icons.phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value),
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
    if (address != null && address.isNotEmpty) {
      final parts = address.split(',');
      final obscuredParts = parts.map((part) => '****');
      return obscuredParts.join(',');
    }
    return address;
  }

  String obscureContact(String contact) {
    if (contact != null && contact.isNotEmpty) {
      return '****';
    }
    return contact;
  }
}