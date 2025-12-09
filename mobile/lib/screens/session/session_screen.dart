import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SessionScreen extends StatelessWidget {
  final String sessionId;

  const SessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Session'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, size: 80, color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            const Text('Hold to record'),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTapDown: (_) {},
              onTapUp: (_) {},
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, size: 40, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
