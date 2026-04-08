// In-memory mock backend for the POC. Simulates 4 campus parking lots
// and streams per-lot occupancy updates.

import 'dart:math' as math;

import 'iot_api.dart';

class MockBackend {
  MockBackend() {
    _lots = [
      Lot(
        id: 'lot_north',
        name: 'North Campus Garage',
        total: 420,
        open: 83,
        occupied: 330,
        reserved: 7,
        lat: 37.875,
        lng: -122.259,
        distanceMeters: 180,
        updatedAt: DateTime.now(),
        history24h: _baseline(0.78),
      ),
      Lot(
        id: 'lot_south',
        name: 'South Lot',
        total: 280,
        open: 122,
        occupied: 152,
        reserved: 6,
        lat: 37.866,
        lng: -122.252,
        distanceMeters: 420,
        updatedAt: DateTime.now(),
        history24h: _baseline(0.55),
      ),
      Lot(
        id: 'lot_stadium',
        name: 'Stadium Parking',
        total: 950,
        open: 610,
        occupied: 320,
        reserved: 20,
        lat: 37.871,
        lng: -122.251,
        distanceMeters: 780,
        updatedAt: DateTime.now(),
        history24h: _baseline(0.33),
      ),
      Lot(
        id: 'lot_library',
        name: 'Library Garage',
        total: 180,
        open: 14,
        occupied: 164,
        reserved: 2,
        lat: 37.872,
        lng: -122.258,
        distanceMeters: 90,
        updatedAt: DateTime.now(),
        history24h: _baseline(0.92),
      ),
    ];
  }

  late List<Lot> _lots;
  final _rand = math.Random();

  List<Lot> getLots() =>
      _lots.map((l) => l.copyWith(history24h: List.of(l.history24h))).toList();

  LotUpdate simulateUpdate() {
    final idx = _rand.nextInt(_lots.length);
    final lot = _lots[idx];
    final delta = _rand.nextInt(7) - 3;
    final newOccupied =
        (lot.occupied + delta).clamp(0, lot.total - lot.reserved);
    final newOpen = lot.total - newOccupied - lot.reserved;
    final now = DateTime.now();
    _lots[idx] = lot.copyWith(
      open: newOpen,
      occupied: newOccupied,
      updatedAt: now,
    );
    return LotUpdate(
      lotId: lot.id,
      open: newOpen,
      occupied: newOccupied,
      reserved: lot.reserved,
      ts: now,
    );
  }

  static List<double> _baseline(double target) {
    return List<double>.generate(24, (i) {
      final wave = 0.15 * math.sin((i / 24) * math.pi * 2);
      return (target + wave).clamp(0.0, 1.0);
    });
  }
}
