import 'package:flutter/foundation.dart';
import 'package:gh_status/foundation.dart';
import 'package:gh_status/github.dart' as github;

class YoursModel {
  AsyncValueNotifier<int> total = ValueNotifier(const LoadingValue<int>());

  AsyncValueNotifier<IssueSearch> created = ValueNotifier(const LoadingValue<IssueSearch>());

  AsyncValueNotifier<IssueSearch> mentioned = ValueNotifier(const LoadingValue<IssueSearch>());

  AsyncValueNotifier<IssueSearch> reviewRequests = ValueNotifier(const LoadingValue<IssueSearch>());

  AsyncValueNotifier<IssueSearch> assigned = ValueNotifier(const LoadingValue<IssueSearch>());
}

class IssueSearchTabModel with ChangeNotifier {
  AsyncValue<IssueSearch> get items => _items;
  AsyncValue<IssueSearch> _items = const LoadingValue<IssueSearch>();
  set items(AsyncValue<IssueSearch> value) {
    _items = value;
    notifyListeners();
  }
}

class IssueSearch {
  IssueSearch({
    required this.results,
    required this.items,
  });

  final int results;
  final List<IssueSearchItem> items;
}

class IssueSearchItem {
  IssueSearchItem({
    required this.authorAvatarUri,
    required this.isDraft,
    required this.lastUpdated,
    required this.reviewDecision,
    required this.state,
    required this.title,
    required this.type,
    required this.updatedAt,
    required this.uri,
  });

  final Uri authorAvatarUri;
  final bool isDraft;
  final DateTime lastUpdated;
  final github.ReviewDecision? reviewDecision;
  final github.ItemState state;
  final String title;
  final github.ItemType type;
  final DateTime updatedAt;
  final Uri uri;
}
