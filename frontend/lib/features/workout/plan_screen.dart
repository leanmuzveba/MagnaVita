import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/pill_button.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/sheet.dart';
import '../../domain/activity.dart';
import '../../domain/goals.dart';
import '../../domain/plan.dart';
import '../../domain/workout.dart';
import '../../state/providers.dart';
import 'exercise_detail.dart';
import 'workout_screen.dart';

String goalLabel(AppLocalizations l, PlanGoal g) => switch (g) {
  PlanGoal.strength => l.goalStrength,
  PlanGoal.muscle => l.goalMuscle,
  PlanGoal.endurance => l.goalEndurance,
  PlanGoal.fatLoss => l.goalFatLoss,
};

String focusLabel(AppLocalizations l, PlanFocus f) => switch (f) {
  PlanFocus.push => l.focusPush,
  PlanFocus.pull => l.focusPull,
  PlanFocus.legs => l.focusLegs,
  PlanFocus.chestTriceps => l.focusChestTriceps,
  PlanFocus.backBiceps => l.focusBackBiceps,
  PlanFocus.shouldersCore => l.focusShouldersCore,
  PlanFocus.chest => l.focusChest,
  PlanFocus.back => l.focusBack,
  PlanFocus.shoulders => l.focusShoulders,
  PlanFocus.armsCore => l.focusArmsCore,
};

/// "Day 2 · Back & biceps".
String planDayLabel(AppLocalizations l, WorkoutPlan p, int day) => l.planDay(day + 1, focusLabel(l, p.days[day].focus));

Future<void> showPlan(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PlanScreen()));

/// Starts [day] of your plan and opens the workout.
Future<void> startPlanDay(BuildContext context, WidgetRef ref, int day) async {
  await ref.read(workoutProvider.notifier).startPlanned(day);
  if (context.mounted) {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WorkoutScreen()));
  }
}

/// Your weekly plan, or the questions that make one.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  var _changing = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final plan = ref.watch(planProvider);
    if (!plan.hasValue) return const Scaffold(body: SizedBox.shrink());
    final p = plan.value;
    return Scaffold(
      body: SafeArea(
        child: p == null || _changing
            ? _PlanSetup(current: p, onDone: () => setState(() => _changing = false))
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                children: [
                  ScreenHeader(
                    title: l.planTitle,
                    subtitle: l.planSummary(goalLabel(l, p.goal), p.days.length, p.rest),
                  ),
                  _WeekCard(plan: p),
                  const SizedBox(height: 12),
                  for (var d = 0; d < p.days.length; d++) ...[_DayCard(plan: p, day: d), const SizedBox(height: 12)],
                  Text(l.planEditHint, textAlign: TextAlign.center, style: AppText.small),
                  TextButton(onPressed: () => setState(() => _changing = true), child: Text(l.planChange)),
                ],
              ),
      ),
    );
  }
}

/// [weekday]'s name (1 = Monday) in the app's language; [narrow] gives "M".
String weekdayName(BuildContext context, int weekday, {bool narrow = false}) => DateFormat(
  narrow ? 'EEEEE' : 'EEEE',
  Localizations.localeOf(context).toString(),
).format(DateTime(2024, 1, weekday)); // 1 Jan 2024 was a Monday

/// This week, Monday to Sunday: the days you train (tap to change), what
/// you've done, and the reminder for training days.
class _WeekCard extends ConsumerWidget {
  const _WeekCard({required this.plan});
  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = ref.read(clockProvider)();
    final monday = weekStart(now);
    final today = now.toLocal().weekday;
    final trained = {
      for (final s in ref.watch(strengthSessionsProvider).value ?? const <ActivityEntry>[])
        if (weekStart(s.startedAt) == monday) s.startedAt.toLocal().weekday,
    };
    final n = ref.read(planProvider.notifier);
    final remindAt = plan.remindAt;
    final time = TimeOfDay(hour: (remindAt ?? 18 * 60) ~/ 60, minute: (remindAt ?? 0) % 60);

