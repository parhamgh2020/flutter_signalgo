/// Backend configuration, resolved from --dart-define values (or a .env
/// loader wired up at startup). Never hardcode endpoint/project values here —
/// the defaults below only make `flutter run` work out of the box against a
/// local self-hosted Appwrite instance.
class AppwriteConfig {
  const AppwriteConfig({
    required this.endpoint,
    required this.projectId,
    required this.databaseId,
    required this.selfSigned,
  });

  factory AppwriteConfig.fromEnvironment() {
    return const AppwriteConfig(
      endpoint: String.fromEnvironment(
        'APPWRITE_ENDPOINT',
        defaultValue: 'http://app.abrahamgroup.ir/v1',
      ),
      projectId: String.fromEnvironment(
        'APPWRITE_PROJECT_ID',
        defaultValue: '6aa52714003b1dc464c1',
      ),
      databaseId: String.fromEnvironment(
        'APPWRITE_DATABASE_ID',
        defaultValue: 'market_data',
      ),
      selfSigned: bool.fromEnvironment(
        'APPWRITE_SELF_SIGNED',
        defaultValue: true,
      ),
    );
  }

  final String endpoint;
  final String projectId;
  final String databaseId;

  /// Set to true for staging instances presenting a self-signed certificate.
  /// Ignored on web (the browser owns TLS trust there).
  final bool selfSigned;
}

/// Appwrite database/collection identifiers, matching the schema documented
/// in README.md. Kept separate from [AppwriteConfig] since these are schema
/// facts, not per-environment configuration.
class AppwriteCollections {
  AppwriteCollections._();

  static const symbols = 'symbols';
  static const analyses = 'analyses';
  static const news = 'news';
  static const watchlist = 'watchlist';
}
