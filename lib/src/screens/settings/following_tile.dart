
import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gh_status/foundation.dart';
import 'package:gh_status/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../ui/avatar.dart';
import 'model.dart';

class FollowingTile extends StatefulWidget {
  const FollowingTile({
    super.key,
    required this.user,
    this.onUpdated,
    this.onDeleted,
  });

  final GitHubUser user;
  final void Function(String)? onUpdated;
  final VoidCallback? onDeleted;

  @override
  State<FollowingTile> createState() => _FollowingTileState();
}

class _FollowingTileState extends State<FollowingTile> {
  var _editing = false;

  @override
  Widget build(BuildContext context) {
    return _editing
      ? _UserForm(
          user: widget.user.login,
          onSaved: (username) {
            // TODO:
            setState(() {
              _editing = false;
            });
          },
          onCancel: () => setState(() => _editing = false),
        )
      : _UserTile(
          user: widget.user,
          onEdited: () => setState(() => _editing = true),
          onDeleted: widget.onDeleted,
        );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    super.key,
    required this.user,
    this.onEdited,
    this.onDeleted,
  });

  final GitHubUser user;
  final VoidCallback? onEdited;
  final VoidCallback? onDeleted;
  
  @override
  Widget build(BuildContext context) {
    user.watch(context);

    return Row(
      children: [
        switch (user.avatar) {
          DataValue<Uri>(value: final iconUri) => AvatarIcon(
            iconUri: iconUri,
            userUri: user.uri,
          ),
          // TODO
          _ => const CircularProgressIndicator(),
        },

        const SizedBox(width: 8.0),

        Expanded(
          child: Link(
            uri: user.uri,
            child: Text(user.login),
          ),
        ),

        ShadButton.outline(
          icon: const Icon(Icons.edit, size: 12.0),
          onPressed: onEdited,
        ),

        ShadButton.destructive(
          onPressed: onDeleted,
          icon: const Icon(Icons.delete, size: 12.0),
        ),
      ],
    );
  }
}

class _UserForm extends StatelessWidget {
  _UserForm({
    super.key,
    required this.user,
    this.onSaved,
    this.onCancel,
  });

  String user;
  void Function(String)? onSaved;
  VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: ShadInput(initialValue: user,)),

        ShadButton(
          onPressed: () => onSaved?.call(user),
          icon: const Icon(Icons.save, size: 12.0),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
