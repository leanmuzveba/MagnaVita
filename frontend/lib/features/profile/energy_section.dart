import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../domain/body.dart';
import '../../domain/energy.dart';
import '../../state/providers.dart';

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
  const EnergySection({super.key, required this.profile, required this.latest, required this.today});

  final BodyProfile profile;
  final WeighIn? latest;
  final DateTime today;

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
            const Divider(height: 28),
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
          ],
        ],
      ),
    );
  }
}
