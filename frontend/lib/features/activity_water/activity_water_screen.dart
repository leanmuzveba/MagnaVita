import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/ruva_logo.dart';
import '../../core/widgets/sheet.dart';
import '../../domain/activity.dart';
import '../../domain/goals.dart';
import '../../domain/hydration.dart';
import '../../domain/settings.dart';
import '../../domain/workout.dart';
import '../../state/providers.dart';
import '../hydration/hydration_screen.dart';
import 'goal_focus_card.dart';
import '../ring/fasting_ring.dart';
import '../workout/exercise_picker.dart';
import '../workout/plan_screen.dart';
import '../workout/progress_screen.dart';
import '../workout/workout_screen.dart';

/// Water (MagnaVita design): today's water against a personal goal with
/// quick-adds. Opened from Home.
class ActivityWaterScreen extends StatelessWidget {
  const ActivityWaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  child: IconButton(
                    tooltip: l.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 30, color: AppColors.primary),
                  ),
                ),
                const Expanded(child: Center(child: RuvaLogo(size: 40, semanticLabel: null))),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),
            MonoLabel(l.today),
            const SizedBox(height: 4),
            Semantics(header: true, child: Text(l.awTitle, style: AppText.title.copyWith(fontSize: 26, height: 1.1))),
            const SizedBox(height: 22),
            const _WaterTab(),
          ],
        ),
      ),
    );
  }
}

// --- Water -------------------------------------------------------------------

class _WaterTab extends ConsumerWidget {
  const _WaterTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final unit = settings.waterUnit;
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final today = localDay(now);
    final entries = ref.watch(hydrationDayProvider(today)).value ?? const [];
    final total = totalMl(entries);
    final progress = (total / settings.waterGoalMl).clamp(0.0, 1.0);
    final quick = unit == VolumeUnit.ml ? const [200.0, 300.0, 500.0] : const [8.0, 12.0, 16.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ForestCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label:
                          '${formatVolume(total, unit)} ${l.waterOfGoal(formatVolume(settings.waterGoalMl.toDouble(), unit))}',
                      hint: l.waterEditGoal,
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => _editGoal(context, ref, settings),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: LayoutBuilder(
                            builder: (_, box) => CustomPaint(
                              painter: RingArcPainter(
                                progress: progress,
                                radius: box.maxWidth / 2 - box.maxWidth * 0.035,
                                stroke: box.maxWidth * 0.07,
                                phases: const [],
                                trackColor: const Color(0x26000000),
                                baseColor: AppColors.accent,
                                knobColor: AppColors.accent,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(box.maxWidth * 0.14),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          formatVolume(total, unit),
                                          style: AppText.cardValue.copyWith(color: AppColors.white, fontSize: 22),
                                        ),
                                        const SizedBox(height: 4),
                                        MonoLabel(
                                          l.waterOfGoal(formatVolume(settings.waterGoalMl.toDouble(), unit)),
                                          color: AppColors.accent,
                                          size: 9,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      for (final q in quick) ...[
                        _LimeQuickAdd(
                          label: '+${formatVolume(unit.toMl(q), unit)}',
                          semantics: l.waterAdd(formatVolume(unit.toMl(q), unit)),
                          onTap: () => ref.read(hydrationActionsProvider).add(unit.toMl(q)),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showWaterEntrySheet(context, day: today),
                  style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                  child: Text(l.waterCustomAmount),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        MonoLabel(l.waterTodaysEntries),
        const SizedBox(height: 12),
        RuvaCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.waterNoneYet, style: AppText.small),
                ),
              for (final (i, e) in entries.reversed.indexed) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.divider),
                _WaterRow(entry: e, unit: unit, use24h: settings.use24HourTime, day: today),
              ],
            ],
          ),
        ),
        if (entries.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            progress >= 1 ? l.waterGoalReached : l.waterKeepGoing,
            textAlign: TextAlign.center,
            style: AppText.small,
          ),
        ],
      ],
    );
  }

  Future<void> _editGoal(BuildContext context, WidgetRef ref, AppSettings s) =>
      showAppSheet<void>(context, (_) => _GoalSheet(initialMl: s.waterGoalMl, unit: s.waterUnit));
}

