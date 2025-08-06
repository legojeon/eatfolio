import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/buttons.dart'; 

class RegisterPage extends StatefulWidget {
  final String imagePath;

  const RegisterPage({super.key, required this.imagePath});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _rating = 0;
  final TextEditingController _memoController = TextEditingController();

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
            Center(
              child: Column(
                children: [
                  const Text('Rating', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  StarRatingButton(
                    rating: _rating,
                    onRatingChanged: (newRating) {
                      setState(() {
                        _rating = newRating;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Memo input
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
            Center(
              child: ButtonWide(
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
            ),
          ],
        ),
      ),
    );
  }
}
