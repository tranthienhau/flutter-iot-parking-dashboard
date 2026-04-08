import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/iot_api.dart';
import '../services/live_feed_service.dart';
import '../services/mock_backend.dart';

class ParkingState {
  const ParkingState({
    this.lots = const [],
    this.updatedAt,
    this.connection = ConnectionStatus.idle,
  });

  final List<Lot> lots;
  final DateTime? updatedAt;
  final ConnectionStatus connection;

  ParkingState copyWith({
    List<Lot>? lots,
    DateTime? updatedAt,
    ConnectionStatus? connection,
  }) {
    return ParkingState(
      lots: lots ?? this.lots,
      updatedAt: updatedAt ?? this.updatedAt,
      connection: connection ?? this.connection,
    );
  }
}

class ParkingNotifier extends StateNotifier<ParkingState> {
  ParkingNotifier() : super(const ParkingState()) {
    _backend = MockBackend();
    _api = IotApi(_backend);
    _feed = LiveFeedService(
      api: _api,
      backend: _backend,
      onUpdate: _applyUpdate,
      onStatus: _setConnection,
    );
    _bootstrap();
  }

  late final MockBackend _backend;
  late final IotApi _api;
  late final LiveFeedService _feed;

  Future<void> _bootstrap() async {
    final lots = await _api.fetchLots();
    state = state.copyWith(lots: lots, updatedAt: DateTime.now());
    _feed.start();
  }

  void _setConnection(ConnectionStatus status) {
    state = state.copyWith(connection: status);
  }

  void _applyUpdate(LotUpdate u) {
    final next = state.lots.map((l) {
      if (l.id != u.lotId) return l;
      final newHistory = [
        ...l.history24h.sublist(l.history24h.length > 23 ? 1 : 0),
        u.occupied / l.total,
      ];
      return l.copyWith(
        open: u.open,
        occupied: u.occupied,
        reserved: u.reserved,
        updatedAt: u.ts,
        history24h: newHistory,
      );
    }).toList();
    state = state.copyWith(lots: next, updatedAt: DateTime.now());
  }

  @override
  void dispose() {
    _feed.stop();
    super.dispose();
  }
}

final parkingProvider =
    StateNotifierProvider<ParkingNotifier, ParkingState>((ref) {
  return ParkingNotifier();
});
