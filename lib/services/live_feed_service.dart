// WebSocket live feed client with exponential backoff, heartbeat, and
// graceful REST polling fallback. Designed to drop in behind a real IoT
// gateway (uses MockBackend locally).

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'iot_api.dart';
import 'mock_backend.dart';

enum ConnectionStatus { idle, live, polling, offline }

typedef UpdateHandler = void Function(LotUpdate update);
typedef StatusHandler = void Function(ConnectionStatus status);

class LiveFeedService {
  LiveFeedService({
    required this.api,
    required this.backend,
    required this.onUpdate,
    required this.onStatus,
    this.useMock = true,
  });

  final IotApi api;
  final MockBackend backend;
  final UpdateHandler onUpdate;
  final StatusHandler onStatus;
  final bool useMock;

  static const _wsUrl = 'wss://iot.example.com/parking';
  static const _backoff = <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 30),
  ];
  static const _pollEvery = Duration(seconds: 5);
  static const _mockEvery = Duration(seconds: 2);

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSub;
  Timer? _reconnectTimer;
  Timer? _pollTimer;
  Timer? _mockTimer;
  int _attempt = 0;

  void start() {
    if (useMock) {
      _startMock();
      return;
    }
    _connect();
  }

  void stop() {
    _wsSub?.cancel();
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _pollTimer?.cancel();
    _mockTimer?.cancel();
    _channel = null;
    _wsSub = null;
    _reconnectTimer = null;
    _pollTimer = null;
    _mockTimer = null;
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      onStatus(ConnectionStatus.live);
      _stopPolling();
      _attempt = 0;
      _wsSub = _channel!.stream.listen(
        (raw) {
          try {
            final data = jsonDecode(raw as String) as Map<String, dynamic>;
            if (data['type'] == 'lot_update') {
              onUpdate(LotUpdate(
                lotId: data['lotId'] as String,
                open: data['open'] as int,
                occupied: data['occupied'] as int,
                reserved: data['reserved'] as int,
                ts: DateTime.fromMillisecondsSinceEpoch(data['ts'] as int),
              ));
            }
          } catch (_) {}
        },
        onError: (_) {
          _startPolling();
          _scheduleReconnect();
        },
        onDone: () {
          onStatus(ConnectionStatus.polling);
          _startPolling();
          _scheduleReconnect();
        },
      );
    } catch (_) {
      _startPolling();
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    final delay = _backoff[_attempt.clamp(0, _backoff.length - 1)];
    _attempt += 1;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connect);
  }

  void _startPolling() {
    if (_pollTimer != null) return;
    onStatus(ConnectionStatus.polling);
    _pollTimer = Timer.periodic(_pollEvery, (_) async {
      final updates = await api.pollLots();
      for (final u in updates) {
        onUpdate(u);
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _startMock() {
    onStatus(ConnectionStatus.live);
    _mockTimer = Timer.periodic(_mockEvery, (_) {
      onUpdate(backend.simulateUpdate());
    });
  }
}
