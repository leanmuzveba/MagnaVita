import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../domain/body.dart';
import '../../domain/energy.dart';
import '../../domain/goals.dart';
import '../../domain/plan.dart';
import '../../domain/settings.dart';
import '../../state/providers.dart';
import '../food/food_labels.dart' show formatNutrient;
import '../profile/energy_section.dart' show formatPace, levelLabel, levelSub;
import '../settings/settings_screen.dart' show allergenLabel, dietLabel;

String mainGoalLabel(AppLocalizations l, MainGoal g) => switch (g) {
  MainGoal.loseWeight => l.goalLoseWeight,
  MainGoal.maintain => l.goalMaintain,
  MainGoal.buildMuscle => l.goalBuildMuscle,
  MainGoal.getFitter => l.goalGetFitter,
  MainGoal.fasting => l.goalFasting,
};

String mainGoalSub(AppLocalizations l, MainGoal g) => switch (g) {
  MainGoal.loseWeight => l.goalLoseWeightSub,
  MainGoal.maintain => l.goalMaintainSub,
  MainGoal.buildMuscle => l.goalBuildMuscleSub,
  MainGoal.getFitter => l.goalGetFitterSub,
  MainGoal.fasting => l.goalFastingSub,
};

String levelName(AppLocalizations l, PlanLevel v) => switch (v) {
  PlanLevel.beginner => l.levelBeginner,
  PlanLevel.intermediate => l.levelIntermediate,
  PlanLevel.expert => l.levelExpert,
};

String equipmentName(AppLocalizations l, PlanEquipment e) => switch (e) {
  PlanEquipment.gym => l.planEquipGym,
  PlanEquipment.dumbbells => l.planEquipDumbbells,
  PlanEquipment.bodyweight => l.planEquipBodyweight,
};

const _steps = 7;

