/// Quick actions bar for prompt refinement
///
/// Provides one-tap actions for common refinement commands

import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback onRefine;
  final VoidCallback onShorter;
  final VoidCallback onMoreDetail;
  final VoidCallback onMoreTechnical;
  final VoidCallback onMoreCreative;

  const QuickActionsBar({
    super.key,
    required this.onRefine,
    required this.onShorter,
    required this.onMoreDetail,
    required this.onMoreTechnical,
    required this.onMoreCreative,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: AppTheme.paddingSm),
                const Text(
                  'Quick Refinements',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMd),
            Wrap(
              spacing: AppTheme.paddingSm,
              runSpacing: AppTheme.paddingSm,
              children: [
                _QuickActionChip(
                  label: 'Refine',
                  icon: Icons.refresh,
                  onTap: onRefine,
                  color: AppTheme.primaryColor,
                ),
                _QuickActionChip(
                  label: 'Shorter',
                  icon: Icons.compress,
                  onTap: onShorter,
                  color: Colors.blue,
                ),
                _QuickActionChip(
                  label: 'More Detail',
                  icon: Icons.add_circle_outline,
                  onTap: onMoreDetail,
                  color: Colors.purple,
                ),
                _QuickActionChip(
                  label: 'Technical',
                  icon: Icons.engineering,
                  onTap: onMoreTechnical,
                  color: Colors.teal,
                ),
                _QuickActionChip(
                  label: 'Creative',
                  icon: Icons.lightbulb_outline,
                  onTap: onMoreCreative,
                  color: Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
