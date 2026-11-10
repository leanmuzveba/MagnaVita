import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/sheet.dart';
import '../../domain/body.dart';
import '../../domain/settings.dart';
import '../../state/providers.dart';
import '../food/food_labels.dart' show formatNutrient;
import '../settings/settings_screen.dart' show ProfileNameSheet;
import 'energy_section.dart';

/// Formats weights/heights in the user's units.
class _Units {
  const _Units(this.imperial);
  final bool imperial;

  static String _one(double v) {
    final t = v.toStringAsFixed(1);
    return t.endsWith('.0') ? t.substring(0, t.length - 2) : t;
  }

  String weight(double kg) => imperial ? '${_one(kg / kgPerLb)} lb' : '${_one(kg)} kg';
  String length(double cm) => imperial ? '${formatNutrient(cm / cmPerInch)} in' : '${formatNutrient(cm)} cm';
  String height(double cm) {
    if (!imperial) return '${cm.round()} cm';
    final inches = (cm / cmPerInch).round();
    return '${inches ~/ 12} ft ${inches % 12} in';
  }
}

/// Profile (PRD v1.2 §7): name, optional body stats, BMI and healthy range
/// with their limits explained, a body-fat estimate and weigh-in history.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.openWeighIn = false});

  /// Opens the weigh-in sheet straight away (home + menu → Weigh in).
  final bool openWeighIn;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openWeighIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final settings = await ref.read(settingsProvider.future);
        if (!mounted) return;
        await showAppSheet<void>(
          context,
          (_) => _WeighInSheet(imperial: settings.units == UnitSystem.imperial, existing: null),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final profile = ref.watch(bodyProfileProvider).value ?? const BodyProfile();
    final weighIns = ref.watch(weighInsProvider).value ?? const <WeighIn>[];
    final units = _Units(settings.units == UnitSystem.imperial);
    final t = ref.watch(clockProvider)().toLocal();
    final age = profile.ageOn(t);
    final adult = age != null ? age >= 18 : settings.eligibility != AgeEligibility.under18;
    final latest = profile.trackWeight && weighIns.isNotEmpty ? weighIns.last : null;
    final name = settings.userName.trim();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            ScreenHeader(title: l.profileTitle, large: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RuvaCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _Row(
                          label: l.profileNameLabel,
                          value: name.isEmpty ? l.bodyNotSet : name,
                          onTap: () => showAppSheet<void>(context, (_) => ProfileNameSheet(initial: name)),
                        ),
                        _Row(
                          label: l.bodyHeight,
                          value: profile.heightCm == null ? l.bodyNotSet : units.height(profile.heightCm!),
                        ),
                        _Row(label: l.bodyAge, value: age == null ? l.bodyNotSet : l.bodyAgeYears(age)),
                        _Row(
                          label: l.bodySex,
                          value: switch (profile.sex) {
                            Sex.female => l.bodyFemale,
                            Sex.male => l.bodyMale,
                            null => l.bodyNotSet,
                          },
                        ),
                        if (profile.trackWeight)
                          _Row(
                            label: l.bodyWeight,
                            value: latest == null ? l.bodyNotSet : units.weight(latest.weightKg),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: l.bodyUpdate,
                    icon: Icons.edit_outlined,
                    onPressed: () => showAppSheet<void>(
                      context,
                      (_) => _StatsSheet(profile: profile, latest: latest, imperial: units.imperial, today: t),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(l.bodyOptional, textAlign: TextAlign.center, style: AppText.small.copyWith(fontSize: 12)),
                  const SizedBox(height: 18),
                  if (!profile.trackWeight)
                    Text(l.bodyTrackOff, textAlign: TextAlign.center, style: AppText.small)
                  else ...[
                    _Numbers(profile: profile, latest: latest, age: age, adult: adult, units: units),
                    if (adult) ...[
                      const SizedBox(height: 12),
                      EnergySection(profile: profile, latest: latest, today: t),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: MonoLabel(l.bodyHistory)),
                        TextButton.icon(
                          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                          onPressed: () => showAppSheet<void>(
                            context,
                            (_) => _WeighInSheet(imperial: units.imperial, existing: null),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(l.bodyAddWeighIn),
                        ),
                      ],
                    ),
                    if (weighIns.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(l.bodyNoWeighIns, textAlign: TextAlign.center, style: AppText.small),
                      )
                    else ...[
                      if (weighIns.length >= 2) ...[
                        RuvaCard(
                          padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                          child: SizedBox(
                            height: 140,
                            child: Semantics(
                              label: l.bodyChange(
                                '${weighIns.last.weightKg >= weighIns.first.weightKg ? '+' : '−'}'
                                '${units.weight((weighIns.last.weightKg - weighIns.first.weightKg).abs())}',
                                DateFormat('d MMM y').format(weighIns.first.at.toLocal()),
                              ),
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _WeightChart([for (final w in weighIns) w.weightKg]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      RuvaCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final w in weighIns.reversed.take(30)) _WeighInTile(weighIn: w, units: units),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 18),
                  RuvaCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.bodyTrack, style: AppText.cardValue.copyWith(fontSize: 15)),
                      subtitle: Text(l.bodyTrackSub, style: AppText.small.copyWith(fontSize: 12.5)),
                      value: profile.trackWeight,
                      activeTrackColor: AppColors.accent,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => ref
                          .read(bodyActionsProvider)
                          .saveProfile(
                            BodyProfile(
                              heightCm: profile.heightCm,
                              birthYear: profile.birthYear,
                              sex: profile.sex,
                              trackWeight: v,
                            ),
                          ),
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
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: onTap != null,
    label: '$label: $value',
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppText.body)),
              Text(value, style: AppText.cardValue.copyWith(fontSize: 15)),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

/// BMI, healthy range, distance to it, body fat — or what's needed for them.
class _Numbers extends StatelessWidget {
  const _Numbers({
    required this.profile,
    required this.latest,
    required this.age,
    required this.adult,
    required this.units,
  });

  final BodyProfile profile;
  final WeighIn? latest;
  final int? age;
  final bool adult;
  final _Units units;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final h = profile.heightCm;
    final w = latest;
    final muted = AppText.body.copyWith(fontSize: 13.5, color: onForestMuted);
    final white = AppText.body.copyWith(fontSize: 14.5, color: AppColors.white);
    return ForestCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: MonoLabel(l.bodyNumbers, color: AppColors.accent, size: 10)),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.accent, minimumSize: const Size(48, 40)),
                onPressed: () => showAppSheet<void>(
                  context,
                  (_) => Gap16Column(
                    children: [
                      Semantics(header: true, child: Text(l.bodyAboutBmi, style: AppText.title)),
                      Text(l.bodyAboutBmiBody, style: AppText.body),
                    ],
                  ),
                ),
                icon: const Icon(Icons.info_outline, size: 18),
                label: Text(l.bodyAboutBmi),
              ),
            ],
          ),
          if (h == null || w == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.bodyNeedStats, style: white),
            )
          else ...[
            () {
              final value = bmi(w.weightKg, h);
              final band = bmiBand(value, adult: adult);
              return Semantics(
                label: '${l.bodyBmi} ${value.toStringAsFixed(1)}',
                excludeSemantics: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value.toStringAsFixed(1), style: AppText.title.copyWith(fontSize: 34, color: AppColors.white)),
                    const SizedBox(width: 8),
                    Text(l.bodyBmi, style: AppText.body.copyWith(color: AppColors.accent)),
                    const SizedBox(width: 12),
                    if (band != null)
                      Flexible(
                        child: Text(switch (band) {
                          BmiBand.underweight => l.bmiUnder,
                          BmiBand.healthy => l.bmiHealthy,
                          BmiBand.overweight => l.bmiOver,
                          BmiBand.obese => l.bmiObese,
                        }, style: muted),
                      ),
                  ],
                ),
              );
            }(),
            if (adult) ...[const SizedBox(height: 12), _BmiBar(value: bmi(w.weightKg, h))],
            const SizedBox(height: 10),
            if (!adult)
              Text(l.bodyUnder18, style: white)
            else ...[
              () {
                final r = healthyRange(h);
                final diff = toHealthyRange(w.weightKg, h);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.bodyRange(units.weight(r.low), units.weight(r.high)), style: white),
                    const SizedBox(height: 4),
                    Text(
                      diff < 0
                          ? l.bodyLose(units.weight(-diff))
                          : diff > 0
                          ? l.bodyGain(units.weight(diff))
                          : l.bodyInRange,
                      style: white.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }(),
              const Divider(color: Color(0x33FFFFFF), height: 28),
              MonoLabel(l.bodyFat, color: AppColors.accent, size: 10),
              const SizedBox(height: 6),
              switch (bodyFat(sex: profile.sex, age: age, heightCm: h, latest: w)) {
                null => Text(l.bodyFatNeeds, style: white),
                final bf => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${bf.percent.round()}%', style: AppText.title.copyWith(fontSize: 26, color: AppColors.white)),
                    Text(bf.method == BodyFatMethod.tape ? l.bodyFatTape : l.bodyFatBmi, style: muted),
                  ],
                ),
              },
            ],
          ],
        ],
      ),
    );
  }
}

