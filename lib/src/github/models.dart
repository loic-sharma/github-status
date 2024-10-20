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
