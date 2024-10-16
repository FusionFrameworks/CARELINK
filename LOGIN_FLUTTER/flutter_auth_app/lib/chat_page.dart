import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> sendMessage(String message) async {
    final url = Uri.parse('http://10.0.2.2:5000/chat'); // Replace with your Flask server URL

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'message': message,
          'language': 'en', // Change to 'kn' for Kannada or 'hi' for Hindi
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _response = data['response'];
        });
      } else {
        setState(() {
          _response = 'Failed to get response';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Symptom Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter your symptoms'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                sendMessage(_controller.text);
              },
              child: Text('Send'),
            ),
            SizedBox(height: 16),
            Text(
              'Response: $_response',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
