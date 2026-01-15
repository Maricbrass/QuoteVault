import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// Service for monitoring network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;

  /// Stream of connectivity status
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _initialize();
  }

  void _initialize() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final wasOnline = _isOnline;

      // Consider online if any connection is available
      _isOnline = results.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);

      // Log connectivity changes
      if (wasOnline != _isOnline) {
        appLogger.info('Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');
        _controller.add(_isOnline);
      }
    } catch (e, stackTrace) {
      appLogger.error('Failed to check connectivity', e, stackTrace);
      // Assume online on error to not block functionality
      _isOnline = true;
    }
  }

  void dispose() {
    _controller.close();
  }
}

/// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for current connectivity status
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

