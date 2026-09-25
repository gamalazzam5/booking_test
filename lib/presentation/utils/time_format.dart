import 'package:flutter/material.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';

/// Presentation-only formatting for the domain's time values (offsets from midnight).
extension DurationTimeFormat on Duration {
  /// This time of day in the user's locale, e.g. "9:30 AM".
  String formatTimeOfDay(BuildContext context) {
    final time = TimeOfDay(hour: inHours, minute: inMinutes.remainder(60));
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  /// This span as words in the user's language, e.g. "1 hr 30 min".
  String formatSpan(S l10n) {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    return [
      if (hours > 0) l10n.durationHours(hours),
      if (minutes > 0) l10n.durationMinutes(minutes),
    ].join(' ');
  }
}
