import 'package:context_watch/context_watch.dart';
import 'package:flutter/widgets.dart';
import 'package:gh_status/foundation/foundation.dart';
import 'package:gh_status/github/github.dart' as github;
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../settings/model.dart';
import '../../settings/settings.dart';
import '../models.dart' as models;
import 'issue_list.dart';

class Inbox extends StatefulWidget {
  const Inbox({
    super.key,
    required this.client,
    required this.yours,
    required this.following});

  final github.GitHub client;
  final models.YoursTab yours;
  final models.FollowingTab following;

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  String tab = 'yours';

  // TODO: Don't initialize settings mdoel here.
  late SettingsModel settingsModel;

  @override
  void initState() {
    super.initState();
     settingsModel = SettingsModel(widget.client);
  }

  @override
  Widget build(BuildContext context) {
    widget.yours.total.watch(context);
    widget.following.watch(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: ShadTabs<String>(
          value: tab,
          tabBarConstraints: const BoxConstraints(maxWidth: 800),
          contentConstraints: const BoxConstraints(maxWidth: 800),
          tabs: [
            ShadTab(
              value: 'yours',
              content: YoursTabContent(yours: widget.yours),
              onPressed: () => setState(() => tab = 'yours'),
              child: switch (widget.yours.total.value) {
                LoadingValue _ => const Text('Yours (...)'),
                ErrorValue _ => const Text('Yours'),
                DataValue(: var value) => Text('Yours ($value)'),
              },
            ),
            ShadTab(
              value: 'team',
              content: FollowingTabContent(following: widget.following),
              onPressed: () => setState(() => tab = 'team'),
              child: switch (widget.following.items) {
                LoadingValue _ => const Text('Following (...)'),
                ErrorValue _ => const Text('Following'),
                DataValue(: var value) => Text('Following (${value.results})'),
              },
            ),
            ShadTab(
              value: 'settings',
              content: Settings(model: settingsModel),
              onPressed: () => setState(() => tab = 'settings'),
              child: const Text('Settings'),
            )
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

  final models.YoursTab yours;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: const Text('Yours'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShadAccordion.multiple(
            initialValue: const ['created', 'review-requests', 'mentioned', 'assigned'],
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

  final models.FollowingTab following;

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
