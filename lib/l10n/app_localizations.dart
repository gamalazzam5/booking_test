import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application title shown in the app bar and system.
  ///
  /// In en, this message translates to:
  /// **'Appointment Booking'**
  String get appTitle;

  /// Main screen heading.
  ///
  /// In en, this message translates to:
  /// **'Book an Appointment'**
  String get bookAppointment;

  /// Displayed below the main heading as context.
  ///
  /// In en, this message translates to:
  /// **'Working hours: 9:00 AM – 6:00 PM'**
  String get workingHours;

  /// Label above the duration chip row.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get selectDuration;

  /// Label for the 30-minute booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get duration30Min;

  /// Label for the 1-hour booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'1 hr'**
  String get duration1Hour;

  /// Label for the 1.5-hour booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'1.5 hr'**
  String get duration1Half;

  /// Label for the 2-hour booking duration chip.
  ///
  /// In en, this message translates to:
  /// **'2 hr'**
  String get duration2Hours;

  /// Label above the time-slot grid.
  ///
  /// In en, this message translates to:
  /// **'Time Slots'**
  String get timeSlots;

  /// Label above the slot legend row.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Legend item and slot status label.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Section heading for the booking summary card.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// Label for the booking start time row.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// Label for the booking end time row.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLabel;

  /// Label for the booking duration row.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// Shown in summary when no start time is selected.
  ///
  /// In en, this message translates to:
  /// **'No time slot selected yet.'**
  String get noSelectionYet;

  /// Reset button label.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Confirm booking button label.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Success message shown after a booking is confirmed.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been booked successfully!'**
  String get bookingSuccessful;

  /// Hint text shown below the time slots label.
  ///
  /// In en, this message translates to:
  /// **'Tap a slot to choose a start time. Outlined slots cannot start a booking of this length.'**
  String get selectStartTimeHint;

  /// Legend item and slot status label for a selection that breaks a booking rule.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// Legend item and slot status label for a free slot that cannot start a booking of the selected duration.
  ///
  /// In en, this message translates to:
  /// **'Can\'t start here'**
  String get cannotStartHere;

  /// Screen-reader label for a slot: its time followed by its status.
  ///
  /// In en, this message translates to:
  /// **'{time}, {status}'**
  String slotSemantics(String time, String status);

  /// Label for the total length of the booking in the summary.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// Hours part of a duration, e.g. '1 hr'.
  ///
  /// In en, this message translates to:
  /// **'{count} hr'**
  String durationHours(int count);

  /// Minutes part of a duration, e.g. '30 min'.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String durationMinutes(int count);

  /// Validation error when booking exceeds working hours.
  ///
  /// In en, this message translates to:
  /// **'The selected duration extends beyond 6:00 PM.'**
  String get errorExceedsWorkingHours;

  /// Validation error when the chosen start slot is already booked.
  ///
  /// In en, this message translates to:
  /// **'This time slot is already booked.'**
  String get errorStartSlotBooked;

  /// Validation error when the chosen start slot is unavailable.
  ///
  /// In en, this message translates to:
  /// **'This time slot is unavailable.'**
  String get errorStartSlotUnavailable;

  /// Validation error when the requested range runs into a booked slot.
  ///
  /// In en, this message translates to:
  /// **'This time overlaps with a booked appointment.'**
  String get errorOverlapsBooking;

  /// Validation error when the range cannot be covered by consecutive available slots.
  ///
  /// In en, this message translates to:
  /// **'The selected time does not contain enough consecutive available slots.'**
  String get errorInsufficientConsecutiveSlots;

  /// Validation error when the booking would strand a single free 30-minute slot between two blocked slots.
  ///
  /// In en, this message translates to:
  /// **'This booking would leave an unusable 30-minute gap.'**
  String get errorCreatesIsolatedGap;

  /// Label for theme setting option.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Label for system default theme option.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// Label for light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// Label for dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;

  /// Drawer settings section header.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Drawer about option label.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Subtitle shown in the drawer header.
  ///
  /// In en, this message translates to:
  /// **'Serv5 Booking System'**
  String get appSubtitle;

  /// Copyright notice shown at the bottom of the drawer.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Serv5. All rights reserved.'**
  String get copyright;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