class _WaterRow extends ConsumerWidget {
  const _WaterRow({required this.entry, required this.unit, required this.use24h, required this.day});
  final HydrationEntry entry;
  final VolumeUnit unit;
  final bool use24h;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final amount = formatVolume(entry.amountMl, unit);
    final time = formatClock(entry.loggedAt, use24h: use24h);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const IconBubble(icon: Icons.water_drop_outlined, size: 41),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount, style: AppText.cardValue.copyWith(fontSize: 16)),
                Text(time, style: AppText.small),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: l.entryOptions('$amount, $time'),
            icon: const Icon(Icons.more_horiz, color: AppColors.muted),
            color: AppColors.white,
            onSelected: (v) => v == 'edit'
                ? showWaterEntrySheet(context, entry: entry, day: day)
                : ref.read(hydrationActionsProvider).delete(entry),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(l.edit)),
              PopupMenuItem(value: 'delete', child: Text(l.delete)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LimeQuickAdd extends StatelessWidget {
  const _LimeQuickAdd({required this.label, required this.semantics, required this.onTap});
  final String label;
  final String semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semantics,
    excludeSemantics: true,
    child: Material(
      color: AppColors.accent,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 112),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop_outlined, size: 16, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Text(label, style: AppText.link.copyWith(fontSize: 14, color: AppColors.primaryDark)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({required this.initialMl, required this.unit});
  final int initialMl;
  final VolumeUnit unit;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late int _ml = widget.initialMl;
  static const _step = 250;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.waterEditGoal, style: AppText.title)),
        Text(l.waterGoalHint, style: AppText.small),
        ValueStepper(
          large: true,
          label: formatVolume(_ml.toDouble(), widget.unit),
          minusTooltip: '−${formatVolume(_step.toDouble(), VolumeUnit.ml)}',
          plusTooltip: '+${formatVolume(_step.toDouble(), VolumeUnit.ml)}',
          onMinus: _ml > minWaterGoalMl ? () => setState(() => _ml -= _step) : null,
          onPlus: _ml < maxWaterGoalMl ? () => setState(() => _ml += _step) : null,
        ),
        PrimaryButton(
          label: l.save,
          onPressed: () async {
            await ref.read(settingsProvider.notifier).change((s) => s.copyWith(waterGoalMl: _ml));
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

// --- Activity ----------------------------------------------------------------

IconData activityIcon(ActivityType t) => switch (t) {
  ActivityType.walk => Icons.directions_walk,
  ActivityType.run => Icons.directions_run,
  ActivityType.cycle => Icons.directions_bike,
  ActivityType.swim => Icons.pool,
  ActivityType.strength => Icons.fitness_center,
  ActivityType.yoga => Icons.self_improvement,
  ActivityType.other => Icons.more_horiz,
};

String activityLabel(AppLocalizations l, ActivityType t) => switch (t) {
  ActivityType.walk => l.activityWalk,
  ActivityType.run => l.activityRun,
  ActivityType.cycle => l.activityCycle,
  ActivityType.swim => l.activitySwim,
  ActivityType.strength => l.activityStrength,
  ActivityType.yoga => l.activityYoga,
  ActivityType.other => l.activityOther,
};

String intensityLabel(AppLocalizations l, Intensity i, {bool swim = false}) => switch (i) {
  Intensity.light => swim ? l.intensityLeisurely : l.intensityLight,
  Intensity.moderate => l.intensityModerate,
  Intensity.heavy => swim ? l.intensityVigorous : l.intensityHeavy,
};

/// "25", or "22.86" for a yards pool.
String _metres(double m) => m.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

/// The Activity tab: log a workout (with gym exercises) and see what you've
/// logged or your watch recorded.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final recent = ref.watch(recentActivitiesProvider).value ?? const [];
    final use24h = ref.watch(settingsProvider).value?.use24HourTime ?? false;
    final goal = ref.watch(userGoalsProvider).value?.main;
    const workout = _WorkoutCard();
    const log = RuvaCard(padding: EdgeInsets.all(18), child: ActivityForm());
    // Arranged around your goal: training first for muscle, the day's
    // numbers first otherwise; fitness puts logging cardio before the gym.
    final top = <Widget>[
      if (goal != null && goal != MainGoal.fasting && goal != MainGoal.buildMuscle) GoalFocusCard(goal: goal),
      ...switch (goal) {
        MainGoal.buildMuscle => [workout, GoalFocusCard(goal: goal!)],
        MainGoal.getFitter => [log, workout],
        _ => [workout, log],
      },
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(header: true, child: Text(l.navActivity, style: AppText.title.copyWith(fontSize: 24))),
            ),
            const RuvaLogo(size: 40, semanticLabel: null),
          ],
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < top.length; i++) ...[if (i > 0) const SizedBox(height: 14), top[i]],
        const SizedBox(height: 26),
        MonoLabel(l.activityRecent),
        const SizedBox(height: 12),
        if (recent.isEmpty) Text(l.activityNone, style: AppText.small),
        for (final a in recent) ...[ActivityCard(entry: a, use24h: use24h), const SizedBox(height: 10)],
      ],
    );
  }
}

