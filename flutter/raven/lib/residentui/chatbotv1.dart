import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:raven/residentui/hotline.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(
    this.text,
    this.isUser,
  );
}

class ChatScreen extends StatefulWidget {
  final String token;

  ChatScreen({required this.token});

  @override
  _ChatScreenState createState() => _ChatScreenState(token: token);
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<ChatMessage> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();
  final String token;
  bool isTagalog = false;

  _ChatScreenState({required this.token});

  @override
  void initState() {
    super.initState();
    // Add a welcome message
    addMessage("Chatbot: Welcome! How can I assist you today?");
  }

  void handleButtonTap(String message) {
    addMessage('$message', isUser: true);
    sendChatToAPI(message); // Send user message to Laravel API
  }

  void addMessage(String message, {bool isUser = false}) {
    setState(() {
      _chatHistory.add(ChatMessage(message, isUser));
    });

    if (!isUser) {
      // If the message is from the chatbot, handle the response
      _handleChatbotResponse(message);
    }
}

  void sendChatToAPI(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://ecensusonlinerequest.online/api/v1/process-message'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String botResponse = responseData['response'] ?? 'No response';
        String action = responseData['action'] ?? '';

        print('API Response: $botResponse');
        print('Action: $action');

        addMessage('Chatbot: $botResponse');

           if (action == 'show_hotline') {
             showDialog(
               context: context,
              builder: (context) => Hotline(
                  token: token
                ),
              );
               print('Opening QR Code Generator');
             } else {
                print('Unknown action: $action');
              }
      } else {
        print('Failed to send message to API. Status code: ${response.statusCode}');
        addMessage('Chatbot: Sorry, something went wrong. Please try again.');
      }
    } catch (e) {
      print('Error sending message to API: $e');
      addMessage('Chatbot: Sorry, something went wrong. Please try again.');
    }
  }
// Create a ScrollController instance
Widget _buildButtonBar() {
  // Create two ScrollController instances
  final scrollController1 = ScrollController();
  final scrollController2 = ScrollController();

  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 3,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Scrollbar(
          thumbVisibility: true,
          thickness: 15.0, // Set this to true to always show the scrollbar
          controller: scrollController1, // Assign the first ScrollController to the first Scrollbar
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: scrollController1, // Assign the first ScrollController to the first scrollable widget
            child: Row(
              children: [
                _buildButtonColumn([
                  'How to Request a Document?',
                  'What is the System Scope?',
                 'Give me the Barangay Hotline',
                ]),
                _buildButtonColumn([
                  'What are the System Benefits?',
                  'Where is the Barangay Hall located?',
                  'What Technologies Used in this system?',

                ]),
                
                
                SizedBox(height: 8),
                _buildButtonColumn([
                  'How was the system created?',
                  'I''m a New Resident, when I can get documents from the barangay hall?',
                  'kailan ko makukuha ang aking document request?',
                ]),
                
                _buildButtonColumn([
                 'Sino-sino yung gumawa ng system na to?',
                 'Ilang araw ang proseso ng akin pagrerequest sa sistema?',
                'Ano ang mga benepisyo ng paggamit ng sistema?',
                ]), // Adjust the spacing between rows as needed
         //       _buildButtonColumn([]),

           //     _buildButtonColumn(['','']),
              ],
            ),
          ),
        ),
        SizedBox(height: 16), // Add some spacing between the two scrollable rows
      ],
    ),
  );
}

Widget _buildButtonColumn(List<String> buttonTexts) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: buttonTexts.map((buttonText) {
      return _buildButton(buttonText, Colors.greenAccent);
    }).toList(),
  );
}

Widget _buildButton(String buttonText, Color buttonColor) {
  return Padding(
    padding: EdgeInsets.all(9),
    child: ElevatedButton(
      onPressed: () => handleButtonTap(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.black,
        padding: EdgeInsets.all(9),
        minimumSize: Size(0, 40), // Adjust the minimum button size
      ),
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 10), // Adjust the font size as needed
      ),
    ),
  );
}

