import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'staff_management.dart';

//DateTime? selectedDate;
//bool showDatePickerOverlay = false;

class EditStaffModal extends StatefulWidget {
  final String token;
  final User userData; // Add this line to accept the Users object

  EditStaffModal({super.key, required this.token, required this.userData});

  @override
  _EditStaffModalState createState() => _EditStaffModalState(token: token);
}

class _EditStaffModalState extends State<EditStaffModal> {
  final _formKey = GlobalKey<FormState>();
final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController suffixController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

      
  List<String> genderItems = [
    'Male',
    'Female',
  ]; // Define dropdown items

  late String selectedGender;

  final String token;

   bool _updatingPassword = false;
  bool isValidPhoneNumber(String phoneNumber) {
  // Regular expression for a valid Philippine mobile number format
  // Change the regex pattern according to your specific requirements
  final RegExp regex = RegExp(r'^\+?63[0-9]{10}$');

  return regex.hasMatch(phoneNumber);
}

  final List<String> validSuffixes = ['Jr.','Sr.','Jr', 'Sr', 'II', 'III', 'IV'];
      bool isValidSuffix(String suffix) {
    return validSuffixes.contains(suffix);
  }

  _EditStaffModalState({required this.token});

  @override
  void initState() {
    super.initState();
    // Populate the form fields with existing user data when the widget is created
    selectedGender = genderItems[0]; 
    populateFormFields(widget.userData);
  }

  @override
  void dispose() {
    // Cancel any pending operations or timers here
    super.dispose();
  }

  // form fields that would load the existing user data.
  void populateFormFields(User userData) {
    firstNameController.text = userData.firstname;
    middleNameController.text = userData.middlename;
    lastNameController.text = userData.lastname;
    suffixController.text = userData.suffix;
    ageController.text = userData.age;
    birthDateController.text = userData.birthDate;
    contactController.text = userData.contactNumber;
    addressController.text = userData.address;
    usernameController.text = userData.username;
    emailController.text = userData.email;
  }

  // function to fetch user data based from id
  Future<void> fetchUserData() async {

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
      final response = await http.get(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.userData.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        // Populate the form fields with fetched resident data
        populateFormFields(userData);
      } else {
        // Handle error, e.g., show an error message
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions, e.g., network error
      print('Error: $e');
    }
  }

    void _updatePassword() async {
  // Set _updatingPassword to true before updating the password


  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
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
    return;
  }

  if (_formKey.currentState!.validate()) {
    final Map<String, dynamic> userData = {
      'password': passwordController.text,
    };

    try {
      final response = await http.patch(
        Uri.parse(
            'https://ecensusonlinerequest.online/api/v1/users/${widget.userData.id}'),
        body: json.encode(userData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Update the stored password in preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userPassword', passwordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User Password updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        print('Password updated successfully!');
        // Now, you can call the submitUser function to update other information
        _submitUser();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        print('Error: $e');
      }
    }
  }

  // Reset _updatingPassword to false after updating the password
  _updatingPassword = false;
}