/// Start (or get back to) a strength workout: the next day of your plan, or
/// an empty one. Also the way to your plan, progress and the library.
class _WorkoutCard extends ConsumerWidget {
  const _WorkoutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final w = ref.watch(workoutProvider).value;
    final plan = ref.watch(planProvider).value;
    final now = w == null ? null : ref.watch(nowProvider).value;
    final upNext = w == null && plan != null && plan.days.isNotEmpty;
    Future<void> openWorkout() async {
      await ref.read(workoutProvider.notifier).start();
      if (context.mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WorkoutScreen()));
      }
    }

    Widget link(IconData icon, String label, VoidCallback onTap) => TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
    return ForestCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  w != null && now != null
                      ? l.workoutInProgress(formatClockDuration(now.difference(w.startedAt)))
                      : upNext
                      ? switch (plan.nextSession(ref.read(clockProvider)())) {
                          final on? when on == localDay(ref.read(clockProvider)()) => l.planToday(
                            planDayLabel(l, plan, plan.next),
                          ),
                          final on? => l.planUpNextOn(
                            weekdayName(context, on.weekday),
                            planDayLabel(l, plan, plan.next),
                          ),
                          null => l.planUpNext(planDayLabel(l, plan, plan.next)),
                        }
                      : l.workoutCardTitle,
                  style: AppText.title.copyWith(color: AppColors.white, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            upNext ? plan.days[plan.next].exercises.map((x) => x.name).join(' · ') : l.workoutCardSub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.small.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            light: true,
            label: w != null
                ? l.workoutResume
                : upNext
                ? l.planStartDay(plan.next + 1)
                : l.workoutStart,
            onPressed: upNext ? () => startPlanDay(context, ref, plan.next) : openWorkout,
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              link(Icons.event_note_outlined, plan == null ? l.planMake : l.planYours, () => showPlan(context)),
              link(Icons.insights_outlined, l.progressTitle, () => showProgress(context)),
              link(Icons.menu_book_outlined, l.libraryBrowse, () => showExerciseLibrary(context)),
              if (upNext) link(Icons.add, l.workoutEmptyStart, openWorkout),
            ],
          ),
        ],
      ),
    );
  }
}

