import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/sheet.dart';
import '../../domain/body.dart';
import '../../domain/energy.dart';
import '../../state/providers.dart';
import '../food/food_labels.dart' show formatNutrient;

String formatKcal(double kcal) => NumberFormat.decimalPattern().format(kcal.round());

String levelLabel(AppLocalizations l, ActivityLevel level) => switch (level) {
  ActivityLevel.sedentary => l.levelSedentary,
  ActivityLevel.light => l.levelLight,
  ActivityLevel.moderate => l.levelModerate,
  ActivityLevel.active => l.levelActive,
  ActivityLevel.veryActive => l.levelVeryActive,
};

String levelSub(AppLocalizations l, ActivityLevel level) => switch (level) {
  ActivityLevel.sedentary => l.levelSedentarySub,
  ActivityLevel.light => l.levelLightSub,
  ActivityLevel.moderate => l.levelModerateSub,
  ActivityLevel.active => l.levelActiveSub,
  ActivityLevel.veryActive => l.levelVeryActiveSub,
};

/// Resting energy, maintenance calories and how active you are (adults only).
class EnergySection extends ConsumerWidget {
  const EnergySection({
    super.key,
    required this.profile,
    required this.latest,
    required this.today,
    required this.weight,
    required this.imperial,
    this.history = const [],
  });

