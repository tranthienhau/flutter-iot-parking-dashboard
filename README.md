# flutter_iot_parking_dashboard

Flutter POC for a real-time IoT smart parking dashboard.

## Features

- Real-time WebSocket live feed (`web_socket_channel`) with exponential backoff
- Graceful REST polling fallback when the socket drops
- Mock in-memory backend so the app is runnable offline
- 4 campus parking lots with live occupancy, reservations, and 24h history
- Haversine distance sorting to show the nearest lot first
- StatusPill widget (Plenty / Limited / Full) driven by the open ratio
- TrendChart 24h bar visualization
- Admin analytics screen with campus-wide utilization and peak-hour table
- Riverpod state, `go_router` navigation, Material 3 dark theme

## IoT backend this plugs into

In production the REST and WebSocket clients point to a Cloud Run gateway that
ingests occupancy events from Axis P3748-PLVE cameras via Google Pub/Sub. The
mobile app is the last-mile consumer; swap `IotApi` / `LiveFeedService` URLs
and the rest of the code stays the same.

## Run

```
flutter pub get
flutter run
```
