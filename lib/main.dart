import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/notifications/notification_service.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/admin_home_screen.dart';
import 'features/auth/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Firebase not available on this platform: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSFM Library+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _RootRedirect(),
    );
  }
}

class _RootRedirect extends ConsumerWidget {
  const _RootRedirect();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (authState.user == null) {
      return const LoginScreen();
    }

    return authState.user!.role == 'admin'
        ? const AdminHomeScreen()
        : const HomeScreen();
  }
}
