import 'package:EatSalad/utils/card_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Card Utils', () {
    test('validates CVV', () {
      expect(CardUtils.validCVV(''), false);
      expect(CardUtils.validCVV('A'), false);
      expect(CardUtils.validCVV('AV'), false);
      expect(CardUtils.validCVV('OVM'), true);
      expect(CardUtils.validCVV('OVMF'), true);
      expect(CardUtils.validCVV('OVMOO'), false);
      expect(CardUtils.validCVV('OVMOOZ'), false);
    });
    test('validates card number', () {
      expect(CardUtils.validCreditCard(''), false);
      expect(CardUtils.validCreditCard('A'), false);
      expect(CardUtils.validCreditCard('4'), false);
      expect(CardUtils.validCreditCard('5235235'), false);
      expect(CardUtils.validCreditCard('52352353243252532523532523532532532'),
          false);

      expect(CardUtils.validCreditCard('4242424242424242'), true);
      expect(CardUtils.validCreditCard('5555555555554444'), true);
      expect(CardUtils.validCreditCard('5200828282828210'), true);
      expect(CardUtils.validCreditCard('378282246310005'), true);
      expect(CardUtils.validCreditCard('6011111111111117'), true);
      expect(CardUtils.validCreditCard('6011111111111117'), true);
      expect(CardUtils.validCreditCard('3056930009020004	'), true);
      expect(CardUtils.validCreditCard('3566002020360505'), true);
      expect(CardUtils.validCreditCard('6200000000000005'), true);
      expect(CardUtils.validCreditCard('4000004840008001'), true);
      expect(CardUtils.validCreditCard('4000004840008001'), true);
    });

    test('validates expiry date', () {
      expect(CardUtils.validDate('02/80'), equals(null));
      expect(CardUtils.validDate('05/80'), equals(null));

      expect(CardUtils.validDate('33/40'), isNot(null));
      expect(CardUtils.validDate('02/3000'), isNot(null));
      expect(CardUtils.validDate('02/3000'), isNot(null));
      expect(CardUtils.validDate(''), isNot(null));
      expect(CardUtils.validDate('0012/2024'), isNot(null));
    });
  });
}
