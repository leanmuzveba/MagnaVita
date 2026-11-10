import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../domain/plan.dart';
import '../../state/providers.dart';
import '../workout/exercise_detail.dart';
import '../workout/plan_screen.dart';
import '../workout/workout_screen.dart';

IconData focusIcon(PlanFocus f) => switch (f) {
  PlanFocus.legs => Icons.directions_walk,
  PlanFocus.pull || PlanFocus.backBiceps || PlanFocus.back => Icons.sports_gymnastics,
  PlanFocus.shouldersCore || PlanFocus.shoulders || PlanFocus.armsCore => Icons.accessibility_new,
  _ => Icons.fitness_center,
};

/// "This week": the Mon–Sun strip and one card per day of your plan. Days
/// before the next one are done this round; tap a card for its exercises.
class WeekPlanSection extends ConsumerWidget {
  const WeekPlanSection({super.key, required this.plan});
  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = ref.watch(nowProvider).value ?? ref.read(clockProvider)();
    final today = localDay(now);
    final trainsToday = plan.weekdays.contains(today.weekday);
    final nextIsToday = plan.nextSession(now) == today;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonoLabel(l.planYours),
        const SizedBox(height: 4),
        Semantics(header: true, child: Text(l.weekTitle, style: AppText.title.copyWith(fontSize: 22))),
        const SizedBox(height: 14),
        _WeekStrip(plan: plan, today: today),
        const SizedBox(height: 18),
        if (!trainsToday) ...[
          RuvaCard(
            child: Row(
              children: [
                const IconBubble(icon: Icons.spa_outlined, size: 36),
                const SizedBox(width: 14),
                Expanded(child: Text(l.weekRestDay, style: AppText.body.copyWith(fontSize: 14))),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        for (var i = 0; i < plan.days.length; i++) ...[
          _DayCard(
            plan: plan,
            day: i,
            look: i < plan.next
                ? _Look.done
                : i == plan.next
                ? _Look.next
                : i == plan.next + 1
                ? _Look.pale
                : _Look.muted,
            badge: i == plan.next ? (nextIsToday ? l.today : l.planNext) : null,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.plan, required this.today});
  final WorkoutPlan plan;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final recent = ref.watch(recentActivitiesProvider).value ?? const [];
    final trained = {for (final a in recent) localDay(a.startedAt.toLocal())};
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: () {
              final d = DateTime(monday.year, monday.month, monday.day + i);
              final done = trained.contains(d), isToday = d == today, training = plan.weekdays.contains(d.weekday);
              final filled = done || isToday;
              final name = weekdayName(context, d.weekday);
              return Semantics(
                container: true,
                label: [
                  name,
                  if (isToday) l.today,
                  if (training) l.weekTrainingDay,
                  if (done) l.weekTrained,
                ].join(', '),
                excludeSemantics: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: filled ? AppColors.primary : null,
                    borderRadius: BorderRadius.circular(999),
                    border: filled
                        ? null
                        : Border.all(color: AppColors.primary.withValues(alpha: training ? 0.45 : 0.12), width: 1.4),
                  ),
                  child: Column(
                    children: [
                      FittedBox(
                        child: Text(
                          (name.length > 3 ? name.substring(0, 3) : name).toUpperCase(),
                          style: AppText.overline.copyWith(
                            fontSize: 10,
                            color: filled ? onForestMuted : AppColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.day}',
                        style: AppText.cardValue.copyWith(fontSize: 16, color: filled ? AppColors.white : AppColors.text),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 12,
                        child: done
                            ? const Icon(Icons.check, size: 12, color: AppColors.accent)
                            : isToday
                            ? const Center(child: CircleAvatar(radius: 3, backgroundColor: AppColors.accent))
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }(),
          ),
        ],
      ],
    );
  }
}

enum _Look { done, next, pale, muted }

class _DayCard extends StatelessWidget {
  const _DayCard({required this.plan, required this.day, required this.look, this.badge});
  final WorkoutPlan plan;
  final int day;
  final _Look look;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = plan.days[day];
    final dark = look == _Look.next;
    final fg = dark ? AppColors.white : AppColors.primaryDark;
    final colors = switch (look) {
      _Look.done => const [AppColors.accent, AppColors.background],
      _Look.next => const [AppColors.primaryMid, AppColors.primary],
      _Look.pale => const [AppColors.cream, AppColors.lime200],
      _Look.muted => const [AppColors.background, AppColors.track],
    };
    final minutes = l.activityMinutes(d.minutes(plan.rest));
    final sub = l.weekDayCard(day + 1, d.exercises.length);
    final title = focusLabel(l, d.focus);
    return Semantics(
      button: true,
      label: [title, sub, minutes, ?badge, if (look == _Look.done) l.weekDayDoneSemantics].join(', '),
      hint: l.weekDayOpen,
      excludeSemantics: true,
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => PlanDayScreen(day: day))),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            ),
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Icon(focusIcon(d.focus), size: 72, color: fg.withValues(alpha: dark ? 0.3 : 0.18)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_filled, size: 14, color: dark ? AppColors.accent : AppColors.primary),
                        const SizedBox(width: 6),
                        MonoLabel(minutes, color: fg),
                        const Spacer(),
                        if (look == _Look.done)
                          const CircleAvatar(
                            radius: 13,
                            backgroundColor: Color(0xCCFFFFFF),
                            child: Icon(Icons.check, size: 16, color: AppColors.primary),
                          )
                        else if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(999)),
                            child: MonoLabel(badge!, color: AppColors.onAccent, size: 10),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(title.toUpperCase(), style: AppText.title.copyWith(fontSize: 20, color: fg)),
                    const SizedBox(height: 6),
                    Text(sub, style: AppText.small.copyWith(color: dark ? onForestMuted : AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One day of your plan: its exercises, and the button that starts it
/// (the workout screen then ticks off each set).
class PlanDayScreen extends ConsumerWidget {
  const PlanDayScreen({super.key, required this.day});
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final plan = ref.watch(planProvider).value;
    final library = ref.watch(exerciseLibraryProvider).value ?? const [];
    final inProgress = ref.watch(workoutProvider).value != null;
    if (plan == null || day >= plan.days.length) return const Scaffold(body: SizedBox.shrink());
    final d = plan.days[day];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: l.back,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.chevron_left_rounded, size: 30, color: AppColors.primary),
                    ),
                  ),
                  MonoLabel('${l.weekDayCard(day + 1, d.exercises.length)} · ${l.activityMinutes(d.minutes(plan.rest))}'),
                  const SizedBox(height: 4),
                  Semantics(
                    header: true,
                    child: Text(focusLabel(l, d.focus), style: AppText.title.copyWith(fontSize: 26)),
                  ),
                  const SizedBox(height: 8),
                  Text(l.dayExercisesHint, style: AppText.small),
                  const SizedBox(height: 18),
                  for (final (i, x) in d.exercises.indexed) ...[
                    RuvaCard(
                      onTap: switch (library.where((e) => e.id == x.libraryId).firstOrNull) {
                        final e? => () => showExerciseDetail(context, e),
                        null => null,
                      },
                      child: Row(
                        children: [
                          IconBubble(
                            icon: focusIcon(d.focus),
                            size: 40,
                            background: i == 0 ? AppColors.primary : AppColors.lime200,
                            foreground: i == 0 ? AppColors.accent : AppColors.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(x.name, style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w500)),
                          ),
                          Text('${x.sets} × ${x.log.first.reps}', style: AppText.cardValue.copyWith(fontSize: 15)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: PrimaryButton(
                label: inProgress ? l.workoutResume : l.planStartDay(day + 1),
                onPressed: d.exercises.isEmpty
                    ? null
                    : inProgress
                    ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WorkoutScreen()))
                    : () => startPlanDay(context, ref, day),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
