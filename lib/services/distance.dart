// Haversine distance helper for sorting lots by proximity.

import 'dart:math' as math;

const double _earthRadiusMeters = 6371000;

double haversineMeters({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  double toRad(double d) => d * math.pi / 180;
  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(toRad(lat1)) *
          math.cos(toRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * _earthRadiusMeters * math.asin(math.sqrt(a));
}
