import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_appointments/core/services/services_locator.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/main.dart';
import 'package:booking_appointments/presentation/widgets/app_drawer_widget.dart';
import 'package:booking_appointments/presentation/widgets/booking_summary_widget.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    await setupServiceLocator();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpApp(WidgetTester tester, {Size size = const Size(800, 2400)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const BookingApp());
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Text inside the summary card only (the same time can also be a grid cell).
  Finder inSummary(String text) => find.descendant(
        of: find.byType(BookingSummaryWidget),
        matching: find.text(text),
      );

  // Seed schedule has three booked slots (10:00, 10:30, 15:00). The legend shows
  // one swatch per look, so every icon count also includes that one swatch.
  const seedBookedCells = 3;
  const legendSwatch = 1;
  final bookedIcon = find.byIcon(Icons.event_busy_rounded);
  final selectedIcon = find.byIcon(Icons.check_circle_rounded);

  group('BookingPage', () {
    testWidgets('renders header, durations, grid, legend, summary and actions', (tester) async {
      await pumpApp(tester);

      expect(find.text('Book an Appointment'), findsNWidgets(2)); // app bar + header
      expect(find.text('Working hours: 9:00 AM – 6:00 PM'), findsOneWidget);
      for (final label in ['30 min', '1 hr', '1.5 hr', '2 hr']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('5:30 PM'), findsOneWidget);
      expect(find.text('No time slot selected yet.'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Confirm Booking'), findsOneWidget);
    });

    testWidgets('the legend names every slot look, including invalid', (tester) async {
      await pumpApp(tester);

      for (final label in [
        'Available',
        "Can't start here",
        'Booked',
        'Unavailable',
        'Selected',
        'Invalid',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('picking a duration selects its chip', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '1 hr');

      expect(
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '1 hr')).selected,
        isTrue,
      );
      expect(
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '30 min')).selected,
        isFalse,
      );
    });

    testWidgets('a valid slot shows start, end, duration and total', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '11:00 AM');
      await tapText(tester, '1.5 hr');

      expect(inSummary('11:00 AM'), findsOneWidget); // start
      expect(inSummary('12:30 PM'), findsOneWidget); // end
      expect(inSummary('1.5 hr'), findsOneWidget); // selected duration
      expect(inSummary('1 hr 30 min'), findsOneWidget); // total
      expect(selectedIcon, findsNWidgets(4)); // 3 selected cells + legend
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget); // legend only
    });

    testWidgets('a booked slot shows one specific message in the banner and the snackbar', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '10:00 AM');

      expect(find.text('This time slot is already booked.'), findsNWidgets(2));
    });

    testWidgets('an unavailable slot is explained as unavailable', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '1:30 PM');

      expect(find.text('This time slot is unavailable.'), findsNWidgets(2));
    });

    testWidgets('a start that would strand a slot explains the 30-minute gap', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '9:00 AM'); // leaves 9:30 between 9:00 and booked 10:00

      expect(
        find.text('This booking would leave an unusable 30-minute gap.'),
        findsNWidgets(2),
      );
    });

    testWidgets('changing the duration revalidates the chosen start and explains the failure', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '5:30 PM');
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull);

      await tapText(tester, '1 hr');

      expect(find.text('The selected duration extends beyond 6:00 PM.'), findsNWidgets(2));
      expect(inSummary('5:30 PM'), findsOneWidget); // start still selected
      expect(inSummary('6:30 PM'), findsOneWidget); // end shows why it fails
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
    });

    testWidgets('a rejected range keeps booked slots looking booked', (tester) async {
      await pumpApp(tester);
      expect(bookedIcon, findsNWidgets(seedBookedCells + legendSwatch));

      await tapText(tester, '9:30 AM');
      await tapText(tester, '1.5 hr'); // 9:30–11:00 runs into the booking at 10:00

      expect(find.text('This time overlaps with a booked appointment.'), findsNWidgets(2));
      // Still booked — the rejected range is not painted over them.
      expect(bookedIcon, findsNWidgets(seedBookedCells + legendSwatch));
      expect(selectedIcon, findsOneWidget); // legend only — nothing is "selected"
    });

    testWidgets('Confirm is disabled until a valid slot is chosen', (tester) async {
      await pumpApp(tester);
      ElevatedButton confirm() => tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(confirm().onPressed, isNull);
      await tapText(tester, '10:00 AM'); // booked
      expect(confirm().onPressed, isNull);
      await tapText(tester, '11:00 AM'); // valid
      expect(confirm().onPressed, isNotNull);
    });

    testWidgets('confirming books the slot and shows the success message', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '11:00 AM');
      await tapText(tester, 'Confirm Booking');

      expect(find.text('Your appointment has been booked successfully!'), findsOneWidget);
      expect(bookedIcon, findsNWidgets(seedBookedCells + 1 + legendSwatch));
      expect(find.text('No time slot selected yet.'), findsOneWidget);
    });

    testWidgets('Reset returns to the initial state', (tester) async {
      await pumpApp(tester);

      await tapText(tester, '1 hr');
      await tapText(tester, '11:00 AM');
      await tapText(tester, 'Confirm Booking');
      await tapText(tester, '10:00 AM'); // leave an error on screen too
      expect(bookedIcon, findsNWidgets(seedBookedCells + 2 + legendSwatch));

      await tapText(tester, 'Reset');

      expect(bookedIcon, findsNWidgets(seedBookedCells + legendSwatch)); // seed only
      expect(find.text('No time slot selected yet.'), findsOneWidget);
      expect(find.text('This time slot is already booked.'), findsNothing);
      expect(
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '30 min')).selected,
        isTrue,
      );
    });

    testWidgets('slots expose their time and status to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);

      expect(find.bySemanticsLabel('10:00 AM, Booked'), findsOneWidget);
      expect(find.bySemanticsLabel('1:30 PM, Unavailable'), findsOneWidget);
      expect(find.bySemanticsLabel('11:00 AM, Available'), findsOneWidget);
      expect(find.bySemanticsLabel("9:00 AM, Can't start here"), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('slot cells are at least 48 dp tall on a small phone', (tester) async {
      await pumpApp(tester, size: const Size(320, 2400));

      final size = tester.getSize(find.ancestor(
        of: find.text('9:30 AM'),
        matching: find.byType(AnimatedContainer),
      ).first);
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('configures AppDrawerWidget on the Scaffold drawer', (tester) async {
      await pumpApp(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isA<AppDrawerWidget>());
    });

    testWidgets('switching to Arabic localizes the screen, including error messages', (tester) async {
      await pumpApp(tester);
      expect(find.text('Book an Appointment'), findsNWidgets(2));

      GetIt.I<SettingsCubit>().setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      expect(find.text('حجز موعد'), findsNWidgets(2));
      expect(find.text('This time slot is already booked.'), findsNothing);
    });
  });
}
