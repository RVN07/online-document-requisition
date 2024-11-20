import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raven/residentui/tutorial/resident-tutorial-tagalog.dart';

class ResidentTutorialTagalogController extends StatefulWidget {
  @override
  _ResidentTutorialTagalogControllerState createState() =>
      _ResidentTutorialTagalogControllerState();
}

class _ResidentTutorialTagalogControllerState extends State<ResidentTutorialTagalogController> {
  bool isTagalog = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _buildTagalogBody(context),
    );
  }

  Widget _buildTagalogBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // If the screen width is greater than 600, use desktop layout
          return ResidentTutorialTagalogDesktop();
        } else {
          // Otherwise, use mobile layout
          return ResidentTutorialTagalogMobile();
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

class ResidentTutorialTagalogDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ResidentTutorialTagalog(),
        ),
      ],
    );
  }
}
class ResidentTutorialTagalogMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResidentTutorialTagalogContent();
  }
}

class ResidentTutorialTagalogContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildSection(
              title: 'Maligayang Pagdating sa Sistema Tutorial!',
              content: 'Learn how to use the system effectively.',
              context: context, // Pass context here if needed
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              title: '1. User Profile',
              content:
                  'Tingnan at i-update ang iyong personal na impormasyon sa seksyon ng User .',
              context: context, // Pass context here if needed
            ),
            const SizedBox(height: 16.0),
            _buildSection(
              title: '2. Request Documents',
               content: '''
              Gumawa ng QR Code para sa mabilisang paghingi ng mga dokumento.
              1. Ibigay ang iyong dahilan kung bakit mo kailangan ng isang dokumento mula sa barangay.
              2. Mag-click/tap sa isa sa mga button na kumakatawan ng isang dokumento tulad ng "Barangay ID" o "Barangay Clearance".
              3. May lalabas na button sa ibaba sa kanang bahagi ng iyong screen, i-click ito.
              4. I-click ang link na ibinigay upang makita ang QR Code at i-save o i-screenshot ang nasabing QR Code.
              5. Makakatanggap ka ng email mula sa Sistema tungkol sa iyong hiling na dokumento.
              6. Mangyaring ihanda ang iyong naisilid na QR Code para sa veripikasyon mula sa barangay staff kung na-aprubahan na ang iyong hiling.
              ''',
              images: [
                '/images/qrgen.png',
                '/images/qrgen3.png',
                '/images/qrgenpt3.png',
                '/images/qrcode_tagalog.png'
              ],
              context: context, // Pass context here if needed
            ),
            const SizedBox(height: 16.0),
            _buildSection(
              title: '3. Chat Screen (Chatbot)',
              content: '''
              Gamitin ang ChatScreen upang makipag-ugnayan sa Chatbot.
              Ang Chatbot ay nagbibigay ng tulong at impormasyon.
              Gamitin ang mga button para madaling mag-navigate sa iba't ibang chat options.
              ''',
              images: [
                '/images/chatbotmobile.png',
                '/images/chatbot_desktop.png'
              ],
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

class ResidentTutorialTagalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildSection(
              title: 'Maligayang Pagdating sa Sistema Tutorial!',
              content: 'Matuto pano gamitin ang sistema.',
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              title: '1. User Profile',
              content:
                  'Tingnan at i-update ang iyong personal na impormasyon sa seksyon ng User.',
            ),
            const SizedBox(height: 16.0),
            _buildSection(
             title: '2. Request Documents',
               content: '''
              Gumawa ng QR Code para sa mabilisang paghingi ng mga dokumento.
              1. Ibigay ang iyong dahilan kung bakit mo kailangan ng isang dokumento mula sa barangay.
              2. Mag-click/tap sa isa sa mga button na kumakatawan ng isang dokumento tulad ng "Barangay ID" o "Barangay Clearance".
              3. May lalabas na button sa ibaba sa kanang bahagi ng iyong screen, i-click ito.
              4. I-click ang link na ibinigay upang makita ang QR Code at i-save o i-screenshot ang nasabing QR Code.
              5. Makakatanggap ka ng email mula sa Sistema tungkol sa iyong hiling na dokumento.
              6. Mangyaring ihanda ang iyong naisilid na QR Code para sa veripikasyon mula sa barangay staff kung na-aprubahan na ang iyong hiling.
              ''',
              images: [
                '/images/qrgen.png',
                '/images/qrgen3.png',
                '/images/qrgenpt3.png',
                '/images/qrcode_tagalog.png'
              ],
            ),
            const SizedBox(height: 16.0),
            _buildSection(
              title: '3. Chat Screen (Chatbot)',
              content: '''
              Gamitin ang Chat Screen upang makipag-ugnayan sa Chatbot.
              Ang Chatbot ay nagbibigay ng tulong at impormasyon.
              Gamitin ang mga button para madaling mag-navigate sa iba't ibang chat options.
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