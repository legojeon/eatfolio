import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/buttons.dart';
import '../../core/fonts.dart'; 

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
              Text(
                'Register meal',
                style: AppFonts.heading3,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(widget.imagePath),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // Star rating
            Center(
              child: Column(
                children: [
                  Text('Rating', style: AppFonts.bodyLarge),
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
              style: AppFonts.bodyMedium,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your thoughts...',
                hintStyle: AppFonts.bodyMedium.copyWith(color: Colors.grey),
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
                    SnackBar(content: Text('Submitted!', style: AppFonts.bodyMedium)),
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
