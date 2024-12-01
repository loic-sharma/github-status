import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:gh_status/foundation/foundation.dart';
import 'package:gh_status/github/github.dart' as github;
import 'package:gh_status/primer/primer.dart' as primer;
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../ui/avatar.dart';
import '../../../ui/link.dart';
import '../models.dart' as models;

class IssueListAccordion extends StatelessWidget {
  const IssueListAccordion({
    super.key,
    required this.accordionKey,
    required this.accordionTitle,
    required this.model,
  });

  final String accordionKey;
  final String accordionTitle;
  final AsyncValueListenable<models.IssueSearch> model;

  @override
  Widget build(BuildContext context) {
    model.watch(context);

    return ShadAccordionItem(
      value: accordionKey,
      title: Wrap(
        children: [
          Text(accordionTitle),
          const SizedBox(width: 4.0),
          Text(
            switch (model.value) {
              LoadingValue _ => '(...)',
              ErrorValue _ => '',
              DataValue(: var value) => '(${value.items.length.toString()})',
            },
            style: TextStyle(color: ShadTheme.of(context).textTheme.muted.color),
          ),
        ],
      ),
      child: IssueList(model: model.value),
    );
  }
}

class IssueList extends StatelessWidget {
  const IssueList({
    super.key,
    required this.model,
  });

  final AsyncValue<models.IssueSearch> model;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ... switch (model) {
          LoadingValue _ => const [ material.CircularProgressIndicator() ],
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
    const spacer = SizedBox(width: 6.0);

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
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
          ),
        ),

        if (reviewDecision != null && reviewDecision != github.ReviewDecision.reviewRequired) ...[
          spacer,

          Link(
            uri: uri,
            child: switch (reviewDecision) {
              github.ReviewDecision.approved => const primer.IssueLabel(
                name: 'Approved',
                color: primer.Colors.openForeground,
              ),
              github.ReviewDecision.changesRequested => const primer.IssueLabel(
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
            // TODO: Format using "Now", 5m, 3h, 3d, 3mo, 3y, etc..
            timeago.format(updatedAt),
            style: TextStyle(color: ShadTheme.of(context).textTheme.muted.color),
          ),
        ),
      ],
    );
  }
}

