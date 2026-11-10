import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/sheet.dart';
import '../../domain/activity.dart';
import '../../domain/food.dart';
import '../../domain/hydration.dart';
import '../../domain/steps.dart';
import '../../state/providers.dart';
import '../ring/fasting_ring.dart' show FastingRing;
import 'stats_export_screen.dart';

/// Home dashboard (MagnaVita design): steps, then today's calories, hours fasted
/// and water. Logging happens from the centre + button.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onOpenTimer,
    required this.onOpenWater,
    required this.onOpenNutrition,
    required this.onOpenActivity,
  });
  final VoidCallback onOpenActivity;
  final VoidCallback onOpenTimer;
  final VoidCallback onOpenWater;
  final VoidCallback onOpenNutrition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = ref.watch(nowProvider).value?.toLocal();
    final settings = ref.watch(settingsProvider).value;
    final snap = ref.watch(timerSnapshotProvider(FastingRing.gapFor(300)));
    if (now == null || settings == null || snap == null) return const Center(child: CircularProgressIndicator());
    final today = DateTime(now.year, now.month, now.day);
    final hour = now.hour;
    final greeting = hour < 12
        ? l.greetingMorning
        : hour < 18
        ? l.greetingAfternoon
        : l.greetingEvening;
    final name = settings.userName.trim().split(RegExp(r'\s+')).first;

    ref.watch(watchSyncProvider); // pulls in new watch workouts (no-op when not connected)
    final food = ref.watch(diaryDayProvider(today)).value ?? const <FoodEntry>[];
    final kcal = DayTotals(food).sum[Nutrient.energy] ?? 0;
    final kcalTarget = ref.watch(dailyCaloriesProvider).value;
    final water = (ref.watch(hydrationDayProvider(today)).value ?? const <HydrationEntry>[]).fold(
      0.0,
      (a, e) => a + e.amountMl,
    );
    final unit = settings.waterUnit;
    final n = NumberFormat.decimalPattern();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        MonoLabel(DateFormat('EEEE · d MMM').format(now)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  name.isEmpty ? greeting : l.homeGreeting(greeting, name),
                  style: AppText.title.copyWith(fontSize: 22, height: 1.2),
                ),
              ),
            ),
            IconButton(
              tooltip: l.shareDayTooltip,
              icon: const Icon(Icons.ios_share_rounded, color: AppColors.primary),
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StatsExportScreen(day: today))),
            ),
          ],
        ),
        if (ref.watch(availableUpdateProvider).value case final update?) ...[
          const SizedBox(height: 16),
          RuvaCard(
            color: AppColors.lime200,
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                const Icon(Icons.system_update_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [l.updateAvailable, if (update.version.isNotEmpty) update.version].join(' · '),
                        style: AppText.cardValue.copyWith(fontSize: 15),
                      ),
                      if (update.notes.isNotEmpty)
                        Text(update.notes, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.small),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => launchUrl(Uri.parse(update.apkUrl), mode: LaunchMode.externalApplication),
                  child: Text(l.updateNow),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        const _StepsCard(),
        const SizedBox(height: 28),
        MonoLabel(l.homeToday),
        const SizedBox(height: 12),
        _MetricRow(
          icon: Icons.local_fire_department_outlined,
          label: l.homeCalories,
          value: n.format(kcal.round()),
          unit: 'kcal',
          sub: kcalTarget == null ? l.homeCaloriesSub : l.homeCaloriesOf(n.format(kcalTarget.round())),
          progress: kcalTarget == null ? null : (kcal / kcalTarget).clamp(0.0, 1.0),
          onTap: onOpenNutrition,
        ),
        const SizedBox(height: 12),
        _MetricRow(
          icon: Icons.timer_outlined,
          label: l.homeFasted,
          value: snap.running ? formatHoursMinutes(snap.elapsed) : '—',
          sub: snap.running
              ? l.homeFastGoal(formatTarget(snap.target), (snap.progress * 100).round())
              : l.homeNotFasting,
          progress: snap.running ? snap.progress : null,
          onTap: onOpenTimer,
        ),
        const SizedBox(height: 12),
        _MetricRow(
          icon: Icons.water_drop_outlined,
          label: l.homeWater,
          value: formatVolume(water, unit),
          sub: l.homeWaterGoal(formatVolume(settings.waterGoalMl.toDouble(), unit)),
          progress: (water / settings.waterGoalMl).clamp(0.0, 1.0),
          onTap: onOpenWater,
        ),
        ...() {
          // Watch calories (already include its workouts) + activities you logged yourself.
          final watchKcal = ref.watch(watchCaloriesTodayProvider).value;
          final logged = (ref.watch(activityDayProvider(today)).value ?? const <ActivityEntry>[])
              .where((a) => !a.fromWatch)
              .fold(0.0, (sum, a) => sum + (a.kcal ?? 0));
          if (watchKcal == null && logged == 0) return const <Widget>[];
          return [
            const SizedBox(height: 12),
            _MetricRow(
              icon: watchKcal == null ? Icons.local_fire_department_outlined : Icons.watch_outlined,
              label: l.homeBurned,
              value: n.format(((watchKcal ?? 0) + logged).round()),
              unit: 'kcal',
              sub: watchKcal == null
                  ? l.homeBurnedLogged
                  : logged > 0
                  ? l.homeBurnedBoth
                  : watchKcal == 0
                  ? l.homeBurnedNone
                  : l.homeBurnedSub,
              onTap: onOpenActivity,
            ),
          ];
        }(),
      ],
    );
  }
}

