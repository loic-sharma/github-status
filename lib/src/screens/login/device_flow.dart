import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../github/device_flow.dart' as auth;

class DeviceFlowModel with ChangeNotifier {
  DeviceFlowModel(this._githubClientId, this._githubClientSecret);

  final String _githubClientId;
  final String _githubClientSecret;

  DeviceFlowState get state => _state;
  DeviceFlowState _state = const StartingState();

  int get nextRefreshSeconds => _nextRefreshSeconds;
  int _nextRefreshSeconds = 0;
  Timer? _nextRefreshTimer;

  factory DeviceFlowModel.run(
    String githubClientId,
    String githubClientSecret,
  ) {
    final result = DeviceFlowModel(githubClientId, githubClientSecret);
    unawaited(result._authenticate());
    return result;
  }

  Future<void> _authenticate() async {
    final client = http.Client();
    try {
      final deviceFlow = await auth.DeviceFlow.start(
        client,
        _githubClientId,
        _githubClientSecret,
      );

      _state = WaitingState(
        deviceFlow.verificationUri,
        deviceFlow.userCode,
      );
      _startSleepCountdown(deviceFlow.sleepDuration);

      while (true) {
        // Sleep then check the status of the device flow.
        final result = await deviceFlow.check();

        switch (result) {
          case auth.WaitingResult():
            _startSleepCountdown(deviceFlow.sleepDuration);
            break;

          case auth.SuccessResult(: final accessToken):
            _state = CompletedState(accessToken: accessToken);
            return;

          case auth.ErrorResult():
            _state = ErrorState(error: result);
            return;
        }
      }
    } finally {
      client.close();
    }
  }

  void retry() {
    assert(state is ErrorState);

    _state = const StartingState();
    notifyListeners();

    unawaited(_authenticate());
  }

  void _startSleepCountdown(Duration duration) {
    _nextRefreshSeconds = duration.inSeconds;
    notifyListeners();

    _nextRefreshTimer?.cancel();
    _nextRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_nextRefreshSeconds == 0) return timer.cancel();
        _nextRefreshSeconds--;
        notifyListeners();
      },
    );
  }
}

sealed class DeviceFlowState {
  const DeviceFlowState();
}

/// Requesting a device code from GitHub.
class StartingState extends DeviceFlowState {
  const StartingState();
}

/// Waiting for the user to enter the code.
class WaitingState extends DeviceFlowState {
  const WaitingState(this.verificationUri, this.userCode);

  final Uri verificationUri;
  final String userCode;
}

/// Device flow failed.
class ErrorState extends DeviceFlowState {
  const ErrorState({required this.error});

  final auth.ErrorResult? error;
}

// Device flow completed and an access token was received.
class CompletedState extends DeviceFlowState {
  const CompletedState({required this.accessToken});

  final String accessToken;
}