    Future<void> pickTime() async {
      final t = await showTimePicker(context: context, initialTime: time);
      if (t == null) return;
      if (!await n.setReminder(t.hour * 60 + t.minute) && context.mounted) {
        showRuvaSnack(context, l.settingsNotificationsBlocked);
      }
    }

    return RuvaCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(l.planWeek),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var w = 1; w <= 7; w++)
                () {
                  final name = weekdayName(context, w);
                  final done = trained.contains(w), training = plan.weekdays.contains(w);
                  return Semantics(
                    button: true,
                    selected: training,
                    label: done
                        ? l.planWeekdayTrained(name)
                        : training
                        ? l.planWeekdayTraining(name)
                        : l.planWeekdayRest(name),
                    excludeSemantics: true,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => n.toggleWeekday(w),
                      child: Column(
                        children: [
                          Text(weekdayName(context, w, narrow: true), style: AppText.small.copyWith(fontSize: 11)),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? AppColors.primary
                                  : training
                                  ? AppColors.lime200
                                  : null,
                              border: Border.all(
                                color: w == today ? AppColors.primary : AppColors.muted.withValues(alpha: 0.35),
                                width: w == today ? 2 : 1,
                              ),
                            ),
                            child: done
                                ? const Icon(Icons.check, size: 20, color: AppColors.white)
                                : Text('${DateTime(monday.year, monday.month, monday.day + w - 1).day}'),
                          ),
                        ],
                      ),
                    ),
                  );
                }(),
            ],
          ),
          const SizedBox(height: 10),
          Text(l.planWeekHint, style: AppText.small),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.planRemind, style: AppText.body.copyWith(fontSize: 15)),
            subtitle: remindAt == null
                ? null
                : Text(l.planRemindAt(MaterialLocalizations.of(context).formatTimeOfDay(time)), style: AppText.small),
            value: remindAt != null,
            onChanged: (on) => on ? pickTime() : n.setReminder(null),
          ),
          if (remindAt != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: pickTime, child: Text(l.settingsReminderTime)),
            ),
        ],
      ),
    );
  }
}

class _DayCard extends ConsumerWidget {
  const _DayCard({required this.plan, required this.day});
  final WorkoutPlan plan;
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final next = plan.next == day;
    final exercises = plan.days[day].exercises;
    return RuvaCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: MonoLabel(planDayLabel(l, plan, day))),
              if (next)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: RuvaChip(label: l.planNext, selected: true, dense: true),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (final (i, x) in exercises.indexed)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(x.name, style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w500)),
              trailing: Text('${x.sets} × ${x.log.first.reps}', style: AppText.cardValue.copyWith(fontSize: 15)),
              onTap: () => showAppSheet<void>(context, (_) => _PlannedSheet(day: day, index: i)),
            ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: double.infinity,
              child: PillButton(
                label: l.planStartDay(day + 1),
                outlined: !next,
                onPressed: exercises.isEmpty ? null : () => startPlanDay(context, ref, day),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One planned exercise: sets and reps, how to do it, or swap it.
class _PlannedSheet extends ConsumerWidget {
  const _PlannedSheet({required this.day, required this.index});
  final int day;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = ref.watch(planProvider).value;
    final library = ref.watch(exerciseLibraryProvider).value ?? const [];
    if (p == null || index >= p.days[day].exercises.length) return const SizedBox.shrink();
    final n = ref.read(planProvider.notifier);
    final x = p.days[day].exercises[index];
    final (sets, reps) = (x.sets, x.log.first.reps);
    final entry = library.where((e) => e.id == x.libraryId).firstOrNull;
    final others = entry == null || entry.primary.isEmpty
        ? const []
        : [
            for (final o in exercisesFor(library, entry.primary.first, p.level, p.equipment))
              if (o.id != x.libraryId && !p.days[day].exercises.any((e) => e.libraryId == o.id)) o,
          ].take(8).toList();
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(x.name, style: AppText.title)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            ValueStepper(
              label: l.planSets(sets),
              minusTooltip: l.exerciseFewerSets,
              plusTooltip: l.exerciseMoreSets,
              onMinus: sets > 1 ? () => n.setSetsReps(day, index, sets - 1, reps) : null,
              onPlus: sets < 10 ? () => n.setSetsReps(day, index, sets + 1, reps) : null,
            ),
            ValueStepper(
              label: l.planReps(reps),
              minusTooltip: l.exerciseFewerReps,
              plusTooltip: l.exerciseMoreReps,
              onMinus: reps > 1 ? () => n.setSetsReps(day, index, sets, reps - 1) : null,
              onPlus: reps < 50 ? () => n.setSetsReps(day, index, sets, reps + 1) : null,
            ),
          ],
        ),
        if (entry != null)
          OutlinedButton.icon(
            onPressed: () => showExerciseDetail(context, entry),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
            icon: const Icon(Icons.info_outline),
            label: Text(l.exerciseAbout(x.name)),
          ),
        if (others.isNotEmpty) ...[
          MonoLabel(l.planSwapFor),
          for (final o in others)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
              title: Text(o.name, style: AppText.body.copyWith(fontSize: 15)),
              onTap: () async {
                await n.swap(day, index, o);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
          onPressed: () async {
            await n.remove(day, index);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l.planRemove),
        ),
      ],
    );
  }
}

