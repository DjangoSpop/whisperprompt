import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.description, color: Colors.white),
              ),
              title: Text('Template ${index + 1}'),
              subtitle: const Text('Tap to view details'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
