import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/templates/template_detail_screen.dart';
import 'screens/session/session_screen.dart';
import 'screens/session/prompt_result_screen.dart';
import 'screens/history/history_detail_screen.dart';
import 'screens/profile/profile_screen.dart';

class AiWhispererApp extends ConsumerWidget {
  const AiWhispererApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AI Whisperer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Initial route
      initialRoute: '/',

      // Routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/profile': (context) => const ProfileScreen(),
      },

      // Named route generator for dynamic routes
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/template/') ?? false) {
          final slug = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => TemplateDetailScreen(templateSlug: slug),
          );
        }

        if (settings.name?.startsWith('/session/') ?? false) {
          final sessionId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => SessionScreen(sessionId: sessionId),
          );
        }

        if (settings.name?.startsWith('/result/') ?? false) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PromptResultScreen(
              prompt: args['prompt'] as String,
              historyId: args['historyId'] as String,
            ),
          );
        }

        if (settings.name?.startsWith('/history/') ?? false) {
          final historyId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => HistoryDetailScreen(historyId: historyId),
          );
        }

        return null;
      },
    );
  }
}
