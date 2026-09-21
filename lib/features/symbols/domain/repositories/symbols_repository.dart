import '../../../../core/error/result.dart';
import '../entities/symbol_entity.dart';

enum SymbolSort { marketCap, gainers, losers }

class SymbolsPage {
  const SymbolsPage({required this.items, required this.nextCursor});

  final List<SymbolEntity> items;

  /// Appwrite document-id cursor for `Query.cursorAfter`; null means no
  /// further pages.
  final String? nextCursor;
}

abstract class SymbolsRepository {
  Future<Result<SymbolsPage>> fetchSymbols({
    int limit = 30,
    String? cursor,
    SymbolSort sort = SymbolSort.marketCap,
    String? search,
  });

  /// Live price/change updates via Appwrite Realtime. Implementations
  /// handle reconnect internally; callers that need a polling fallback
  /// should pair this with periodic [fetchSymbols] calls when this stream
  /// goes quiet (see `SymbolsListController`).
  Stream<SymbolEntity> watchPriceUpdates();
}
