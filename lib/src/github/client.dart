import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

class GitHub {
  const GitHub({required String? token}) : _token = token;

  final String? _token;

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
      return const Result.unauthorized();
    }

    if (response.statusCode >= 500 && response.statusCode <= 599) {
      return const Result.serverError();
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

  const factory Result.serverError() = ServerErrorResult;
  const factory Result.unauthorized() = UnauthorizedResult;
  const factory Result.ok(T data) = OkResult;

  T get requireData {
    return switch (this) {
      OkResult<T>(:final data) => data,
      _ => throw 'Error result does not have data',
    };
  }
}

class ServerErrorResult<T> extends Result<T> {
  const ServerErrorResult();
}

class UnauthorizedResult<T> extends Result<T> {
  const UnauthorizedResult();
}

class OkResult<T> extends Result<T> {
  const OkResult(this.data);

  final T data;
}

const searchPullRequestsQuery = r'''
query Search($first: Int, $query: String!) {
  search(type: ISSUE, first: $first, query: $query) {
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