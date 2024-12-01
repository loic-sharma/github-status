import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:gh_status/foundation/foundation.dart';
import 'package:gh_status/ui/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'model.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({
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
          LoadingValue _ => const material.CircularProgressIndicator(),
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
          icon: const Icon(material.Icons.logout, size: 16.0),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
