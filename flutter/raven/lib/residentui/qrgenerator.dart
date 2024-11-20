import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity/connectivity.dart';
class QRGenerator extends StatefulWidget {
  final String token;

  QRGenerator({required this.token});

  @override
  _QRGeneratorState createState() => _QRGeneratorState(token: token);
}

class _QRGeneratorState extends State<QRGenerator> {
  String qrCodeImageUrl = '';
  late DateTime qrCodeGeneratedTime;
  String message = '';
  bool isGenerating = false;
  TextEditingController _reasonController = TextEditingController();
bool isTagalog = false;
  String selectedDocumentType = ''; // Added variable to store selected document type
  final ScrollController _scrollController = ScrollController();

  final String token;

    

  _QRGeneratorState({required this.token});

  

  final apiUrl =
      'https://ecensusonlinerequest.online/api/v1/documentrequests/generate-qrcode';

       final apiUrl2 =
      'https://ecensusonlinerequest.online/api/v1/doc-request';

  Future<void> generateQRCodeAndRequestDocument(String documentType) async {

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
    // Call both functions here
    await generateQRCode(documentType);
    await requestDocument(documentType);

    if (qrCodeImageUrl != null && qrCodeImageUrl.isNotEmpty) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: content(context),
      );
    },
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please generate a QR code first.'),
    ),
  );
}
  }




