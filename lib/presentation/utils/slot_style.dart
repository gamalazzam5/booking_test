import 'package:flutter/material.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';

/// Every look a slot (or its legend swatch) can have. Display-only: none of this
/// is stored in the schedule data.
enum SlotVisual {
  /// Free and a valid start for the chosen duration.
  available,

  /// Free, but a booking of the chosen duration cannot start here.
  cannotStart,

  booked,
  unavailable,

  /// Part of a valid selection.
  selected,

  /// A free slot inside a selection that breaks a rule.
  invalid,
}

/// Colors, icon and text treatment for a [SlotVisual]. Status is never conveyed
/// by color alone: every non-plain state also has an icon and/or strike-through.
class SlotStyle {
  const SlotStyle({
    required this.background,
    required this.foreground,
    required this.borderColor,
    this.borderWidth = 1,
    this.icon,
    this.strikeThrough = false,
  });

  final Color background;
  final Color foreground;
  final Color borderColor;
  final double borderWidth;
  final IconData? icon;
  final bool strikeThrough;

  static SlotStyle of(SlotVisual visual, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final outline = AppColors.outline.withValues(alpha: isDark ? 0.3 : 1.0);

    return switch (visual) {
      SlotVisual.available => SlotStyle(
          background:
              isDark ? AppColors.slotAvailableBgDark : AppColors.slotAvailableBg,
          foreground:
              isDark ? AppColors.slotAvailableFgDark : AppColors.slotAvailableFg,
          borderColor: outline,
        ),
      SlotVisual.cannotStart => SlotStyle(
          background: Colors.transparent,
          foreground: theme.colorScheme.onSurfaceVariant,
          borderColor: theme.colorScheme.outline,
        ),
      SlotVisual.booked => SlotStyle(
          background:
              isDark ? AppColors.slotBookedBgDark : AppColors.slotBookedBg,
          foreground:
              isDark ? AppColors.slotBookedFgDark : AppColors.slotBookedFg,
          borderColor: outline,
          icon: Icons.event_busy_rounded,
        ),
      SlotVisual.unavailable => SlotStyle(
          background: isDark
              ? AppColors.slotUnavailableBgDark
              : AppColors.slotUnavailableBg,
          foreground: isDark
              ? AppColors.slotUnavailableFgDark
              : AppColors.slotUnavailableFg,
          borderColor: outline,
          icon: Icons.block_rounded,
          strikeThrough: true,
        ),
      SlotVisual.selected => SlotStyle(
          background:
              isDark ? AppColors.slotSelectedBgDark : AppColors.slotSelectedBg,
          foreground:
              isDark ? AppColors.slotSelectedFgDark : AppColors.slotSelectedFg,
          borderColor: AppColors.primary,
          borderWidth: 2,
          icon: Icons.check_circle_rounded,
        ),
      SlotVisual.invalid => SlotStyle(
          background:
              isDark ? AppColors.slotInvalidBgDark : AppColors.slotInvalidBg,
          foreground:
              isDark ? AppColors.slotInvalidFgDark : AppColors.slotInvalidFg,
          borderColor: theme.colorScheme.error,
          borderWidth: 2,
          icon: Icons.error_outline_rounded,
        ),
    };
  }

  /// Screen-reader / legend name for [visual].
  static String labelOf(SlotVisual visual, S l10n) => switch (visual) {
        SlotVisual.available => l10n.available,
        SlotVisual.cannotStart => l10n.cannotStartHere,
        SlotVisual.booked => l10n.booked,
        SlotVisual.unavailable => l10n.unavailable,
        SlotVisual.selected => l10n.selected,
        SlotVisual.invalid => l10n.invalid,
      };
}
