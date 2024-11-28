import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:gh_status/main.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../ui/link.dart';
import '../device_flow.dart';

class Login extends StatelessWidget {
  const Login({super.key, required this.model});

  final DeviceFlowModel model;

  @override
  Widget build(BuildContext context) {
    model.watch(context);


    return switch (model.state) {
      StartingState _ => const Text('Starting...'),
      ErrorState(: var error) => const Text('Error'),
      CompletedState(: var accessToken) => const Text('Completed'),
      WaitingState(: final verificationUri, : final userCode) => _Waiting(
        nextRefreshSeconds: model.nextRefreshSeconds,
        verificationUri: verificationUri,
        userCode: userCode,
      ),
    };
  }
}

class _Waiting extends material.StatelessWidget {
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
  Widget build(material.BuildContext context) {
    final theme = ShadTheme.of(context);

    return SizedBox(
      width: 480,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login to GitHub',
            style: theme.textTheme.h3,
          ),

          const SizedBox(height: 16),

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
                  initialValue: 'ABCD-EFGH',
                  readOnly: true,
                ),
              ),
      
              ShadButton.secondary(
                onPressed: () {},
                icon: const Icon(material.Icons.copy, size: 16),
                child: const Text('Copy'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Refreshing in $nextRefreshSeconds seconds...',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
