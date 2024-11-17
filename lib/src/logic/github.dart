import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gh_status/github.dart' as github;
import 'package:gh_status/logic.dart';

import 'mutable_models.dart';

YoursModel createYoursModel(github.GitHub client) {
  final result = MutableYoursModel();

  unawaited(_updateIssueSearchModel(
    result.created,
    client,
    'is:open is:pr author:@me archived:false',
  ));
  unawaited(_updateIssueSearchModel(
    result.reviewRequests,
    client,
    'sort:updated-desc is:open is:pr archived:false review-requested:@me',
  ));
  unawaited(_updateIssueSearchModel(
    result.mentioned,
    client,
    'sort:updated-desc is:open is:pr archived:false mentions:@me',
  ));
  unawaited(_updateIssueSearchModel(
    result.assigned,
    client,
    'sort:updated-desc is:open is:pr archived:false assignee:@me',
  ));

  return result;
}

SimpleIssueSearchTabModel createFollowingModel(github.GitHub client) {
  final following = [
    'cbracken',
    'hellohuanlin',
    'jmagman',
    'louisehsu',
  ];

  final model = MutableSimpleIssueSearchTabModel();

  unawaited(_searchMultipleIssuesAndUpdateModel(
    model.items,
    client,
    queries: [
      for (final user in following)
        'is:open is:pr archived:false author:$user sort:updated-desc',
    ],
  ));

  return model;
}

Future<void> _updateIssueSearchModel(
  ValueNotifier<AsyncValue<IssueSearchModel>> model,
  github.GitHub client,
  String query,
) async {
  final result = await client.searchIssues(query);

  model.value = _createIssueSearchModel(result);
}

Future<void> _searchMultipleIssuesAndUpdateModel(
  ValueNotifier<AsyncValue<IssueSearchModel>> model,
  github.GitHub client, {
  required List<String> queries,
}) async {
  final results = await Future.wait([
    for (final query in queries)
      client.searchIssues(query),
  ]);

  final models = results.map(_createIssueSearchModel).toList();

  assert(models.whereType<LoadingValue>().isEmpty);

  final errors = models.whereType<ErrorValue>().toList();
  if (errors.isNotEmpty) {
    model.value = AsyncValue.error(
      error: errors.map((e) => e.error).join('\n\n'),
      stackTrace: errors.first.stackTrace,
    );
    return;
  }

  // TODO: Sort items by updated date
  final data = models.cast<DataValue<IssueSearchModel>>();
  var items = data.map((d) => d.value.items).expand((i) => i).toList();
  var resultsCount = data.map((d) => d.value.results).fold(0, (a, b) => a + b);

  model.value = AsyncValue.data(IssueSearchModel(
    results: resultsCount,
    items: items,
  ));
}

AsyncValue<IssueSearchModel> _createIssueSearchModel(
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
    final items = <IssueSearchItemModel>[];
    for (final item in data.items) {
      items.add(switch (item) {
        github.SearchResultPullRequest pull => IssueSearchItemModel(
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

    return AsyncValue.data(IssueSearchModel(
      results: data.issueCount,
      items: items,
    ));
  }

  throw 'Unsupported GitHub issue search type ${result.runtimeType}';
}
