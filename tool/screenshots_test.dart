// Generates the README screenshots into docs/screenshots/.
//
//   flutter test tool/screenshots_test.dart
//
// Renders the real app at a phone size with the bundled Tajawal font,
// driving it through the same taps a user would make.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heritage_app/data/auth_service.dart';
import 'package:heritage_app/data/heritage_repository.dart';
import 'package:heritage_app/main.dart';

const _shotKey = ValueKey('screenshot');
const _phone = Size(390, 844);

Future<void> _loadFonts() async {
  Future<ByteData> file(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());

  final tajawal = FontLoader('Tajawal');
  for (final w in ['Regular', 'Medium', 'Bold', 'ExtraBold']) {
    tajawal.addFont(file('assets/fonts/Tajawal-$w.ttf'));
  }
  await tajawal.load();

  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      file(
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      ),
    );
  await icons.load();
}

Future<void> _settleImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
  });
  await tester.pumpAndSettle();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await _settleImages(tester);
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_shotKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      'docs/screenshots/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<DemoHeritageRepository> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = _phone * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final repo = DemoHeritageRepository();
  await tester.pumpWidget(
    RepaintBoundary(
      key: _shotKey,
      child: HeritageApp(repository: repo, auth: DemoAuthService()),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// Waits out any visible snackbar so it doesn't leak into the next shot.
Future<void> _clearSnackbar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}

Future<void> _openAuctionAndBid(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('زايد الآن'));
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester, String demoLabel) async {
  await tester.tap(find.text('تسجيل الدخول'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(demoLabel));
  await tester.pump();
  await tester.tap(find.text('دخول'));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('visitor screens', (tester) async {
    final repo = await _pumpApp(tester);
    await _shot(tester, '01_welcome');

    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('زائر'));
    await tester.pump();
    await _shot(tester, '02_login');
    await tester.tap(find.text('دخول'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await _shot(tester, '03_places');

    await tester.tap(find.text('احجز زيارة').first);
    await tester.pumpAndSettle();
    await _shot(tester, '04_booking');
    await tester.tap(find.text('تأكيد الحجز'));
    await tester.pumpAndSettle();
    await _clearSnackbar(tester);

    await tester.tap(find.text('الفعاليات').last);
    await tester.pumpAndSettle();
    await _shot(tester, '05_events');

    // Bid on the dallah, then let a rival outbid us.
    await tester.tap(find.text('المزادات').last);
    await tester.pumpAndSettle();
    await _shot(tester, '06_auctions');
    await _openAuctionAndBid(tester, 'دلّتان نحاسيتان');
    await _shot(tester, '07_bid_sheet');
    await tester.tap(find.text('تأكيد المزايدة'));
    await tester.pumpAndSettle();
    await _clearSnackbar(tester);
    final dallah = repo.auctions.firstWhere((a) => a.id == 'a2');
    repo.placeBid(
      'a2',
      bidderId: 'rival-reem',
      bidderName: 'ريم',
      amount: dallah.minimumNextBid,
    );
    await tester.pumpAndSettle();
    await _shot(tester, '08_outbid');
    await _clearSnackbar(tester);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    // Lead on the khanjar so "My bids" shows both states.
    await _openAuctionAndBid(tester, 'خنجر احتفالي مذهّب');
    await tester.tap(find.text('تأكيد المزايدة'));
    await tester.pumpAndSettle();
    await _clearSnackbar(tester);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('حسابي').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('مزايداتي').last);
    await tester.pumpAndSettle();
    await _shot(tester, '09_my_bids');
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('حجوزاتي').last);
    await tester.pumpAndSettle();
    await _shot(tester, '10_bookings');
  });

  testWidgets('admin screens', (tester) async {
    await _pumpApp(tester);
    await _signIn(tester, 'مدير');
    await _shot(tester, '11_admin');

    await tester.tap(find.text('المزادات'));
    await tester.pumpAndSettle();
    await _shot(tester, '12_admin_auctions');
  });
}
