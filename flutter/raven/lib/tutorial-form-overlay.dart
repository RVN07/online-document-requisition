import 'package:flutter/material.dart';

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Chatbot Tutorial"),
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Welcome to the Chatbot Tutorial!"),
          SizedBox(height: 15),
          // Image.asset('assets/step1.png',
          //      width: 50, height: 50), // Image placeholder for Step 1
          SizedBox(height: 10),
          Text("Step 1: Start a Conversation"),
          Text(
              "To chat with the chatbot, enter your message in the text field and click 'Submit'."),
          SizedBox(height: 10),
          //  Image.asset('assets/step2.png',
          //     width: 50, height: 50), // Image placeholder for Step 2
          SizedBox(height: 10),
          Text("Step 2: Request a Document"),
          Text(
              "You can request a document by typing its name, such as 'Barangay ID'."),
          SizedBox(height: 10),
          //   Image.asset('assets/step3.png',
          //      width: 50, height: 50), // Image placeholder for Step 3
          SizedBox(height: 10),
          Text("Step 3: Provide Your Name"),
          Text(
              "The chatbot will prompt you to enter your name for verification."),
          SizedBox(height: 10),
          //   Image.asset('assets/step4.png',
          //        width: 50, height: 50), // Image placeholder for Step 4
          SizedBox(height: 10),
          Text("Step 4: Wait for Confirmation"),
          Text(
              "The chatbot will search for your name in the system's records."),
          SizedBox(height: 10),
          Text("Step 5: Fill Up your details"),
          Text(
              "The chatbot tells you to input your information in a form that will show up after Step 4."),
          Text(
              "You will receive an email or SMS confirmation for your document request."),
          Text("Check your email or messaging app for the confirmation."),
          SizedBox(height: 20),
          Text(
              "If you need help at any point, contact us or go to our barangay about our system"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Got it"),
        ),
      ],
    );
  }
}
