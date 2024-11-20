import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:raven/residentui/resident-dashboard.dart';
import 'package:connectivity/connectivity.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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

  List<String> genderItems = ['Male', 'Female'];
  final List<String> validSuffixes = ['Jr.','Sr.','Jr', 'Sr', 'II', 'III', 'IV'];
  late String selectedGender;
  bool _isLoggingIn = false;
  
  @override
  void initState() {
    super.initState();
    selectedGender = genderItems[0];
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _registerUser() async {

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
        'role_id': 3,
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
        'status': 'Verified'
      };

      try {
        final response = await http.post(
          Uri.parse('https://ecensusonlinerequest.online/api/v1/new/user'),
          body: json.encode(userData),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registration Successful'),
                content: const Text(
                    'Please check your email for verification.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (response.statusCode == 422) {
          final errors = json.decode(response.body)['errors'];
          // Handle validation errors
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registration Failed'),
                content: const Text(
                    'Registration failed... It looks like you got a wrong input or your email is existing in our database.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          debugPrint('API Response: ${response.body}');
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

   Future<String?> _performLogin() async {
    setState(() {
      _isLoggingIn = true;
    });

    const String apiUrl = 'https://ecensusonlinerequest.online/api/v1/auth/login';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['token'];
      print('Login successfully!');
      Future.delayed(Duration.zero, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardPage(
                token: token,
                email: emailController.text,
                password: passwordController.text),
          ),
        );
      });
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage = errorData['message'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    setState(() {
      _isLoggingIn = false;
    });
  }
    bool isValidSuffix(String suffix) {
    return validSuffixes.contains(suffix);
  }

bool isValidPhoneNumber(String phoneNumber) {
  // Regular expression for a valid Philippine mobile number format
  // Change the regex pattern according to your specific requirements
  final RegExp regex = RegExp(r'^\+?63[0-9]{10}$');

  return regex.hasMatch(phoneNumber);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined, size: 20, color: Colors.black),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // On larger screens, use the default layout
                return buildDesktopLayout();
              } else {
                // On smaller screens, stack the form fields in a column
                return buildMobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }

Widget buildDesktopLayout() {
  return Scaffold(
    backgroundColor: Colors.grey[200], // Light grey background color
    body: DefaultTextStyle(
      style: TextStyle(color: Colors.grey[150]),
      child: SingleChildScrollView(
        child: Center(
          child: Card(
            color: Colors.white, 
                    margin: EdgeInsets.all(10.0), // Add margin as needed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          15.0), // Add border radius for rounded corners
                    ),
                    elevation: 4, // Add elevation for a shadow effect
                    child:  Container(
            width: 800,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
              // White container background color
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('images/central_bicutan.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Register Account",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: makeInputContainer(
                          label: "First Name",
                          child: TextFormField(
                            controller: firstNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your first name ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: makeInputContainer(
                          label: "Middle Name",
                          child: TextFormField(
                            controller: middleNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your middle name or leave N/A ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: makeInputContainer(
                          label: "Last Name",
                          child: TextFormField(
                            controller: lastNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your last name ';
                              }
                              return null;
                            },
                          ),
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                         Container(
        width: 80, // Adjust the width as needed
        child: makeInputContainer(
          label: "Gender",
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
      ),
                      Expanded(
                        child: makeInputContainer(
                          label: "Address",
                          child: TextFormField(
                            controller: addressController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your address ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      
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
                      const SizedBox(width: 25),
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
                      
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                     
                      Expanded(
                        child: makeInputContainer(
                          label: "Email",
                          child: TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an email';
                              }
                              return null;
                            },
                          ),
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
                        child: makeInputContainer(
                          label: "Username",
                          child: TextFormField(
                            controller: usernameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a username';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 50),
                      Expanded(
                        child: makeInputContainer(
                          label: "Password",
                          child: TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                      Expanded(
                        child: makeInputContainer(
                          label: "Confirm Password",
                          child: TextFormField(
                            obscureText: true,
                            controller: confirmPasswordController,
                            validator: (value) {
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _registerUser();
                          },
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  )
  );
}


 Widget buildMobileLayout() {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Center(
        child: Container(
                    width: 200.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('images/central_bicutan.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
      ),
      const Text(
        "Sign up",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        "Register Account",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 10),
      makeInputContainer(
        label: "First Name",
        child: TextFormField(
          controller: firstNameController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your first name ';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 10),
      makeInputContainer(
        label: "Middle Name",
        child: TextFormField(
          controller: middleNameController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your middle name or leave N/A ';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 10),
      makeInputContainer(
        label: "Last Name",
        child: TextFormField(
          controller: lastNameController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your last name ';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 10),
       makeInputContainer(
          label: "Suffix",
          child: TextFormField(
            controller: suffixController,
            validator: (value) {
              if (value!.isEmpty) {
                return null; // Suffix is optional
              } else {
                if (isValidSuffix(value)) {
                  return null; // Valid suffix
                } else {
                  return 'Invalid suffix';
                }
              }
            },
          ),
        ),
      const SizedBox(height: 10),
      Container(
        width: 150,
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
          underline: Container(),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
      ),
      const SizedBox(height: 10),
      makeInputContainer(
        label: "Address",
        child: TextFormField(
          controller: addressController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your address ';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 10),
    
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
       makeInputContainer(
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

 const SizedBox(height: 10),
      makeInputContainer(
        label: "Email",
        child: TextFormField(
          controller: emailController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter an email';
            }
            return null;
          },
        ),
      ),

      const SizedBox(height: 10),

    makeInputContainer(
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
     
      
      const SizedBox(height: 10),
      makeInputContainer(
        label: "Username",
        child: TextFormField(
          controller: usernameController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a username';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 10),
      makeInputContainer(
        label: "Password",
        child: TextFormField(
          obscureText: true,
          controller: passwordController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a password';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 10),
      makeInputContainer(
        label: "Confirm Password",
        child: TextFormField(
          obscureText: true,
          controller: confirmPasswordController,
          validator: (value) {
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: 250,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue,
          ),
          onPressed: () {
            _registerUser();
            _performLogin();
          },
          child: const Text('Sign Up'),
        ),
      ),
      const SizedBox(height: 10),
    ],
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
      // Remove the square brackets
      // SizedBox(
      //   width: double.infinity,
      //   child: child,
      // ),
      child,
      const SizedBox(height: 5),
    ],
  );
}
}