# Issues

Audit of the existing appointment-booking implementation against the task brief.
Every entry below is based on code that was read during the audit (Phase 1). Line
numbers refer to the code **before** the refactor.

Baseline before any change: `flutter analyze` → no issues; `flutter test` → 61 passing.

## What already works (kept)

- Working day 09:00–18:00 as 18 half-hour slots; four durations (30 / 60 / 90 / 120 min).
- X-O-X rule **is** implemented and is evaluated on a *simulated* schedule
  (`applyBooking` → `_createsInvalidGap`), not only on the selected slots.
- Booked / unavailable / non-consecutive / 6 PM boundary rules are enforced.
- Cubit-based state, get_it DI, local seed data only (no API, no Hive).
- `getValidStartIndexes` drives dimming of invalid start slots.
- Reset, confirm, localization (en/ar), light/dark theme, drawer.

## Assumptions (task is silent; documented so they are testable)

- **A1.** `unavailable` counts as blocked (`X`) for the X-O-X rule, same as `booked`.
- **A2.** X-O-X needs an occupied slot on **both** sides. A free slot at the very
  first/last position of the day has only one neighbour, so it is not "between" two
  blocked slots and is not a violation.
- **A3.** A booking is rejected only for gaps it **creates**. A gap that already
  existed in the schedule is not the new booking's fault (see ISSUE-001).
- **A4.** The existing *Confirm* button is kept (it is what makes "resulting schedule"
  observable to the user), even though the brief only requires Reset.

---

## Critical

None found. The X-O-X rule exists and runs on the resulting schedule.
(See ISSUE-001 for a Major defect in *how* the gap is detected.)

---

## Major

### ISSUE-001 — Gap rule inspects the whole schedule, not the gaps the booking creates

File:
`lib/features/booking/domain/booking_validator.dart` (`_createsInvalidGap`, lines 170-186; used at 63 and 123)

Problem:
`_createsInvalidGap(simulatedSlots)` returns `true` if the simulated schedule contains
*any* isolated free slot. It never compares against the schedule *before* the booking.
If an isolated slot already exists anywhere (e.g. `booked, free, booked` in the seed
data, or after a future data change), then **every** other booking is rejected with
"would leave an isolated gap" — even one on the opposite side of the day that has
nothing to do with it. `getValidStartIndexes` would also return almost nothing.

