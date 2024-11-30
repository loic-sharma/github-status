import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../config.dart';
import '../../ui/link.dart';
import 'device_flow.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
    this.onLogin,
  });

  final OnCompletedCallback? onLogin;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late DeviceFlowModel model;

  @override
  void initState() {
    super.initState();

    model = DeviceFlowModel.run(
      Config.githubClientId,
      Config.githubClientSecret,
      onCompleted: widget.onLogin,
    );
  }

  @override
  Widget build(BuildContext context) {
    model.watch(context);

    return _LoginLayout(
      child: switch (model.state) {
        StartingState _ => const Text('Starting...'),
        // TODO: Improve error handling.
        ErrorState _ => const Text('Error'),
        CompletedState _ => const Text('Completed'),
        WaitingState(: final verificationUri, : final userCode) => _Waiting(
          nextRefreshSeconds: model.nextRefreshSeconds,
          verificationUri: verificationUri,
          userCode: userCode,
        ),
      },
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({
    super.key,
    required this.nextRefreshSeconds,
    required this.verificationUri,
    required this.userCode,
  });

  final int nextRefreshSeconds;
  final Uri verificationUri;
  final String userCode;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: 'Open '),
              TextSpan(
                text: verificationUri.toString(),
                style: const TextStyle(color: material.Colors.blue),
                recognizer: linkRecognizer(url: verificationUri),
              ),
              const TextSpan(text: ' and enter:'),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntrinsicWidth(
              child: ShadInputFormField(
                initialValue: userCode,
                readOnly: true,
              ),
            ),

            ShadButton.secondary(
              onPressed: () {},
              icon: const Icon(material.Icons.copy, size: 16),
              child: const Text('Copy'),
              onTapUp: (value) {
                Clipboard.setData(ClipboardData(text: userCode));
              },
            ),
          ],
        ),
    
        const SizedBox(height: 24),
    
        Text(
          'Refreshing in $nextRefreshSeconds seconds...',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}

class _LoginLayout extends StatelessWidget {
  const _LoginLayout({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 64.0),
        const Icon(OctIcons.mark_github_16, size: 100.0),
        const SizedBox(height: 16.0),
        Text(
          'Login to GitHub',
          style: theme.textTheme.h3,
        ),
        const SizedBox(height: 16.0),

        child,
      ],
    );
  }
}