class _WeighInTile extends ConsumerWidget {
  const _WeighInTile({required this.weighIn, required this.units});
  final WeighIn weighIn;
  final _Units units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final date = DateFormat('d MMM y').format(weighIn.at.toLocal());
    final tape = [
      if (weighIn.waistCm case final v?) '${l.bodyWaist} ${units.length(v)}',
      if (weighIn.neckCm case final v?) '${l.bodyNeck} ${units.length(v)}',
      if (weighIn.hipCm case final v?) '${l.bodyHip} ${units.length(v)}',
    ].join(' · ');
    return ListTile(
      title: Text(units.weight(weighIn.weightKg), style: AppText.cardValue.copyWith(fontSize: 15)),
      subtitle: Text(tape.isEmpty ? date : '$date · $tape', style: AppText.small.copyWith(fontSize: 12.5)),
      trailing: PopupMenuButton<String>(
        tooltip: l.bodyWeighInLabel(units.weight(weighIn.weightKg), date),
        onSelected: (v) async {
          if (v == 'edit') {
            await showAppSheet<void>(context, (_) => _WeighInSheet(imperial: units.imperial, existing: weighIn));
          } else {
            await ref.read(bodyActionsProvider).deleteWeighIn(weighIn);
            if (context.mounted) showRuvaSnack(context, l.bodyDeleted);
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(l.edit)),
          PopupMenuItem(value: 'delete', child: Text(l.delete)),
        ],
      ),
    );
  }
}

