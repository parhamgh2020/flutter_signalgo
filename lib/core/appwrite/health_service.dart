import 'package:http/http.dart' as http;

import 'appwrite_config.dart';

enum BackendStatus { checking, online, offline }

/// Pings the self-hosted Appwrite instance's public `/health` endpoint —
/// used by Settings > About as a lightweight "is the backend reachable"
/// indicator, independent of whether the user is authenticated.
class HealthService {
  const HealthService(this._config);

  final AppwriteConfig _config;

  Future<BackendStatus> ping() async {
    try {
      final base = _config.endpoint.endsWith('/')
          ? _config.endpoint.substring(0, _config.endpoint.length - 1)
          : _config.endpoint;
      final res = await http.get(Uri.parse('$base/health')).timeout(const Duration(seconds: 5));
      return res.statusCode == 200 ? BackendStatus.online : BackendStatus.offline;
    } catch (_) {
      return BackendStatus.offline;
    }
  }
}
