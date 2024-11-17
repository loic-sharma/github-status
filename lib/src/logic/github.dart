import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gh_status/github.dart' as github;
import 'package:gh_status/logic.dart';

import 'mutable_models.dart';

YoursModel createYoursModel(github.GitHub client) {
  final result = MutableYoursModel();

  unawaited(_searchIssues(
    client,
    'is:open is:pr author:@me archived:false',
    result.created,
  ));
  unawaited(_searchIssues(
    client,
    'sort:updated-desc is:open is:pr archived:false review-requested:@me',
    result.reviewRequests,
  ));
  unawaited(_searchIssues(
    client,
    'sort:updated-desc is:open is:pr archived:false mentions:@me',
    result.mentioned,
  ));
  unawaited(_searchIssues(
    client,
    'sort:updated-desc is:open is:pr archived:false assignee:@me',
    result.assigned,
  ));

  return result;
}

Future<void> _searchIssues(
  github.GitHub client,
  String query,
  ValueNotifier<AsyncValue<IssueSearchModel>> model,
) async {
  final result = await client.searchIssues(query);

  if (result case github.ServerErrorResult<github.IssueSearch>()) {
    model.value = AsyncValue.error(
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
    model.value = AsyncValue.error(
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
    return;
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

    model.value = AsyncValue.data(IssueSearchModel(
      results: data.issueCount,
      items: items,
    ));
    return;
  }
}
