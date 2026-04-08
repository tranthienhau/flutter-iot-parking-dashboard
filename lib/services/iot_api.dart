// REST client for the IoT gateway. In production this hits a Cloud Run
// service fed by Axis P3748-PLVE cameras via Pub/Sub. For the POC we
// delegate to an in-memory MockBackend so the app is runnable offline.

import 'mock_backend.dart';

class Lot {
  Lot({
    required this.id,
    required this.name,
    required this.total,
    required this.open,
    required this.occupied,
    required this.reserved,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
    required this.updatedAt,
    required this.history24h,
  });

  final String id;
  final String name;
  final int total;
  final int open;
  final int occupied;
  final int reserved;
  final double lat;
  final double lng;
  final double distanceMeters;
  final DateTime updatedAt;
  final List<double> history24h; // 24 values, 0..1 utilization

  Lot copyWith({
    int? open,
    int? occupied,
    int? reserved,
    DateTime? updatedAt,
    List<double>? history24h,
  }) {
    return Lot(
      id: id,
      name: name,
      total: total,
      open: open ?? this.open,
      occupied: occupied ?? this.occupied,
      reserved: reserved ?? this.reserved,
      lat: lat,
      lng: lng,
      distanceMeters: distanceMeters,
      updatedAt: updatedAt ?? this.updatedAt,
      history24h: history24h ?? this.history24h,
    );
  }
}

class LotUpdate {
  const LotUpdate({
    required this.lotId,
    required this.open,
    required this.occupied,
    required this.reserved,
    required this.ts,
  });

  final String lotId;
  final int open;
  final int occupied;
  final int reserved;
  final DateTime ts;
}

class IotApi {
  IotApi(this._backend);
  final MockBackend _backend;

  Future<List<Lot>> fetchLots() async {
    // Production: http.get(Uri.parse('https://iot.example.com/lots'))
    return _backend.getLots();
  }

  Future<List<LotUpdate>> pollLots() async {
    // Fallback polling endpoint.
    return _backend.getLots().map((l) {
      return LotUpdate(
        lotId: l.id,
        open: l.open,
        occupied: l.occupied,
        reserved: l.reserved,
        ts: DateTime.now(),
      );
    }).toList();
  }
}
