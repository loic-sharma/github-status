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

class IssueSearchModel {
  IssueSearchModel({
    required this.results,
    required this.items,
  });

  final int results;
  final List<IssueSearchItemModel> items;
}

class IssueSearchItemModel {
  IssueSearchItemModel({
    required this.isDraft,
    required this.lastUpdated,
    required this.reviewDecision,
    required this.state,
    required this.title,
    required this.type,
    required this.uri,
  });

  final bool isDraft;
  final DateTime lastUpdated;
  final github.ReviewDecision? reviewDecision;
  final github.ItemState state;
  final String title;
  final github.ItemType type;
  final Uri uri;
}
