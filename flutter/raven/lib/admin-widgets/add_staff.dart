import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:raven/LoginWidgets/resident-register.dart';
import 'package:flutter/cupertino.dart';

Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

class AddStaffModal extends StatefulWidget {
  final String token;

  const AddStaffModal({required this.token});

  @override
  _AddStaffModalState createState() => _AddStaffModalState(token: token);
}

class _AddStaffModalState extends State<AddStaffModal> {
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

  final List<String> validSuffixes = ['Jr.','Sr.','Jr', 'Sr', 'II', 'III', 'IV'];
    @override
  void initState() {
    super.initState(); // Set the flag to true when the widget is mounted
    selectedGender = genderItems[0]; // Initialize here
  }

  bool isValidPhoneNumber(String phoneNumber) {
  // Regular expression for a valid Philippine mobile number format
  // Change the regex pattern according to your specific requirements
  final RegExp regex = RegExp(r'^\+?63[0-9]{10}$');

  return regex.hasMatch(phoneNumber);
}


  final String token;

  _AddStaffModalState({required this.token});

  @override
  void dispose() {
    // Dispose of your controllers
    super.dispose();
  }

      bool isValidSuffix(String suffix) {
    return validSuffixes.contains(suffix);
  }

  void _addStaff() async {

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
        'password': passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('https://ecensusonlinerequest.online/api/v1/users'),
          body: json.encode(userData),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 201) {
          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Staff Account created successfully!'),
              duration: Duration(seconds: 2), // Adjust the duration as needed
            ),
          );
          print('Response Staff Data: $userData');
          // Close the modal or navigate to another screen if needed
          Navigator.of(context).pop();
        } else {
          // Handle other status codes as needed, e.g., display an error message
          print('Error: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.statusCode}'),
              duration:
                  const Duration(seconds: 2), // Adjust the duration as needed
            ),
          );
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
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Staff',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
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
                            return 'Please enter the first name';
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
                            return 'Please enter middle name or type N/A ';
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
                            return 'Please enter the last name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
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
                      const SizedBox(width: 10),
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
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 10),
                    
                  ],
                ),
                Row(
                  children: [
                    
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
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
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  obscureText: true, // Hide the password
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addStaff,
                  child: const Text('Add Staff'),
                ),
              ],
            ),
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
