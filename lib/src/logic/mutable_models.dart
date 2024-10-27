import 'package:flutter/foundation.dart';

import 'package:gh_status/github.dart' as github;

import 'async.dart';
import 'models.dart';

class MutableAppModel implements AppModel {
  MutableAppModel({required this.githubClient});

  final github.GitHub githubClient;

  @override
  final AppTabsModel tabs = MutableAppTabsModel();

}

class MutableAppTabsModel with ChangeNotifier implements AppTabsModel {
  @override
  final List<AppTabModel> tabs = [
    MutableAppTabModel(key: 'created', label: 'Created'),
    MutableAppTabModel(key: 'mentioned', label: 'Mentioned'),
    MutableAppTabModel(key: 'reviewRequests', label: 'Review requests'),
    MutableAppTabModel(key: 'assigned', label: 'Assigned'),
  ];
}

class MutableAppTabModel with ChangeNotifier implements AppTabModel {
  MutableAppTabModel({required this.key, required this.label});

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

class MutableYoursModel implements YoursModel {
  @override
  ValueNotifier<AsyncValue<IssueSearchModel>> created = ValueNotifier(const LoadingValue<IssueSearchModel>());

  @override
  ValueNotifier<AsyncValue<IssueSearchModel>> mentioned = ValueNotifier(const LoadingValue<IssueSearchModel>());

  @override
  ValueNotifier<AsyncValue<IssueSearchModel>> reviewRequests = ValueNotifier(const LoadingValue<IssueSearchModel>());

  @override
  ValueNotifier<AsyncValue<IssueSearchModel>> assigned = ValueNotifier(const LoadingValue<IssueSearchModel>());
}