class _StepsCard extends ConsumerWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final watchSteps = ref.watch(watchStepsTodayProvider).value;
    final synced = ref.watch(watchStepsSyncedProvider).value?.toLocal();
    // The watch counts the whole day; the phone sensor only since you opened the app.
    // Show the higher one, so a forgotten watch doesn't freeze the count.
    final phone = ref.watch(todayStepsProvider).value ?? const StepsState();
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final manual = ref.watch(manualStepsProvider(today)).value;
    final phoneOk = !phone.unavailable && !phone.needsPermission;
    final (count, source) = shownSteps(watch: watchSteps, phone: phoneOk ? phone.steps : null, manual: manual);
    final state = source == StepSource.phone ? phone : StepsState(steps: count);
    final height = ref.watch(bodyProfileProvider).value?.heightCm;
    final n = NumberFormat.decimalPattern();
    final muted = AppText.small.copyWith(color: onForestMuted, fontSize: 13);
    final goal = ref.watch(stepGoalProvider).value ?? dailyStepGoal;
    final progress = (state.steps / goal).clamp(0.0, 1.0);

    return ForestCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.homeSteps, style: AppText.title.copyWith(color: AppColors.white, fontSize: 18)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.route_outlined, size: 15, color: AppColors.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  [
                    l.homeKm(stepsToKm(state.steps, heightCm: height).toStringAsFixed(1)),
                    if (source == StepSource.watch) l.homeStepsWatch,
                    if (source == StepSource.edited) l.homeStepsEdited,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 40),
                  textStyle: muted,
                ),
                onPressed: () => showAppSheet<void>(context, (_) => _GoalSheet(goal: goal)),
                icon: const Icon(Icons.flag_outlined, size: 15, color: AppColors.accent),
                label: Text(l.homeStepGoal(n.format(goal)), style: muted),
              ),
              const Icon(Icons.edit_outlined, size: 13, color: onForestMuted),
            ],
          ),
          const SizedBox(height: 18),
          if (state.unavailable)
            Text(l.homeStepsUnavailable, style: muted)
          else if (state.needsPermission)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.homeStepsWhy, style: muted),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: () async {
                        final ok = await ref.read(stepCounterProvider).request();
                        if (ok) {
                          ref.invalidate(todayStepsProvider);
                        } else if (context.mounted) {
                          showRuvaSnack(context, l.homeStepsDenied);
                        }
                      },
                      child: Text(l.homeStepsAllow),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppColors.white, minimumSize: const Size(48, 48)),
                      onPressed: openAppSettings,
                      child: Text(l.homeStepsOpenSettings),
                    ),
                  ],
                ),
              ],
            )
          else
            Center(
              child: Semantics(
                container: true,
                label: '${l.homeSteps}: ${n.format(state.steps)}, ${l.homeOfGoal((progress * 100).round())}',
                excludeSemantics: true,
                child: _Gauge(
                  progress: progress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(n.format(state.steps), style: AppText.title.copyWith(fontSize: 30, color: AppColors.white)),
                      Text(
                        l.homeOfGoal((progress * 100).round()),
                        style: AppText.small.copyWith(color: AppColors.accent, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!state.unavailable && !state.needsPermission)
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.white, textStyle: muted),
                onPressed: () => showAppSheet<void>(
                  context,
                  (_) => _StepsEditSheet(day: today, current: state.steps, edited: manual != null),
                ),
                icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.accent),
                label: Text(l.homeStepsEdit),
              ),
            ),
          // Mi Fitness syncs in batches: say how fresh the watch's count is.
          if (synced != null && !state.unavailable && !state.needsPermission) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                l.homeWatchSynced(
                  formatClock(synced, use24h: ref.watch(settingsProvider).value?.use24HourTime ?? false),
                ),
                style: muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Segmented semicircle: lime ticks done, faint ticks to go.
