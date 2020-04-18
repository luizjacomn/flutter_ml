import 'package:flutter/material.dart';

import 'package:pet_detector/pages/detector_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Detector',
      theme: ThemeData.dark(),
      home: DetectorPage(),
    );
  }
}
