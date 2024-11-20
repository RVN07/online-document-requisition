import 'package:flutter/material.dart';

class Hotline extends StatelessWidget {
  final String token;

  Hotline({required this.token});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Emergency Contacts'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  'HOTLINE NUMBERS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            buildCard(
              Colors.white,
              'HOTLINE NUMBERS',
              [
                buildContactContainer(
                  'ROADSIDE EMERGENCY ASSISTANCE IN THE CITY OF TAGUIG (REACT)',
                  [
                    '(02) 860-7006',
                    '0929-631-5924',
                    '0929-631-5740',
                    '0977-311-6359',
                  ],
                ),
                buildContactContainer(
                  'TAGUIG BUREAU OF FIRE PROTECTION',
                  [
                    '(02) 8837-0740',
                    '(02) 8837-4496',
                    '0906-211-0919',
                  ],
                ),
                buildContactContainer(
                  'PHILIPPINE NATIONAL POLICE',
                  [
                    '(02) 8642-3582',
                    '0998-598-7932',
                  ],
                ),
              ],
            ),
            buildCard(
              Colors.white,
              'OTHER CONTACTS',
              [
                buildContactContainer('TAGUIG RESCUE', ['0919-070-3112']),
                buildContactContainer('COMMAND CENTER', ['(02) 8789-3200']),
                buildContactContainer('DOCTOR ON CALL', ['0919-079-9112']),
                buildContactContainer(
                  'MENTAL HEALTH SUPPORT TELECONSULTATION',
                  ['0929-521-8373'],
                ),
                buildContactContainer(
                  'TAGUIG-PATEROS DISTRICT HOSPITAL',
                  [
                    'Booking of Appointment: 0960-371-2880',
                    '🌐 www.facebook.com/TPDHospital',
                    '✉ taguigpaterosdistricthospital@ymail.com',
                  ],
                ),
                buildContactContainer('PEDIA', ['Contact: 0961-704-4365']),
                buildContactContainer('SURGERY', ['Contact: 0961-704-4359']),
                buildContactContainer(
                  'INTERNAL MEDICINE',
                  ['Contact: 0961-704-4384'],
                ),
                buildContactContainer('OB-GYNE', ['Contact: 0961-704-4383']),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.black,
          ),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget buildCard(Color color, String title, List<Widget> contacts) {
    return Card(
      color: color,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSection(title),
            ...contacts,
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildContactContainer(String title, List<String> contacts) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ...contacts.map(
            (contact) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.contact_emergency, color: Colors.red),
                  SizedBox(width: 5),
                  Text(
                    contact,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