  // function to update user data.
  void _submitUser() async {

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
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> userData = {
        'role_id': 4,
        'firstname': firstNameController.text,
        'middlename': middleNameController.text,
        'lastname': lastNameController.text,
        'suffix': suffixController.text,
        'gender': selectedGender,
        'age': ageController.text,
        'address': addressController.text,
        'birthDate': birthDateController.text,
        'contactnumber': contactController.text,
        'username': usernameController.text,
        'email': emailController.text,
      };

      try {
        final response = await http.put(
          Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.userData.id}'),
          body: json.encode(userData),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          // Handle success, e.g., show a success message or close the overlay
          Navigator.of(context).pop();
        } else {
          // Handle error, e.g., show an error message
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        // Handle exceptions, e.g., network error
        if (mounted) {
          print('Error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      iconPadding: const EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey, // Add the Form widget here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter or update the first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: middleNameController,
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter or update middle name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter or update the last name';
                        }
                        return null;
                      },
                    ),
                  ),
                   Expanded(
                        child: makeInputContainer(
                          label: "Suffix",
                          child: TextFormField(
                            controller: suffixController,
                            validator: (value) {
                              if (value!.isNotEmpty && !isValidSuffix(value)) {
                                return 'Invalid suffix';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                        Container(
        width: 150, // Adjust the width as needed
        child: DropdownButton<String>(
          value: selectedGender,
          onChanged: (String? newValue) {
            setState(() {
              selectedGender = newValue!;
            });
          },
          items: genderItems.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          underline: Container(), // Remove the default underline
          isExpanded: true, // Allow the dropdown to take up the full width
          icon: const Icon(Icons.arrow_drop_down), // Add an arrow icon
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
      ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                   Expanded(
                        child: makeInputContainer(
  label: "Birth Date",
  child: Row(
    children: [
      Expanded(
        child: InkWell(
          onTap: () async {
            DateTime? picked;
            await showDialog(
              context: context,
              builder: (BuildContext builder) {
                return AlertDialog(
                  title: Text('Select Birth Date'),
                  content: Container(
                    height: 350,
                    width: 350,
                    child: Column(
                      children: [
                        Expanded(
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: DateTime.now(),
                            minimumDate: DateTime(1900),
                            maximumDate: DateTime.now(),
                            onDateTimeChanged: (DateTime dateTime) {
                              picked = dateTime;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel', style: const TextStyle(fontSize: 15)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(picked);
                      },
                      child: Text('Done',style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                );
              },
            );

            if (picked != null && picked != DateTime.now()) {
              final today = DateTime.now();
              int age = today.year - picked!.year;

              // Check if the birthday has occurred this year
              if (today.month < picked!.month ||
                  (today.month == picked!.month && today.day < picked!.day)) {
                age -= 1;
              }

              setState(() {
                birthDateController.text =
                    DateFormat('yyyy-MM-dd').format(picked!);
                ageController.text = age.toString();
              });
            }
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: birthDateController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a birthdate ';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Click / Tap me to set your birth date',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
                      ),
                      const SizedBox(width: 10),
                  Expanded(
                        child: makeInputContainer(
                          label: "Age",
                          child: TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your age';
                              }

                              // Check if the entered value is a valid integer
                              try {
                                int age = int.parse(value);
                                if (age <= 0 || age > 150) {
                                  return 'Invalid age';
                                }
                              } catch (e) {
                                return 'Invalid age';
                              }

                              return null;
                            },
                          ),
                        ),
                      ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter or update the address';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                    
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                                    Expanded(
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter or update email';
                        }
                        return null;
                      },
                    ),
                  ),
                   Expanded(
                        child: makeInputContainer(
  label: "Contact Number",
  child: TextFormField(
    controller: contactController,
    validator: (value) {
      if (value!.isEmpty) {
        return 'Please enter contact number';
      } else {
        // Include the prefix in the validation
        final phoneNumber = "+63" + value;
        if (!isValidPhoneNumber(phoneNumber)) {
          return 'Invalid contact number format';
        }
      }
      return null;
    },
    decoration: InputDecoration(
      // labelText: "Contact Number",
      prefixText: "+63",
      prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
),

                      ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please update username';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                ],
              ),
              const SizedBox(height: 20),
           TextFormField(
  controller: passwordController,
  decoration: const InputDecoration(
    labelText: 'Password',
  ),
  validator: (value) {
    if (_updatingPassword && value!.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  },
  obscureText: true, // Hide the password
),
TextFormField(
  controller: confirmPasswordController,
  decoration: const InputDecoration(
    labelText: 'Confirm Password',
  ),
  validator: (value) {
    if (_updatingPassword && value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  },
  obscureText: true, // Hide the password
),

              const SizedBox(height: 20),
              Row(children: [ElevatedButton(
                onPressed: _submitUser,
                child: const Text('Update Staff Account'),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: _updatePassword,
                child: const Text('Update Staff Password'),
              ),
              ]),
              
            ],
          ),
        ),
      ),
    );
  }
  Widget makeInputContainer({label, child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 5),
      SizedBox(
        width: double.infinity,
        child: child,
      ),
      const SizedBox(height: 5),
    ],
  );
}
}
