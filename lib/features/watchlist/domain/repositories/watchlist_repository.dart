import '../../../../core/error/result.dart';

abstract class WatchlistRepository {
  Future<Result<Set<String>>> fetchWatchlistSymbols();
  Future<Result<void>> add(String symbol);
  Future<Result<void>> remove(String symbol);

  /// Live updates so a watchlist change on another device reflects here.
  Stream<Set<String>> watch();
}
