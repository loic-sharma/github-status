/// The unique identifier for a GitHub issue or pull request.
class ItemIdentifier {
  const ItemIdentifier({
    required this.owner,
    required this.repo,
    required this.id,
  });

  final String owner;
  final String repo;
  final int id;
}

class IssueSearch {
  IssueSearch({
    required this.items,
  });

  final List<SearchResultIssueOrPullRequest> items;

  factory IssueSearch.fromJson(Map<String, dynamic> json) {
    final edges = json['data']?['search']?['edges'] as List<dynamic>? ?? const [];

    final items = <SearchResultIssueOrPullRequest>[];
    for (final edge in edges) {
      final node = edge['node'] as Map<String, dynamic>?;

      if (node == null) continue;

      items.add(SearchResultIssueOrPullRequest.fromJson(node));
    }

    return IssueSearch(
      items: items,
    );
  }
}

/// A GitHub search issue or pull request item.
sealed class SearchResultIssueOrPullRequest {
  const SearchResultIssueOrPullRequest();

  factory SearchResultIssueOrPullRequest.fromJson(Map<String, dynamic> json) {
    return switch (ItemType.fromString(json['__typename'])) {
      ItemType.pullRequest => SearchResultPullRequest.fromJson(json),
      _ => throw 'Invalid type ${json['__typename']}',
    };
  }
}

class SearchResultPullRequest extends SearchResultIssueOrPullRequest {
  const SearchResultPullRequest({
    required this.authorLogin,
    required this.isDraft,
    required this.number,
    required this.repositoryNameWithOwner,
    required this.reviewDecision,
    required this.state,
    required this.title,
    required this.totalCommentsCount,
    required this.updatedAt,
    required this.url,
  });

  final String authorLogin;
  final bool isDraft;
  final int number;
  final String repositoryNameWithOwner;
  final ReviewDecision? reviewDecision;
  final ItemState state;
  final String title;
  final int totalCommentsCount;
  final DateTime updatedAt;
  final Uri url;

  factory SearchResultPullRequest.fromJson(Map<String, dynamic> json) {
    assert(json['__typename'] == 'PullRequest');
    assert(json.containsKey('author'));
    assert(json.containsKey('repository'));

    final reviewDecision = json['reviewDecision'] as String?;

    return SearchResultPullRequest(
      authorLogin: json['author']['login'],
      isDraft: json['isDraft'],
      number: json['number'],
      repositoryNameWithOwner: json['repository']['nameWithOwner'],
      reviewDecision: reviewDecision != null ? ReviewDecision.fromString(reviewDecision) : null,
      state: ItemState.fromString(json['state']),
      title: json['title'],
      totalCommentsCount: json['totalCommentsCount'],
      updatedAt: DateTime.parse(json['updatedAt']),
      url: Uri.parse(json['url']),
    );
  }
}

class Label {
  Label(this.name, this.color);

  final String name;
  final String color;
}

enum ItemType {
  discussion,
  issue,
  pullRequest;

  static ItemType fromString(String value) {
    return switch (value) {
      'Discussion' => discussion,
      'Issue' => issue,
      'PullRequest' => pullRequest,
      _ => throw 'Invalid type $value',
    };
  }
}

enum ItemState {
  closed,
  merged,
  open;

  static ItemState fromString(String value) {
    return switch (value) {
      'CLOSED' => closed,
      'MERGED' => merged,
      'OPEN' => open,
      _ => throw 'Invalid state $value',
    };
  }
}

enum IssueStateReason {
  completed,
  notPlanned,
  reopened;

  static IssueStateReason fromString(String value) {
    return switch (value) {
      'COMPLETED' => completed,
      'NOT_PLANNED' => notPlanned,
      'REOPENED' => reopened,
      _ => throw 'Invalid issue state reason $value',
    };
  }
}

enum ReviewDecision {
  approved,
  changesRequested,
  reviewRequired;

  static ReviewDecision fromString(String value) {
    return switch (value) {
      'APPROVED' => approved,
      'CHANGES_REQUESTED' => changesRequested,
      'REVIEW_REQUIRED' => reviewRequired,
      _ => throw 'Invalid review decision $value',
    };
  }
}

enum ReviewState {
  approved,
  changesRequested,
  commented,
  dismissed,
  pending;

  static ReviewState fromString(String value) {
    return switch (value) {
      'APPROVED' => approved,
      'CHANGES_REQUESTED' => changesRequested,
      'COMMENTED' => commented,
      'DISMISSED' => dismissed,
      'PENDING' => pending,
      _ => throw 'Invalid state $value',
    };
  }
}

class User {
  const User({
    required this.login,
    required this.name,
    required this.avatarUrl,
    required this.url
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'],
      name: json['name'],
      avatarUrl: Uri.parse(json['avatar_url']),
      url: Uri.parse(json['html_url']),
    );
  }

  final String login;
  final String name;
  final Uri avatarUrl;
  final Uri url;
}
