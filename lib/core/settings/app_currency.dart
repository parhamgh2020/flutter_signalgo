enum AppCurrency { usd, irt }

extension AppCurrencyFormat on AppCurrency {
  /// USD → IRT (Toman) is genuinely a live market rate; a production build
  /// should source it from the backend's market-overview document rather
  /// than a constant. This illustrative rate keeps the mock/offline path
  /// functional without a network call.
  static const double _usdToTomanRate = 60000;

  String format(double usdPrice, {required bool persianDigits}) {
    final value = switch (this) {
      AppCurrency.usd => usdPrice,
      AppCurrency.irt => usdPrice * _usdToTomanRate,
    };

    final formatted = _formatCompact(value);
    final prefixed = switch (this) {
      AppCurrency.usd => '\$$formatted',
      AppCurrency.irt => '$formatted تومان',
    };
    return prefixed;
  }

  String _formatCompact(double value) {
    if (value >= 1) {
      return value.toStringAsFixed(value >= 1000 ? 0 : 2).replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (m) => ',',
          );
    }
    return value.toStringAsPrecision(3);
  }
}
