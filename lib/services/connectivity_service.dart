import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:assignment/ui/widgets/top_snackbar.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasConnected = true;
  BuildContext? _context;

  void initialize(BuildContext context) {
    _context = context;
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _wasConnected = _isConnected(result);
  }

  bool _isConnected(List<ConnectivityResult> result) {
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    final isConnected = _isConnected(result);

    if (_context != null) {
      if (!isConnected && _wasConnected) {
        // Connection lost
        TopSnackbar.show(
          _context!,
          'No internet connection',
          backgroundColor: Colors.red,
        );
      } else if (isConnected && !_wasConnected) {
        // Connection restored
        TopSnackbar.show(
          _context!,
          'Back online',
          backgroundColor: Colors.green,
        );
      }
    }

    _wasConnected = isConnected;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _context = null;
  }
}
