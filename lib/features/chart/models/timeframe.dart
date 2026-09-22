enum Timeframe { h1, h4, d1, w1 }

extension TimeframeApi on Timeframe {
  String get apiValue => switch (this) {
        Timeframe.h1 => '1h',
        Timeframe.h4 => '4h',
        Timeframe.d1 => '1d',
        Timeframe.w1 => '1w',
      };

  static Timeframe fromApiValue(String value) => switch (value) {
        '1h' => Timeframe.h1,
        '4h' => Timeframe.h4,
        '1w' => Timeframe.w1,
        _ => Timeframe.d1,
      };

  Duration get candleSpan => switch (this) {
        Timeframe.h1 => const Duration(hours: 1),
        Timeframe.h4 => const Duration(hours: 4),
        Timeframe.d1 => const Duration(days: 1),
        Timeframe.w1 => const Duration(days: 7),
      };
}
