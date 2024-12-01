import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/device_flow.dart';
import 'models/issue_search.dart';
import 'models/user.dart';

class GitHub {
  GitHub({String? token}) : _token = token;

  String? _token;
  set token(String? value) {
    _token = value;
  }

  Future<DeviceAuthorizationResponse> authorizeDevice(String clientId) async {
    // TODO: Handle errors.
    // 404 response if client ID unknown.
    final response = await http.post(
      Uri.parse('https://github.com/login/device/code'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: 'client_id=$clientId&scope=repo+notifications+read:org',
    );
    if (response.statusCode != 200) {
      throw 'Unexpected device flow response: ${response.statusCode}\n${response.reasonPhrase}}}';
    }

    final bodyJson = json.decode(response.body) as Map<String, dynamic>;

    return DeviceAuthorizationResponse.fromJson(bodyJson);
  }

  Future<UserAuthenticationResponse> authenticateUser(
    String clientId,
    String deviceCode,
  ) async {
    final response = await http.post(
      Uri.parse('https://github.com/login/oauth/access_token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: 'client_id=$clientId&device_code=$deviceCode&grant_type=urn:ietf:params:oauth:grant-type:device_code',
    );
    if (response.statusCode != 200) {
      throw 'Unexpected access token response: ${response.statusCode}\n${response.reasonPhrase}}}';
    }

    final bodyJson = json.decode(response.body) as Map<String, dynamic>;

    return UserAuthenticationResponse.fromJson(bodyJson);
  }

  // https://docs.github.com/en/graphql/reference/queries#search
  Future<Result<IssueSearch>> searchIssues(
    String query, {
    int first = 20,
  }) async {
    return await _doJsonRequest(
      method: 'POST',
      path: '/graphql',
      body: jsonEncode({
        'query': searchPullRequestsQuery,
        'variables': {
          'first': first,
          'query': query,
        },
      }),
      resultCallback: (raw) => IssueSearch.fromJson(raw as Map<String, dynamic>),
    );
  }

  Future<Result<User>> user() async {
    return await _doJsonRequest(
      method: 'GET',
      path: '/user',
      resultCallback: (raw) {
        final json = raw as Map<String, dynamic>;
        return User.fromJson(json);
      },
    );
  }

  Future<Result<T>> _doJsonRequest<T>({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    String? body,
    required T Function(dynamic) resultCallback,
  }) async {
    var response = await _doRequest(method, path, queryParameters, body);

    if (response.statusCode == 401) {
      return Result.unauthorized(response);
    }

    if (response.statusCode >= 500 && response.statusCode <= 599) {
      return Result.serverError(response);
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    final result = resultCallback(json);

    return Result.ok(result);
  }

  Future<http.Response> _doRequest(
    String method,
    String path,
    Map<String, dynamic>? queryParameters,
    String? body,
  ) async {
    // TODO Cache client?
    var client = http.Client();
    try {
      // TODO Cancellation
      final uri = Uri.https('api.github.com', path, queryParameters);
      final headers = {
          'Accept': 'application/vnd.github.v3+json',
          if (_token != null)
            'Authorization': 'token $_token',
        };

      late http.Response response;
      for (var attempt = 0; attempt < 3; attempt++) {
        // TODO: Wait if rate limited...
        // TODO: Logging...
        debugPrint('$method $uri...');
        final stopwatch = Stopwatch()..start();
        final request = http.Request(method, uri)
          ..headers.addAll(headers);
        if (body != null) {
          request.body = body;
        }

        final streamed = await client.send(request);

        response = await http.Response.fromStream(streamed);

        if (response.statusCode >= 500 && response.statusCode <= 599) {
          debugPrint('$method $uri: ${response.statusCode}, retrying...');
          continue;
        }

        debugPrint(
          '$method $uri: status ${response.statusCode} in '
          '${stopwatch.elapsedMilliseconds}ms',
        );
        return response;
      }

      return response;
    } finally {
      client.close();
    }
  }
}

enum ResultKind {
  ok,
  serverError,
  unauthorized,
}

sealed class Result<T> {
  const Result();

  const factory Result.serverError(http.Response response) = ServerErrorResult;
  const factory Result.unauthorized(http.Response response) = UnauthorizedResult;
  const factory Result.ok(T data) = OkResult;

  T get requireData {
    return switch (this) {
      OkResult<T>(:final data) => data,
      _ => throw 'Error result does not have data',
    };
  }
}

class ServerErrorResult<T> extends Result<T> {
  const ServerErrorResult(this.response);

  final http.Response response;
}

class UnauthorizedResult<T> extends Result<T> {
  const UnauthorizedResult(this.response);

  final http.Response response;
}

class OkResult<T> extends Result<T> {
  const OkResult(this.data);

  final T data;
}

const searchPullRequestsQuery = r'''
query Search($first: Int, $query: String!) {
  search(type: ISSUE, first: $first, query: $query) {
    issueCount
    edges {
      node {
        ...IssueOrPullRequestFields
      }
    }
  }
}

fragment IssueOrPullRequestFields on IssueOrPullRequest {
  __typename
  ... on PullRequest {
    isDraft
    number
    state
    reviewDecision
    title
    totalCommentsCount
    updatedAt
    url
    author {
      avatarUrl
      login
    }
    repository {
      nameWithOwner
    }
  }
  ... on PullRequest {
    number
    state
    title
    updatedAt
    url
    author {
      avatarUrl
      login
    }
    repository {
      nameWithOwner
    }
  }
}
''';