class _Gauge extends StatelessWidget {
  const _Gauge({required this.progress, required this.child});
  final double progress;
  final Widget child;

  static const _width = 200.0;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: progress),
    duration: const Duration(milliseconds: 900),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => SizedBox(
      width: _width,
      height: _width * 0.56,
      child: CustomPaint(
        painter: _GaugePainter(v),
        child: Align(
          alignment: const Alignment(0, 0.95),
          child: FittedBox(fit: BoxFit.scaleDown, child: child),
        ),
      ),
    ),
  );
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.progress);
  final double progress;
  static const _segments = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.98);
    final outer = size.width / 2 - 4, inner = outer * 0.72;
    final done = (progress * _segments).round();
    for (var i = 0; i < _segments; i++) {
      final angle = math.pi + i / (_segments - 1) * math.pi;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * inner,
        center + dir * outer,
        Paint()
          ..color = i < done ? AppColors.accent : const Color(0x40FFFFFF)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.progress != progress;
}

/// Daily row: icon disc, label and value, optional progress bar, subtitle.
class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.onTap,
    this.unit,
    this.progress,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final String sub;
  final double? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    label: '$label: $value${unit == null ? '' : ' $unit'}. $sub',
    excludeSemantics: true,
    child: Material(
      color: AppColors.lime200.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(label, style: AppText.body.copyWith(color: AppColors.textSecondary)),
                        ),
                        Text(value, style: AppText.cardValue.copyWith(fontSize: 17)),
                        if (unit != null) ...[
                          const SizedBox(width: 3),
                          Text(unit!, style: AppText.small.copyWith(fontSize: 12)),
                        ],
                      ],
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.track,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryMid),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(sub, style: AppText.small.copyWith(fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Change the daily steps goal (500-step steps).
/// Type the count your watch shows; the phone keeps adding to it.
class _StepsEditSheet extends ConsumerStatefulWidget {
  const _StepsEditSheet({required this.day, required this.current, required this.edited});
  final DateTime day;
  final int current;
  final bool edited;

  @override
  ConsumerState<_StepsEditSheet> createState() => _StepsEditSheetState();
}

class _StepsEditSheetState extends ConsumerState<_StepsEditSheet> {
  late final _steps = TextEditingController(text: '${widget.current}');

  @override
  void dispose() {
    _steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final value = int.tryParse(_steps.text.replaceAll(RegExp(r'[^0-9]'), ''));
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.stepsEditTitle, style: AppText.title)),
        Text(l.stepsEditBody, style: AppText.body.copyWith(color: AppColors.textSecondary)),
        RuvaTextField(
          controller: _steps,
          label: l.stepsEditField,
          keyboardType: TextInputType.number,
          autofocus: true,
          bold: true,
          onChanged: (_) => setState(() {}),
        ),
        PrimaryButton(
          label: l.save,
          onPressed: value == null || value > 200000
              ? null
              : () async {
                  await setManualSteps(ref, widget.day, value);
                  if (context.mounted) Navigator.pop(context);
                },
        ),
        if (widget.edited)
          TextButton(
            onPressed: () async {
              await setManualSteps(ref, widget.day, null);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.stepsEditReset),
          ),
      ],
    );
  }
}

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({required this.goal});
  final int goal;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late int _goal = widget.goal;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = NumberFormat.decimalPattern();
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.homeStepGoalTitle, style: AppText.title)),
        ValueStepper(
          large: true,
          label: n.format(_goal),
          minusTooltip: l.addFoodLess,
          plusTooltip: l.addFoodMore,
          onMinus: _goal > minStepGoal ? () => setState(() => _goal -= 500) : null,
          onPlus: _goal < maxStepGoal ? () => setState(() => _goal += 500) : null,
        ),
        PrimaryButton(
          label: l.save,
          onPressed: () async {
            await ref.read(settingsRepositoryProvider).saveStepGoal(_goal);
            ref.invalidate(stepGoalProvider);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
