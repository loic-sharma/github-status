import 'package:context_watch/context_watch.dart';
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
    yours.total.watch(context);
    following.watch(context);

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
              child: switch(yours.total.value) {
                LoadingValue _ => const Text('Yours (...)'),
                ErrorValue _ => const Text('Yours'),
                DataValue(: var value) => Text('Yours ($value)'),
              },
            ),
            ShadTab(
              value: 'team',
              content: FollowingTabContent(following: following),
              child: switch(following.items) {
                LoadingValue _ => const Text('Following (...)'),
                ErrorValue _ => const Text('Following'),
                DataValue(: var value) => Text('Following (${value.results})'),
              },
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
  final AsyncValue<int> items;

  @override
  Widget build(BuildContext context) {
    return switch(items) {
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
    following.watch(context);

    return ShadCard(
      title: const Text('Following'),
      child: IssueList(
        model: following.items,
      ),
    );
  }
}
