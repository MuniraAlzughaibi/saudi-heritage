import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_scope.dart';
import 'core/theme.dart';
import 'core/formatters.dart';
import 'data/auth_service.dart';
import 'data/heritage_repository.dart';
import 'screens/auth/welcome_screen.dart';

void main() {
  runApp(
    HeritageApp(
      repository: DemoHeritageRepository(simulateRivals: true),
      auth: DemoAuthService(),
    ),
  );
}

final _messenger = GlobalKey<ScaffoldMessengerState>();

class HeritageApp extends StatelessWidget {
  final HeritageRepository repository;
  final AuthService auth;

  const HeritageApp({super.key, required this.repository, required this.auth});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      repository: repository,
      auth: auth,
      child: MaterialApp(
        title: 'Saudi Heritage',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        scaffoldMessengerKey: _messenger,
        builder: (context, child) => _OutbidListener(
          repository: repository,
          auth: auth,
          messenger: _messenger,
          child: child!,
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}

/// Shows an app-wide alert when the signed-in user is outbid on an auction.
class _OutbidListener extends StatefulWidget {
  final HeritageRepository repository;
  final AuthService auth;
  final GlobalKey<ScaffoldMessengerState> messenger;
  final Widget child;

  const _OutbidListener({
    required this.repository,
    required this.auth,
    required this.messenger,
    required this.child,
  });

  @override
  State<_OutbidListener> createState() => _OutbidListenerState();
}

class _OutbidListenerState extends State<_OutbidListener> {
  StreamSubscription<OutbidAlert>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.repository.outbidAlerts.listen((alert) {
      if (alert.userId != widget.auth.currentUser?.id) return;
      widget.messenger.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(
              'تمت المزايدة عليك في "${alert.item.title}" • السعر الآن ${Fmt.price(alert.item.currentPrice)}',
            ),
          ),
        );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
