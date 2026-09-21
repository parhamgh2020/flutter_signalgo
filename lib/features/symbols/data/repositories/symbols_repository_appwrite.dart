import 'dart:async';
import 'dart:math';

import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/cache/offline_cache.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/symbol_entity.dart';
import '../../domain/repositories/symbols_repository.dart';
import '../models/symbol_model.dart';

const _cacheKey = 'symbols.page1';

class SymbolsRepositoryAppwrite implements SymbolsRepository {
  SymbolsRepositoryAppwrite({
    required Databases databases,
    required Realtime realtime,
    required AppwriteConfig config,
    required OfflineCache cache,
  })  : _databases = databases,
        _realtime = realtime,
        _config = config,
        _cache = cache;

  final Databases _databases;
  final Realtime _realtime;
  final AppwriteConfig _config;
  final OfflineCache _cache;

  @override
  Future<Result<SymbolsPage>> fetchSymbols({
    int limit = 30,
    String? cursor,
    SymbolSort sort = SymbolSort.marketCap,
    String? search,
  }) async {
    try {
      final queries = <String>[Query.limit(limit)];
      if (cursor != null) queries.add(Query.cursorAfter(cursor));
      if (search != null && search.trim().isNotEmpty) {
        queries.add(Query.search('name', search.trim()));
      }
      queries.add(switch (sort) {
        SymbolSort.marketCap => Query.orderDesc('market_cap'),
        SymbolSort.gainers => Query.orderDesc('change_24h'),
        SymbolSort.losers => Query.orderAsc('change_24h'),
      });

      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: AppwriteCollections.symbols,
        queries: queries,
      );

      final items = res.documents.map((d) => SymbolModel.fromMap(d.data..[r'$id'] = d.$id)).toList();

      if (cursor == null) {
        await _cache.writeList(_cacheKey, items.map((e) => e.toCacheMap()).toList());
      }

      return Ok(SymbolsPage(
        items: items,
        nextCursor: items.length == limit ? items.last.id : null,
      ));
    } on AppwriteException catch (e) {
      if (cursor == null) {
        final cached = _cache.readList(_cacheKey);
        if (cached != null) {
          final items = cached.map(SymbolModel.fromMap).toList();
          return Ok(SymbolsPage(items: items, nextCursor: null));
        }
      }
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Stream<SymbolEntity> watchPriceUpdates() {
    late StreamController<SymbolEntity> controller;
    RealtimeSubscription? subscription;
    var backoff = const Duration(seconds: 2);
    late void Function() connect;

    void reconnect() {
      subscription?.close();
      final delay = backoff;
      backoff = Duration(seconds: min(backoff.inSeconds * 2, 30));
      Future.delayed(delay, () {
        if (!controller.isClosed) connect();
      });
    }

    connect = () {
      subscription = _realtime.subscribe([
        'databases.${_config.databaseId}.collections.${AppwriteCollections.symbols}.documents',
      ]);
      subscription!.stream.listen(
        (message) {
          backoff = const Duration(seconds: 2);
          final isRelevant = message.events.any((e) => e.contains('.update') || e.contains('.create'));
          if (!isRelevant) return;
          try {
            controller.add(SymbolModel.fromMap(message.payload));
          } catch (_) {
            // Malformed payload — skip this event rather than kill the stream.
          }
        },
        onError: (_) => reconnect(),
        onDone: reconnect,
      );
    };

    controller = StreamController<SymbolEntity>.broadcast(
      onListen: connect,
      onCancel: () => subscription?.close(),
    );
    return controller.stream;
  }
}
