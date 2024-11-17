import 'package:context_watch/context_watch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gh_status/logic.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'issue_list.dart';

class Shell extends StatelessWidget {
  const Shell({super.key, required this.yours, required this.following});

  final YoursModel yours;
  final SimpleIssueSearchTabModel following;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: ShadTabs<String>(
          value: 'yours',
          tabBarConstraints: const BoxConstraints(maxWidth: 800),
          contentConstraints: const BoxConstraints(maxWidth: 800),
          tabs: [
            ShadTab(
              value: 'yours',
              content: YoursTabContent(yours: yours),
              child: Tab(
                name: 'Yours',
                items: yours.total,
              ),
            ),
            ShadTab(
              value: 'team',
              content: FollowingTabContent(following: following),
              child: Tab(
                name: 'Following',
                items: following.total,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Tab extends StatelessWidget {
  const Tab({
    super.key,
    required this.name,
    required this.items,
  });

  final String name;
  final ValueListenable<AsyncValue<int>> items;

  @override
  Widget build(BuildContext context) {
    items.watch(context);

    return switch(items.value) {
      LoadingValue _ => Text('$name (...)'),
      ErrorValue _ => Text(name),
      DataValue(: var value) => Text('$name ($value)'),
    };
  }
}

class YoursTabContent extends StatelessWidget {
  const YoursTabContent({
    super.key,
    required this.yours,
  });

  final YoursModel yours;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: const Text('Yours'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadAccordion.multiple(
            initialValue: ['created', 'review-requests', 'mentioned', 'assigned'],
            children: [
              IssueListAccordion(
                accordionKey: 'created',
                accordionTitle: 'Created',
                model: yours.created,
              ),
              IssueListAccordion(
                accordionKey: 'review-requests',
                accordionTitle: 'Review requests',
                model: yours.reviewRequests,
              ),
              IssueListAccordion(
                accordionKey: 'mentioned',
                accordionTitle: 'Mentioned',
                model: yours.mentioned,
              ),
              IssueListAccordion(
                accordionKey: 'assigned',
                accordionTitle: 'Assigned',
                model: yours.assigned,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FollowingTabContent extends StatelessWidget {
  const FollowingTabContent({
    super.key,
    required this.following,
  });

  final SimpleIssueSearchTabModel following;

  @override
  Widget build(BuildContext context) {
    following.items.watch(context);

    return ShadCard(
      title: const Text('Following'),
      child: IssueList(
        model: following.items.value,
      ),
    );
  }
}