/// One activity row; tap to edit or delete.
class ActivityCard extends ConsumerWidget {
  const ActivityCard({super.key, required this.entry, required this.use24h});
  final ActivityEntry entry;
  final bool use24h;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final a = entry;
    final imperial = ref.watch(settingsProvider).value?.units == UnitSystem.imperial;
    final exercises = [for (final x in a.exercises) x.describe(imperial: imperial)];
    final detail = [
      l.activityMinutes(a.minutes),
      if (a.laps != null) l.swimLapsSummary(a.laps!, a.swumM == null ? '?' : _metres(a.swumM!)),
      if (a.intensity != null) intensityLabel(l, a.intensity!, swim: a.type == ActivityType.swim).toLowerCase(),
      if (a.kcal != null) '${a.kcal!.round()} kcal',
      '${formatShortDay(a.startedAt)} ${formatClock(a.startedAt, use24h: use24h)}',
    ].join(' · ');
    return RuvaCard(
      padding: const EdgeInsets.all(16),
      onTap: () => showAppSheet<void>(context, (_) => ActivityForm(entry: a)),
      child: Semantics(
        container: true,
        label:
            '${activityLabel(l, a.type)}, $detail${a.fromWatch ? ', ${l.activityFromWatch}' : ''}'
            '${exercises.isEmpty ? '' : '. ${exercises.join(', ')}'}. ${l.edit}',
        excludeSemantics: true,
        child: Row(
          children: [
            IconBubble(
              icon: activityIcon(a.type),
              size: 48,
              background: AppColors.primary,
              foreground: AppColors.accent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activityLabel(l, a.type), style: AppText.cardValue.copyWith(fontSize: 15)),
                  Text(detail, style: AppText.small),
                  if (a.fromWatch)
                    Row(
                      children: [
                        const Icon(Icons.watch_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          l.activityFromWatch,
                          style: AppText.small.copyWith(fontSize: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  if (exercises.isNotEmpty)
                    Text(exercises.join(' · '), style: AppText.small.copyWith(color: AppColors.primary)),
                  if (a.notes.isNotEmpty)
                    Text(a.notes, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.small),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Log a new activity, or edit/delete [entry].
class ActivityForm extends ConsumerStatefulWidget {
  const ActivityForm({super.key, this.entry});
  final ActivityEntry? entry;

  @override
  ConsumerState<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<ActivityForm> {
  late ActivityType _type = widget.entry?.type ?? ActivityType.walk;
  late int _minutes = widget.entry?.minutes ?? 30;
  late Intensity? _intensity = widget.entry?.intensity;
  late List<Exercise> _exercises = widget.entry?.exercises ?? const [];
  late final _notes = TextEditingController(text: widget.entry?.notes ?? '');
  // Your own calories figure (optional); otherwise the MET estimate is saved.
  late final _kcal = TextEditingController();
  double? _shownEstimate; // what the form shows; saved unless you type your own
  late DateTime? _when = widget.entry?.startedAt.toLocal(); // null = now
  String? _error;
  // Swims: pool, laps, and time as total minutes or pace per lap.
  late double? _poolM = widget.entry?.poolM ?? poolLengths.first; // null = custom
  late final _customPool = TextEditingController();
  late final _laps = TextEditingController(text: widget.entry?.laps?.toString() ?? '');
  late final _pace = TextEditingController();
  bool _byPace = false;

  @override
  void initState() {
    super.initState();
    if (_poolM != null && !poolLengths.contains(_poolM)) {
      _customPool.text = _metres(_poolM!);
      _poolM = null;
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    _kcal.dispose();
    _customPool.dispose();
    _laps.dispose();
    _pace.dispose();
    super.dispose();
  }

  bool get _swim => _type == ActivityType.swim;
  int? get _lapCount => int.tryParse(_laps.text.trim());
  double? get _pool => _poolM ?? double.tryParse(_customPool.text.trim().replaceAll(',', '.'));

  /// Minutes from laps × pace, or null until both are entered.
  int? get _paceMinutes {
    final laps = _lapCount, pace = int.tryParse(_pace.text.trim());
    return laps == null || pace == null || laps <= 0 || pace <= 0 ? null : swimMinutes(laps, pace);
  }

  int? get _effectiveMinutes => _swim && _byPace ? _paceMinutes : _minutes;

  /// Equal-width outlined chips; tapping one runs its action.
  Widget _chipRow(List<(String, bool, VoidCallback)> chips) => Row(
    children: [
      for (final (i, (label, selected, onTap)) in chips.indexed) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: RuvaChip(
            label: label,
            selected: selected,
            outlined: true,
            dense: true,
            onTap: () => setState(() {
              onTap();
              _error = null;
            }),
          ),
        ),
      ],
    ],
  );

  List<Widget> _swimFields(AppLocalizations l) => [
    const SizedBox(height: 18),
    MonoLabel(l.swimPool),
    const SizedBox(height: 10),
    _chipRow([
      for (final m in poolLengths) (m == 22.86 ? '25 yd' : '${_metres(m)} m', _poolM == m, () => _poolM = m),
      (l.swimPoolCustom, _poolM == null, () => _poolM = null),
    ]),
    if (_poolM == null) ...[
      const SizedBox(height: 10),
      RuvaTextField(
        controller: _customPool,
        label: l.swimPoolCustomField,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
      ),
    ],
    const SizedBox(height: 18),
    RuvaTextField(
      controller: _laps,
      label: l.swimLaps,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() => _error = null),
    ),
  ];

  Future<void> _pickWhen() async {
    final now = ref.read(clockProvider)();
    final initial = _when ?? now;
    final date = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: now);
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _error = null;
    });
  }

  Future<void> _save() async {
    final l = context.l10n;
    final minutes = _effectiveMinutes;
    if (minutes == null) {
      setState(() => _error = l.swimNeedPace);
      return;
    }
    final now = ref.read(clockProvider)().toUtc();
    final e = widget.entry;
    final laps = _swim ? _lapCount : null;
    final entry = ActivityEntry(
      id: e?.id,
      type: _type,
      startedAt: (_when ?? now).toUtc(),
      minutes: minutes,
      laps: laps,
      poolM: laps == null ? null : _pool,
      intensity: _intensity,
      notes: _notes.text,
      createdAt: e?.createdAt ?? now,
      updatedAt: now,
      externalId: e?.externalId,
      kcal: double.tryParse(_kcal.text.trim()) ?? _shownEstimate,
      exercises: _exercises,
    );
    if (!await ref.read(activityActionsProvider).save(entry)) {
      setState(() => _error = l.activityFutureError);
      return;
    }
    if (!mounted) return;
    if (e != null) {
      Navigator.pop(context);
    } else {
      showRuvaSnack(context, l.activityLogged(activityLabel(l, _type), minutes));
      setState(() {
        _notes.clear();
        _kcal.clear();
        _laps.clear();
        _pace.clear();
        _when = null;
        _exercises = const [];
      });
    }
  }

  Future<void> _addExercise() async {
    final used = [
      for (final a in ref.read(recentActivitiesProvider).value ?? const <ActivityEntry>[])
        for (final x in a.exercises) x.name,
    ];
    final library = ref.read(exerciseLibraryProvider).value ?? const <LibraryExercise>[];
    final imperial = ref.read(settingsProvider).value?.units == UnitSystem.imperial;
    final x = await showAppSheet<Exercise>(
      context,
      (_) => _ExerciseSheet(
        suggestions: {...used, ...commonExercises, for (final e in library) e.name},
        imperial: imperial,
      ),
    );
    if (x == null) return;
    // Linked to the library when the name matches, so its history adds up.
    final id = library.where((e) => e.name.toLowerCase() == x.name.toLowerCase()).firstOrNull?.id;
    setState(() => _exercises = [..._exercises, Exercise.logged(x.name, x.log, libraryId: id)]);
  }

  /// Latest weigh-in (null when none or weight tracking is off).
  double? get _weightKg {
    if (ref.watch(bodyProfileProvider).value?.trackWeight == false) return null;
    final w = ref.watch(weighInsProvider).value;
    return w == null || w.isEmpty ? null : w.last.weightKg;
  }

  /// Swims with a full profile: from your own resting energy (Mifflin-St Jeor).
  double? _personalSwimKcal(int minutes) {
    final p = ref.watch(bodyProfileProvider).value;
    final kg = _weightKg, age = p?.ageOn(ref.read(clockProvider)());
    if (!_swim || kg == null || p?.heightCm == null || age == null || p?.sex == null) return null;
    return swimKcal(_intensity, minutes, weightKg: kg, heightCm: p!.heightCm!, age: age, sex: p.sex!);
  }

  /// MET estimate; a watch workout keeps the watch's own figure.
  double? _estimate() {
    final e = widget.entry;
    if (e != null && e.fromWatch) return e.kcal;
    final kg = _weightKg, minutes = _effectiveMinutes;
    if (kg == null || minutes == null) return null;
    return _personalSwimKcal(minutes) ?? activityKcal(_type, _intensity, minutes, kg);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final use24h = ref.watch(settingsProvider).value?.use24HourTime ?? false;
    final estimate = _shownEstimate = _estimate();
    final kg = _weightKg;
    final whenLabel = _when == null ? l.today : '${formatShortDay(_when!)}, ${formatClock(_when!, use24h: use24h)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            widget.entry == null ? l.activityLogTitle : l.activityEditTitle,
            style: AppText.title.copyWith(fontSize: 17),
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
          children: [
            for (final t in ActivityType.values)
              Semantics(
                button: true,
                selected: t == _type,
                label: activityLabel(l, t),
                excludeSemantics: true,
                child: Material(
                  color: t == _type ? AppColors.primary : AppColors.lime200,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => setState(() => _type = t),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(activityIcon(t), color: t == _type ? AppColors.accent : AppColors.primary),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            activityLabel(l, t),
                            style: AppText.body.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: t == _type ? AppColors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_swim) ..._swimFields(l),
        const SizedBox(height: 18),
        MonoLabel(_swim ? l.swimTime : l.activityDuration),
        const SizedBox(height: 10),
        if (_swim) ...[
          _chipRow([(l.swimByMinutes, !_byPace, () => _byPace = false), (l.swimByPace, _byPace, () => _byPace = true)]),
          const SizedBox(height: 10),
        ],
        if (_swim && _byPace) ...[
          RuvaTextField(
            controller: _pace,
            label: l.swimPaceField,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 8),
          Text(
            _paceMinutes == null ? l.swimNeedPace : l.swimDurationFromPace(_paceMinutes!),
            style: AppText.small.copyWith(fontSize: 13.5, color: AppColors.primary),
          ),
        ] else
          ValueStepper(
            large: true,
            label: l.activityMinutes(_minutes),
            minusTooltip: l.decreaseMinute,
            plusTooltip: l.increaseMinute,
            onMinus: _minutes > minActivityMinutes ? () => setState(() => _minutes--) : null,
            onPlus: _minutes < maxActivityMinutes ? () => setState(() => _minutes++) : null,
          ),
        const SizedBox(height: 18),
        MonoLabel(l.activityIntensity),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final (i, v) in Intensity.values.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: RuvaChip(
                  label: intensityLabel(l, v, swim: _swim),
                  selected: v == _intensity,
                  outlined: true,
                  // Tap again to clear: intensity is optional.
                  onTap: () => setState(() => _intensity = v == _intensity ? null : v),
                ),
              ),
            ],
          ],
        ),
        if (_type == ActivityType.strength || _type == ActivityType.other || _exercises.isNotEmpty) ...[
          const SizedBox(height: 18),
          MonoLabel(l.activityExercises),
          const SizedBox(height: 6),
          for (final (i, x) in _exercises.indexed)
            Row(
              children: [
                Expanded(child: Text('$x', style: AppText.body.copyWith(fontSize: 14))),
                IconButton(
                  tooltip: l.exerciseRemove(x.name),
                  icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
                  onPressed: () => setState(() => _exercises = [..._exercises]..removeAt(i)),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.activityAddExercise),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Semantics(
          container: true,
          liveRegion: true,
          child: Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.entry?.fromWatch ?? false
                      ? l.activityKcalWatch((estimate ?? 0).round())
                      : estimate == null
                      ? (kg == null ? l.activityKcalNeedWeight : l.swimNeedPace)
                      : _personalSwimKcal(_effectiveMinutes!) != null
                      ? l.activityKcalPersonal(estimate.round())
                      : l.activityKcalEstimate(
                          estimate.round(),
                          kg!.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), ''),
                        ),
                  style: AppText.small.copyWith(fontSize: 13.5, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        RuvaTextField(
          controller: _kcal,
          label: l.activityKcalOwn,
          hint: estimate == null ? '' : '${estimate.round()}',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 18),
        MonoLabel(l.activityWhen),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _pickWhen,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            side: const BorderSide(color: AppColors.divider),
          ),
          icon: const Icon(Icons.schedule, color: AppColors.primary),
          label: Text(whenLabel),
        ),
        const SizedBox(height: 18),
        RuvaTextField(controller: _notes, label: l.activityNotes, maxLines: 2),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: AppText.small.copyWith(color: AppColors.errorText)),
        ],
        const SizedBox(height: 18),
        PrimaryButton(label: widget.entry == null ? l.activityLogButton : l.save, onPressed: _save),
        if (widget.entry != null)
          TextButton(
            onPressed: () async {
              await ref.read(activityActionsProvider).delete(widget.entry!);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
            child: Text(l.delete),
          ),
      ],
    );
  }
}

/// Name an exercise (suggestions filter as you type), then sets and reps.
class _ExerciseSheet extends StatefulWidget {
  const _ExerciseSheet({required this.suggestions, required this.imperial});
  final Set<String> suggestions;
  final bool imperial;

