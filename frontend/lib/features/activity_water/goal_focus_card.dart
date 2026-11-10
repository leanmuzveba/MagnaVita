import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../domain/food.dart';
import '../../domain/goals.dart';
import '../../domain/workout.dart';
import '../../state/providers.dart';
import '../profile/energy_section.dart' show formatKcal;
import '../profile/profile_screen.dart';

/// Minutes of moderate activity a week the WHO suggests for adults (at least).
const weeklyActiveMinutesGuide = 150;

/// Protein guide for building muscle: about 1.6 g per kg of body weight.
const proteinPerKgForMuscle = 1.6;

/// The top of the Activity page, arranged around your main goal. Nothing for
/// "better fasting habits" or no goal (the timer on Home covers fasting).
class GoalFocusCard extends ConsumerWidget {
  const GoalFocusCard({super.key, required this.goal});
  final MainGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (goal) {
    MainGoal.loseWeight || MainGoal.maintain => _CaloriesCard(goal: goal),
    MainGoal.buildMuscle => const _MuscleCard(),
    MainGoal.getFitter => const _FitterCard(),
    MainGoal.fasting => const SizedBox.shrink(),
  };
}

DateTime _today(WidgetRef ref) {
  final now = ref.read(clockProvider)().toLocal();
  return DateTime(now.year, now.month, now.day);
}

String _n(num v) => NumberFormat.decimalPattern().format(v.round());

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => RuvaCard(
    padding: const EdgeInsets.all(18),
    child: Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(context.l10n.focusYourGoal),
          const SizedBox(height: 4),
          Text(title, style: AppText.title.copyWith(fontSize: 18)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.sub});
  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.small.copyWith(fontSize: 12)),
        Text(value, style: AppText.cardValue.copyWith(fontSize: 18)),
        if (sub != null) Text(sub!, style: AppText.small.copyWith(fontSize: 11.5)),
      ],
    ),
  );
}

Widget _bar(double fraction, {String? semantics}) => Semantics(
  label: semantics,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: LinearProgressIndicator(
      value: fraction.clamp(0, 1),
      minHeight: 10,
      color: AppColors.primary,
      backgroundColor: AppColors.track,
    ),
  ),
);

/// Lose weight / stay where I am: eaten vs your daily calories, burned, steps.
class _CaloriesCard extends ConsumerWidget {
  const _CaloriesCard({required this.goal});
  final MainGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final today = _today(ref);
    final food = ref.watch(diaryDayProvider(today)).value ?? const <FoodEntry>[];
    final eaten = DayTotals(food).sum[Nutrient.energy] ?? 0;
    final stats = ref.watch(dayStatsProvider(today)).value;
    final target = ref.watch(dailyCaloriesProvider).value;
    final title = goal == MainGoal.loseWeight ? l.focusLoseTitle : l.focusMaintainTitle;
    return _Frame(
      title: title,
      children: [
        Row(
          children: [
            _Stat(l.focusEaten, '${_n(eaten)} kcal', sub: target == null ? null : l.focusOf(formatKcal(target))),
            _Stat(l.focusBurned, '${_n(stats?.kcal ?? 0)} kcal', sub: l.focusEstimate),
            _Stat(l.focusSteps, stats?.steps == null ? '—' : _n(stats!.steps!)),
          ],
        ),
        const SizedBox(height: 12),
        if (target != null) ...[
          _bar(eaten / target, semantics: l.focusEatenLabel(_n(eaten), formatKcal(target))),
          const SizedBox(height: 8),
          Text(
            eaten <= target ? l.focusLeft(formatKcal(target - eaten)) : l.focusOver(formatKcal(eaten - target)),
            style: AppText.small,
          ),
        ] else
          TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(48, 40)),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: Text(l.focusSetUpCalories),
          ),
      ],
    );
  }
}

/// Build muscle: workouts this week against your plan, streak and protein today.
class _MuscleCard extends ConsumerWidget {
  const _MuscleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = ref.read(clockProvider)();
    final sessions = ref.watch(strengthSessionsProvider).value ?? const [];
    final counts = weeklyCounts(sessions.map((s) => s.startedAt), now);
    final plan = ref.watch(planProvider).value;
    final goals = ref.watch(userGoalsProvider).value;
    final planned = plan?.days.length ?? goals?.trainingDays;
    final thisWeek = counts.last;
    final food = ref.watch(diaryDayProvider(_today(ref))).value ?? const <FoodEntry>[];
    final protein = DayTotals(food).sum[Nutrient.protein] ?? 0;
    final weighIns = ref.watch(weighInsProvider).value ?? const [];
    final proteinGuide = weighIns.isEmpty ? null : weighIns.last.weightKg * proteinPerKgForMuscle;
    return _Frame(
      title: l.focusMuscleTitle,
      children: [
        Row(
          children: [
            _Stat(
              l.progressThisWeek,
              planned == null || planned == 0 ? '$thisWeek' : l.progressOfPlan(thisWeek, planned),
              sub: l.focusWorkouts,
            ),
            _Stat(l.progressStreak, l.progressWeeks(weekStreak(counts))),
            _Stat(
              l.focusProtein,
              '${_n(protein)} g',
              sub: proteinGuide == null ? null : l.focusOfGrams(_n(proteinGuide)),
            ),
          ],
        ),
        if (planned != null && planned > 0) ...[
          const SizedBox(height: 12),
          _bar(thisWeek / planned, semantics: l.progressOfPlan(thisWeek, planned)),
        ],
        if (proteinGuide != null) ...[
          const SizedBox(height: 8),
          Text(l.focusProteinWhy, style: AppText.small.copyWith(fontSize: 12)),
        ],
      ],
    );
  }
}

/// Get fitter: active minutes this week (WHO: 150+) and steps today.
class _FitterCard extends ConsumerWidget {
  const _FitterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final today = _today(ref);
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    var minutes = 0;
    for (var d = monday; !d.isAfter(today); d = DateTime(d.year, d.month, d.day + 1)) {
      minutes += ref.watch(dayStatsProvider(d)).value?.activeMinutes ?? 0;
    }
    final steps = ref.watch(dayStatsProvider(today)).value?.steps;
    final goal = ref.watch(stepGoalProvider).value;
    return _Frame(
      title: l.focusFitterTitle,
      children: [
        Row(
          children: [
            _Stat(l.focusActiveMinutes, l.focusMinutesOf(minutes, weeklyActiveMinutesGuide), sub: l.progressThisWeek),
            _Stat(
              l.focusSteps,
              steps == null ? '—' : _n(steps),
              sub: goal == null ? null : l.homeStepGoal(_n(goal)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _bar(
          minutes / weeklyActiveMinutesGuide,
          semantics: l.focusMinutesOf(minutes, weeklyActiveMinutesGuide),
        ),
        const SizedBox(height: 8),
        Text(
          minutes >= weeklyActiveMinutesGuide
              ? l.focusMinutesDone
              : l.focusMinutesLeft(math.max(0, weeklyActiveMinutesGuide - minutes)),
          style: AppText.small,
        ),
      ],
    );
  }
}