Expected:
A booking is rejected when it *causes* `X O X` (brief §3: "if the new booking causes
it"). Gaps already present before the booking must not be blamed on it.

Impact:
Latent today (the current seed has no isolated slot), but any schedule that starts with
one makes the screen unusable, and the wrong error message is shown.

Recommended fix:
Compute the set of isolated slots before and after the hypothetical booking; reject only
if the "after" set contains an isolated slot that was not in the "before" set. Add a
reproducing test with a pre-existing `X O X` far from the booking.

### ISSUE-002 — Changing duration silently discards the selection

File:
`lib/features/booking/presentation/manager/booking_cubit.dart` (`selectDuration`, lines 83-89)

Problem:
When the previously selected start is not in the new duration's valid-start list, the
cubit emits `status: idle` with no `selectedStartIndex` and no `validationResult`. The
selection vanishes and the user is never told why.

Expected:
Brief §2.5 / §5: on duration change the system "immediately recalculates whether the
currently selected start time is still valid" and gives "a clear reason" when it is not.

Impact:
User picks 5:00 PM, switches to 2 hr, and the selection just disappears — no
explanation, no indication that 5:00 PM + 2 hr crosses 6 PM.

Recommended fix:
Keep the selected start, re-run `validateBooking`, and emit the failing reason.

### ISSUE-003 — Snackbar error text is hardcoded English and duplicates the banner mapping

File:
`lib/features/booking/presentation/widgets/booking_view_body.dart` (lines 36-49);
`lib/features/booking/presentation/widgets/validation_error_widget.dart` (lines 20-25)

Problem:
For booked/unavailable the snackbar builds `'$slotName is already booked.'` /
`'$slotName is currently unavailable.'` as raw English strings, bypassing `S` (the app
ships Arabic). The banner shows a *different* string for the same reason
(`errorContainsBookedSlot`). The reason→message `switch` is written twice.

Expected:
One localized message per reason, shared by every place that shows it.

Impact:
Arabic users see English snackbars; the two feedback surfaces disagree.

Recommended fix:
Single `BookingInvalidReason → String` mapping in presentation, used by both surfaces.

### ISSUE-004 — Invalid reasons are too coarse for the messages the brief asks for

File:
`lib/features/booking/domain/booking_validation_result.dart` (lines 6-21)

Problem:
Only four reasons exist. "Overlaps a booked appointment", "not enough consecutive
available slots" and "the tapped start slot itself is booked/unavailable" are all folded
into `containsBookedSlot` / `containsUnavailableSlot` ("One or more required time slots
are already booked").

Expected:
Brief §5 lists distinct messages: overlaps a booked appointment; extends beyond 6 PM;
not enough consecutive available slots; leaves an unusable 30-minute gap.

Impact:
Generic wording where a more specific explanation is possible (explicitly discouraged).

Recommended fix:
Split into `exceedsWorkingHours`, `startSlotBooked`, `startSlotUnavailable`,
`overlapsBooking`, `insufficientConsecutiveSlots`, `createsIsolatedGap`; add en/ar strings.

### ISSUE-005 — Selection overlay paints over booked/unavailable slots; no "invalid" visual state

File:
`lib/features/booking/presentation/manager/booking_cubit.dart` (`_buildDisplaySlots`, lines 197-211);
`lib/features/booking/presentation/widgets/slot_cell_widget.dart`;
`lib/features/booking/presentation/widgets/slot_legend_widget.dart` (lines 30-49)

Problem:
`_buildDisplaySlots` overwrites every slot in the requested range with
`SlotStatus.selected`, including booked/unavailable ones. Selecting 09:30 for 1.5 hr
turns the booked 10:00 and 10:30 cells the same solid blue as a valid selection, hiding
the very conflict the error message describes. Tapping a booked slot likewise turns it
"selected". The legend has no "invalid" entry and the cell has no invalid style.

Expected:
Brief §6: available, booked, unavailable, selected **and invalid selections** must be
clearly distinguishable.

Impact:
The grid contradicts the error banner; the user cannot see *where* the conflict is.

Recommended fix:
Do not mutate slot data for display. Derive a per-cell visual state (selected vs
invalid-range vs booked vs unavailable) in presentation; keep booked/unavailable identity
and add an error emphasis; add an "Invalid" legend entry.

---

## Architecture

### ISSUE-006 — No repository; cubit reads the seed constant directly

File:
`lib/features/booking/presentation/manager/booking_cubit.dart` (line 34, `_originalSlots = initialSchedule`);
`lib/features/booking/data/local_schedule.dart`

Problem:
The cubit imports and reads the data-layer constant directly. There is no
`BookingRepository` / `BookingRepositoryImpl`.

Expected:
Brief §7/§9: repository provides the local schedule; cubit depends on it.

Impact:
Presentation is coupled to a data file; the schedule source cannot be swapped or faked in tests.

Recommended fix:
`BookingRepository` interface + `BookingRepositoryImpl` returning the local schedule;
inject into the cubit via get_it.

### ISSUE-007 — `SlotModel` has no start/end time; display state lives in the domain enum

File:
`lib/features/booking/domain/slot_model.dart` (lines 14-15, 22-29, 32-56)

Problem:
A slot is only `(index, status)`. Start/end times are derived by `9 * 60 + index * 30`
in a free function that also hardcodes English `AM`/`PM` (Arabic locale still shows
"AM/PM"). `SlotStatus.selected` is a *display* state stored in the *domain* status enum,
which is why the cubit must keep two parallel lists (`_baseSlots` and the overlay list).

Expected:
Brief §8: `TimeSlot` carries start, end and status (`available/booked/unavailable`).

Impact:
Magic numbers, two sources of truth, non-localized time text.

Recommended fix:
`TimeSlot(start, end, status)` in `data/models/time_slot.dart`, status enum without
`selected`; format times in presentation with the platform localizations.

### ISSUE-008 — Validator is free functions built on list-position index maths

File:
`lib/features/booking/domain/booking_validator.dart` (lines 10-12, 23-27, 170-186)

Problem:
Rules are top-level functions with day bounds as `const int` (`17`, `18` slots) that
duplicate the seed's shape. `_createsInvalidGap` relies on "list position == slot index"
(comment at line 173). Not injectable, so the cubit cannot be tested with a fake rule set.

Expected:
Brief §10: a `BookingValidator` exposing `getRequiredSlots`, `isWithinWorkingHours`,
`hasConflict`, `areSlotsConsecutive`, `wouldCreateIsolatedGap`, `getValidStartTimes`,
`validateBooking`.

Impact:
Hidden coupling to list ordering; bounds not derived from the schedule.

Recommended fix:
`BookingValidator` class in `domain/services/`, working on `TimeSlot` times; working-day
end is taken from the schedule itself, not a magic constant.

### ISSUE-009 — Folder structure differs from the requested target

File:
`lib/features/booking/**`

Problem:
Code lives under `features/booking/{data,domain,presentation}`; the brief's target is
`lib/data`, `lib/domain/services`, `lib/presentation/{cubit,views}`.

Expected:
Brief §7 target tree.

Impact:
Structural non-compliance only; no behavioural effect.

Recommended fix:
Move files with `git mv`; keep `core/` and `l10n/`. (Note: the user's global CLAUDE.md
prefers `features/{name}/...`; the explicit task instruction takes precedence here.)

### ISSUE-010 — State is one flat class with five nullable fields and a status enum used as an event

File:
`lib/features/booking/presentation/manager/booking_data_state.dart`;
`lib/features/booking/presentation/manager/booking_state.dart`

Problem:
`BookingData` carries `selectedStartIndex?`, `selectedEndIndex?`, `validationResult?`
plus `status` (`idle/selected/confirmed`). `confirmed` is really a one-shot event, and
`listenWhen` (booking_view_body.dart:26-30) ignores `previous`. The state has no value
equality, so identical states re-emit and rebuild.

Expected:
Brief §12: clean immutable state, few unrelated flags.

Impact:
Impossible states are representable (e.g. `selected` with null start); fragile listener.

Recommended fix:
`Equatable` state: `BookingLoading` | `BookingLoaded(slots, duration, selectedStart,
validation, validStartTimes, confirmedBooking?)`; derive end/selected slots by getter.

---

## UX

### ISSUE-011 — Summary lacks "Total Booking Duration"; end time hidden when invalid

File:
`lib/features/booking/presentation/widgets/booking_summary_widget.dart` (lines 52-57)

Problem:
Shows Start / End / Duration only. For a range past 6 PM the End row is `—`.

Expected:
Brief §6: Start Time, End Time, Selected Duration **and** Total Booking Duration.
Showing the computed end (e.g. 6:30 PM) also explains an "exceeds 6 PM" error.

Recommended fix:
Add a Total row (formatted hours/minutes) and always show the calculated end time.

### ISSUE-012 — Accessibility: colour-only status, small chip targets, no semantics, low contrast

File:
`slot_cell_widget.dart` (lines 36-44, 65-71); `duration_chip_widget.dart` (lines 26-31);
`app_colors.dart` (`slotUnavailableFg` on `slotUnavailableBg`)

Problem:
- Available/booked/unavailable differ only by colour; the cell text is just the time.
- Duration chips are `GestureDetector` + `10.h` vertical padding around 14 sp text
  (≈ 40 dp, under the 48 dp guideline), with no ripple, focus, or selected semantics.
- No `Semantics` anywhere in `lib/` (verified by grep).
- `slotUnavailableFg #94A3B8` on `#F1F5F9` is roughly 2.3:1 (estimated), below 4.5:1;
  "available but not a valid start" further applies `Opacity(0.45)`.

Recommended fix:
Add status icons + semantic labels to cells, `Semantics(selected/button)` and ≥48 dp
targets to chips, use `InkWell`, and raise the unavailable/dimmed contrast.

---

## Minor

### ISSUE-013 — `handleSlotTap` is a pure alias of `selectStartTime`

File:
`lib/features/booking/presentation/manager/booking_cubit.dart` (lines 120-123)

Problem: one-line forwarding method; two public names for one action (used by UI and tests).
Recommended fix: keep a single entry point.

### ISSUE-014 — No guard for a start outside the schedule

File:
`lib/features/booking/domain/booking_validator.dart` (`validateBooking` lines 99-108; `applyBooking` line 143)

Problem:
`validateBooking(startIndex: -1, …)` yields an empty required range, passes every check
and returns **valid**. `applyBooking` uses `calculateEndIndex(...)!` and throws a null-check
error when out of range. Not reachable from the current UI, but the API is unsafe.

Recommended fix: return `exceedsWorkingHours`/not-found for a start that is not a schedule slot.

---

## Code Quality

### ISSUE-015 — `pubspec.yaml` configuration problems

File:
`pubspec.yaml` (lines 16, 19, 31-32)

Problem:
- `flutter_launcher_icons` and `flutter_native_splash` are listed under `dependencies`,
  so they are resolved into the app; they are build-time tools (`dev_dependencies`).
- `assets: - assets/images/` is a **top-level** key, outside `flutter:`, so Flutter ignores
  it. (Harmless at runtime today because no code loads an asset and the icon/splash
  generators read their own yaml files, but it is wrong config.)

Recommended fix: move the two packages to `dev_dependencies`; nest `assets` under `flutter:` or remove it.

### ISSUE-016 — README is the default template with a corrupted (UTF-16) tail

File: `README.md`

Problem: boilerplate text; last line contains NUL-interleaved characters
(`#   b o o k i n g …`), i.e. the file was appended in UTF-16.
Recommended fix: replace with a short project README (run, architecture, rules).

### ISSUE-017 — Test suite is coupled to the index-based API and misses key cases

File:
`test/features/booking/domain/booking_validator_test.dart`

Problem:
Tests assert on `int` indexes (`calculateEndIndex`, `getValidStartIndexes`) and will not
survive the `TimeSlot` refactor. No test covers: a pre-existing isolated slot elsewhere
(ISSUE-001), the `X O O X` matrix, selection kept-and-flagged on duration change
(ISSUE-002), unavailable-as-`X` in a *both-sides* sense with multiple blocked slots, or
the repository. Test names carry numeric IDs (`T01…T47`) instead of describing behaviour.

Recommended fix: rewrite against the new API, add the missing cases, one behaviour per test.

---

### ISSUE-018 — Error snackbar survives Reset (found while writing the widget tests)

File:
`lib/features/booking/presentation/widgets/booking_action_bar_widget.dart` (`onPressed: cubit.reset`, before the refactor)

Problem:
Reset restored the state and cleared the inline banner, but a snackbar from the earlier
invalid tap ("… already booked") stayed on screen for its 3 s duration, describing a
selection that no longer existed.

Expected:
Brief §6: Reset returns the screen to the initial state.

Recommended fix:
Clear snackbars in the Reset button handler (a UI concern; the cubit stays pure).
Covered by the page test "Reset returns to the initial state".

---

## Status

| Issue | Status | How |
|---|---|---|
| 001 Gap rule blamed pre-existing gaps | Fixed | `wouldCreateIsolatedGap` compares isolated slots before vs. after; mutation-checked test |
| 002 Duration change dropped selection | Fixed | Selection kept and revalidated; reason shown |
| 003 Hardcoded English snackbar, duplicate mapping | Fixed | One `BookingInvalidReason.message(l10n)` used by banner and snackbar |
| 004 Coarse reasons | Fixed | Six specific reasons, en + ar strings |
| 005 Overlay hid booked slots; no invalid state | Fixed | Display derived in presentation; invalid look + legend entry |
| 006 No repository | Fixed | `BookingRepository` + `BookingRepositoryImpl`, injected |
| 007 `SlotModel` without times / `selected` in data enum | Fixed | `TimeSlot(start, end, status)`; localized time formatting |
| 008 Free functions, magic constants | Fixed | Injectable `BookingValidator`; day bounds come from the schedule |
| 009 Folder structure | Fixed | `lib/data`, `lib/domain`, `lib/presentation` |
| 010 Flat nullable state | Fixed | Sealed `Equatable` state; `BookingSelection` bundles start + validation |
| 011 No Total row / hidden end time | Fixed | Total row added; end always shown |
| 012 Accessibility | Fixed | Icons, semantics, 48 dp cells and chips, contrast raised |
| 013 `handleSlotTap` alias | Fixed | Removed |
| 014 No out-of-schedule guard | Fixed | Out-of-range start → `exceedsWorkingHours`; test added |
| 015 pubspec config | Fixed | Tools moved to `dev_dependencies`; ineffective `assets:` key removed |
| 016 README | Fixed | Rewritten |
| 017 Test suite | Fixed | Rewritten against the new API, behaviour-named, plus new cases |
| 018 Snackbar survives Reset | Fixed | Cleared in the Reset handler |

### Not addressed (out of scope, noted by the independent review)
- `go_router` is used for a single route. Left in place: it is existing infrastructure and removing it is a separate change.
- `duration_chip_widget.dart` keeps an inherited hardcoded dark chip colour (`0xFF1E2340`); `summary_row_widget.dart` overrides a font size inline.
- `main.dart` passes a literal `title` instead of the localized `appTitle`.
- Grid rebuilds all 18 cells on any state change (negligible at this size).