double? _parse(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));
String _fmt(double? v) => v == null ? '' : formatNutrient(v);

/// Height, age, sex, and (optionally) today's weight and tape measurements.
class _StatsSheet extends ConsumerStatefulWidget {
  const _StatsSheet({required this.profile, required this.latest, required this.imperial, required this.today});
  final BodyProfile profile;
  final WeighIn? latest;
  final bool imperial;
  final DateTime today;

  @override
  ConsumerState<_StatsSheet> createState() => _StatsSheetState();
}

class _StatsSheetState extends ConsumerState<_StatsSheet> {
  late final bool _imp = widget.imperial;
  late final _cm = TextEditingController(text: _imp ? '' : _fmt(widget.profile.heightCm?.roundToDouble()));
  late final _ft = TextEditingController(
    text: widget.profile.heightCm == null ? '' : '${(widget.profile.heightCm! / cmPerInch).round() ~/ 12}',
  );
  late final _in = TextEditingController(
    text: widget.profile.heightCm == null ? '' : '${(widget.profile.heightCm! / cmPerInch).round() % 12}',
  );
  late final _age = TextEditingController(text: widget.profile.ageOn(widget.today)?.toString() ?? '');
  late final _weight = TextEditingController();
  final _waist = TextEditingController(), _neck = TextEditingController(), _hip = TextEditingController();
  late Sex? _sex = widget.profile.sex;
  String? _error;

