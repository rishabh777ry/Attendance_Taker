import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_taker/main.dart';

void main() {
  test('Basic addition test', () {
    final result = add(1, 2);
    expect(result, 3);
  });
}

add(int i, int j) {
  int a;
  a = i + j;
  return a;
}