  @override
  State<_ExerciseSheet> createState() => _ExerciseSheetState();
}

class _ExerciseSheetState extends State<_ExerciseSheet> {
  final _name = TextEditingController();
  final _weight = TextEditingController();
  int _sets = 3, _reps = 10;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = _name.text.trim().toLowerCase();
    final matches = widget.suggestions.where((s) => s.toLowerCase().contains(q) && s.toLowerCase() != q).take(8);
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.exerciseTitle, style: AppText.title)),
        RuvaTextField(controller: _name, label: l.exerciseName, autofocus: true, onChanged: (_) => setState(() {})),
        if (matches.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in matches)
                RuvaChip(
                  label: m,
                  selected: false,
                  dense: true,
                  outlined: true,
                  onTap: () => setState(() => _name.text = m),
                ),
            ],
          ),
        ValueStepper(
          label: l.exerciseSets(_sets),
          minusTooltip: l.exerciseFewerSets,
          plusTooltip: l.exerciseMoreSets,
          onMinus: _sets > 1 ? () => setState(() => _sets--) : null,
          onPlus: _sets < 20 ? () => setState(() => _sets++) : null,
        ),
        ValueStepper(
          label: l.exerciseReps(_reps),
          minusTooltip: l.exerciseFewerReps,
          plusTooltip: l.exerciseMoreReps,
          onMinus: _reps > 1 ? () => setState(() => _reps -= _reps > 20 ? 5 : 1) : null,
          onPlus: _reps < 300 ? () => setState(() => _reps += _reps >= 20 ? 5 : 1) : null, // 5s past 20 (plank holds)
        ),
        Text(l.exerciseRepsHint, style: AppText.small),
        RuvaTextField(
          controller: _weight,
          label: l.exerciseWeight(widget.imperial ? 'lb' : 'kg'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        PrimaryButton(
          label: l.exerciseAdd,
          onPressed: q.isEmpty
              ? null
              : () {
                  final w = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
                  final kg = w == null || w <= 0 ? null : (widget.imperial ? w * 0.45359237 : w);
                  Navigator.pop(context, Exercise(_name.text.trim(), sets: _sets, reps: _reps, kg: kg));
                },
        ),
      ],
    );
  }
}
