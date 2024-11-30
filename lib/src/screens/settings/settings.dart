import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart';
import 'package:gh_status/foundation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../ui.dart';
import '../../ui/avatar.dart';
import 'following_tile.dart';
import 'model.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  final SettingsModel model = SettingsModel();

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: Text('Settings'),
      child: Column(
        children: [
          const SizedBox(height: 8.0),

          GitHubSettings(model: model.profile),

          const SizedBox(height: 32.0),

          FollowingSettings(model: model),
        ],
      ),
    );
  }
}

class GitHubSettings extends StatelessWidget {
  const GitHubSettings({
    super.key,
    required this.model,
    this.onLogout,
  });

  final AsyncValueListenable<ProfileModel> model;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    model.watch(context);

    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GitHub',
          style: theme.textTheme.list.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),

        switch (model.value) {
          LoadingValue _ => const CircularProgressIndicator(),
          ErrorValue _ => const Text('Error loading profile.'),
          DataValue(value: final profile) => Row(
            children: [
              AvatarIcon(
                iconUri: profile.avatar,
                userUri: profile.uri,
                size: 32.0,
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Link(
                    uri: profile.uri,
                    child: Text(profile.name),
                  ),
                  Link(
                    uri: profile.uri,
                    child: Text('@${profile.login}'),
                  ),
                ],
              ),
            ],
          ),
        },
        const SizedBox(height: 8.0),
        ShadButton.outline(
          onPressed: () => onLogout?.call(),
          icon: const Icon(Icons.logout, size: 16.0),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

class FollowingSettings extends StatelessWidget {
  const FollowingSettings({super.key, required this.model});

  final SettingsModel model;

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

        ListenableBuilder(
          listenable: model.following,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final user in model.following.users)
                FollowingTile(user: user),
            ],
          ),
        ),

        Row(
          children: [
              ShadButton.outline(
              onPressed: () {
                model.following.addUser();
              },
              icon: const Icon(Icons.add, size: 16.0,),
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
