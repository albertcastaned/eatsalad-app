import 'package:EatSalad/utils/location_utils.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Location Utils',
    () {
      test(
        'calculates correctly',
        () {
          expect(
            distanceBetweenPoints(0, 0, 5, 5).toStringAsFixed(3),
            (7.071068).toStringAsFixed(3),
          );
        },
      );
    },
  );
}
