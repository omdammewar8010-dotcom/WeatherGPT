import 'dart:async';

enum NetworkStatus {
  online,
  offline,
  cellularWeak;

  bool get isConnected => this != NetworkStatus.offline;
  String get displayName {
    switch (this) {
      case NetworkStatus.online:
        return 'Online (High-Speed)';
      case NetworkStatus.cellularWeak:
        return 'Cellular Edge (Weak Signal)';
      case NetworkStatus.offline:
        return 'Offline (No Connection)';
    }
  }
}

abstract class ConnectivityService {
  NetworkStatus get currentStatus;
  Stream<NetworkStatus> get statusStream;
  void simulateNetworkStatus(NetworkStatus status);
  void toggleOfflineMode();
}

class ConnectivityServiceImpl implements ConnectivityService {
  NetworkStatus _currentStatus = NetworkStatus.online;
  final _statusController = StreamController<NetworkStatus>.broadcast();

  ConnectivityServiceImpl({NetworkStatus initialStatus = NetworkStatus.online})
      : _currentStatus = initialStatus {
    _statusController.add(_currentStatus);
  }

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  @override
  void simulateNetworkStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(_currentStatus);
    }
  }

  @override
  void toggleOfflineMode() {
    if (_currentStatus == NetworkStatus.offline) {
      simulateNetworkStatus(NetworkStatus.online);
    } else {
      simulateNetworkStatus(NetworkStatus.offline);
    }
  }

  void dispose() {
    _statusController.close();
  }
}
