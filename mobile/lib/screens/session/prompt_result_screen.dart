import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PromptResultScreen extends StatelessWidget {
  final String prompt;
  final String historyId;

  const PromptResultScreen({
    super.key,
    required this.prompt,
    required this.historyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Prompt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(prompt),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.copy),
              label: const Text('Copy to Clipboard'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.volume_up),
              label: const Text('Read Aloud'),
            ),
          ],
        ),
      ),
    );
  }
}
