import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raven/residentui/tutorial/resident-tutorial-tagalog.dart';

class ResidentTutorialController extends StatefulWidget {
  @override
  _ResidentTutorialControllerState createState() =>
      _ResidentTutorialControllerState();
}

class _ResidentTutorialControllerState extends State<ResidentTutorialController> {
  bool isTagalog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTagalog ? 'Resident Tutorial (Tagalog)' : 'Resident Tutorial',
        ),
        leading: IconButton(
          icon: Icon(Icons.language),
          onPressed: () {
            switchLanguage();
          },
        ),
      ),
      body: isTagalog 
      ? ResidentTutorialTagalogController()
      : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // If the screen width is greater than 600, use desktop layout
          return ResidentTutorialDesktop();
        } else {
          // Otherwise, use mobile layout
          return ResidentTutorialMobile();
        }
      },
    );
  }

  void switchLanguage() {
    setState(() {
      isTagalog = !isTagalog;
    });
  }
}

class ResidentTutorialDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ResidentTutorial(),
        ),
      ],
    );
  }
}
class ResidentTutorialMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResidentTutorialContent();
  }
}

class ResidentTutorialContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildSection(
              title: 'Welcome to System Tutorial!',
              content: 'Learn how to use the system effectively, This system is created by a group of stu',
              context: context, // Pass context here if needed
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              title: '1. User Profile',
              content:
                  'View and update your personal information in the User section.',
              context: context, // Pass context here if needed
            ),
            const SizedBox(height: 16.0),
            _buildSection(
              title: '2. Request Documents',
              content: '''
              Generate a QR Code to request documents efficiently.
              1. State your reason why you are requesting a document from the barangay.
              2. Click / Tap on one of the buttons that represents a document like "Barangay ID" or "Barangay Clearance".
              3. There would be a button that pops up at the bottom right of the screen, click it.
              4. Click the link provided to see the generated QR Code and save or screenshot said QR Code.
              5. You will receive an email from the System regarding your requested document.
              6. Please prepare your saved QR Code for verification from the barangay staff present if your document request has been approved.
              ''',
              images: [
                '/images/qrgen.png',
                '/images/qrgen3.png',
                '/images/qrgenpt3.png',
                '/images/qrcode_en.png'
              ],
              context: context, // Pass context here if needed
            ),
            const SizedBox(height: 16.0),
            _buildSection(
              title: '3. Chat Screen (Chatbot)',
              content: '''
              Go to the ChatScreen section to access and interact with the Chatbot.
              The Chatbot provides assistance and information based from the responses sent by the user
              There are buttons that contains general questions and messages about the system and its process.
              ''',
              images: [
                '/images/chatbotmobile.png',
                '/images/chatbot_desktop.png'
              ],
              context: context, // Pass context here if needed
            ),
            _buildSection(
              title: 'Overview of System',
              content: '''
              ''',
              context: context, // Pass context here if needed
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    List<String>? images,
    required BuildContext? context, // Make context optional
  }) {
   /// context ??= this.context; // If not provided, use the context from the build method
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              style: TextStyle(fontSize: 14.0),
            ),
            if (images != null && images.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Row(
                children: images
                    .map(
                      (image) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            _showImageDialog(context!, image);
                          },
                          child: Image.asset(
                            image,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    // Extract the image name from the URL (assuming it's the part after the last '/')
    String imageName = imageUrl.split('/').last;

    // Replace the file extension (assuming it's '.png') to get the asset path
    String assetPath = 'images/${imageName.replaceAll('.png', '')}.png';

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}


class ResidentTutorialSidePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16.0),
      child: Text('Side Panel'),
    );
  }
}

class ResidentTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildSection(
              title: 'Welcome to System Tutorial!',
              content: 'Learn how to use the system effectively.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              title: '1. User Profile',
              content:
                  'View and update your personal information in the User section.',
            ),
            const SizedBox(height: 16.0),
            _buildSection(
              title: '2. Request Documents',
              content: '''
              Generate a QR Code to request documents efficiently. Here are the steps on how to do it.
              a. State your reason why you are requesting a document from the barangay.
              b. Click / Tap on one of the buttons that represents a document like "Barangay ID" or "Barangay Clearance".
              c. There would be a button that pops up at the bottom right of the screen, click / it.
              d. Click the link provided to see the generated QR Code and save or screenshot said QR Code.
              e. You will receive an email from the System regarding your requested document.
              f. Please prepare your saved QR Code for verification from the barangay staff present if your document request has been approved.
              ''',
              images: [
                '/images/qrgen.png',
                '/images/qrgen3.png',
                '/images/qrgenpt3.png',
                '/images/qrcode_en.png'
              ],
            ),
            const SizedBox(height: 16.0),
            _buildSection(
              title: '3. Chat Screen (Chatbot)',
              content: '''
              Use the ChatScreen to interact with the Chatbot.
              The Chatbot provides assistance and information.
              Utilize buttons to easily navigate through various chat options.
              ''',
              images: [
                '/images/chatbotmobile.png',
                '/images/chatbot_desktop.png'
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    List<String>? images,
  }) {
    return Builder(
    builder: (context) => Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              style: TextStyle(fontSize: 14.0),
            ),
            if (images != null && images.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Row(
                children: images
                    .map(
                      (image) => Expanded(
                        child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            _showImageDialog(context, image);
                          },
                          child: Image.asset(
                            image,
                            height: 100,
                            fit: BoxFit.cover,
),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

void _showImageDialog(BuildContext context, String imageUrl) {
  // Extract the image name from the URL (assuming it's the part after the last '/')
  String imageName = imageUrl.split('/').last;

  // Replace the file extension (assuming it's '.png') to get the asset path
  String assetPath = 'images/${imageName.replaceAll('.png', '')}.png';

  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
              children: [
          Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
          ),
  );
}
}