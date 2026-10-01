import 'package:flutter/widgets.dart';

import '../data/auth_service.dart';
import '../data/heritage_repository.dart';

/// Provides the repository and auth service to the widget tree and
/// rebuilds dependents whenever either of them changes.
class AppScope extends InheritedNotifier<Listenable> {
  final HeritageRepository repository;
  final AuthService auth;

  AppScope({
    super.key,
    required this.repository,
    required this.auth,
    required super.child,
  }) : super(notifier: Listenable.merge([repository, auth]));

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }
}

extension AppScopeContext on BuildContext {
  HeritageRepository get repo => AppScope.of(this).repository;
  AuthService get auth => AppScope.of(this).auth;
}
