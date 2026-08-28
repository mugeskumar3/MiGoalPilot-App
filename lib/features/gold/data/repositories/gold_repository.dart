import 'dart:async';
import 'dart:math';
import 'package:migoalpilot/core/models/models.dart';

abstract class GoldRepository {
  Future<GoldPrice> getLivePrice();
  Future<List<double>> getPriceHistory(String range);
}

class MockGoldRepository implements GoldRepository {
  @override
  Future<GoldPrice> getLivePrice() async {
    return GoldPrice(
      rate22K: 12500,
      rate24K: 13640,
      dailyChangePercentage: -1.2,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<List<double>> getPriceHistory(String range) async {
    const basePrice = 12500.0;
    final points = range == '7D' ? 7 : range == '30D' ? 30 : 60;
    final rand = Random();
    return List.generate(points, (idx) {
      final change = (rand.nextDouble() - 0.52) * 300;
      return basePrice + (idx * change);
    });
  }
}