Widget _buildButtonRow(List<String> buttonTexts) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: buttonTexts.map((buttonText) {
      return _buildButton(buttonText, Colors.greenAccent);
    }).toList(),
  );
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
                  ? 'Disclaimer at Pahayag sa Chatbot'
                  : 'Chatbot Disclaimer and Data Privacy Notice',
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
                  //    _buildSectionTitle(isTagalog ? 'Pagbati:' : 'Welcome:'),
                      _buildSectionContent(
                        isTagalog
                            ? 'Maligayang pagdating sa Barangay Central Bicutan Assistance Chatbot.'
                            : 'Welcome to the Barangay Central Bicutan Assistance Chatbot.',
                      ),
                      _buildSectionContent(
                        isTagalog ? 'Paalala at Pagsang-ayon:' : 'Disclaimer and Acknowledgment:',
                        isTagalog
                            ? 'Ang platapormang ito ay idinisenyo upang magbigay ng pangkalahatang impormasyon at suporta kaugnay ng mga bagay sa barangay.'
                            : 'This platform is designed to provide general information and support related to barangay inqueries.',
                      ),
                      _buildSectionContent(
                        isTagalog
                            ? 'Seguridad at Pagiging Pribado:'
                            : 'Security and Confidentiality:',
                        isTagalog
                            ? 'Bagamat nangunguna kami sa seguridad at pagiging pribado ng iyong impormasyon.'
                            : 'While we prioritize the security and confidentiality of your information.',
                      ),
                      _buildSectionContent(
                        isTagalog
                            ? 'Iwasang Ibigay ang Sensitive na Impormasyon:'
                            : 'Avoid Sensitive Information:',
                        isTagalog
                            ? 'Bagamat narito kami upang tulungan ka, iwasang ibahagi ang sensitibong personal na impormasyon o opisyal na dokumento sa pamamagitan ng chat na ito.'
                            : 'While we are here to assist you, refrain from sharing sensitive personal information or official documents through this chat. The purpose of this platform is to provide general information and guidance.',
                      ),
                      _buildSectionContent(
                        isTagalog
                            ? 'Proseso ng Veripikasyon:'
                            : 'Verification Process:',
                        isTagalog
                            ? 'Sa kahilingan ng anumang opisyal na dokumento, maaaring mayroong proseso ng veripikasyon ang opisina ng barangay upang mapanatili ang seguridad ng iyong impormasyon. Siguruhing ikaw ay pamilyar at sumusunod sa anumang mga prosedyur na ito.'
                            : 'In case of any official document requests, the barangay office may have a verification process in place to safeguard your information. Ensure that you are aware of and comply with any such procedures.',
                      ),
                      _buildSectionContent(
                        isTagalog
                        ? 'Limitasyon: '
                        :  'Limitation: ',
                        isTagalog
                            ? 'Sa pakikipag-usap sa chatbot na ito, kinikilala at nauunawaan mo ang mga limitasyon ng plataporma na ito sa pag-handle ng opisyal na dokumento.'
                            : 'By engaging in this chatbot, you acknowledge and understand the limitations of this platform in handling official documents.',
                      ),
                      _buildSectionContent(
                        isTagalog
                        ? 'Pananagutan at Pagiging Kompidensyal'
                        : 'Responsibility and Confidentiality',
                        isTagalog
                            ? 'Ang opisina ng barangay ay nangangako na maging responsable sa seguridad at pagiging pribado ng impormasyon na iyong ibinabahagi sa chatbot na ito.'
                            : 'The barangay office is committed to taking responsibility for the security and confidentiality of the information you share through this chatbot.',
                      ),
                      _buildSectionContent(
                        isTagalog
                            ? 'Salamat sa iyong pang-unawa at kooperasyon.'
                            : 'Thank you for your understanding and cooperation.',
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
      title: Text('Chatbot'),
      automaticallyImplyLeading: false,
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
    body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
          color: Colors.grey[200],
          ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
                        itemCount: _chatHistory.length,
            itemBuilder: (context, index) {
                              ChatMessage chatMessage = _chatHistory[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: chatMessage.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: chatMessage.isUser
                            ? Colors.blue[400]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        chatMessage.text,
                        style: TextStyle(
                          color: chatMessage.isUser
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildButtonBar(),
          ],
        ),
          ),
        );
        }

  // Define the callback function
  void _handleChatbotResponse(String response) {
    // Handle the chatbot's response here
    print('Chatbot Response: $response');
    // You can add more logic based on the chatbot's response
  }
  
}
