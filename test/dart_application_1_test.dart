import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dart_native_demo/dart_native_demo.dart';

late CppLib cpp;
late GoLib go;

void main() {
  setUpAll(() {
    final projectRoot = p.dirname(p.dirname(Platform.script.toFilePath()));
    final libsDir = p.join(projectRoot, 'native', 'libs');
    cpp = CppLib(libsDir);
    go = GoLib(libsDir);
  });

  group('CppLib', () {
    test('add', () {
      expect(cpp.add(3, 4), equals(7));
      expect(cpp.add(0, 0), equals(0));
      expect(cpp.add(-1, 1), equals(0));
    });
  });

  group('GoLib', () {
    test('multiply', () {
      expect(go.multiply(3, 4), equals(12));
      expect(go.multiply(0, 99), equals(0));
    });

    test('fibonacci', () {
      expect(go.fibonacci(0), equals(0));
      expect(go.fibonacci(1), equals(1));
      expect(go.fibonacci(10), equals(55));
      expect(go.fibonacci(20), equals(6765));
    });
  });
}
