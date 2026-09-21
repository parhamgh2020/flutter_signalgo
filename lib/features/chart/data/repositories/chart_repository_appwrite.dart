import 'dart:async';

import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/entities/candle_entity.dart';
import '../../domain/entities/timeframe.dart';
import '../../domain/repositories/chart_repository.dart';
import '../models/analysis_model.dart';
import '../models/candle_model.dart';

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
  Future<Result<List<CandleEntity>>> fetchCandles({
    required String symbol,
    required Timeframe timeframe,
    int limit = 200,
  }) async {
    try {
      final res = await _databases.listDocuments(
        databaseId: _config.databaseId,
        collectionId: _candlesCollectionId(symbol, timeframe),
        queries: [
          Query.orderDesc('timestamp'),
          Query.limit(limit),
        ],
      );
      final candles = res.documents.map((d) => CandleModel.fromMap(d.data)).toList().reversed.toList();
      return Ok(candles);
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Future<Result<AnalysisEntity?>> fetchLatestAnalysis({
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
      if (res.documents.isEmpty) return const Ok(null);
      return Ok(AnalysisModel.fromMap(res.documents.first.data));
    } on AppwriteException catch (e) {
      return Err(Failure.fromAppwriteException(e));
    } catch (e) {
      return Err(UnknownFailure(e));
    }
  }

  @override
  Stream<CandleEntity> watchLiveCandle({required String symbol, required Timeframe timeframe}) {
    final collectionId = _candlesCollectionId(symbol, timeframe);
    final channel = 'databases.${_config.databaseId}.collections.$collectionId.documents';
    late StreamController<CandleEntity> controller;
    RealtimeSubscription? subscription;

    controller = StreamController<CandleEntity>.broadcast(
      onListen: () {
        subscription = _realtime.subscribe([channel]);
        subscription!.stream.listen((RealtimeMessage message) {
          try {
            controller.add(CandleModel.fromMap(message.payload));
          } catch (_) {}
        });
      },
      onCancel: () => subscription?.close(),
    );
    return controller.stream;
  }
}
