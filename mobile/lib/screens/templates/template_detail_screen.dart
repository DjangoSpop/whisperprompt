import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TemplateDetailScreen extends StatelessWidget {
  final String templateSlug;

  const TemplateDetailScreen({
    super.key,
    required this.templateSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text('Template: $templateSlug'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start Session'),
            ),
          ],
        ),
      ),
    );
  }
}
