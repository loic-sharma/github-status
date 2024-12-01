import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gh_status/foundation/foundation.dart';
import 'package:gh_status/github/github.dart' as github;

import 'models.dart' as models;

models.YoursTab createYoursModel(github.GitHub client) {
  final model = models.YoursTab();
  _loadYoursModel(client, model);
  return model;
}

Future<void> _loadYoursModel(
  github.GitHub client,
  models.YoursTab model,
) async {
  await Future.wait([
    _updateIssueSearchModel(
      model.created,
      client,
      'is:open is:pr author:@me archived:false',
    ),
    _updateIssueSearchModel(
      model.reviewRequests,
      client,
      'sort:updated-desc is:open is:pr archived:false review-requested:@me',
    ),
    _updateIssueSearchModel(
      model.mentioned,
      client,
      'sort:updated-desc is:open is:pr archived:false mentions:@me',
    ),
    _updateIssueSearchModel(
      model.assigned,
      client,
      'sort:updated-desc is:open is:pr archived:false assignee:@me',
    ),
  ]);

  int totalResults = 0;
  if (model.created.value case DataValue<models.IssueSearch>(value: final created)) {
    totalResults += created.results;
  }
  if (model.reviewRequests.value case DataValue<models.IssueSearch>(value: final reviewRequests)) {
    totalResults += reviewRequests.results;
  }
  if (model.mentioned.value case DataValue<models.IssueSearch>(value: final mentioned)) {
    totalResults += mentioned.results;
  }
  if (model.assigned.value case DataValue<models.IssueSearch>(value: final assigned)) {
    totalResults += assigned.results;
  }

  model.total.value = AsyncValue.data(totalResults);
}

models.FollowingTab createFollowingModel(github.GitHub client) {
  final model = models.FollowingTab();
  unawaited(_loadFollowingModel(client, model));
  return model;
}

Future<void> _loadFollowingModel(
  github.GitHub client,
  models.FollowingTab model
) async {
  final following = [
    'cbracken',
    'hellohuanlin',
    'jmagman',
    'louisehsu',
  ];

  await _searchMultipleIssuesAndUpdateModel(
    model,
    client,
    queries: [
      for (final user in following)
        'is:open is:pr archived:false author:$user sort:updated-desc',
    ],
  );
}

Future<void> _updateIssueSearchModel(
  ValueNotifier<AsyncValue<models.IssueSearch>> model,
  github.GitHub client,
  String query,
) async {
  final result = await client.searchIssues(query);

  model.value = _createIssueSearchModel(result);
}

Future<void> _searchMultipleIssuesAndUpdateModel(
  models.FollowingTab model,
  github.GitHub client, {
  required List<String> queries,
}) async {
  final results = await Future.wait([
    for (final query in queries)
      client.searchIssues(query),
  ]);

  final raw = results.map(_createIssueSearchModel).toList();

  assert(raw.whereType<LoadingValue>().isEmpty);

  final errors = raw.whereType<ErrorValue>().toList();
  if (errors.isNotEmpty) {
    model.items = AsyncValue.error(
      error: errors.map((e) => e.error).join('\n\n'),
      stackTrace: errors.first.stackTrace,
    );
    return;
  }

  final data = raw.cast<DataValue<models.IssueSearch>>();
  var items = data
    .map((d) => d.value.items)
    .expand((i) => i).sortedBy((i) => i.updatedAt)
    .sortedByCompare((i) => i.updatedAt, (a, b) => b.compareTo(a))
    .toList();
  var resultsCount = data.map((d) => d.value.results).sum;

  model.items = AsyncValue.data(models.IssueSearch(
    results: resultsCount,
    items: items,
  ));
}

AsyncValue<models.IssueSearch> _createIssueSearchModel(
  github.Result<github.IssueSearch> result,
) {
  if (result case github.ServerErrorResult<github.IssueSearch>()) {
    return AsyncValue.error(
      error:
        'Server error\n'
        '${kDebugMode
          ? 'Status code: ${result.response.statusCode}\n'
            'Reason phrase: ${result.response.reasonPhrase}\n'
            'Body: ${result.response.body}\n'
          : ''
        }',
      stackTrace: StackTrace.current,
    );
  }

  if (result case github.UnauthorizedResult<github.IssueSearch>()) {
    return AsyncValue.error(
      error:
        'Unauthorized\n'
        '${kDebugMode
          ? 'Status code: ${result.response.statusCode}\n'
            'Reason phrase: ${result.response.reasonPhrase}\n'
            'Body: ${result.response.body}\n'
          : ''
        }',
      stackTrace: StackTrace.current,
    );
  }

  if (result case github.OkResult<github.IssueSearch>(:final data)) {
    final items = <models.IssueSearchItem>[];
    for (final item in data.items) {
      items.add(switch (item) {
        github.SearchResultPullRequest pull => models.IssueSearchItem(
          authorAvatarUri: pull.authorAvatarUrl,
          isDraft: pull.isDraft,
          lastUpdated: pull.updatedAt,
          reviewDecision: pull.reviewDecision,
          state: pull.state,
          title: pull.title,
          type: github.ItemType.pullRequest,
          updatedAt: pull.updatedAt,
          uri: pull.url,
        ),
        _ => throw 'Invalid type ${item.runtimeType}',
      });
    }

    return AsyncValue.data(models.IssueSearch(
      results: data.issueCount,
      items: items,
    ));
  }

  throw 'Unsupported GitHub issue search type ${result.runtimeType}';
}
