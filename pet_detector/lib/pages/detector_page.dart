import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class DetectorPage extends StatefulWidget {
  @override
  _DetectorPageState createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> {
  bool _isLoading;
  File _file;
  List _output;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<String> loadModel() async {
    return await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future chooseFile() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _isLoading = true;
      _file = image;
    });

    classifyImage(image);
  }

  Future classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Detector'),
      ),
      body: Container(
        child: _isLoading
            ? const Center(child: const CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _file != null ? Image.file(_file) : Container(),
                  const SizedBox(height: 8.0),
                  _output != null
                      ? Chip(
                          backgroundColor: Theme.of(context).accentColor,
                          label: Text(
                            'It\'s a $_className'.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const Text('Pick an image on your gallery'),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_photo_alternate),
        onPressed: chooseFile,
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
