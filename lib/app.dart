import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printmax_app/features/auth/auth_provider.dart';
import 'package:printmax_app/features/auth/login_screen.dart';
import 'package:printmax_app/features/dashboard/dashboard_provider.dart';
import 'package:printmax_app/features/dashboard/dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (_) => DashboardProvider(),
          update: (_, auth, dash) => (dash ?? DashboardProvider())..setAuth(auth),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PrintMax',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/dashboard': (_) => const DashboardScreen(),
            },
            home: _RootGate(auth: auth),
          );
        },
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    if (auth.initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.isAuthenticated) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}

