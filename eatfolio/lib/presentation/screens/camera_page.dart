import 'dart:io';
import 'package:eatfolio/presentation/screens/register_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // compute 함수를 사용하기 위해 추가
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/provider_nav.dart';
import '../widgets/buttons.dart';

/// 현재 위치를 가져오는 함수
Future<Map<String, double>?> _getCurrentLocation() async {
  try {
    // 위치 권한 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return {'latitude': position.latitude, 'longitude': position.longitude};
  } catch (e) {
    debugPrint('Location error: $e');
    return null;
  }
}

/// 이미지 처리를 위한 최상위 함수 (compute에서 사용하기 위함)
///
/// 이 함수는 별도의 Isolate에서 실행되어 UI 스레드를 차단하지 않습니다.
/// [params] 맵에는 'imagePath'와 'cropSize'가 포함되어야 합니다.
Future<Uint8List> _processAndCropImage(Map<String, dynamic> params) async {
  final String imagePath = params['imagePath'];
  final int cropSize = params['cropSize'];

  final bytes = await File(imagePath).readAsBytes();
  // 이미지 라이브러리를 사용하여 바이트 데이터를 이미지 객체로 디코딩
  final decodedImage = img.decodeImage(bytes);

  if (decodedImage == null) {
    throw Exception('Failed to decode image');
  }

  // 이미지 중앙을 기준으로 정사각형으로 자를 좌표 계산
  final x = (decodedImage.width - cropSize) ~/ 2;
  final y = (decodedImage.height - cropSize) ~/ 2;

  final croppedImage = img.copyCrop(
    decodedImage,
    x: x,
    y: y,
    width: cropSize,
    height: cropSize,
  );

  // 크롭된 이미지를 바이트로 인코딩하여 반환
  return Uint8List.fromList(img.encodeJpg(croppedImage));
}

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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], // 사용 가능한 카메라 목록의 첫 번째 카메라 사용
          ResolutionPreset.medium,
          enableAudio: false, // 오디오는 사용하지 않음
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        _initializeControllerFuture = _controller!.initialize();
        await _initializeControllerFuture;

        if (mounted && !_isDisposed) {
          setState(() {});
        }
      } else {
        debugPrint('No cameras found on device.');
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    // 컨트롤러가 초기화되지 않았거나, 사진 찍는 중이거나, 위젯이 dispose된 경우 아무것도 하지 않음
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isDisposed) {
      return;
    }
    if (_isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    // 화면 너비를 미리 가져옴 (비동기 호출 전에)
    final screenWidth = MediaQuery.of(context).size.width.toInt();

    try {
      await _initializeControllerFuture;
      if (!mounted || _isDisposed) return;

      // ✅ 안정적인 촬영을 위해 프리뷰를 일시 정지
      await _controller?.pausePreview();

      final image = await _controller!.takePicture();

      // 현재 위치 정보 가져오기
      final locationData = await _getCurrentLocation();

      // ✅ compute를 사용하여 무거운 이미지 처리를 백그라운드에서 실행
      final croppedImageBytes = await compute(_processAndCropImage, {
        'imagePath': image.path,
        'cropSize': screenWidth,
      });

      if (!mounted || _isDisposed) return;

      // 앱 전용 외부 저장소에 크롭된 이미지 저장
      final Directory? appDir = await getExternalStorageDirectory();
      if (appDir == null) {
        throw Exception('앱 전용 외부 저장소 경로를 찾을 수 없습니다.');
      }

      // 고유한 파일명으로 저장
      final String fileName =
          'eatfolio_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String croppedPath = '${appDir.path}/$fileName';
      await File(croppedPath).writeAsBytes(croppedImageBytes);

      // 원본 임시 파일 삭제
      try {
        await File(image.path).delete();
      } catch (_) {
        // 삭제 실패 시 에러를 무시하고 진행
      }

      // 결과물을 다음 페이지로 전달 (위치정보 포함)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(
            imagePath: croppedPath,
            latitude: locationData?['latitude'],
            longitude: locationData?['longitude'],
          ),
        ),
      );
    } catch (e) {
      if (!mounted || _isDisposed) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      // ✅ 모든 작업이 끝나면 프리뷰를 재개하고 상태를 초기화
      if (!_isDisposed && _controller?.value.isInitialized == true) {
        await _controller?.resumePreview();
      }
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  void _goBackToHome() {
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setSelectedIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final marginHeight = (screenHeight - screenWidth) / 2;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null) {
            final previewSize = _controller!.value.previewSize!;
            return Stack(
              children: [
                // 전체 화면 카메라 프리뷰
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
                // 상단 반투명 영역
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: marginHeight,
                    width: double.infinity,
                    color: Colors.black54,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 330.0, top: 20.0),
                        child: Back(onPressed: _goBackToHome),
                      ),
                    ),
                  ),
                ),
                // 하단 반투명 영역
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
            // 로딩 중 표시
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
