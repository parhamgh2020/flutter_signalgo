import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../models/analysis_model.dart';
import '../models/candle_model.dart';
import '../models/timeframe.dart';
import 'chart_repository.dart';

class ChartRepositoryAppwrite implements ChartRepository {
  ChartRepositoryAppwrite({
    required Databases databases,
    required Realtime realtime,
    required AppwriteConfig config,
  })  : _databases = databases,
        _realtime = realtime,
        _config = config;

  final Databases _databases;
  final Realtime _realtime;
  final AppwriteConfig _config;

  /// Candles live in one collection per symbol/timeframe pair (e.g.
  /// `BTCUSDT_1d`), not a shared `candles` collection — [symbol] is the
  /// short ticker from the `symbols` collection (e.g. `BTC`); every pair is
  /// quoted in USDT.
  String _candlesCollectionId(String symbol, Timeframe timeframe) =>
      '${symbol.toUpperCase()}USDT_${timeframe.apiValue}';

  @override
  Future<Result<List<CandleModel>>> fetchCandles({
    required String symbol,
    required Timeframe timeframe,
    int limit = 200,
  }) async {
    final collectionId = _candlesCollectionId(symbol, timeframe);
    debugPrint('[ChartRepo] fetchCandles db=${_config.databaseId} collection="$collectionId" limit=$limit');
    try {
      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: collectionId,
        queries: [
          Query.orderDesc('open_time'),
          Query.limit(limit),
        ],
      );
      debugPrint('[ChartRepo] "$collectionId" returned ${res.documents.length}/${res.total} docs'
          '${res.documents.isEmpty ? '' : ', first raw: ${res.documents.first.data}'}');
      final candles = res.documents.map((d) => CandleModel.fromMap(d.data)).toList().reversed.toList();
      return Ok(candles);
    } on AppwriteException catch (e) {
      debugPrint('[ChartRepo] fetchCandles "$collectionId" AppwriteException ${e.code} ${e.type}: ${e.message}');
      return Err(Failure.fromAppwriteException(e));
    } catch (e, st) {
      debugPrint('[ChartRepo] fetchCandles "$collectionId" failed: $e\n$st');
      return Err(UnknownFailure(e));
    }
  }

  @override
  Future<Result<AnalysisModel?>> fetchLatestAnalysis({
    required String symbol,
    required Timeframe timeframe,
  }) async {
    try {
      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: AppwriteCollections.analyses,
        queries: [
          Query.equal('symbol', symbol),
          Query.equal('timeframe', timeframe.apiValue),
          Query.orderDesc('created_at'),
          Query.limit(1),
        ],
      );
      debugPrint('[ChartRepo] fetchLatestAnalysis symbol=$symbol timeframe=${timeframe.apiValue} '
          'returned ${res.documents.length}/${res.total} docs');
      if (res.documents.isEmpty) return const Ok(null);
      return Ok(AnalysisModel.fromMap(res.documents.first.data));
    } on AppwriteException catch (e) {
      debugPrint('[ChartRepo] fetchLatestAnalysis AppwriteException ${e.code} ${e.type}: ${e.message}');
      return Err(Failure.fromAppwriteException(e));
    } catch (e, st) {
      debugPrint('[ChartRepo] fetchLatestAnalysis failed: $e\n$st');
      return Err(UnknownFailure(e));
    }
  }

  @override
  Stream<CandleModel> watchLiveCandle({required String symbol, required Timeframe timeframe}) {
    final collectionId = _candlesCollectionId(symbol, timeframe);
    final channel = 'databases.${_config.databaseId}.collections.$collectionId.documents';
    debugPrint('[ChartRepo] watchLiveCandle channel=$channel');
    late StreamController<CandleModel> controller;
    RealtimeSubscription? subscription;

    controller = StreamController<CandleModel>.broadcast(
      onListen: () {
        subscription = _realtime.subscribe([channel]);
        subscription!.stream.listen(
          (RealtimeMessage message) {
            try {
              controller.add(CandleModel.fromMap(message.payload));
            } catch (e) {
              debugPrint('[ChartRepo] bad realtime payload on $collectionId: $e, payload=${message.payload}');
            }
          },
          // Realtime errors (e.g. a rejected subscription) would otherwise
          // surface as unhandled exceptions; the SDK reconnects on its own.
          onError: (Object e) => debugPrint('[ChartRepo] realtime error on $collectionId: $e'),
        );
      },
      onCancel: () => subscription?.close(),
    );
    return controller.stream;
  }
}
