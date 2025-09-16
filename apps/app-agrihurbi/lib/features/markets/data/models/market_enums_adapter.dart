import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:hive/hive.dart';

/// Hive Type Adapters for Market Enums
/// 
/// Register these adapters before using Hive with market models

// Market Type Adapter
class MarketTypeAdapter extends TypeAdapter<MarketType> {
  @override
  final int typeId = 7; // Ensure unique typeId across the app

  @override
  MarketType read(BinaryReader reader) {
    final index = reader.readByte();
    return MarketType.values[index];
  }

  @override
  void write(BinaryWriter writer, MarketType obj) {
    writer.writeByte(obj.index);
  }
}

// Market Status Adapter
class MarketStatusAdapter extends TypeAdapter<MarketStatus> {
  @override
  final int typeId = 8; // Ensure unique typeId across the app

  @override
  MarketStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return MarketStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, MarketStatus obj) {
    writer.writeByte(obj.index);
  }
}

/// Register all market adapters
void registerMarketAdapters() {
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(MarketTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(MarketStatusAdapter());
  }
}