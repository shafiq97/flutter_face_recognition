import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => this._cameraController;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => this._cameraRotation;

  String? _imagePath;
  String? get imagePath => this._imagePath;

  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0; // default to back camera

  Future<void> initialize() async {
    if (_cameraController != null) return;
    CameraDescription description = await _getCameraDescription();
    await _setupCameraController(description: description);
    this._cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
  }

  Future<void> toggleCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
    await initialize();
  }

  Future<CameraDescription> _getCameraDescription() async {
    _availableCameras = await availableCameras();
    return _availableCameras[_currentCameraIndex];
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    this._cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController?.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<XFile?> takePicture() async {
    assert(_cameraController != null, 'Camera controller not initialized');
    await _cameraController?.stopImageStream();
    XFile? file = await _cameraController?.takePicture();
    _imagePath = file?.path;
    return file;
  }

  Size getImageSize() {
    assert(_cameraController != null, 'Camera controller not initialized');
    assert(
        _cameraController!.value.previewSize != null, 'Preview size is null');
    return Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );
  }

  dispose() async {
    await this._cameraController?.dispose();
    this._cameraController = null;
  }
}
