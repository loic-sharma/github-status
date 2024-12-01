import 'dart:async';

import 'client.dart';
import 'models/device_flow.dart';

// https://learn.microsoft.com/azure/active-directory/develop/v2-oauth2-device-code
// https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#device-flow
class DeviceFlow {
  DeviceFlow._(this._client, this._githubClientId, this._deviceResponse) :
    _sleepDuration = Duration(seconds: _deviceResponse.interval),
    _sleepFuture = Future.delayed(Duration(seconds: _deviceResponse.interval));

  final GitHub _client;
  final String _githubClientId;
  final DeviceAuthorizationResponse _deviceResponse;
  final Stopwatch _stopwatch = Stopwatch()..start();
  Duration _sleepDuration;
  Future _sleepFuture;

  /// The URI the user should use to login.
  Uri get verificationUri => _deviceResponse.verificationUri;

  /// The code the user should enter to login.
  String get userCode => _deviceResponse.userCode;

  /// How long [check] will sleep for before polling again.
  Duration get sleepDuration => _sleepDuration;

  /// Start the device flow.
  static Future<DeviceFlow> start(
    GitHub client,
    String githubClientId,
    String githubClientSecret,
  ) async {
    // Check that the client ID and secret are set.
    if (githubClientId.isEmpty || githubClientSecret.isEmpty) {
      throw 'Please set the GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET variables.';
    }

    final deviceResponse = await client.authorizeDevice(githubClientId);
    return DeviceFlow._(
      client,
      githubClientId,
      deviceResponse,
    );
  }

  /// Check the current status of the device flow.
  ///
  /// This sleeps if necessary before checking the status.
  Future<CheckResult> check() async {
    // Check the device code isn't expired.
    if (_stopwatch.elapsed.inSeconds >= _deviceResponse.expiresIn) {
      return const ExpiredResult();
    }

    await _sleepFuture;
    final authResponse = await _client.authenticateUser(
      _githubClientId,
      _deviceResponse.deviceCode,
    );

    switch (authResponse) {
      case AuthorizationPendingResponse():
        _sleepFuture = Future.delayed(_sleepDuration);
        return const WaitingResult();

      // Update the sleep interval if needed.
      case SlowDownResponse():
        _sleepDuration = Duration(seconds: authResponse.interval);
        _sleepFuture = Future.delayed(_sleepDuration);
        return const WaitingResult();

      case ExpiredTokenResponse(): return const ExpiredResult();
      case AccessDeniedResponse(): return const AccessDeniedResult();
      case AccessTokenResponse(
        accessToken: final accessToken,
        tokenType: final tokenType,
        scope: final scope,
      ): return SuccessResult(accessToken, tokenType, scope);
    }
  }
}

sealed class CheckResult { const CheckResult(); }

/// Device flow is still pending. Poll again in the future.
class WaitingResult extends CheckResult { const WaitingResult(); }

/// User logged in successfully.
class SuccessResult extends CheckResult {
  const SuccessResult(this.accessToken, this.tokenType, this.scope);

  final String accessToken;
  final String tokenType;
  final String scope;
}

/// Device flow has ended with failure.
sealed class ErrorResult extends CheckResult { const ErrorResult(); }

/// User took too long to login.
class ExpiredResult extends ErrorResult { const ExpiredResult(); }

/// User declined to login.
class AccessDeniedResult extends ErrorResult { const AccessDeniedResult(); }
