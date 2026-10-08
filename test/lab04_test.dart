// =============================================================================
// lab04_test.dart — Week 4 Lab: the nine tests, automated
// IMT01303305 Visual Programming · Module 1 · UI Layer
//
// Sixteen cases covering the nine tests, plus one bonus.
//
// Put this file at  lab04/test/lab04_test.dart  and run:
//   flutter test test/lab04_test.dart
//
// Every test sets a screen size (and sometimes a keyboard, a notch, or a data
// set), pumps the app, and fails if Flutter reports ANY layout error —
// "A RenderFlex overflowed…", "unbounded height", a RangeError, anything.
//
// ONE THING TO KNOW: flutter test draws text with a test font in which every
// letter is a full square, so text is much wider here than on a phone. If a
// test fails but the harness looks fine, that text has no overflow strategy
// (maxLines + ellipsis, or room to wrap). Fix the strategy, not the font.
//
// If your project is not called lab04, change "package:lab04/" below.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab04/lab04_start.dart';

const Size small = Size(320, 568);
const Size large = Size(430, 932);
const Size tablet = Size(800, 1280);

const List<(String, Size)> screens = [
  ('small phone', small),
  ('large phone', large),
  ('tablet', tablet),
];

/// Sets the fake screen, pumps the app and lets every animation finish.
Future<void> pumpLab(
  WidgetTester tester,
  Size size, {
  List<MenuItem> items = kMenu,
  double keyboard = 0,
  double topInset = 0,
  double bottomInset = 0,
  ThemeMode theme = ThemeMode.light,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  tester.view.padding = FakeViewPadding(top: topInset, bottom: bottomInset);
  tester.view.viewPadding = FakeViewPadding(top: topInset, bottom: bottomInset);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(Lab04App(items: items, themeMode: theme));
  await tester.pumpAndSettle();
}

/// Fails with Flutter's own message, so you can read widget, axis and pixels.
/// If several errors happened at once, the reason only says "Multiple
/// exceptions" — scroll up in the test output to read each one.
void expectNoLayoutErrors(WidgetTester tester) {
  final Object? error = tester.takeException();
  expect(error, isNull, reason: 'Layout error:\n$error');
}

/// The main vertical list or scroll view (not the search field, not the chips).
Finder get mainScrollable => find
    .byWidgetPredicate(
      (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

void main() {
  group('Lab 04 — the unbreakable screen', () {
    testWidgets('1 · small phone, 320 dp', (tester) async {
      await pumpLab(tester, small);
      expectNoLayoutErrors(tester);
    });

    testWidgets('2 · large phone, 430 dp', (tester) async {
      await pumpLab(tester, large);
      expectNoLayoutErrors(tester);
    });

    testWidgets('3 · tablet, 800 dp — the layout changes, it does not stretch', (tester) async {
      await pumpLab(tester, tablet);
      expectNoLayoutErrors(tester);
      expect(
        find.byType(MenuTile),
        findsNothing,
        reason: 'At 800 dp the phone list should become a grid or two panes.',
      );
    });

    for (final (name, size) in screens) {
      testWidgets('4 · landscape — $name', (tester) async {
        await pumpLab(tester, size.flipped);
        expectNoLayoutErrors(tester);
      });
    }

    for (final (name, size) in screens) {
      testWidgets('5 · a 200-character item name — $name', (tester) async {
        await pumpLab(tester, size, items: kLongNameMenu);
        expectNoLayoutErrors(tester);
      });
    }

    testWidgets('6 · zero items shows an empty state', (tester) async {
      await pumpLab(tester, small, items: const <MenuItem>[]);
      expectNoLayoutErrors(tester);
      expect(
        find.byKey(const Key('empty-state')),
        findsOneWidget,
        reason: "Zero items needs an empty state with key: const Key('empty-state').",
      );
    });

    testWidgets('7 · 500 items — built lazily, scrolled hard', (tester) async {
      await pumpLab(tester, small, items: kBigMenu);
      expectNoLayoutErrors(tester);
      expect(
        find.byType(MenuTile).evaluate().length,
        lessThan(100),
        reason: 'Only the visible tiles should be built. Is a long list shrink-wrapped?',
      );

      for (var i = 0; i < 5; i++) {
        await tester.fling(mainScrollable, const Offset(0, -2000), 3000);
        await tester.pumpAndSettle();
      }
      expectNoLayoutErrors(tester);
    });

    testWidgets('8 · keyboard open on a short screen — content stays reachable', (tester) async {
      await pumpLab(tester, small, keyboard: 260);
      expectNoLayoutErrors(tester);
      final field = tester.getRect(find.byKey(const Key('search-field')));
      expect(
        field.bottom,
        lessThanOrEqualTo(small.height - 260),
        reason: 'The search field is hidden behind the keyboard.',
      );
      expect(
        tester.getRect(mainScrollable).bottom,
        lessThanOrEqualTo(small.height - 260),
        reason: 'The scrollable content should end above the keyboard so everything can be scrolled into view.',
      );
    });

    testWidgets('8 · keyboard open in landscape', (tester) async {
      await pumpLab(tester, small.flipped, keyboard: 180);
      expectNoLayoutErrors(tester);
    });

    for (final (name, size) in screens) {
      testWidgets('9 · dark mode — $name', (tester) async {
        await pumpLab(tester, size, theme: ThemeMode.dark);
        expectNoLayoutErrors(tester);
        // Legibility is checked by eye in the harness: flip "Dark mode" on.
      });
    }

    testWidgets('Bonus · notch and gesture bar', (tester) async {
      await pumpLab(tester, small, topInset: 32, bottomInset: 20);
      expectNoLayoutErrors(tester);
      final button = tester.getRect(find.byKey(const Key('order-button')));
      expect(
        button.bottom,
        lessThanOrEqualTo(small.height - 20),
        reason: 'The order button sits under the gesture bar. Which widget keeps content out of it?',
      );
    });
  });
}
