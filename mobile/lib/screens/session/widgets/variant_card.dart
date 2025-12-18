/// Variant card widget for displaying enhancement variants
///
/// Shows a single prompt variant with quality score, strategy name,
/// and selection state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../intelligence/models/enhancement.dart';
import '../../../config/theme.dart';

class VariantCard extends StatelessWidget {
  final PromptVariant variant;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;
  final VoidCallback? onCopy;

  const VariantCard({
    super.key,
    required this.variant,
    this.isSelected = false,
    this.isRecommended = false,
    required this.onTap,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : isRecommended
                  ? AppTheme.secondaryColor.withOpacity(0.3)
                  : Colors.transparent,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Strategy icon
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSm),
                    decoration: BoxDecoration(
                      color: _getStrategyColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStrategyIcon(),
                      color: _getStrategyColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSm),

                  // Strategy name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              variant.strategyName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isRecommended) ...[
                              const SizedBox(width: AppTheme.paddingSm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BEST',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          variant.strategyDescription,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quality score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getQualityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: _getQualityColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${variant.qualityScore}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getQualityColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.paddingMd),

              // Prompt text
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMd),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  variant.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.paddingSm),

              // Footer row with stats
              Row(
                children: [
                  _buildStat(
                    Icons.text_fields,
                    '${variant.text.split(' ').length} words',
                  ),
                  const SizedBox(width: AppTheme.paddingMd),
                  _buildStat(
                    Icons.code,
                    '~${variant.estimatedTokens} tokens',
                  ),
                  const Spacer(),
                  if (onCopy != null)
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: variant.text));
                        onCopy?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copy to clipboard',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStrategyColor() {
    switch (variant.strategy) {
      case EnhancementStrategy.concise:
        return Colors.blue;
      case EnhancementStrategy.expert:
        return Colors.purple;
      case EnhancementStrategy.stepwise:
        return Colors.orange;
      case EnhancementStrategy.creative:
        return Colors.pink;
      case EnhancementStrategy.technical:
        return Colors.teal;
    }
  }

  IconData _getStrategyIcon() {
    switch (variant.strategy) {
      case EnhancementStrategy.concise:
        return Icons.compress;
      case EnhancementStrategy.expert:
        return Icons.school;
      case EnhancementStrategy.stepwise:
        return Icons.list_alt;
      case EnhancementStrategy.creative:
        return Icons.lightbulb;
      case EnhancementStrategy.technical:
        return Icons.engineering;
    }
  }

  Color _getQualityColor() {
    if (variant.qualityScore >= 80) return Colors.green;
    if (variant.qualityScore >= 60) return Colors.orange;
    return Colors.grey;
  }
}
