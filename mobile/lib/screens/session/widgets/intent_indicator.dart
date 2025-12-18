/// Intent indicator widget
///
/// Displays detected intent, tone, and output type with visual indicators

import 'package:flutter/material.dart';
import '../../../intelligence/models/intent.dart';
import '../../../config/theme.dart';

class IntentIndicator extends StatelessWidget {
  final IntentAnalysis intent;
  final bool showConfidence;

  const IntentIndicator({
    super.key,
    required this.intent,
    this.showConfidence = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.paddingSm),
                const Text(
                  'Intent Analysis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showConfidence) ...[
                  const Spacer(),
                  _buildConfidenceBadge(),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.paddingMd),
            Wrap(
              spacing: AppTheme.paddingSm,
              runSpacing: AppTheme.paddingSm,
              children: [
                _buildIntentChip(
                  label: _getIntentTypeLabel(intent.intentType),
                  icon: _getIntentTypeIcon(intent.intentType),
                  color: _getIntentTypeColor(intent.intentType),
                ),
                _buildIntentChip(
                  label: _getToneLabel(intent.tone),
                  icon: Icons.tune,
                  color: _getToneColor(intent.tone),
                ),
                _buildIntentChip(
                  label: _getOutputTypeLabel(intent.outputType),
                  icon: Icons.output,
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge() {
    final percentage = (intent.confidence * 100).toInt();
    final color = intent.confidence >= 0.7
        ? Colors.green
        : intent.confidence >= 0.5
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '$percentage% confident',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildIntentChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
    );
  }

  String _getIntentTypeLabel(IntentType type) {
    switch (type) {
      case IntentType.coding:
        return 'Coding';
      case IntentType.writing:
        return 'Writing';
      case IntentType.business:
        return 'Business';
      case IntentType.education:
        return 'Education';
      case IntentType.marketing:
        return 'Marketing';
      case IntentType.general:
        return 'General';
    }
  }

  IconData _getIntentTypeIcon(IntentType type) {
    switch (type) {
      case IntentType.coding:
        return Icons.code;
      case IntentType.writing:
        return Icons.edit;
      case IntentType.business:
        return Icons.business;
      case IntentType.education:
        return Icons.school;
      case IntentType.marketing:
        return Icons.campaign;
      case IntentType.general:
        return Icons.chat;
    }
  }

  Color _getIntentTypeColor(IntentType type) {
    switch (type) {
      case IntentType.coding:
        return Colors.blue;
      case IntentType.writing:
        return Colors.green;
      case IntentType.business:
        return Colors.indigo;
      case IntentType.education:
        return Colors.orange;
      case IntentType.marketing:
        return Colors.pink;
      case IntentType.general:
        return Colors.grey;
    }
  }

  String _getToneLabel(Tone tone) {
    switch (tone) {
      case Tone.formal:
        return 'Formal';
      case Tone.casual:
        return 'Casual';
      case Tone.urgent:
        return 'Urgent';
      case Tone.creative:
        return 'Creative';
      case Tone.technical:
        return 'Technical';
    }
  }

  Color _getToneColor(Tone tone) {
    switch (tone) {
      case Tone.formal:
        return Colors.purple;
      case Tone.casual:
        return Colors.cyan;
      case Tone.urgent:
        return Colors.red;
      case Tone.creative:
        return Colors.pink;
      case Tone.technical:
        return Colors.teal;
    }
  }

  String _getOutputTypeLabel(OutputType type) {
    switch (type) {
      case OutputType.code:
        return 'Code Output';
      case OutputType.explanation:
        return 'Explanation';
      case OutputType.steps:
        return 'Step-by-Step';
      case OutputType.summary:
        return 'Summary';
      case OutputType.list:
        return 'List';
      case OutputType.document:
        return 'Document';
    }
  }
}
