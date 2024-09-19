import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

double textSize = 20;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';

  String albumName = 'Media';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    child: SizedBox.expand(
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blue),
                        ),
                        onPressed: _takePhoto,
                        child: Text(
                          firstButtonText,
                          style: TextStyle(fontSize: textSize, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                ScreenshotWidget(),
                Flexible(
                  child: Container(
                    child: SizedBox.expand(
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: _recordVideo,
                        child: Text(
                          secondButtonText,
                          style: TextStyle(fontSize: textSize, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _takePhoto() async {
    try {
      final XFile? recordedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (recordedImage != null) {
        setState(() {
          firstButtonText = 'Saving in progress...';
        });
        bool? success = await GallerySaver.saveImage(recordedImage.path, albumName: albumName);
        setState(() {
          firstButtonText = success! ? 'Image saved!' : 'Failed to save image';
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  void _recordVideo() async {
    try {
      final XFile? recordedVideo = await ImagePicker().pickVideo(source: ImageSource.camera);
      if (recordedVideo != null) {
        setState(() {
          secondButtonText = 'Saving in progress...';
        });
        bool? success = await GallerySaver.saveVideo(recordedVideo.path, albumName: albumName);
        setState(() {
          secondButtonText = success! ? 'Video saved!' : 'Failed to save video';
        });
      }
    } catch (e) {
      print('Error recording video: $e');
    }
  }
}

class ScreenshotWidget extends StatefulWidget {
  @override
  _ScreenshotWidgetState createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  final GlobalKey _globalKey = GlobalKey();
  String screenshotButtonText = 'Save screenshot';

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: RepaintBoundary(
        key: _globalKey,
        child: Container(
          child: SizedBox.expand(
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pink),
              ),
              onPressed: _saveScreenshot,
              child: Text(
                screenshotButtonText,
                style: TextStyle(fontSize: textSize, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveScreenshot() async {
    setState(() {
      screenshotButtonText = 'Saving in progress...';
    });
    try {
      final RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String fullPath = '$dir/${DateTime.now().millisecondsSinceEpoch}.png';
      File capturedFile = File(fullPath);
      await capturedFile.writeAsBytes(pngBytes);

      bool? success = await GallerySaver.saveImage(capturedFile.path);
      setState(() {
        screenshotButtonText = success! ? 'Screenshot saved!' : 'Failed to save screenshot';
      });
    } catch (e) {
      print('Error saving screenshot: $e');
    }
  }
}
