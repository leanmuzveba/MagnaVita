import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../domain/body.dart';
import '../../domain/energy.dart';

String formatKcal(double kcal) => NumberFormat.decimalPattern().format(kcal.round());

/// Resting energy, daily calories and the weight forecast (adults only).
class EnergySection extends StatelessWidget {
  const EnergySection({super.key, required this.profile, required this.latest, required this.today});

  final BodyProfile profile;
  final WeighIn? latest;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final resting = restingEnergy(profile, latest?.weightKg, today);
    return RuvaCard(
      child: Semantics(
        container: true,
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
            ],
          ],
        ),
      ),
    );
  }
}
