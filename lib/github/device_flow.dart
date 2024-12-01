import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// https://learn.microsoft.com/azure/active-directory/develop/v2-oauth2-device-code
// https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#device-flow
class DeviceFlow {
  DeviceFlow._(this._client, this._githubClientId, this._deviceResponse) :
    _sleepDuration = Duration(seconds: _deviceResponse.interval),
    _sleepFuture = Future.delayed(Duration(seconds: _deviceResponse.interval));

  final http.Client _client;
  final String _githubClientId;
  final _DeviceAuthorizationResponse _deviceResponse;
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
    http.Client client,
    String githubClientId,
    String githubClientSecret,
  ) async {
    // Check that the client ID and secret are set.
    if (githubClientId.isEmpty || githubClientSecret.isEmpty) {
      throw 'Please set the GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET variables.';
    }

    final deviceResponse = await _authorizeDevice(client, githubClientId);
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
    final authResponse = await _authenticateUser(
      _client,
      _githubClientId,
      _deviceResponse.deviceCode,
    );

    switch (authResponse) {
      case _AuthorizationPendingResponse():
        _sleepFuture = Future.delayed(_sleepDuration);
        return const WaitingResult();

      // Update the sleep interval if needed.
      case _SlowDownResponse():
        _sleepDuration = Duration(seconds: authResponse.interval);
        _sleepFuture = Future.delayed(_sleepDuration);
        return const WaitingResult();

      case _ExpiredTokenResponse(): return const ExpiredResult();
      case _AccessDeniedResponse(): return const AccessDeniedResult();
      case _AccessTokenResponse(
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

Future<_DeviceAuthorizationResponse> _authorizeDevice(
  http.Client client,
  String clientId,
) async {
  final request = http.Request('POST', Uri.parse('https://github.com/login/device/code'))
   ..headers['Content-Type'] = 'application/x-www-form-urlencoded'
   ..headers['Accept'] = 'application/json'
   ..body = 'client_id=$clientId&scope=repo+notifications+read:org';

  // TODO: Handle errors.
  // 404 response if client ID unknown.
  final response = await client.send(request);
  if (response.statusCode != 200) {
    throw 'Unexpected device flow response: ${response.statusCode}\n${response.reasonPhrase}}}';
  }

  final bodyJson = await response
    .stream
    .transform(utf8.decoder)
    .transform(json.decoder)
    .first as Map<String, dynamic>;

  return _DeviceAuthorizationResponse.fromJson(bodyJson);
}

Future<_UserAuthenticationResponse> _authenticateUser(
  http.Client client,
  String clientId,
  String deviceCode,
) async {
  final request = http.Request('POST', Uri.parse('https://github.com/login/oauth/access_token'))
   ..headers['Content-Type'] = 'application/x-www-form-urlencoded'
   ..headers['Accept'] = 'application/json'
   ..body = 'client_id=$clientId&device_code=$deviceCode&grant_type=urn:ietf:params:oauth:grant-type:device_code';

  final response = await client.send(request);
  if (response.statusCode != 200) {
    throw 'Unexpected access token response: ${response.statusCode}\n${response.reasonPhrase}}}';
  }

  final bodyJson = await response
    .stream
    .transform(utf8.decoder)
    .transform(json.decoder)
    .first as Map<String, dynamic>;

  return _UserAuthenticationResponse.fromJson(bodyJson);
}

class _DeviceAuthorizationResponse {
  _DeviceAuthorizationResponse({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });

  final String deviceCode;
  final String userCode;
  final Uri verificationUri;

  /// Number of seconds before the [deviceCode] and [userCode] expire.
  final int expiresIn;

  /// Minimum number of seconds that must elapse between polling requests.
  final int interval;

  factory _DeviceAuthorizationResponse.fromJson(Map<String, dynamic> json) {
    return _DeviceAuthorizationResponse(
      deviceCode: json['device_code'],
      userCode: json['user_code'],
      verificationUri: Uri.parse(json['verification_uri']),
      expiresIn: json['expires_in'],
      interval: json['interval'],
    );
  }
}

sealed class _UserAuthenticationResponse {
  _UserAuthenticationResponse();

  factory _UserAuthenticationResponse.fromJson(Map<String, dynamic> json) {
    // https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#error-codes-for-the-device-flow
    return switch (json['error']) {
      'authorization_pending' => _AuthorizationPendingResponse(),
      'slow_down' => _SlowDownResponse.fromJson(json),
      'expired_token' => _ExpiredTokenResponse(),
      'access_denied' => _AccessDeniedResponse(),
      null => _AccessTokenResponse.fromJson(json),
      _ => throw 'Unsupported error code ${json['error']}\n'
        '${json['error_description']}\n'
        '${json['error_uri']}',
    };
  }
}

class _AuthorizationPendingResponse extends _UserAuthenticationResponse {}
class _SlowDownResponse extends _UserAuthenticationResponse {
  _SlowDownResponse({
    required this.interval,
  });

  final int interval;

  factory _SlowDownResponse.fromJson(Map<String, dynamic> json) {
    return _SlowDownResponse(
      interval: json['interval'],
    );
  }
}

class _ExpiredTokenResponse extends _UserAuthenticationResponse {}
class _AccessDeniedResponse extends _UserAuthenticationResponse {}

class _AccessTokenResponse extends _UserAuthenticationResponse {
  _AccessTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.scope,
  });

  final String accessToken;
  final String tokenType;
  final String scope;

  factory _AccessTokenResponse.fromJson(Map<String, dynamic> json) {
    return _AccessTokenResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      scope: json['scope'],
    );
  }
}
