import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalgo/l10n/generated/app_localizations.dart';

Widget _appWithLocale(Locale locale) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (context) {
        final direction = Directionality.of(context);
        return Scaffold(
          body: Row(
            children: [
              Text(direction == TextDirection.rtl ? 'rtl' : 'ltr'),
              Text(AppLocalizations.of(context).navSymbols),
            ],
          ),
        );
      },
    ),
  );
}

void main() {
  testWidgets('fa locale renders with RTL directionality', (tester) async {
    await tester.pumpWidget(_appWithLocale(const Locale('fa')));
    await tester.pumpAndSettle();

    expect(find.text('rtl'), findsOneWidget);
    expect(find.text('نمادها'), findsOneWidget);
  });

  testWidgets('en locale renders with LTR directionality', (tester) async {
    await tester.pumpWidget(_appWithLocale(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('ltr'), findsOneWidget);
    expect(find.text('Symbols'), findsOneWidget);
  });
}
