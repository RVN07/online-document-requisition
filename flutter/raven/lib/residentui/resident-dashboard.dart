import 'package:flutter/material.dart';
import 'package:raven/residentui/chatbotv1.dart';
import 'package:raven/residentui/profile.dart';
import 'package:raven/residentui/qrgenerator.dart';
import 'package:raven/residentui/tutorial/resident-tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
class UserDashboardPage extends StatefulWidget {
  final String token;
  final String email;
  final String password;

  UserDashboardPage({
    required this.token,
    required this.email,
    required this.password,
  });

  @override
  _UserDashboardPageState createState() =>
      _UserDashboardPageState(token: token);
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  List<UserData> userData = [];
  //List<DocumentRequest> documentList = [];
  bool _isMounted = false;

  final String token;

  _UserDashboardPageState({required this.token});

  bool showUserProfile = true;
  bool isUserProfileVisible = true;
  bool isQRGeneratorVisible = false;
  bool isChatScreenVisible = true;

  int selectedIndex = 0;

  void toggleContent(int index) {
    setState(() {
      selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return buildMobileLayout();
    } else {
      return buildDesktopLayout();
    }
  }

Scaffold buildMobileLayout() {
  return Scaffold(
    appBar: AppBar(
      title: Text('User Dashboard'),
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
        UserProfile(
          token: token,
          userEmail: widget.email, // Pass the email here
        ),
        QRGenerator(token: token),
        ChatScreen(token: token),
        ResidentTutorialController(),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: toggleContent,
      selectedItemColor: Colors.blue, // Set the color for selected item
      unselectedItemColor: Colors.grey, // Set the color for unselected items
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'User',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'Request Documents',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Chat Screen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Tutorial',
        ),
      ],
    ),
  );
}


  
  Scaffold buildDesktopLayout() {
  return Scaffold(
    body: Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Color.fromARGB(255, 213, 219, 213),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
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
                    buildOption(
                      icon: Icons.person_2,
                      label: 'User',
                      index: 0,
                    ),
                    buildOption(
                      icon: Icons.qr_code_2,
                      label: 'Request Documents',
                      index: 1,
                    ),
                    buildOption(
                      icon: Icons.chat_bubble,
                      label: 'Chat Screen',
                      index: 2,
                    ),
                     buildOption(
                      icon: Icons.info_outline,
                      label: 'Tutorial',
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
                      ? UserProfile(
                token: token,
                userEmail: widget.email, // Pass the email here
              )
                      : const CircularProgressIndicator(),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedIndex == 1
                      ? QRGenerator(token: token)
                      : const CircularProgressIndicator(),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedIndex == 2
                      ? ChatScreen(token: token)
                      : const CircularProgressIndicator(),
                ),
                 Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedIndex == 3
                      ? ResidentTutorialController() //token: token
                      : const CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ],
    ),
  );
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
            leading: Icon(Icons.qr_code_2),
            title: Text('Request Documents'),
            onTap: () {
              toggleContent(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.chat_bubble),
            title: Text('Chat Screen'),
            onTap: () {
              toggleContent(2);
              Navigator.pop(context);
            },
          ),
           ListTile(
            leading: Icon(Icons.info),
            title: Text('Tutorial'),
            onTap: () {
              toggleContent(3);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
