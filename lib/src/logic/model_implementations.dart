import 'package:flutter/foundation.dart';

import 'package:gh_status/github.dart' as github;

import 'async.dart';
import 'models.dart';

class _AppModel implements AppModel {
  _AppModel({required this.githubClient});

  final github.GitHub githubClient;

  @override
  final AppTabsModel tabs = _AppTabsModel();

}

class _AppTabsModel with ChangeNotifier implements AppTabsModel {
  @override
  final List<AppTabModel> tabs = [
    _AppTabModel(key: 'created', label: 'Created'),
    _AppTabModel(key: 'mentioned', label: 'Mentioned'),
    _AppTabModel(key: 'reviewRequests', label: 'Review requests'),
    _AppTabModel(key: 'assigned', label: 'Assigned'),
  ];
}

class _AppTabModel with ChangeNotifier implements AppTabModel {
  _AppTabModel({required this.key, required this.label});

  @override
  final String key;
  @override
  final String label;

  @override
  int? value;

  @override
  void open() {
  }
}

class _YoursModel implements YoursModel {
  @override
  final ValueNotifier<AsyncValue<IssueSearchModel>> created = ValueNotifier(const LoadingValue<IssueSearchModel>());
  @override
  final ValueNotifier<AsyncValue<IssueSearchModel>> mentioned = ValueNotifier(const LoadingValue<IssueSearchModel>());
  @override
  final ValueNotifier<AsyncValue<IssueSearchModel>> reviewRequests = ValueNotifier(const LoadingValue<IssueSearchModel>());
  @override
  final ValueNotifier<AsyncValue<IssueSearchModel>> assigned = ValueNotifier(const LoadingValue<IssueSearchModel>());
}

class _IssueSearchModel with ChangeNotifier implements IssueSearchModel {
  _IssueSearchModel({
    required this.results,
    required this.items,
  });

  @override
  final int results;
  @override
  final List<github.SearchResultIssueOrPullRequest> items;
}
