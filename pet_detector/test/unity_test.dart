import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Testing class name extract', () {
    var className = '0 Dog';
    var regex = RegExp('\([A-Z]\)\\w+');
    var matcher = regex.firstMatch(className);
    
    expect(matcher.group(0), 'Dog');
  });
}
