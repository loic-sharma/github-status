import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart';
import 'package:gh_status/src/github/github.dart' as github;

import 'colors.dart';

class IssueIcon extends StatelessWidget {
  const IssueIcon({
    super.key,
    required this.type,
    required this.state,
    required this.isDraft,
    this.size,
  });

  final github.ItemType type;
  final github.ItemState state;
  final bool isDraft;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      switch (type) {
        github.ItemType.issue => OctIcons.issue_opened_16,
        // TODO: OctIcons.git_merge_16 if merged
        github.ItemType.pullRequest => OctIcons.git_pull_request_16,
        // TODO
        // Releases
        // Discussions: OctIcons.comment_discussion_16
        _ => throw 'TODO',
      },
      color: switch (state) {
        // TODO: Closed issue that is marked completed should be HubbubColors.done_fg
        github.ItemState.closed => Colors.closedForeground,
        github.ItemState.merged => Colors.doneForeground,
        github.ItemState.open => switch(isDraft) {
          true => Colors.neutralEmphasis,
          false => Colors.openForeground,
        },
      },
      size: size,
    );
  }
}
