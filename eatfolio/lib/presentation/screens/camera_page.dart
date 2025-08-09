import 'package:eatfolio/presentation/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../core/provider_nav.dart';
import '../widgets/buttons.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? _cameras;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() {});
    } else {
      debugPrint('No cameras found on device.');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isTakingPicture) return;
    _isTakingPicture = true;

    // Capture screenWidth early (before any await)
    final screenWidth = MediaQuery.of(context).size.width.toInt();

    try {
      await _initializeControllerFuture;
      if (!mounted) return;

      final image = await _controller!.takePicture();

      // Pause preview to avoid preview buffer backlog while processing
      try {
        await _controller?.pausePreview();
      } catch (_) {}

      // Read image bytes
      final bytes = await File(image.path).readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Determine crop size: screenWidth or fallback to shortest side
      final cropSize =
          screenWidth <= decodedImage.width &&
              screenWidth <= decodedImage.height
          ? screenWidth
          : (decodedImage.width < decodedImage.height
                ? decodedImage.width
                : decodedImage.height);

      final x = (decodedImage.width - cropSize) ~/ 2;
      final y = (decodedImage.height - cropSize) ~/ 2;

      final croppedImage = img.copyCrop(
        decodedImage,
        x: x,
        y: y,
        width: cropSize,
        height: cropSize,
      );

      final directory = Directory.systemTemp;
      final croppedPath =
          '${directory.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(imagePath: croppedFile.path),
        ),
      );

      // Resume preview when returning to this page
      try {
        await _controller?.resumePreview();
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      _isTakingPicture = false;
    }
  }

  void _goBackToHome() {
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setSelectedIndex(0); // Home 페이지 인덱스
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final marginHeight = (screenHeight - screenWidth) / 2;

    return Scaffold(
      extendBodyBehindAppBar: true, // allow full screen usage
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final previewSize = _controller!.value.previewSize!;
                  return Stack(
                    children: [
                      // Full-screen camera preview
                      Container(
                        color: Colors.black,
                        width: double.infinity,
                        height: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: previewSize.height,
                            height: previewSize.width,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),

                      // Top translucent margin
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: marginHeight,
                          width: double.infinity,
                          color: Colors.black54,
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 330.0,
                                top: 20.0,
                              ),
                              child: Back(onPressed: _goBackToHome),
                            ),
                          ),
                        ),
                      ),

                      // Bottom translucent margin
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: marginHeight,
                          width: double.infinity,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Camera error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: _controller == null
          ? null
          : CameraButton(onPressed: _takePicture),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
