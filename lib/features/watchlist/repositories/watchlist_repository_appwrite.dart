import 'dart:async';

import 'package:appwrite/appwrite.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import 'watchlist_repository.dart';

class WatchlistRepositoryAppwrite implements WatchlistRepository {
  WatchlistRepositoryAppwrite({
    required Databases databases,
    required Account account,
    required Realtime realtime,
    required AppwriteConfig config,
  })  : _databases = databases,
        _account = account,
        _realtime = realtime,
        _config = config;

  final Databases _databases;
  final Account _account;
  final Realtime _realtime;
  final AppwriteConfig _config;

  Future<String> get _userId async => (await _account.get()).$id;

  @override
  Future<Result<Set<String>>> fetchWatchlistSymbols() async {
    try {
      final userId = await _userId;
      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: AppwriteCollections.watchlist,
        queries: [Query.equal('user_id', userId), Query.limit(200)],
      );
      return Ok(res.documents.map((d) => d.data['symbol'] as String).toSet());
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Future<Result<void>> add(String symbol) async {
    try {
      final userId = await _userId;
      await _databases.createDocument(
        databaseId: _config.databaseId,
        collectionId: AppwriteCollections.watchlist,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'symbol': symbol,
          'created_at': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
      return const Ok(null);
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Future<Result<void>> remove(String symbol) async {
    try {
      final userId = await _userId;
      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: AppwriteCollections.watchlist,
        queries: [Query.equal('user_id', userId), Query.equal('symbol', symbol), Query.limit(1)],
      );
      for (final doc in res.documents) {
        await _databases.deleteDocument(
          databaseId: _config.databaseId,
          collectionId: AppwriteCollections.watchlist,
          documentId: doc.$id,
        );
      }
      return const Ok(null);
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Stream<Set<String>> watch() {
    final channel = 'databases.${_config.databaseId}.collections.${AppwriteCollections.watchlist}.documents';
    late StreamController<Set<String>> controller;
    final current = <String>{};
    RealtimeSubscription? subscription;

    Future<void> primeAndListen() async {
      final initial = await fetchWatchlistSymbols();
      initial.fold((symbols) {
        current
          ..clear()
          ..addAll(symbols);
        controller.add(Set.of(current));
      }, (_) {});

      subscription = _realtime.subscribe([channel]);
      subscription!.stream.listen((RealtimeMessage message) {
        final symbol = message.payload['symbol'] as String?;
        if (symbol == null) return;
        final isDelete = message.events.any((e) => e.contains('.delete'));
        if (isDelete) {
          current.remove(symbol);
        } else {
          current.add(symbol);
        }
        controller.add(Set.of(current));
      });
    }

    controller = StreamController<Set<String>>.broadcast(
      onListen: primeAndListen,
      onCancel: () => subscription?.close(),
    );
    return controller.stream;
  }
}