  @override
  void dispose() {
    for (final c in [_cm, _ft, _in, _age, _weight, _waist, _neck, _hip]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _len(TextEditingController c) => switch (_parse(c)) {
    final v? => _imp ? v * cmPerInch : v,
    null => null,
  };

  Future<void> _save() async {
    final l = context.l10n;
    final height = _imp
        ? (_parse(_ft) == null && _parse(_in) == null
              ? null
              : ((_parse(_ft) ?? 0) * 12 + (_parse(_in) ?? 0)) * cmPerInch)
        : _parse(_cm);
    final age = int.tryParse(_age.text.trim());
    final weight = switch (_parse(_weight)) {
      final v? => _imp ? v * kgPerLb : v,
      null => null,
    };
    final waist = _len(_waist), neck = _len(_neck), hip = _len(_hip);
    bool bad(double? v, double lo, double hi) => v != null && (v < lo || v > hi);
    if (bad(height, 50, 250) ||
        (age != null && (age < 5 || age > 120)) ||
        bad(weight, 20, 350) ||
        bad(waist, 30, 250) ||
        bad(neck, 15, 80) ||
        bad(hip, 40, 250)) {
      return setState(() => _error = l.bodyInvalid);
    }
    final actions = ref.read(bodyActionsProvider);
    await actions.saveProfile(
      BodyProfile(
        heightCm: height,
        birthYear: age == null ? null : widget.today.year - age,
        sex: _sex,
        trackWeight: widget.profile.trackWeight,
      ),
    );
    if (weight != null) {
      await actions.addWeighIn(
        WeighIn(at: ref.read(clockProvider)().toUtc(), weightKg: weight, waistCm: waist, neckCm: neck, hipCm: hip),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const numeric = TextInputType.numberWithOptions(decimal: true);
    final lenUnit = _imp ? 'in' : 'cm';
    Widget half(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 10),
        Expanded(child: b),
      ],
    );
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.bodyUpdate, style: AppText.title)),
        if (widget.profile.trackWeight)
          RuvaTextField(
            controller: _weight,
            label: '${l.bodyWeight} (${_imp ? 'lb' : 'kg'})',
            hint: widget.latest == null ? '' : _fmt(_imp ? widget.latest!.weightKg / kgPerLb : widget.latest!.weightKg),
            keyboardType: numeric,
            bold: true,
          ),
        if (_imp)
          half(
            RuvaTextField(controller: _ft, label: l.bodyFeet, keyboardType: TextInputType.number),
            RuvaTextField(controller: _in, label: l.bodyInches, keyboardType: numeric),
          )
        else
          RuvaTextField(controller: _cm, label: '${l.bodyHeight} (cm)', keyboardType: numeric),
        RuvaTextField(controller: _age, label: l.bodyAge, keyboardType: TextInputType.number),
        MonoLabel(l.bodySex),
        Wrap(
          spacing: 8,
          children: [
            for (final (v, label) in [(Sex.female, l.bodyFemale), (Sex.male, l.bodyMale), (null, l.bodySexNone)])
              RuvaChip(label: label, selected: _sex == v, onTap: () => setState(() => _sex = v)),
          ],
        ),
        Text(l.bodySexHint, style: AppText.small.copyWith(fontSize: 12)),
        if (widget.profile.trackWeight) ...[
          MonoLabel(l.bodyTape),
          Text(l.bodyTapeHint, style: AppText.small.copyWith(fontSize: 12.5)),
          half(
            RuvaTextField(controller: _waist, label: '${l.bodyWaist} ($lenUnit)', keyboardType: numeric),
            RuvaTextField(controller: _neck, label: '${l.bodyNeck} ($lenUnit)', keyboardType: numeric),
          ),
          if (_sex != Sex.male)
            RuvaTextField(controller: _hip, label: '${l.bodyHip} ($lenUnit)', keyboardType: numeric),
        ],
        if (_error != null) Text(_error!, style: AppText.small.copyWith(color: AppColors.errorText)),
        PrimaryButton(label: l.save, onPressed: _save),
      ],
    );
  }
}

