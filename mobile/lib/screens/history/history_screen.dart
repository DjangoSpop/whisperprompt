import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListTile(
              leading: const Icon(Icons.history, color: AppColors.primary),
              title: Text('Prompt ${index + 1}'),
              subtitle: const Text('2 hours ago'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
