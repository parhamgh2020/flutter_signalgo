import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when the device reports any network connectivity. Used both for the
/// offline banner and as the trigger to fall back from Appwrite Realtime to
/// polling (and back) in feature repositories.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity().then(_hasConnection);
  yield* connectivity.onConnectivityChanged.map(_hasConnection);
});

bool _hasConnection(List<ConnectivityResult> results) {
  return results.any((r) => r != ConnectivityResult.none);
}
