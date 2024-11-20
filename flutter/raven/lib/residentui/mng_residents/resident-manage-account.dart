import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:raven/residentui/profile.dart';


//DateTime? selectedDate;
//bool showDatePickerOverlay = false;



class EditUserAccountModal extends StatefulWidget {
  final String token;
  final UserData userData; // Add this line to accept the Users object

  EditUserAccountModal({required this.token, required this.userData});

  @override
  _EditUserAccountModalState createState() =>
      _EditUserAccountModalState(token: token);
}

class _EditUserAccountModalState extends State<EditUserAccountModal> {
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
  final List<String> validSuffixes = ['Jr.','Sr.','Jr', 'Sr', 'II', 'III', 'IV'];
  late String selectedGender;

  bool isValidPhoneNumber(String phoneNumber) {
  // Regular expression for a valid Philippine mobile number format
  // Change the regex pattern according to your specific requirements
  final RegExp regex = RegExp(r'^\+?63[0-9]{10}$');

  return regex.hasMatch(phoneNumber);
}

    bool isValidSuffix(String suffix) {
    return validSuffixes.contains(suffix);
  }

  final String token;

  _EditUserAccountModalState({required this.token});

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

  void populateFormFields(UserData userData) {
    firstNameController.text = userData.firstname;
    middleNameController.text = userData.middlename;
    lastNameController.text = userData.lastname;
    suffixController.text = userData.suffix ?? '';
    ageController.text = userData.age.toString();
    birthDateController.text = userData.birthDate;
    contactController.text = userData.contactNumber;
    addressController.text = userData.address;
    usernameController.text = userData.username;
    emailController.text = userData.email;
  }

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
        // Handle error, show an error message
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions, e.g., network error
      print('Error: $e');
    }
  }

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
//'password': passwordController.text,
      };

      try {
        final response = await http.patch(
  Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.userData.id}'),
  body: json.encode(userData),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  },
);

        if (response.statusCode == 200) {
          // Handle success, e.g., show a success message or close the overlay
          print('User updated successfully!');
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
              TextFormField(
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
              const SizedBox(height: 10),
              TextFormField(
                controller: middleNameController,
                decoration: const InputDecoration(
                  labelText: 'Middle Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter or update the middle name';
                  }
                  return null;
                },
              ),
              TextFormField(
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
              TextFormField(
              
                            controller: suffixController,
                            decoration: const InputDecoration(labelText: 'Suffix' ),
                            validator: (value) {
                              if (value!.isNotEmpty && !isValidSuffix(value)) {
                                return 'Invalid suffix';
                              }
                              return null;
                            },
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
             
              const SizedBox(height: 10),
              TextFormField(
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
              makeInputContainer(
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
                      
              const SizedBox(height: 10),
               TextFormField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter or update age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
               TextFormField(
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
              const SizedBox(height: 10),
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter or update contact';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
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
             
const SizedBox(height: 20),
 //             TextFormField(
 //               controller: passwordController,
 //               decoration: const InputDecoration(
  //                labelText: 'Password',
  //              ),
   //             validator: (value) {
     //             if (value!.isEmpty) {
       //             return 'Please enter a password';
         //         }
           //       return null;
             //   },
             //   obscureText: true, // Hide the password
            //  ),
           //   TextFormField(
            //    controller: confirmPasswordController,
             //   decoration: const InputDecoration(
             //     labelText: 'Confirm Password',
             //   ),
             //   validator: (value) {
             //     if (value != passwordController.text) {
             //       return 'Passwords do not match';
             //     }
             //     return null;
             //   },
              //  obscureText: true, // Hide the password
             // ),
            //  const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitUser,
                child: const Text('Update Account'),
              ),
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
        width: double.infinity, // Controls the width
        child: child,
      ),
      const SizedBox(height: 5), // Adjusted height
    ],
  );
}
}
