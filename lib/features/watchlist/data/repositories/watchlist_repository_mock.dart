import 'dart:async';

import '../../../../core/error/result.dart';
import '../../domain/repositories/watchlist_repository.dart';

class WatchlistRepositoryMock implements WatchlistRepository {
  final _symbols = <String>{'sym_btc', 'sym_eth'};
  final _controller = StreamController<Set<String>>.broadcast();

  @override
  Future<Result<Set<String>>> fetchWatchlistSymbols() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return Ok(Set.of(_symbols));
  }

  @override
  Future<Result<void>> add(String symbol) async {
    _symbols.add(symbol);
    _controller.add(Set.of(_symbols));
    return const Ok(null);
  }

  @override
  Future<Result<void>> remove(String symbol) async {
    _symbols.remove(symbol);
    _controller.add(Set.of(_symbols));
    return const Ok(null);
  }

  @override
  Stream<Set<String>> watch() async* {
    yield Set.of(_symbols);
    yield* _controller.stream;
  }
}
