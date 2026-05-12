import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../data/local/app_database.dart';
import '../data/remote/firebase_service.dart';
import '../data/remote/pose_tracking_service.dart';
import '../data/repositories/app_repository.dart';
import '../features/shared/app_bootstrap_screen.dart';
import '../features/dashboard/home_shell_screen.dart';
import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exercise_catalog_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/session_provider.dart';

class NabdAlHarakaApp extends StatelessWidget {
  const NabdAlHarakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppRepository>(
          create: (_) => AppRepository(
            database: AppDatabase.instance,
            firebaseService: FirebaseService(),
          ),
        ),
        ChangeNotifierProvider<AppStateProvider>(
          create: (context) => AppStateProvider(
            repository: context.read<AppRepository>(),
          )..initialize(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            repository: context.read<AppRepository>(),
          )..initialize(),
        ),
        ChangeNotifierProvider<ExerciseCatalogProvider>(
          create: (context) => ExerciseCatalogProvider(
            repository: context.read<AppRepository>(),
          )..load(),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (context) => ProgressProvider(
            repository: context.read<AppRepository>(),
          ),
        ),
        ChangeNotifierProvider<SessionProvider>(
          create: (context) => SessionProvider(
            repository: context.read<AppRepository>(),
            poseTrackingService: PoseTrackingService(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'مشروع التخرج',
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('ar', 'SA'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomeShellScreen(),
              );
            case '/splash':
              return MaterialPageRoute(
                builder: (_) => const AppBootstrapScreen(),
              );
            default:
              return null;
          }
        },
        home: const AppBootstrapScreen(),
      ),
    );
  }
}