/// First-time questions (after the account step): about you, weight, goal,
/// activity, meals, training, diet. Every answer is optional and can be
/// changed later; existing installs see it once, filled in from what's saved.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _step = 0;
  bool _loaded = false, _busy = false;
  String? _error;

  final _name = TextEditingController();
  final _year = TextEditingController();
  final _cm = TextEditingController(), _ft = TextEditingController(), _in = TextEditingController();
  final _weight = TextEditingController();
  final _goalWeight = TextEditingController();
  UnitSystem _units = UnitSystem.metric;
  Sex? _sex;
  MainGoal? _main;
  double _pace = 0.5;
  ActivityLevel? _level;
  int? _meals, _training;
  PlanLevel? _experience;
  PlanEquipment? _equipment;
  DietPreference _diet = DietPreference.none;
  Set<Allergen> _allergies = {};
  bool _trackWeight = true;
  double? _savedWeight;

  bool get _imp => _units == UnitSystem.imperial;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _year, _cm, _ft, _in, _weight, _goalWeight]) {
      c.dispose();
    }
    super.dispose();
  }

  String _kgText(double? kg) => kg == null ? '' : formatNutrient(_imp ? kg / kgPerLb : kg);

  Future<void> _load() async {
    final s = await ref.read(settingsProvider.future);
    final body = await ref.read(bodyProfileProvider.future);
    final weighIns = await ref.read(weighInsProvider.future);
    final goals = await ref.read(userGoalsProvider.future);
    final goal = await ref.read(weightGoalProvider.future);
    final level = await ref.read(chosenActivityLevelProvider.future);
    if (!mounted) return;
    setState(() {
      _units = s.units;
      _name.text = s.userName;
      _year.text = body.birthYear?.toString() ?? '';
      _sex = body.sex;
      _trackWeight = body.trackWeight;
      if (body.heightCm case final h?) {
        final inches = (h / cmPerInch).round();
        _cm.text = '${h.round()}';
        _ft.text = '${inches ~/ 12}';
        _in.text = '${inches % 12}';
      }
      _savedWeight = weighIns.isEmpty ? null : weighIns.last.weightKg;
      _weight.text = _kgText(_savedWeight);
      _main = goals.main;
      _goalWeight.text = _kgText(goal?.goalKg);
      _pace = goal?.paceKg ?? 0.5;
      _level = level;
      _meals = goals.mealsPerDay;
      _training = goals.trainingDays;
      _experience = goals.level;
      _equipment = goals.equipment;
      _diet = s.diet;
      _allergies = {...s.allergies};
      _loaded = true;
    });
  }

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  double? get _heightCm => _imp
      ? (_num(_ft) == null && _num(_in) == null ? null : ((_num(_ft) ?? 0) * 12 + (_num(_in) ?? 0)) * cmPerInch)
      : _num(_cm);

  double? _kg(TextEditingController c) => switch (_num(c)) {
    final v? => _imp ? v * kgPerLb : v,
    null => null,
  };

  /// Checks the current step; returns an error to show, or null.
  String? _check() {
    final l = context.l10n;
    final thisYear = ref.read(clockProvider)().toLocal().year;
    switch (_step) {
      case 0:
        final year = int.tryParse(_year.text.trim());
        if (_year.text.trim().isNotEmpty && (year == null || year < thisYear - 110 || year > thisYear - 18)) {
          return l.setupYearInvalid;
        }
        final h = _heightCm;
        if (h != null && (h < 100 || h > 250)) return l.bodyInvalid;
      case 1:
        final w = _kg(_weight);
        if (_weight.text.trim().isNotEmpty && (w == null || w < 25 || w > 400)) return l.bodyInvalid;
      case 2:
        if (_main == MainGoal.loseWeight || _main == MainGoal.buildMuscle) {
          final g = _kg(_goalWeight);
          if (_goalWeight.text.trim().isEmpty) return null;
          if (g == null || g < 25 || g > 400) return l.bodyInvalid;
          final h = _heightCm;
          if (h != null && g < minGoalKg(h) - 0.05) return l.goalTooLow(_fmtKg(minGoalKg(h)));
        }
    }
    return null;
  }

  String _fmtKg(double kg) {
    final t = (_imp ? kg / kgPerLb : kg).toStringAsFixed(1);
    return '${t.endsWith('.0') ? t.substring(0, t.length - 2) : t} ${_imp ? 'lb' : 'kg'}';
  }

  void _next() {
    final error = _check();
    setState(() => _error = error);
    if (error != null) return;
    if (_step < _steps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  /// Saves every answer given so far, then opens the app.
  Future<void> _finish() async {
    if (_check() != null) _clearInvalid();
    setState(() => _busy = true);
    final now = ref.read(clockProvider)();
    await ref
        .read(settingsProvider.notifier)
        .change(
          (s) => s.copyWith(
            userName: _name.text.trim(),
            units: _units,
            diet: _diet,
            allergies: _allergies,
          ),
        );
    final body = ref.read(bodyActionsProvider);
    await body.saveProfile(
      BodyProfile(
        heightCm: _heightCm,
        birthYear: int.tryParse(_year.text.trim()),
        sex: _sex,
        trackWeight: _trackWeight,
      ),
    );
    final w = _kg(_weight);
    if (w != null && (_savedWeight == null || (w - _savedWeight!).abs() > 0.05)) {
      await body.addWeighIn(WeighIn(at: now.toUtc(), weightKg: w));
    }
    if (_level != null) await setChosenActivityLevel(ref, _level!);
    final g = _kg(_goalWeight);
    final wantsWeightGoal = _main == MainGoal.loseWeight || _main == MainGoal.buildMuscle;
    await setWeightGoal(ref, wantsWeightGoal && g != null ? WeightGoal(goalKg: g, paceKg: _pace) : null);
    await setUserGoals(
      ref,
      UserGoals(
        main: _main,
        mealsPerDay: _meals,
        trainingDays: _training,
        level: _experience,
        equipment: _equipment,
      ),
    );
    await setSetupDone(ref);
  }

  /// "Skip" from a step with a half-typed value: drop what can't be saved.
  void _clearInvalid() {
    for (var s = 0; s < _steps; s++) {
      final keep = _step;
      _step = s;
      if (_check() != null) {
        switch (s) {
          case 0:
            _year.clear();
            _cm.clear();
            _ft.clear();
            _in.clear();
          case 1:
            _weight.clear();
          case 2:
            _goalWeight.clear();
        }
      }
      _step = keep;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final (title, sub, body) = switch (_step) {
      0 => (l.setupAboutTitle, l.setupAboutSub, _about(l)),
      1 => (l.setupWeightTitle, l.setupWeightSub, _weightStep(l)),
      2 => (l.setupGoalTitle, l.setupGoalSub, _goalStep(l)),
      3 => (l.setupActivityTitle, l.setupActivitySub, _activityStep(l)),
      4 => (l.setupMealsTitle, l.setupMealsSub, _mealsStep(l)),
      5 => (l.setupTrainingTitle, l.setupTrainingSub, _trainingStep(l)),
      _ => (l.setupDietTitle, l.setupDietSub, _dietStep(l)),
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(child: MonoLabel(l.setupStep(_step + 1, _steps))),
                  TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                    onPressed: _busy ? null : _finish,
                    child: Text(l.setupSkip),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _steps,
                  minHeight: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.track,
                  semanticsLabel: l.setupStep(_step + 1, _steps),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                children: [
                  Semantics(header: true, child: Text(title, style: AppText.title.copyWith(fontSize: 22))),
                  const SizedBox(height: 6),
                  Text(sub, style: AppText.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 22),
                  ...body,
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(_error!, style: AppText.body.copyWith(color: AppColors.errorText)),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                          onPressed: _busy ? null : () => setState(() {
                            _step--;
                            _error = null;
                          }),
                          child: Text(l.setupBack),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: _step == _steps - 1 ? l.setupFinish : l.planNext,
                      onPressed: _busy ? null : _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(text, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
  );

  Widget _chips<T>(List<T> options, T? selected, String Function(T) label, ValueChanged<T> onTap) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      for (final o in options) RuvaChip(label: label(o), selected: o == selected, onTap: () => setState(() => onTap(o))),
    ],
  );

  Widget _option({required String title, required String sub, required bool selected, required VoidCallback onTap}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Semantics(
          button: true,
          selected: selected,
          label: '$title. $sub',
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(onTap),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? AppColors.soft : AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: selected ? AppColors.primary : AppColors.track, width: selected ? 2 : 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.cardValue.copyWith(fontSize: 15.5)),
                        const SizedBox(height: 2),
                        Text(sub, style: AppText.small.copyWith(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? AppColors.primary : AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _unitsRow(AppLocalizations l) => _chips(
    UnitSystem.values,
    _units,
    (u) => u == UnitSystem.metric ? l.unitsMetric : l.unitsImperial,
    (u) {
      if (u == _units) return;
      // Keep what was typed: convert it to the new units.
      final h = _heightCm, w = _kg(_weight), g = _kg(_goalWeight);
      _units = u;
      if (h != null) {
        final inches = (h / cmPerInch).round();
        _cm.text = '${h.round()}';
        _ft.text = '${inches ~/ 12}';
        _in.text = '${inches % 12}';
      }
      _weight.text = _kgText(w);
      _goalWeight.text = _kgText(g);
    },
  );

  List<Widget> _about(AppLocalizations l) => [
    RuvaTextField(controller: _name, label: l.authName, autofillHints: const [AutofillHints.givenName]),
    const SizedBox(height: 16),
    _label(l.bodySex),
    _chips([Sex.female, Sex.male], _sex, (s) => s == Sex.female ? l.bodyFemale : l.bodyMale, (s) => _sex = s),
    const SizedBox(height: 6),
    Text(l.setupSexWhy, style: AppText.small.copyWith(fontSize: 12.5)),
    const SizedBox(height: 16),
    RuvaTextField(controller: _year, label: l.setupBirthYear, keyboardType: TextInputType.number),
    const SizedBox(height: 16),
    _label(l.settingsUnits),
    _unitsRow(l),
    const SizedBox(height: 12),
    if (_imp)
      Row(
        children: [
          Expanded(
            child: RuvaTextField(controller: _ft, label: l.bodyFeet, keyboardType: TextInputType.number),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RuvaTextField(
              controller: _in,
              label: l.bodyInches,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      )
    else
      RuvaTextField(
        controller: _cm,
        label: '${l.bodyHeight} (cm)',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
  ];

  List<Widget> _weightStep(AppLocalizations l) => [
    RuvaTextField(
      controller: _weight,
      label: '${l.bodyWeight} (${_imp ? 'lb' : 'kg'})',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    ),
    const SizedBox(height: 10),
    Text(l.bodyOptional, style: AppText.small.copyWith(fontSize: 12.5)),
  ];

  List<Widget> _goalStep(AppLocalizations l) => [
    for (final g in MainGoal.values)
      _option(title: mainGoalLabel(l, g), sub: mainGoalSub(l, g), selected: _main == g, onTap: () => _main = g),
    if (_main == MainGoal.loseWeight || _main == MainGoal.buildMuscle) ...[
      const SizedBox(height: 8),
      RuvaTextField(
        controller: _goalWeight,
        label: l.goalWeight(_imp ? 'lb' : 'kg'),
        hint: l.setupOptional,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 12),
      _label(l.goalPace),
      _chips(
        [for (final p in paceOptionsKg) if (_main == MainGoal.loseWeight || p <= maxGainPaceKg) p],
        _pace,
        (p) => l.goalPacePerWeek(formatPace(p, imperial: _imp)),
        (p) => _pace = p,
      ),
      const SizedBox(height: 8),
      Text(l.setupGoalSafety, style: AppText.small.copyWith(fontSize: 12.5)),
    ],
  ];

  List<Widget> _activityStep(AppLocalizations l) => [
    for (final v in ActivityLevel.values)
      _option(title: levelLabel(l, v), sub: levelSub(l, v), selected: _level == v, onTap: () => _level = v),
    const SizedBox(height: 4),
    Text(l.setupActivityLater, style: AppText.small.copyWith(fontSize: 12.5)),
  ];

  List<Widget> _mealsStep(AppLocalizations l) => [
    _chips(mealsPerDayOptions, _meals, (n) => n == 5 ? l.setupMealsFivePlus : l.setupMealsN(n), (n) => _meals = n),
    const SizedBox(height: 10),
    Text(l.setupMealsWhy, style: AppText.small.copyWith(fontSize: 12.5)),
  ];

  List<Widget> _trainingStep(AppLocalizations l) => [
    _label(l.setupTrainingDays),
    _chips(trainingDayOptions, _training, (n) => n == 0 ? l.setupNotYet : l.planDaysChip(n), (n) => _training = n),
    if (_training != null && _training! > 0) ...[
      const SizedBox(height: 16),
      _label(l.planLevel),
      _chips(PlanLevel.values, _experience, (v) => levelName(l, v), (v) => _experience = v),
      const SizedBox(height: 16),
      _label(l.planEquipment),
      _chips(PlanEquipment.values, _equipment, (e) => equipmentName(l, e), (e) => _equipment = e),
    ],
  ];

  List<Widget> _dietStep(AppLocalizations l) => [
    _label(l.settingsDiet),
    _chips(DietPreference.values, _diet, (d) => dietLabel(l, d), (d) => _diet = d),
    const SizedBox(height: 16),
    _label(l.settingsAllergies),
    Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final a in Allergen.values)
          RuvaChip(
            label: allergenLabel(l, a),
            selected: _allergies.contains(a),
            onTap: () => setState(() => _allergies.contains(a) ? _allergies.remove(a) : _allergies.add(a)),
          ),
      ],
    ),
  ];
}
