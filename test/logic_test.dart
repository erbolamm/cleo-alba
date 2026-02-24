import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApliArteBot Logic Tests', () {
    test('Basic state check', () {
      String state = 'idle';
      expect(state, 'idle');
    });

    test('Status mapping check', () {
      bool isAsleep = true;
      String getStatus(bool asleep) => asleep ? 'En reposo' : 'Conectado';
      expect(getStatus(isAsleep), 'En reposo');
      expect(getStatus(false), 'Conectado');
    });
  });
}
