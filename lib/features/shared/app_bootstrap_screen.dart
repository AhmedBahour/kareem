import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/home_shell_screen.dart';
import 'splash_screen.dart';

class AppBootstrapScreen extends StatelessWidget {
  const AppBootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final auth = context.watch<AuthProvider>();

    if (!appState.initialized) {
      return const SplashScreen();
    }

    if (auth.currentUser == null) {
      return const SplashScreen();
    }

    return const Directionality(
      textDirection: TextDirection.rtl,
      child: HomeShellScreen(),
    );
  }
}
