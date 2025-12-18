/// Enhancement Result Screen
///
/// Displays all enhancement variants with intent analysis,
/// allows selection, and provides quick refinement actions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/features/session_provider.dart';
import '../../intelligence/models/enhancement.dart';
import 'widgets/variant_card.dart';
import 'widgets/intent_indicator.dart';
import 'widgets/quick_actions_bar.dart';

class EnhancementResultScreen extends ConsumerWidget {
  const EnhancementResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final sessionNotifier = ref.read(sessionProvider.notifier);

    if (sessionState.enhancement == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Enhancement Results'),
        ),
        body: const Center(
          child: Text('No enhancement results available'),
        ),
      );
    }

    final enhancement = sessionState.enhancement!;
    final intent = sessionState.intent!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Enhanced Prompts'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show version history
            },
            tooltip: 'Version History',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _sharePrompt(context, enhancement.selected.text);
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with processing time
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingMd),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.paddingSm),
                Text(
                  '${enhancement.variants.length} variants generated in ${enhancement.processingTimeMs}ms',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                if (enhancement.processingTimeMs < 200)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.flash_on, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'FAST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original transcription
                  _buildOriginalSection(enhancement.originalText),

                  const SizedBox(height: AppTheme.paddingLg),

                  // Intent analysis
                  IntentIndicator(intent: intent),

                  const SizedBox(height: AppTheme.paddingLg),

                  // Quick actions
                  QuickActionsBar(
                    onRefine: () => _refine(context, sessionNotifier, 'refine'),
                    onShorter: () =>
                        _refine(context, sessionNotifier, 'make it shorter'),
                    onMoreDetail: () =>
                        _refine(context, sessionNotifier, 'more detail'),
                    onMoreTechnical: () =>
                        _refine(context, sessionNotifier, 'more technical'),
                    onMoreCreative: () =>
                        _refine(context, sessionNotifier, 'more creative'),
                  ),

                  const SizedBox(height: AppTheme.paddingLg),

                  // Section title
                  const Text(
                    'Choose Your Best Variant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingSm),
                  Text(
                    'Tap to select, then save or refine further',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: AppTheme.paddingMd),

                  // Variants list
                  ...enhancement.variants.map((variant) {
                    final isSelected = variant.id == enhancement.selected.id;
                    final isRecommended =
                        variant.id == enhancement.recommendedVariantId;

                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppTheme.paddingMd),
                      child: VariantCard(
                        variant: variant,
                        isSelected: isSelected,
                        isRecommended: isRecommended,
                        onTap: () {
                          sessionNotifier.selectVariant(variant.id);
                          HapticFeedback.selectionClick();
                        },
                        onCopy: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: AppTheme.paddingXl),
                ],
              ),
            ),
          ),

          // Bottom action bar
          _buildBottomBar(context, sessionNotifier, enhancement),
        ],
      ),
    );
  }

  Widget _buildOriginalSection(String originalText) {
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
                  Icons.mic,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: AppTheme.paddingSm),
                const Text(
                  'Your Voice Input',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSm),
            Text(
              originalText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    SessionNotifier notifier,
    EnhancementResult enhancement,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: enhancement.selected.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.paddingMd),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Save to history and navigate
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Save & Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refine(
    BuildContext context,
    SessionNotifier notifier,
    String command,
  ) {
    notifier.refineWithStrategy(command);
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refining with: "$command"...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _sharePrompt(BuildContext context, String text) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
      ),
    );
  }
}
