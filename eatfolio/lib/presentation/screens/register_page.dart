import 'dart:io';
import 'package:eatfolio/core/provider_nav.dart';
import 'package:eatfolio/presentation/screens/home_page.dart';
import 'package:eatfolio/presentation/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
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

  Future<void> _submitData() async {
    try {
      // Use timestamp for record_id
      String recordId = DateTime.now().millisecondsSinceEpoch.toString();

      // Get current user_id (or "guest" if not logged in)
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "guest";

      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection('Photos').doc(recordId).set({
        'record_id': recordId,
        'user_id': userId,
        'rating': _rating,
        'memo': _memoController.text.trim(),
        'image_path': widget.imagePath,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Show "Submitted" Snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submitted')));

      // Small delay so Snackbar is visible before navigation
      await Future.delayed(const Duration(milliseconds: 300));

      // Switch to Home tab
      if (mounted) {
        context.read<NavigationProvider>().setSelectedIndex(0);

        // Navigate to main NavBar container
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ), // <-- your main scaffold with NavBar
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving to database: $e')));
    }
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
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Back(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              // Title
              Text('Register meal', style: AppFonts.heading3),
            ],
          ),
        ),
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScope.of(context).unfocus(); // hide keyboard
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image preview
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

              // Submit button
              Center(
                child: ButtonWide(text: 'Submit', onPressed: _submitData),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
