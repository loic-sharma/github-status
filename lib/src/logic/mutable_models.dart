import 'package:flutter/foundation.dart';

import 'package:gh_status/github.dart' as github;

import 'async.dart';
import 'models.dart';

class MutableAppModel implements AppModel {
  MutableAppModel({required this.githubClient});

  final github.GitHub githubClient;
}

class MutableYoursModel implements YoursModel {
  @override
  AsyncValueNotifier<int> total = ValueNotifier(const LoadingValue<int>());

  @override
  AsyncValueNotifier<IssueSearchModel> created = ValueNotifier(const LoadingValue<IssueSearchModel>());

  @override
  AsyncValueNotifier<IssueSearchModel> mentioned = ValueNotifier(const LoadingValue<IssueSearchModel>());

  @override
  AsyncValueNotifier<IssueSearchModel> reviewRequests = ValueNotifier(const LoadingValue<IssueSearchModel>());

  @override
  AsyncValueNotifier<IssueSearchModel> assigned = ValueNotifier(const LoadingValue<IssueSearchModel>());
}

class MutableSimpleIssueSearchTabModel implements SimpleIssueSearchTabModel {
  @override
  AsyncValueNotifier<int> total = ValueNotifier(const LoadingValue<int>());

  @override
  AsyncValueNotifier<IssueSearchModel> items = ValueNotifier(const LoadingValue<IssueSearchModel>());
}

typedef AsyncValueNotifier<T> = ValueNotifier<AsyncValue<T>>;
