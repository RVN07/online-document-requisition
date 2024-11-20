import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:raven/staffWidgets/staffProfile.dart';


//DateTime? selectedDate;
//bool showDatePickerOverlay = false;



class EditStaffAccountModal extends StatefulWidget {
  final String token;
  final StaffUserData staffData; // Add this line to accept the Users object

  EditStaffAccountModal({required this.token, required this.staffData});

  @override
  _EditStaffAccountModalState createState() =>
      _EditStaffAccountModalState(token: token);
}

class _EditStaffAccountModalState extends State<EditStaffAccountModal> {
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

  _EditStaffAccountModalState({required this.token});

  @override
  void initState() {
    super.initState();
    // Populate the form fields with existing user data when the widget is created
    selectedGender = genderItems[0]; 
    populateFormFields(widget.staffData);
  }

  @override
  void dispose() {
    // Cancel any pending operations or timers here
    super.dispose();
  }

  void populateFormFields(StaffUserData staffData) {
    firstNameController.text = staffData.firstname;
    middleNameController.text = staffData.middlename;
    lastNameController.text = staffData.lastname;
    suffixController.text = staffData.suffix ?? '';
    ageController.text = staffData.age.toString();
    birthDateController.text = staffData.birthDate;
    contactController.text = staffData.contactNumber;
    addressController.text = staffData.address;
    usernameController.text = staffData.username;
    emailController.text = staffData.email;
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.staffData.id}'),
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
      };

      try {
        final response = await http.patch(
          Uri.parse('https://ecensusonlinerequest.online/api/v1/users/${widget.staffData.id}'),
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
                decoration: const InputDecoration(
                  labelText: 'Suffix',
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
              TextFormField(
                controller: birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please update birthdate';
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
              const SizedBox(height: 20),
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
