import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../ui/avatar.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: Text('Settings'),
      child: Column(
        children: [
          const SizedBox(height: 8.0),

          GitHubSettings(),

          const SizedBox(height: 32.0),

          FollowingSettings(),
        ],
      ),
    );
  }
}

class GitHubSettings extends StatelessWidget {
  const GitHubSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GitHub',
          style: theme.textTheme.list.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            AvatarIcon(
              iconUri: Uri.parse('https://avatars.githubusercontent.com/u/737941?v=4'),
              userUri: Uri.parse('https://github.com/loic-sharma'),
              size: 32.0,
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loic Sharma'),
                Text('@loic-sharma'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        ShadButton.outline(
          onPressed: () {
            // TODO: Logout
          },
          icon: const Icon(Icons.logout, size: 16.0),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

class FollowingSettings extends StatelessWidget {
  const FollowingSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Following',
          style: theme.textTheme.list.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),

        for (final user in ['cbracken', 'cbracken', 'cbracken'])
          Row(
            children: [
              Expanded(child: ShadInput(initialValue: user,)),
              ShadButton.outline(
                onPressed: () {
                  // TODO: Open user profile in browser.
                },
                icon: const Icon(Icons.open_in_new, size: 12.0),
              ),
            ],
          ),

        Row(
          children: [
            ShadButton.outline(
              onPressed: () {
                // TODO: Add new field
              },
              icon: const Icon(Icons.add, size: 16.0,),
              child: const Text('Add'),
            ),
            ShadButton(
              onPressed: () {
                // TODO: Save changes
              },
              icon: const Icon(Icons.save, size: 16.0),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
