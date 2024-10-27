import 'package:flutter/foundation.dart';

import 'package:gh_status/github.dart' as github;

import 'async.dart';

abstract class AppModel {
  AppTabsModel get tabs;
}

abstract class AppTabsModel implements Listenable {
  List<AppTabModel> get tabs;
}

abstract class AppTabModel implements Listenable {
  String get key;
  String get label;
  int? get value;

  void open();
}

abstract class YoursModel {
  ValueListenable<AsyncValue<IssueSearchModel>> get created;
  ValueListenable<AsyncValue<IssueSearchModel>> get mentioned;
  ValueListenable<AsyncValue<IssueSearchModel>> get reviewRequests;
  ValueListenable<AsyncValue<IssueSearchModel>> get assigned;
}

abstract class IssueSearchModel implements Listenable {
  int get results;
  List<github.SearchResultIssueOrPullRequest> get items;
}
