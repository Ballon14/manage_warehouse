import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_service.dart';
import '../models/stock_move_model.dart';
import '../models/stock_level_model.dart';
import '../models/inventory_count_line_model.dart';

final stockServiceProvider = Provider<StockService>((ref) => StockService());

final stockMovesStreamProvider = StreamProvider<List<StockMoveModel>>((ref) {
  final stockService = ref.watch(stockServiceProvider);
  return stockService.getStockMoves(limit: 50);
});

final stockLevelsProvider = StreamProvider.family<List<StockLevelModel>, String>(
    (ref, itemId) {
  final stockService = ref.watch(stockServiceProvider);
  return stockService.getStockLevelsForItem(itemId);
});

final inventoryCountLinesProvider =
    StreamProvider.family<List<InventoryCountLineModel>, String>(
        (ref, sessionId) {
  final stockService = ref.watch(stockServiceProvider);
  return stockService.getInventoryCountLines(sessionId);
});

