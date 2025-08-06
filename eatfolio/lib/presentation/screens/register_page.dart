import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/buttons.dart'; // Update path if needed

class RegisterPage extends StatefulWidget {
  final String imagePath;

  const RegisterPage({super.key, required this.imagePath});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _rating = 0;
  final TextEditingController _memoController = TextEditingController();

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 32,
      ),
      onPressed: () {
        setState(() {
          _rating = index;
        });
      },
    );
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Back button on the left
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Back(
                    onPressed: () {
                      Navigator.pop(context); // Return to CameraPage
                    },
                  ),
                ),
              ),

              // Center title
              const Text(
                'Register meal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(widget.imagePath),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // Star rating
            const Text('Rate this moment:', style: TextStyle(fontSize: 18)),
            Row(
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            const SizedBox(height: 24),

            // Memo input
            const Text('Memo:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _memoController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your thoughts...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit button (placeholder)
            ButtonWide(
              text: 'Submit',
              onPressed: () {
                print('Image path: ${widget.imagePath}');
                print('Rating: $_rating');
                print('Memo: ${_memoController.text}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Submitted!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