Future<void> generateQRCode(String documentType) async {

 
  setState(() {
    isGenerating = true;
    selectedDocumentType = documentType;
  });

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'documenttype': documentType,
        'reason': _reasonController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.containsKey('error')) {
        setState(() {
          message = responseData['error'];
          qrCodeImageUrl = '';
        });
      } else {
        setState(() {
          message = responseData['response'];
          qrCodeImageUrl = responseData['image_url'];
          qrCodeGeneratedTime = DateTime.now(); // Set the QR code generation time
        });

        showMessage('You chose: $documentType');
      }
    } else {
      setState(() {
        message = 'Failed to generate QR code. Status code: ${response.statusCode}';
        qrCodeImageUrl = '';
      });
    }
  } catch (e) {
    setState(() {
      message = 'Error generating QR code: $e';
      qrCodeImageUrl = '';
    });
  } finally {
    setState(() {
      isGenerating = false;
    });
  }
}


  Future<void> requestDocument(String documentType) async {
    setState(() {
      isGenerating = true;
      selectedDocumentType = documentType; // Update selected document type
    });

      try {
      final response = await http.post(
        Uri.parse(apiUrl2),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'documenttype': documentType,
          'reason': _reasonController.text,
        }),
      );

    } catch (e) {
      setState(() {
        message = 'Error requesting document: $e';
      });
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  

void switchLanguage() {
    setState(() {
      isTagalog = !isTagalog;
    });
  }

Future<void> _showDisclaimerDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              isTagalog
                  ? 'Disclaimer at Pahayag sa Pagkapribado ng QR Code Generator'
                  : 'QR Code Generator Disclaimer and Data Privacy Notice',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(4),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  
                  _buildSectionTitle(isTagalog ? 'Mahalagang Impormasyon:' : 'Important Information:'),
_buildSectionContent(
  isTagalog
      ? 'Impormasyon ng Gumagamit:'
      : 'User Information:',
  isTagalog
      ? '''Ang iyong personal na impormasyon ay ligtas na na-encode sa loob ng lumikha ng QR Code. 
Walang hiwalay na pormularyo na kailangang punan, na nagbibigay daan sa mabilis at maaasahang proseso.'''
      : '''Your personal information is securely encoded within the generated QR Code. 
No separate form needs to be filled out, ensuring a streamlined and efficient process.''',
),

_buildSectionContent(
  isTagalog
      ? 'Pribado at Ligtas:'
      : 'Privacy and Security:',
  isTagalog
      ? '''Itinuturing namin nang seryoso ang iyong privacy. Ang iyong na-encode na impormasyon ay binubuhatan 
ng kamay na may katiyakan at ginagamit lamang para sa layunin ng pagproseso ng dokumento.'''
      : '''We take your privacy seriously. Your encoded information is handled with care and used solely for the purpose of document processing.''',
),
                  _buildSectionTitle(
                      isTagalog ? 'Paglikha ng QR Code:' : 'Generating a QR Code:'),
                  _buildSectionContent(
                    isTagalog
                        ? 'Dahilan ng Paghiling:'
                        : 'Reason for Request:',
                    isTagalog
                        ? '''Kapag humihiling ng dokumento mula sa barangay, hinihingan ka ng maikling dahilan para sa iyong kahilingan. 
  Ang impormasyong ito ay mahalaga para sa pagproseso at veripikasyon.'''
                        : '''When requesting a document from the barangay, you will be asked to provide a brief reason for your request. 
  This information is crucial for processing and verification purposes.''',
                  ),
                  _buildSectionContent(
                    isTagalog
                        ? 'Piling ng Dokumento:'
                        : 'Document Selection:',
                    isTagalog
                        ? '''Pumili ng tamang uri ng dokumento sa pamamagitan ng pagpindot sa ibinigay na mga button. 
  Ang iyong pagpili ay tumutulong sa amin na maunawaan ang layunin ng iyong kahilingan at masiguro ang tumpak na paglikha ng dokumento.'''
                        : '''Choose the appropriate document type by selecting from the provided buttons. 
  Your selection helps us understand the nature of your request and ensures accurate document generation.''',
                  ),
                  _buildSectionContent(
                    isTagalog
                        ? 'Lumikha ng QR Code:'
                        : 'Generate QR Code:',
                    isTagalog
                        ? '''Pagkatapos pumili ng uri ng dokumento, mag-aappear ang isang button na may label na "Click Me." 
  Ang pag-click sa button na ito ay maglilikha ng QR Code na naglalaman ng impormasyon na na-encode, kasama ang iyong dahilan para sa kahilingan at ang napiling uri ng dokumento.'''
                        : '''After selecting a document type, an icon button labeled "Click Me" will appear. 
  Clicking this button will generate a QR Code containing encoded information, 
  including your reason for the request and selected document type.''',
                  ),
  _buildSectionContent(
  isTagalog
      ? 'Pagkuha ng Dokumento:'
      : 'Document Retrieval:',
  isTagalog
      ? '''I-save o kunan ng screenshot ang lumikha ng QR Code. 
Ang QR code na ito ay gumaganap bilang isang natatanging tagapagtukoy para sa pagkuha ng dokumento.'''
      : '''Save or screenshot the generated QR Code. 
This QR code serves as a unique identifier for document retrieval.''',
),
                  
                  _buildSectionTitle('Note:'),
              _buildSectionContent(
                isTagalog
              ? '''Mangyaring itago ang QR Code nang pribado upang mapanatili ang iyong personal na impormasyon.'''
              : '''Please keep the generated QR Code confidential to protect your personal information.''',
              ),
                 ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.language),
                    onPressed: () {
                      setState(() {
                        switchLanguage();
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        switchLanguage();
                      });
                    },
                    child: Text(
                      isTagalog ? 'Switch to English' : 'Switch to Filipino',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.only(top: 10, bottom: 5),
    child: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildSectionContent(String content, [String subContent = '']) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subContent.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(subContent),
              )
            : SizedBox.shrink(),
      ],
    ),
  );
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('QR Code Generator'),
      backgroundColor: const Color.fromARGB(255, 192, 192, 192),
      actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showDisclaimerDialog(context);
            },
          ),
        ],
    ),
    body: Stack(
      alignment: Alignment.center,
      children: [
        // Background Image
        // Your background image widget here
        // ...

        // Content Box
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              contentBox(context),
              SizedBox(height: 5),
              Container(
                child: Text(
                  'Reminder: The Barangay opens at 8:00 AM and closes at 5:00 PM.',
                  style: TextStyle(color: Colors.black, fontSize: 10),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Generating the QR code also counts as requesting a document in the barangay',
                  style: TextStyle(color: Colors.black, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: selectedDocumentType.isNotEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                            Text(
                'Click Me',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  // Trigger both functions here
                  generateQRCodeAndRequestDocument(selectedDocumentType);
                },
                child: const Icon(Icons.qr_code),
              ),
              const SizedBox(height: 8),

            ],
          )
        : null,
  );
}

  Widget contentBox(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    documentTypeButton('Barangay ID'),
                    const SizedBox(width: 10),
                    documentTypeButton('Barangay Clearance'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    documentTypeButton('Barangay Certificate'),
                    const SizedBox(width: 10),
                    documentTypeButton('Certificate of Indigency'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Reason'),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter your reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 6, // Makes the TextField multiline
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                _reasonController.clear();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  // Show the button only when a document type is selected
 Widget content(BuildContext context) {
  return Stack(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Colors.black,
              offset: Offset(0, 10),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'QR Code Generated',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                if (qrCodeImageUrl != null && qrCodeImageUrl.isNotEmpty) {
                  launchUrl(Uri.parse(qrCodeImageUrl));
                } else {
                  showMessage('QR code link is not available.');
                }
              },
              child: Text(
                'Link: $qrCodeImageUrl',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(message),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            if (qrCodeGeneratedTime != null && DateTime.now().difference(qrCodeGeneratedTime).inMinutes >= 10)
              FloatingActionButton(
                onPressed: () {
                  // Trigger the QR code regeneration function
                  generateQRCode(selectedDocumentType);
                },
                child: const Icon(Icons.refresh),
              ),
          ],
        ),
      ),
    ],
  );
}


  Widget documentTypeButton(String documentType) {
    return ElevatedButton(
      onPressed: () {
        generateQRCode(documentType);
        _reasonController.text;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedDocumentType == documentType
            ? Colors.blue // Highlight the selected button
            : null,
      ),
      child: Text(documentType),
    );
  }

  void launchUrl(Uri uri) async {
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch $uri';
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
