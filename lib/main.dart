
import 'package:flutter/material.dart';
import 'package:gh_status/github.dart' as github;
import 'package:gh_status/primer.dart' as primer;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
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
              child: const Text('Yours (10)'),
              content: ShadCard(
                title: const Text('Yours'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShadAccordion.multiple(
                      initialValue: ['created', 'mentioned', 'review-requests', 'assigned'],
                      children: [
                        ShadAccordionItem(
                          value: 'created',
                          title: Wrap(
                            children: [
                              Text('Created'),
                              SizedBox(width: 4.0),
                              Text(
                                '(15)',
                                style: TextStyle(color: ShadTheme.of(context).textTheme.muted.color),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              IssueTile(
                                type: github.ItemType.pullRequest,
                                state: github.ItemState.open,
                                isDraft: false,
                                title: 'This is my PR',
                              ),
                              SizedBox(height: 4.0),
                              IssueTile(
                                type: github.ItemType.pullRequest,
                                state: github.ItemState.open,
                                isDraft: false,
                                title: 'This is my PR',
                              ),
                              SizedBox(height: 4.0),
                              IssueTile(
                                type: github.ItemType.pullRequest,
                                state: github.ItemState.open,
                                isDraft: false,
                                title: 'This is my PR',
                              ),
                            ],
                          ),
                        ),
                        ShadAccordionItem(value: 'mentioned', title: Text('Mentioned'), child: Text('...')),
                        ShadAccordionItem(value: 'review-requests', title: Text('Review requests'), child: Text('...')),
                        ShadAccordionItem(value: 'assigned', title: Text('Assigned'), child: Text('...')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ShadTab(
              value: 'team',
              child: const Text('Team (5)'),
              content: ShadCard(
                title: const Text('Team'),
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

class IssueTile extends StatelessWidget {
  const IssueTile({
    super.key,
    required this.type,
    required this.state,
    required this.isDraft,
    required this.title,
  });

  final github.ItemType type;
  final github.ItemState state;
  final bool isDraft;
  final String title;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse('https://google.com');
    final spacer = const SizedBox(width: 6.0);

    return Row(
      children: [
        AvatarIcon(
          iconUri: Uri.parse('https://avatars.githubusercontent.com/u/737941?v=4'),
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
    
        spacer,
    
        Link(
          uri: uri,
          child: primer.IssueLabel(
            name: 'Approved',
            color: primer.Colors.openForeground,
          ),
        ),
    
        spacer,
    
        Link(
          uri: uri,
          child: Text(
            '5m',
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
