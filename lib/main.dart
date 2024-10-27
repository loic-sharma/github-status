
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gh_status/github.dart' as github;
import 'package:gh_status/logic.dart';
import 'package:gh_status/primer.dart' as primer;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'src/logic/timeago.dart';

const client = github.GitHub(token: 'TODO');

YoursModel yours = createYoursModel(client);

void main() async {
  registerTimeago();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
        // Example with google fonts
        // textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),

        // Example of custom font family
        // textTheme: ShadTextTheme(family: 'UbuntuMono'),

        // Example to disable the secondary border
        // disableSecondaryBorder: true,
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
        // Example of custom font family
        // textTheme: ShadTextTheme(family: 'UbuntuMono'),
      ),
      home: Shell(),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});

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
              child: Text('Yours (15)'),
              content: ShadCard(
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
              ),
            ),
            ShadTab(
              value: 'team',
              child: const Text('Following (5)'),
              content: ShadCard(
                title: const Text('Following'),
                description: const Text(
                    "Change your password here. After saving, you'll be logged out."),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      label: const Text('Current password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    ShadInputFormField(
                      label: const Text('New password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                footer: const ShadButton(child: Text('Save password')),
              ),
            ),
            ShadTab(
              value: 'ios-triage',
              child: const Text('iOS triage (3)'),
              content: ShadCard(
                title: const Text('iOS triage'),
                description: const Text(
                    "Change your password here. After saving, you'll be logged out."),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      label: const Text('Current password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    ShadInputFormField(
                      label: const Text('New password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                footer: const ShadButton(child: Text('Save password')),
              ),
            ),
            ShadTab(
              value: 'desktop-triage',
              child: const Text('Desktop triage (3)'),
              content: ShadCard(
                title: const Text('Desktop triage'),
                description: const Text(
                    "Change your password here. After saving, you'll be logged out."),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      label: const Text('Current password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    ShadInputFormField(
                      label: const Text('New password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                footer: const ShadButton(child: Text('Save password')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IssueListAccordion extends StatelessWidget {
  const IssueListAccordion({
    super.key,
    required this.accordionKey,
    required this.accordionTitle,
    required this.model,
  });

  final String accordionKey;
  final String accordionTitle;
  final ValueListenable<AsyncValue<IssueSearchModel>> model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, child) {
        return ShadAccordionItem(
          value: accordionKey,
          title: Wrap(
            children: [
              Text(accordionTitle),
              const SizedBox(width: 4.0),
              Text(
                switch (model.value) {
                  LoadingValue _ || ErrorValue _ => '(...)',
                  DataValue(: var value) => '(${value.items.length.toString()})',
                },
                style: TextStyle(color: ShadTheme.of(context).textTheme.muted.color),
              ),
            ],
          ),
          child: IssueList(model: model.value),
        );
      },
    );
  }
}

class IssueList extends StatelessWidget {
  const IssueList({
    super.key,
    required this.model,
  });

  final AsyncValue<IssueSearchModel> model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ... switch (model) {
          LoadingValue _ => const [ CircularProgressIndicator() ],
          ErrorValue(: var error) => [ Text('Error: $error') ],
          DataValue(: var value) => [
            for (final item in value.items) ...[
              IssueTile(
                authorAvatarUri: item.authorAvatarUri,
                isDraft: item.isDraft,
                reviewDecision: item.reviewDecision,
                state: item.state,
                title: item.title,
                type: item.type,
                updatedAt: item.updatedAt,
                uri: item.uri,
              ),
              const SizedBox(height: 4.0),
            ],
          ],
        },
      ],
    );
  }
}

class IssueTile extends StatelessWidget {
  const IssueTile({
    super.key,
    required this.authorAvatarUri,
    required this.isDraft,
    required this.reviewDecision,
    required this.state,
    required this.title,
    required this.type,
    required this.updatedAt,
    required this.uri,
  });

  final Uri authorAvatarUri;
  final bool isDraft;
  final github.ReviewDecision? reviewDecision;
  final github.ItemState state;
  final String title;
  final github.ItemType type;
  final DateTime updatedAt;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final spacer = const SizedBox(width: 6.0);

    return Row(
      children: [
        AvatarIcon(
          iconUri: authorAvatarUri,
          userUri: uri,
        ),

        spacer,

        Link(
          uri: uri,
          child: primer.IssueIcon(
            type: type,
            state: state,
            isDraft: isDraft,
            size: 16.0,
          ),
        ),
    
        spacer,
    
        Expanded(
          child: Link(
            uri: uri,
            child: Text(
              title,
              style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
          ),
        ),

        if (reviewDecision != null && reviewDecision != github.ReviewDecision.reviewRequired) ...[
          spacer,

          Link(
            uri: uri,
            child: switch (reviewDecision) {
              github.ReviewDecision.approved => primer.IssueLabel(
                name: 'Approved',
                color: primer.Colors.openForeground,
              ),
              github.ReviewDecision.changesRequested => primer.IssueLabel(
                name: 'Changes requested',
                color: primer.Colors.closedForeground,
              ),
              _ => throw 'Unknown review decision $reviewDecision',
            },
          ),
        ],

        spacer,
    
        Link(
          uri: uri,
          child: Text(
            timeago.format(updatedAt),
            style: TextStyle(color: ShadTheme.of(context).textTheme.muted.color),
          ),
        ),
      ],
    );
  }
}

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({
    super.key,
    required this.iconUri,
    required this.userUri,
    double? size,
  }) : size = size ?? 12.0;

  final Uri iconUri;
  final Uri userUri;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: userUri,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.fromSize(
          size: const Size.fromRadius(12),
          child: Image.network(
            iconUri.toString(),
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
        ),
      ),
    );
  }
}

class Link extends StatelessWidget {
  const Link({
    super.key,
    required this.uri,
    required this.child,
  });

  final Uri uri;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(uri),
        child: child,
      ),
    );
  }
}