/// Goal, days a week, experience and equipment → a plan.
class _PlanSetup extends ConsumerStatefulWidget {
  const _PlanSetup({required this.current, required this.onDone});
  final WorkoutPlan? current;
  final VoidCallback onDone;

  @override
  ConsumerState<_PlanSetup> createState() => _PlanSetupState();
}

class _PlanSetupState extends ConsumerState<_PlanSetup> {
  // A new plan starts from your setup answers.
  late final _setup = ref.read(userGoalsProvider).value;
  late var _goal = widget.current?.goal ?? (_setup?.main == null ? PlanGoal.muscle : planGoalFor(_setup!.main));
  late var _days = widget.current?.days.length ?? planDaysFor(_setup?.trainingDays);
  late var _level = widget.current?.level ?? _setup?.level ?? PlanLevel.beginner;
  late var _equipment = widget.current?.equipment ?? _setup?.equipment ?? PlanEquipment.gym;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget chips<T>(String title, List<T> values, T selected, String Function(T) label, ValueChanged<T> pick) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        MonoLabel(title),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in values)
              RuvaChip(label: label(v), selected: v == selected, outlined: true, onTap: () => setState(() => pick(v))),
          ],
        ),
      ],
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        ScreenHeader(title: l.planSetupTitle, subtitle: l.planSetupSub),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              chips(l.planGoal, PlanGoal.values, _goal, (g) => goalLabel(l, g), (g) => _goal = g),
              chips(l.planDaysPerWeek, const [3, 4, 5], _days, (d) => l.planDaysChip(d), (d) => _days = d),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(splits[_days]!.map((f) => focusLabel(l, f)).join(' · '), style: AppText.small),
              ),
              chips(
                l.planLevel,
                PlanLevel.values,
                _level,
                (v) => switch (v) {
                  PlanLevel.beginner => l.levelBeginner,
                  PlanLevel.intermediate => l.levelIntermediate,
                  PlanLevel.expert => l.levelExpert,
                },
                (v) => _level = v,
              ),
              chips(
                l.planEquipment,
                PlanEquipment.values,
                _equipment,
                (v) => switch (v) {
                  PlanEquipment.gym => l.planEquipGym,
                  PlanEquipment.dumbbells => l.planEquipDumbbells,
                  PlanEquipment.bodyweight => l.planEquipBodyweight,
                },
                (v) => _equipment = v,
              ),
              const SizedBox(height: 28),
              if (widget.current != null) ...[
                Text(l.planReplaces, textAlign: TextAlign.center, style: AppText.small),
                const SizedBox(height: 8),
              ],
              PrimaryButton(
                label: l.planCreate,
                onPressed: () async {
                  await ref
                      .read(planProvider.notifier)
                      .create(goal: _goal, daysPerWeek: _days, level: _level, equipment: _equipment);
                  widget.onDone();
                },
              ),
              if (widget.current != null) TextButton(onPressed: widget.onDone, child: Text(l.cancel)),
            ],
          ),
        ),
      ],
    );
  }
}
