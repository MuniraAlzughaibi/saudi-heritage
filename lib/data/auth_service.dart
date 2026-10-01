import 'package:flutter/foundation.dart';

import 'models.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// Authentication contract. Swap [DemoAuthService] for a Firebase Auth
/// implementation in production.
abstract class AuthService extends ChangeNotifier {
  AppUser? get currentUser;
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });
  void signOut();
}

/// Demo accounts shown on the login screen so anyone can try the app.
class DemoAccounts {
  DemoAccounts._();
  static const visitorEmail = 'visitor@heritage.demo';
  static const adminEmail = 'admin@heritage.demo';
  static const password = 'demo1234';
}

class DemoAuthService extends AuthService {
  final Map<String, ({AppUser user, String password})> _accounts = {
    DemoAccounts.visitorEmail: (
      user: const AppUser(
        id: 'u1',
        name: 'زائر تجريبي',
        email: DemoAccounts.visitorEmail,
      ),
      password: DemoAccounts.password,
    ),
    DemoAccounts.adminEmail: (
      user: const AppUser(
        id: 'u0',
        name: 'مدير المنصة',
        email: DemoAccounts.adminEmail,
        role: UserRole.admin,
      ),
      password: DemoAccounts.password,
    ),
  };

  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
    _current = account.user;
    notifyListeners();
    return account.user;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('يوجد حساب مسجّل بهذا البريد');
    }
    if (password.length < 8) {
      throw const AuthException('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    }
    final user = AppUser(
      id: 'u${_accounts.length + 1}',
      name: name.trim(),
      email: key,
    );
    _accounts[key] = (user: user, password: password);
    _current = user;
    notifyListeners();
    return user;
  }

  @override
  void signOut() {
    _current = null;
    notifyListeners();
  }
}
