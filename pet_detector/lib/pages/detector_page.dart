import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class DetectorPage extends StatefulWidget {
  @override
  _DetectorPageState createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> {
  bool _isLoading;
  File _image;
  List _output;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<String> _loadModel() async {
    return await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future _captureImage() async {
    var file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (file == null) return null;

    setState(() {
      _isLoading = true;
      _image = file;
    });

    _classifyImage(file);
  }

  Future _chooseFile() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;

    setState(() {
      _isLoading = true;
      _image = file;
    });

    _classifyImage(file);
  }

  Future _classifyImage(File file) async {
    var output = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    Future.delayed(Duration(milliseconds: 250)).then((_) {
      setState(() {
        _isLoading = false;
        _output = output;
      });
    });
  }

  String get _className {
    var className = _output[0]['label'];
    var regex = RegExp('\([A-Z]\)\\w+');
    var matcher = regex.firstMatch(className);
    return matcher.group(0);
  }

  String get _confidenceLevel {
    double confidence = _output[0]['confidence'];

    return (confidence * 100).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Detector'),
      ),
      body: Container(
        width: size.width,
        child: _isLoading
            ? const Center(child: const CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _image != null
                      ? Image.file(
                          _image,
                          height: size.height / 2,
                          fit: BoxFit.fitHeight,
                        )
                      : Container(),
                  const SizedBox(height: 8.0),
                  _output != null
                      ? Chip(
                          backgroundColor: Theme.of(context).accentColor,
                          label: Text(
                            'It\'s a $_className'.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const Text('Pick an image on your gallery'),
                  if (_output != null)
                    Text(
                      'Confidence level: $_confidenceLevel%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'Select image source',
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.add_photo_alternate),
            labelWidget:
                const Text('Gallery', style: TextStyle(fontSize: 16.0)),
            onTap: _chooseFile,
          ),
          SpeedDialChild(
            child: Icon(Icons.add_a_photo),
            labelWidget: const Text('Camera', style: TextStyle(fontSize: 16.0)),
            onTap: _captureImage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
