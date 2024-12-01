import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'following_settings.dart';
import 'model.dart';
import 'profile_settings.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.model});

  final SettingsModel model;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();

    unawaited(widget.model.loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: const Text('Settings'),
      child: Column(
        children: [
          const SizedBox(height: 8.0),

          ProfileSettings(model: widget.model.profile),

          const SizedBox(height: 32.0),

          FollowingSettings(model: widget.model),
        ],
      ),
    );
  }
}
