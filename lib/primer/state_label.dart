import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart';
import 'package:gh_status/github/github.dart' as github;

import 'colors.dart';

// See: https://primer.style/react/StateLabel
enum StateLabelKind {
  draft,
  issueClosed,
  issueClosedNotPlanned,
  issueDraft,
  issueOpened,
  pullClosed,
  pullMerged,
  pullOpened
}

class StateLabel extends StatelessWidget {
  const StateLabel({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  factory StateLabel.from(
    github.ItemType type,
    github.ItemState state,
    bool isDraft,
  ) {
    return StateLabel(
      color: switch (state) {
        github.ItemState.closed => Colors.closedEmphasis,
        github.ItemState.merged => Colors.doneEmphasis,
        github.ItemState.open when isDraft => Colors.neutralEmphasis,
        github.ItemState.open => Colors.openEmphasis,
      },
      icon: switch (type) {
        github.ItemType.issue => switch (state) {
          github.ItemState.closed => const Icon(OctIcons.issue_closed_16),
          github.ItemState.open => const Icon(OctIcons.issue_opened_16),
          github.ItemState.merged => throw 'Invalid issue state: $state',
        },
        github.ItemType.pullRequest => switch (state) {
          github.ItemState.closed => const Icon(OctIcons.git_pull_request_closed_16),
          github.ItemState.merged => const Icon(OctIcons.git_merge_16),
          github.ItemState.open => const Icon(OctIcons.git_pull_request_16),
        },
        github.ItemType.discussion => throw 'Unsupported item type: $type',
      },
      label: switch (state) {
        github.ItemState.closed => const Text('Closed'),
        github.ItemState.merged => const Text('Merged'),
        github.ItemState.open => const Text('Open'),
      },
    );
  }

  final Color color;
  final Widget icon;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 12.0, right: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          label,
        ],
      ),
    );
  }
}