  final BodyProfile profile;
  final WeighIn? latest;
  final List<WeighIn> history;
  final DateTime today;
  final String Function(double kg) weight;
  final bool imperial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final resting = restingEnergy(profile, latest?.weightKg, today);
    final energy = ref.watch(energyProvider).value;
    final chosen = ref.watch(chosenActivityLevelProvider).value;
    return RuvaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(l.energyBmr),
          const SizedBox(height: 6),
          if (resting == null)
            Text(l.energyNeeds, style: AppText.body)
          else ...[
            Text(l.energyKcalDay(formatKcal(resting)), style: AppText.title.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text(l.energyBmrSub, style: AppText.small.copyWith(fontSize: 12.5)),
            const Divider(height: 28, color: AppColors.divider),
            if (energy != null) ...[
              MonoLabel(l.energyMaintain),
              const SizedBox(height: 6),
              Text(l.energyKcalDay(formatKcal(energy.maintenance)), style: AppText.title.copyWith(fontSize: 24)),
              const SizedBox(height: 12),
              MonoLabel(l.energyLevel),
              const SizedBox(height: 6),
              Text(levelLabel(l, energy.level), style: AppText.cardValue.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                energy.measured
                    ? l.energyMeasured(energy.days, formatKcal(energy.activeKcal))
                    : l.energyChosen(minMeasuredDays),
                style: AppText.small.copyWith(fontSize: 12.5),
              ),
            ],
            if (energy == null || !energy.measured) ...[
              const SizedBox(height: 12),
              Text(l.energyPickLevel, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              RadioGroup<ActivityLevel>(
                groupValue: chosen,
                onChanged: (v) => setChosenActivityLevel(ref, v!),
                child: Column(
                  children: [
                    for (final level in ActivityLevel.values)
                      RadioListTile<ActivityLevel>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: level,
                        activeColor: AppColors.primary,
                        title: Text(levelLabel(l, level), style: AppText.body),
                        subtitle: Text(levelSub(l, level), style: AppText.small.copyWith(fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
            if (latest != null && profile.heightCm != null) ...[
              const Divider(height: 28, color: AppColors.divider),
              _GoalPart(
                current: latest!.weightKg,
                heightCm: profile.heightCm!,
                hasEnergy: energy != null,
                weight: weight,
                imperial: imperial,
              ),
            ],
            if (energy != null && latest != null) ...[
              const Divider(height: 28, color: AppColors.divider),
              _ForecastPart(history: history, weight: weight, today: today),
            ],
          ],
        ],
      ),
    );
  }
}

/// Recorded weigh-ins, then a dashed 12-week projection, with the goal line.
class _ForecastPart extends ConsumerWidget {
  const _ForecastPart({required this.history, required this.weight, required this.today});

  final List<WeighIn> history;
  final String Function(double kg) weight;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final f = ref.watch(forecastProvider).value;
    final goal = ref.watch(weightGoalProvider).value;
    if (f == null) return const SizedBox.shrink();
    final end = f.weeklyKg.last;
    final small = AppText.small.copyWith(fontSize: 12.5);
    final reach = switch (f.reachesGoal) {
      final d? => l.forecastReach(weight(goal!.goalKg), DateFormat('d MMM y').format(d)),
      null when goal != null && directionFor(f.weeklyKg.first, goal.goalKg) != WeightDirection.maintain =>
        l.forecastNotReached(weight(goal.goalKg)),
      _ => null,
    };
    final start = DateTime(today.year, today.month, today.day - forecastWeeks * 7);
    final past = [
      for (final w in history)
        if (!w.at.toLocal().isBefore(start)) (w.at.toLocal().difference(today).inHours / 24.0, w.weightKg),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoLabel(l.forecastTitle),
        const SizedBox(height: 6),
        Text(l.forecastIn(forecastWeeks, weight(end)), style: AppText.title.copyWith(fontSize: 20)),
        if (reach != null) ...[const SizedBox(height: 2), Text(reach, style: AppText.body)],
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: Semantics(
            container: true,
            image: true,
            label: l.forecastChartLabel(weight(f.weeklyKg.first), forecastWeeks, weight(end)),
            child: CustomPaint(
              size: Size.infinite,
              painter: _ForecastChart(
                past: past,
                future: [for (var i = 0; i < f.weeklyKg.length; i++) (i * 7.0, f.weeklyKg[i])],
                goalKg: goal?.goalKg,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        ExcludeSemantics(
          child: Row(
            children: [
              Text(l.forecastPast, style: small),
              const Spacer(),
              Text(l.forecastToday, style: small.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(l.forecastAhead(forecastWeeks), style: small),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(switch (f.source) {
          IntakeSource.diary => l.forecastFromDiary(formatKcal(f.intake)),
          IntakeSource.target => l.forecastFromTarget(formatKcal(f.intake)),
          IntakeSource.maintenance => l.forecastFromMaintenance(formatKcal(f.intake)),
        }, style: small),
        const SizedBox(height: 4),
        Text(l.forecastEstimate, style: small),
      ],
    );
  }
}

/// x = days from today (negative = past), y = kg.
class _ForecastChart extends CustomPainter {
  _ForecastChart({required this.past, required this.future, this.goalKg});
  final List<(double, double)> past;
  final List<(double, double)> future;
  final double? goalKg;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...past, ...future].map((p) => p.$2).toList();
    if (goalKg != null) all.add(goalKg!);
    final lo = all.reduce(math.min), hi = all.reduce(math.max);
    final span = math.max(hi - lo, 1.0);
    final minX = -forecastWeeks * 7.0, maxX = forecastWeeks * 7.0;
    Offset at((double, double) p) => Offset(
      (p.$1 - minX) / (maxX - minX) * size.width,
      size.height - 8 - (p.$2 - lo) / span * (size.height - 16),
    );
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Today.
    final x0 = at((0, lo)).dx;
    canvas.drawLine(Offset(x0, 0), Offset(x0, size.height), Paint()..color = AppColors.textSecondary.withValues(alpha: .25));

    // Goal: a thin dashed line.
    if (goalKg != null) {
      final y = at((0, goalKg!)).dy;
      final dash = Paint()
        ..color = AppColors.textSecondary
        ..strokeWidth = 1.5;
      for (var x = 0.0; x < size.width; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 5, size.width), y), dash);
      }
    }

    // Recorded: solid line with dots.
    if (past.isNotEmpty) {
      final path = Path()..moveTo(at(past.first).dx, at(past.first).dy);
      for (final p in past.skip(1)) {
        path.lineTo(at(p).dx, at(p).dy);
      }
      canvas.drawPath(path, stroke);
      for (final p in past) {
        canvas.drawCircle(at(p), 3, Paint()..color = AppColors.primary);
      }
    }

    // Projected: dashed.
    for (var i = 1; i < future.length; i++) {
      final a = at(future[i - 1]), b = at(future[i]);
      final mid = Offset.lerp(a, b, .6)!;
      canvas.drawLine(a, mid, stroke..strokeWidth = 2.5);
    }
    canvas.drawCircle(at(future.last), 4, Paint()..color = AppColors.primaryMid);
  }

  @override
  bool shouldRepaint(_ForecastChart old) => old.past != past || old.future != future || old.goalKg != goalKg;
}

/// Goal weight and the daily calories for it, with the safety limits shown.
class _GoalPart extends ConsumerWidget {
  const _GoalPart({
    required this.current,
    required this.heightCm,
    required this.hasEnergy,
    required this.weight,
    required this.imperial,
  });

  final double current;
  final double heightCm;
  final bool hasEnergy;
  final String Function(double kg) weight;
  final bool imperial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final goal = ref.watch(weightGoalProvider).value;
    final target = ref.watch(calorieTargetProvider).value;
    Future<void> edit() => showAppSheet<void>(
      context,
      (_) => _GoalSheet(goal: goal, current: current, heightCm: heightCm, weight: weight, imperial: imperial),
    );
    final small = AppText.small.copyWith(fontSize: 12.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonoLabel(l.goalTitle),
        const SizedBox(height: 6),
        if (goal == null)
          OutlinedButton.icon(onPressed: edit, icon: const Icon(Icons.flag_outlined), label: Text(l.goalSet))
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  l.goalSummary(weight(goal.goalKg), weight(goal.paceKg)),
                  style: AppText.cardValue.copyWith(fontSize: 16),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: edit,
                child: Text(l.goalEdit),
              ),
            ],
          ),
          if (!hasEnergy)
            Text(l.goalNeedsEnergy, style: AppText.body)
          else if (target != null) ...[
            const SizedBox(height: 4),
            Text(switch (target.direction) {
              WeightDirection.lose => l.goalEatLose(formatKcal(target.kcal), weight(-target.weeklyKg)),
              WeightDirection.gain => l.goalEatGain(formatKcal(target.kcal), weight(target.weeklyKg)),
              WeightDirection.maintain => l.goalEatMaintain(formatKcal(target.kcal)),
            }, style: AppText.title.copyWith(fontSize: 17, color: AppColors.primary)),
            if (target.limited) ...[
              const SizedBox(height: 6),
              Text(l.goalLimited(formatKcal(target.kcal)), style: small),
            ],
            if (target.direction == WeightDirection.gain && goal.paceKg > maxGainPaceKg) ...[
              const SizedBox(height: 6),
              Text(l.goalGainCapped(weight(maxGainPaceKg)), style: small),
            ],
          ],
          const SizedBox(height: 8),
          Text(l.goalEstimate, style: small),
        ],
      ],
    );
  }
}

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({
    required this.goal,
    required this.current,
    required this.heightCm,
    required this.weight,
    required this.imperial,
  });

  final WeightGoal? goal;
  final double current;
  final double heightCm;
  final String Function(double kg) weight;
  final bool imperial;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late final _kg = TextEditingController(
    text: switch (widget.goal?.goalKg) {
      final kg? => formatNutrient(widget.imperial ? kg / kgPerLb : kg),
      null => '',
    },
  );
  late double _pace = widget.goal?.paceKg ?? 0.5;
  String? _error;

  @override
  void dispose() {
    _kg.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = double.tryParse(_kg.text.trim().replaceAll(',', '.'));
    if (v == null || v <= 0) return setState(() => _error = context.l10n.bodyInvalid);
    final kg = widget.imperial ? v * kgPerLb : v;
    final min = minGoalKg(widget.heightCm);
    if (kg < min - 0.05) return setState(() => _error = context.l10n.goalTooLow(widget.weight(min)));
    await setWeightGoal(ref, WeightGoal(goalKg: kg, paceKg: _pace));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.goalTitle, style: AppText.title)),
        RuvaTextField(
          controller: _kg,
          label: l.goalWeight(widget.imperial ? 'lb' : 'kg'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorText: _error,
        ),
        Text(l.goalPace, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final p in paceOptionsKg)
              RuvaChip(
                label: l.goalPacePerWeek(widget.weight(p)),
                selected: _pace == p,
                onTap: () => setState(() => _pace = p),
              ),
          ],
        ),
        PrimaryButton(label: l.save, onPressed: _save),
        if (widget.goal != null)
          TextButton(
            onPressed: () async {
              await setWeightGoal(ref, null);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.goalRemove),
          ),
      ],
    );
  }
}
