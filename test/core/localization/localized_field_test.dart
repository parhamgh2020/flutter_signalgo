import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalgo/core/localization/localized_field.dart';

void main() {
  group('LocalizedFieldLocale.pick', () {
    test('returns the fa field when locale is fa and fa is non-empty', () {
      expect(const Locale('fa').pick(en: 'Hello', fa: 'سلام'), 'سلام');
    });

    test('falls back to en when fa is null', () {
      expect(const Locale('fa').pick(en: 'Hello', fa: null), 'Hello');
    });

    test('falls back to en when fa is empty or whitespace', () {
      expect(const Locale('fa').pick(en: 'Hello', fa: '   '), 'Hello');
    });

    test('returns the en field when locale is en regardless of fa', () {
      expect(const Locale('en').pick(en: 'Hello', fa: 'سلام'), 'Hello');
    });
  });
}