/// Add or edit one weigh-in (weight and date).
class _WeighInSheet extends ConsumerStatefulWidget {
  const _WeighInSheet({required this.imperial, required this.existing});
  final bool imperial;
  final WeighIn? existing;

  @override
  ConsumerState<_WeighInSheet> createState() => _WeighInSheetState();
}

class _WeighInSheetState extends ConsumerState<_WeighInSheet> {
  late final _weight = TextEditingController(
    text: widget.existing == null
        ? ''
        : _fmt(widget.imperial ? widget.existing!.weightKg / kgPerLb : widget.existing!.weightKg),
  );
  late DateTime _at = (widget.existing?.at ?? ref.read(clockProvider)()).toLocal();
  String? _error;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = _parse(_weight);
    final kg = v == null ? null : (widget.imperial ? v * kgPerLb : v);
    if (kg == null || kg < 20 || kg > 350) return setState(() => _error = context.l10n.bodyInvalid);
    final actions = ref.read(bodyActionsProvider);
    final e = widget.existing;
    if (e == null) {
      await actions.addWeighIn(WeighIn(at: _at.toUtc(), weightKg: kg));
    } else {
      await actions.updateWeighIn(e.copyWith(at: _at.toUtc(), weightKg: kg));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.bodyWeighIn, style: AppText.title)),
        RuvaTextField(
          controller: _weight,
          label: '${l.bodyWeight} (${widget.imperial ? 'lb' : 'kg'})',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          bold: true,
          autofocus: true,
          errorText: _error,
        ),
        TextButton.icon(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () async {
            final now = ref.read(clockProvider)().toLocal();
            final d = await showDatePicker(
              context: context,
              initialDate: _at,
              firstDate: DateTime(now.year - 10),
              lastDate: now,
            );
            if (d != null) setState(() => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute));
          },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(DateFormat('EEE, d MMM y').format(_at)),
        ),
        PrimaryButton(label: l.save, onPressed: _save),
      ],
    );
  }
}

/// Simple weight line, oldest → newest, scaled to its own min/max.
class _WeightChart extends CustomPainter {
  _WeightChart(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final lo = values.reduce(math.min), hi = values.reduce(math.max);
    final span = math.max(hi - lo, 1.0);
    Offset at(int i) => Offset(
      values.length == 1 ? size.width / 2 : size.width * i / (values.length - 1),
      size.height - 8 - (values[i] - lo) / span * (size.height - 16),
    );
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final dot = Paint()..color = AppColors.primary;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(at(i), i == values.length - 1 ? 5 : 3, dot);
    }
  }

  @override
  bool shouldRepaint(_WeightChart old) => old.values != values;
}

/// Underweight · healthy · overweight bands (BMI 15–35 shown) with a marker
/// for your BMI. Labelled, so colour isn't the only cue.
class _BmiBar extends StatelessWidget {
  const _BmiBar({required this.value});
  final double value;

  static const _lo = 15.0, _hi = 35.0;
  static const _under = Color(0xFFF2A93B), _healthy = Color(0xFF9BD84B), _over = Color(0xFFFF9B85);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final label = AppText.small.copyWith(fontSize: 11.5, color: onForestMuted);
    return ExcludeSemantics(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final x = (value.clamp(_lo, _hi) - _lo) / (_hi - _lo) * c.maxWidth;
              return SizedBox(
                height: 26,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Row(
                          children: [
                            for (final (flex, color) in [(35, _under), (65, _healthy), (100, _over)])
                              Expanded(
                                flex: flex,
                                child: Container(height: 10, color: color),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: x - 3,
                      top: 0,
                      child: Container(
                        width: 6,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 3)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(flex: 35, child: Text(l.bmiBandUnder, style: label)),
              Expanded(
                flex: 65,
                child: Text(l.bmiBandHealthy, textAlign: TextAlign.center, style: label),
              ),
              Expanded(
                flex: 100,
                child: Text(l.bmiBandOver, textAlign: TextAlign.end, style: label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
