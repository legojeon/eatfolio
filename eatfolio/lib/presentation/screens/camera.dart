import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
      );
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

  try {
    await _initializeControllerFuture;
    if (!mounted) return;  // <-- check mounted here before using context

    final image = await _controller!.takePicture();
    if (!mounted) return;  // <-- and again check after async call

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Picture saved to ${image.path}')),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller!);
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Camera error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
              onPressed: _takePicture,
              child: const Icon(Icons.camera_alt),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
