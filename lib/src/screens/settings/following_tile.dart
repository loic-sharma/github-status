
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../ui/avatar.dart';
import '../../ui/link.dart';
import 'model.dart';

class FollowingTile extends StatelessWidget {
  const FollowingTile({
    super.key,
    required this.user,
    this.onUpdated,
    this.onDeleted,
  });

  final FollowedUser user;
  final void Function(String)? onUpdated;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return switch (user) {
      ViewUser viewUser => _UserTile(
        login: viewUser.login,
        iconUri: viewUser.avatarUri,
        profileUri: viewUser.profileUri,
        onEdited: viewUser.edit,
        onDeleted: viewUser.delete,
      ),

      AddUser addUser => _EditUser(
        initialLogin: '',
        onSaved: addUser.save,
        onCancel: addUser.cancel,
      ),

      EditUser editUser => _EditUser(
        initialLogin: editUser.initialLogin,
        onSaved: editUser.save,
        onCancel: editUser.cancel,
      ),
    };
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    super.key,
    required this.login,
    required this.iconUri,
    required this.profileUri,
    this.onEdited,
    this.onDeleted,
  });

  final String login;
  final Uri iconUri;
  final Uri profileUri;

  final VoidCallback? onEdited;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarIcon(
          iconUri: iconUri,
          userUri: profileUri,
        ),

        const SizedBox(width: 8.0),

        Expanded(
          child: Link(
            uri: profileUri,
            child: Text(login),
          ),
        ),

        ShadButton.outline(
          onPressed: onDeleted,
          icon: const Icon(material.Icons.delete, size: 12.0),
        ),

        ShadButton.outline(
          icon: const Icon(material.Icons.edit, size: 12.0),
          onPressed: onEdited,
        ),
      ],
    );
  }
}

class _EditUser extends StatefulWidget {
  const _EditUser({
    super.key,
    required this.initialLogin,
    this.onSaved,
    this.onCancel,
  });

  final String initialLogin;
  final void Function(String)? onSaved;
  final VoidCallback? onCancel;

  @override
  State<_EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<_EditUser> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLogin);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShadInput(controller: _controller),
        ),

        ShadButton.outline(
          onPressed: () => widget.onCancel?.call(),
          icon: const Icon(material.Icons.cancel, size: 12.0),
          child: const Text('Cancel'),
        ),

        ShadButton(
          onPressed: () => widget.onSaved?.call(_controller.text),
          icon: const Icon(material.Icons.save, size: 12.0),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
