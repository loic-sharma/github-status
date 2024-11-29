import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text('Settings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          Text(
            'Following',
            style: theme.textTheme.list.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          ShadInput(initialValue: 'cbracken',),
          ShadInput(initialValue: 'cbracken',),
          ShadInput(initialValue: 'cbracken',),
          ShadInput(initialValue: 'cbracken',),

          Row(
            children: [
              ShadButton.outline(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16.0,),
                child: const Text('Add'),
              ),
              ShadButton(
                onPressed: () {},
                icon: const Icon(Icons.save, size: 16.0),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
