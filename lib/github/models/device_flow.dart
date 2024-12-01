class DeviceAuthorizationResponse {
  DeviceAuthorizationResponse({
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

  factory DeviceAuthorizationResponse.fromJson(Map<String, dynamic> json) {
    return DeviceAuthorizationResponse(
      deviceCode: json['device_code'],
      userCode: json['user_code'],
      verificationUri: Uri.parse(json['verification_uri']),
      expiresIn: json['expires_in'],
      interval: json['interval'],
    );
  }
}

sealed class UserAuthenticationResponse {
  UserAuthenticationResponse();

  factory UserAuthenticationResponse.fromJson(Map<String, dynamic> json) {
    // https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#error-codes-for-the-device-flow
    return switch (json['error']) {
      'authorization_pending' => AuthorizationPendingResponse(),
      'slow_down' => SlowDownResponse.fromJson(json),
      'expired_token' => ExpiredTokenResponse(),
      'access_denied' => AccessDeniedResponse(),
      null => AccessTokenResponse.fromJson(json),
      _ => throw 'Unsupported error code ${json['error']}\n'
        '${json['error_description']}\n'
        '${json['error_uri']}',
    };
  }
}

class AuthorizationPendingResponse extends UserAuthenticationResponse {}
class ExpiredTokenResponse extends UserAuthenticationResponse {}
class AccessDeniedResponse extends UserAuthenticationResponse {}

class SlowDownResponse extends UserAuthenticationResponse {
  SlowDownResponse({required this.interval});

  final int interval;

  factory SlowDownResponse.fromJson(Map<String, dynamic> json) {
    return SlowDownResponse(
      interval: json['interval'],
    );
  }
}

class AccessTokenResponse extends UserAuthenticationResponse {
  AccessTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.scope,
  });

  final String accessToken;
  final String tokenType;
  final String scope;

  factory AccessTokenResponse.fromJson(Map<String, dynamic> json) {
    return AccessTokenResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      scope: json['scope'],
    );
  }
}
