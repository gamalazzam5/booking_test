import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/data/models/time_slot.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/presentation/utils/slot_style.dart';
import 'package:booking_appointments/presentation/utils/time_format.dart';

/// How a slot relates to the user's current selection.
enum SlotSelectionState {
  /// Not part of the selection.
  none,

  /// Part of a valid selection.
  valid,

  /// Part of a selection that breaks a booking rule.
  invalid,
}

/// One time slot in the grid.
///
/// The look is derived (see [SlotVisual]); the slot's own data is never changed
/// for display. Every slot is tappable — tapping one that cannot be booked shows
/// the user exactly why.
class SlotCellWidget extends StatelessWidget {
  const SlotCellWidget({
    super.key,
    required this.slot,
    required this.isValidStart,
    required this.selectionState,
    required this.onTap,
  });

  final TimeSlot slot;

  /// True when a booking of the chosen duration can start at this slot.
  final bool isValidStart;

  final SlotSelectionState selectionState;
  final VoidCallback onTap;

  SlotVisual get _visual {
    final blockedVisual = slot.status == SlotStatus.booked
        ? SlotVisual.booked
        : SlotVisual.unavailable;
    return switch (selectionState) {
      SlotSelectionState.valid => SlotVisual.selected,
      SlotSelectionState.invalid =>
        slot.isAvailable ? SlotVisual.invalid : blockedVisual,
      SlotSelectionState.none => slot.isAvailable
          ? (isValidStart ? SlotVisual.available : SlotVisual.cannotStart)
          : blockedVisual,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final visual = _visual;
    final style = SlotStyle.of(visual, context);
    final time = slot.start.formatTimeOfDay(context);

    // A booked/unavailable slot inside a rejected selection keeps its own colors
    // but is outlined in the error color: that is where the conflict is.
    final isConflict =
        selectionState == SlotSelectionState.invalid && slot.isBlocked;
    final borderColor =
        isConflict ? Theme.of(context).colorScheme.error : style.borderColor;
    final borderWidth = isConflict ? 2.0 : style.borderWidth;

    return Semantics(
      button: true,
      selected: selectionState == SlotSelectionState.valid,
      label: l10n.slotSemantics(time, SlotStyle.labelOf(visual, l10n)),
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (style.icon != null) ...[
                    Icon(style.icon, size: 14.r, color: style.foreground),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    time,
                    style: AppTextStyles.medium12.copyWith(
                      color: style.foreground,
                      decoration: style.strikeThrough
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: style.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
