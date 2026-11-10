import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/ruva_logo.dart';
import '../../core/widgets/sheet.dart';
import '../../domain/food.dart';
import '../../domain/goals.dart';
import '../../state/providers.dart';
import '../kitchen/my_kitchen_screen.dart';
import '../recipes/recipe_form_screen.dart';
import '../recipes/recipes_screen.dart';
import '../../domain/recipe.dart';
import 'add_food_screen.dart';
import 'meal_export_screen.dart';
import 'meal_photo_screen.dart';
import 'food_labels.dart';

/// Nutrition tab root (MagnaVita design, PRD v1.2 §3): one day's meals with
/// estimated totals, plus shortcuts to My Kitchen.
class FoodDiaryScreen extends ConsumerStatefulWidget {
  const FoodDiaryScreen({super.key});

  @override
  ConsumerState<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends ConsumerState<FoodDiaryScreen> {
  DateTime? _day; // null = today
  bool _micros = false;

  DateTime get _today {
    final t = ref.read(clockProvider)().toLocal();
    return DateTime(t.year, t.month, t.day);
  }

  void _shift(int days) {
    final d = (_day ?? _today);
    final next = DateTime(d.year, d.month, d.day + days);
    setState(() => _day = next == _today ? null : next);
  }

  /// The + buttons: choose how to log (search, scan a barcode, meal photo).
  Future<void> _add(Meal meal, DateTime day) async {
    final l = context.l10n;
    final how = await showAppSheet<String>(
      context,
      (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonoLabel(l.addFoodTo(mealLabel(l, meal), DateFormat('EEE, d MMM').format(day))),
          const SizedBox(height: 6),
          Semantics(header: true, child: Text(l.logHow, style: AppText.title)),
          const SizedBox(height: 8),
          for (final (icon, title, sub, value) in [
            (Icons.search_rounded, l.logSearch, l.logSearchSub, 'search'),
            (Icons.qr_code_scanner_rounded, l.scanTitle, l.logScanSub, 'scan'),
            (Icons.photo_camera_outlined, l.photoTitle, l.logPhotoSub, 'photo'),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconBubble(icon: icon, size: 37),
              title: Text(title, style: AppText.cardValue.copyWith(fontSize: 15)),
              subtitle: Text(sub, style: AppText.small.copyWith(fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => Navigator.pop(ctx, value),
            ),
        ],
      ),
    );
    if (how == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => how == 'photo'
            ? MealPhotoScreen(day: day, meal: meal)
            : AddFoodScreen(day: day, meal: meal, scan: how == 'scan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final today = _today;
    final day = _day ?? today;
    final isToday = day == today;
    final entries = ref.watch(diaryDayProvider(day)).value ?? const <FoodEntry>[];
    final kitchenCount = ref.watch(kitchenProvider).value?.length ?? 0;
    final totals = DayTotals(entries);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
          children: [
            ScreenHeader(
              eyebrow: l.navNutrition,
              title: l.diaryTitle,
              centered: true,
              leading: const Padding(padding: EdgeInsets.only(left: 8), child: RuvaLogo(size: 34, semanticLabel: null)),
              trailing: IconButton(
                tooltip: l.mealExportTooltip,
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => MealExportScreen(day: day))),
                icon: const Icon(Icons.ios_share_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: _DatePill(
                label: isToday ? l.today : DateFormat('EEE, d MMM').format(day),
                onPrev: () => _shift(-1),
                onNext: isToday ? null : () => _shift(1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.kitchen_outlined,
                          title: l.kitchenTitle,
                          subtitle: l.kitchenItems(kitchenCount),
                          page: const MyKitchenScreen(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.menu_book_outlined,
                          title: l.diaryRecipes,
                          subtitle: l.diaryRecipesSub,
                          page: const RecipesScreen(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SummaryCard(
                    title: isToday ? l.diarySummaryToday : l.diarySummaryDay,
                    totals: totals,
                    empty: entries.isEmpty,
                    showMicros: _micros,
                    onToggleMicros: () => setState(() => _micros = !_micros),
                  ),
                  const SizedBox(height: 20),
                  for (final meal in Meal.values) ...[
                    _MealCard(
                      meal: meal,
                      guide: switch ((ref.watch(dailyCaloriesProvider).value, ref.watch(userGoalsProvider).value?.mealsPerDay)) {
                        (final kcal?, final meals?) => switch (mealShares(meals)[meal]) {
                          final share? => kcal * share,
                          null => null,
                        },
                        _ => null,
                      },
                      entries: [
                        for (final e in entries)
                          if (e.meal == meal) e,
                      ],
                      onAdd: () => _add(meal, day),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.title, required this.subtitle, required this.page});
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  @override
  Widget build(BuildContext context) => RuvaCard(
    padding: const EdgeInsets.all(14),
    radius: 20,
    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
    child: Row(
      children: [
        IconBubble(icon: icon, size: 38),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.cardValue.copyWith(fontSize: 14),
              ),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.small.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label, required this.onPrev, required this.onNext});
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.track),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l.diaryPrevDay,
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 110),
            child: Text(label, textAlign: TextAlign.center, style: AppText.cardValue.copyWith(fontSize: 15)),
          ),
          IconButton(
            tooltip: l.diaryNextDay,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.primary,
            disabledColor: AppColors.track,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.totals,
    required this.empty,
    required this.showMicros,
    required this.onToggleMicros,
  });

  final String title;
  final DayTotals totals;
  final bool empty;
  final bool showMicros;
  final VoidCallback onToggleMicros;

  Widget _grid(BuildContext context, List<Nutrient> ns) => LayoutBuilder(
    builder: (context, c) {
      final w = (c.maxWidth - 24) / 3;
      return Wrap(
        spacing: 12,
        runSpacing: 18,
        children: [
          for (final n in ns)
            SizedBox(
              width: w,
              child: _Value(n: n, value: empty ? 0 : totals.sum[n], partial: totals.incomplete.contains(n)),
            ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ForestCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppText.title.copyWith(fontSize: 18, color: AppColors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              IconButton(
                tooltip: l.diaryInfoTitle,
                onPressed: () => showAppSheet<void>(
                  context,
                  (_) => Gap16Column(
                    children: [
                      Semantics(header: true, child: Text(l.diaryInfoTitle, style: AppText.title)),
                      Text(l.diaryInfoBody, style: AppText.body),
                    ],
                  ),
                ),
                icon: const Icon(Icons.info_outline, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _grid(context, Nutrient.macros),
          const SizedBox(height: 8),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 48),
            ),
            onPressed: onToggleMicros,
            icon: Icon(showMicros ? Icons.expand_less : Icons.expand_more),
            label: Text(l.diaryMicros),
          ),
          if (showMicros) _grid(context, Nutrient.micros),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.n, required this.value, required this.partial});
  final Nutrient n;
  final double? value;
  final bool partial;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final name = nutrientLabel(l, n);
    final status = value == null
        ? l.nutrientUnavailable
        : partial
        ? l.nutrientPartial
        : l.nutrientEstimated;
    return Semantics(
      container: true,
      label: value == null ? '$name: $status' : '$name: ${formatNutrient(value!)} ${n.unit}, $status',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(name, color: AppColors.accent, size: 10),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value == null ? '—' : formatNutrient(value!),
                    style: AppText.title.copyWith(fontSize: 26, color: AppColors.white),
                  ),
                  if (value != null)
                    TextSpan(
                      text: ' ${n.unit}',
                      style: AppText.body.copyWith(fontSize: 15, color: AppColors.accent),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          // "Estimated" is explained once by the (i) button; only flag gaps here.
          if (value == null || partial) MonoLabel(status, color: onForestMuted, size: 9),
        ],
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.meal, required this.entries, required this.onAdd, this.guide});
  final Meal meal;
  final List<FoodEntry> entries;
  final VoidCallback onAdd;

  /// Rough calories for this meal from your daily target and meals a day.
  final double? guide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final name = mealLabel(l, meal);
    return RuvaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Semantics(header: true, child: MonoLabel(name))),
              if (entries.isNotEmpty)
                IconButton(
                  tooltip: l.diarySaveRecipe(name),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RecipeFormScreen(
                        existing: Recipe(
                          id: 'mine:',
                          name: '',
                          category: name,
                          servings: 1,
                          ingredients: [
                            for (final e in entries)
                              RecipeIngredient(e.name, formatPortion(e.portion, e.grams, e.unit)),
                          ],
                          nutrients: DayTotals(entries).sum,
                        ),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.primary, size: 22),
                ),
              if (entries.isNotEmpty)
                IconButton(
                  tooltip: l.diaryCopyMeal(name),
                  onPressed: () => copyEntries(context, ref, entries),
                  icon: const Icon(Icons.copy_all_outlined, color: AppColors.primary, size: 22),
                ),
              RoundIconButton(icon: Icons.add, onTap: onAdd, tooltip: l.addFoodAddTo(name)),
            ],
          ),
          if (guide case final g?)
            Text(
              l.diaryMealGuide(
                formatNutrient((DayTotals(entries).sum[Nutrient.energy] ?? 0).roundToDouble()),
                formatNutrient((g / 10).round() * 10.0),
              ),
              style: AppText.small.copyWith(fontSize: 12.5, color: AppColors.primary),
            ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.diaryMealEmpty, style: AppText.small.copyWith(fontSize: 14)),
            ),
          for (final (i, e) in entries.indexed) ...[
            if (i > 0) const Divider(color: AppColors.divider, height: 8),
            _EntryRow(entry: e),
          ],
        ],
      ),
    );
  }
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({required this.entry});
  final FoodEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(entry.loggedAt.toLocal()),
      alwaysUse24HourFormat: ref.watch(settingsProvider).value?.use24HourTime ?? false,
    );
    final kcal = entry.nutrients[Nutrient.energy];
    final amount = kcal == null ? l.addFoodNoData : '${l.diaryKcal(formatNutrient(kcal))} ${l.diaryEst}';
    return Semantics(
      button: true,
      label: l.diaryEntryLabel(entry.name, time, '${formatPortion(entry.portion, entry.grams, entry.unit)}, $amount'),
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showAppSheet<void>(context, (_) => _EntrySheet(entry: entry)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              IconBubble(icon: mealIcon(entry.meal), size: 41),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: AppText.cardValue.copyWith(fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(
                      '$time · ${formatPortion(entry.portion, entry.grams, entry.unit)} · $amount',
                      style: AppText.small.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Change the amount of a logged food, or remove it.
class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({required this.entry});
  final FoodEntry entry;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  late double _grams = widget.entry.grams ?? 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final e = widget.entry;
    final changed = _grams != e.grams;
    final kcal = e.copyWith(grams: _grams).nutrients[Nutrient.energy];
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(e.name, style: AppText.title)),
        if (e.grams != null) ...[
          MonoLabel(l.diaryChangeAmount),
          ValueStepper(
            large: true,
            label: changed ? formatPortion('', _grams, e.unit) : formatPortion(e.portion, _grams, e.unit),
            minusTooltip: l.addFoodLess,
            plusTooltip: l.addFoodMore,
            onMinus: _grams > 5 ? () => setState(() => _grams = (_grams - 10).clamp(5, 2000)) : null,
            onPlus: _grams < 2000 ? () => setState(() => _grams = (_grams + 10).clamp(5, 2000)) : null,
          ),
          if (kcal != null) Text(l.addFoodAbout(formatNutrient(kcal)), style: AppText.small),
          PrimaryButton(
            label: l.save,
            onPressed: changed
                ? () async {
                    await ref.read(foodActionsProvider).update(e.copyWith(grams: _grams));
                    if (context.mounted) Navigator.pop(context);
                  }
                : null,
          ),
        ],
        TextButton.icon(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () async {
            final navigator = Navigator.of(context);
            if (await copyEntries(context, ref, [e])) navigator.pop();
          },
          icon: const Icon(Icons.copy_outlined),
          label: Text(l.diaryCopy),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: AppColors.errorText, minimumSize: const Size(48, 48)),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await ref.read(foodActionsProvider).delete(e);
            if (context.mounted) Navigator.pop(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l.diaryRemoved(e.name)), duration: const Duration(seconds: 2)));
          },
          icon: const Icon(Icons.delete_outline),
          label: Text(l.diaryRemove),
        ),
      ],
    );
  }
}

/// Pick a day (up to today) and copy [entries] there as they are.
/// Returns true when copied.
Future<bool> copyEntries(BuildContext context, WidgetRef ref, List<FoodEntry> entries) async {
  final l = context.l10n;
  final now = ref.read(clockProvider)().toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = await showDatePicker(
    context: context,
    helpText: l.diaryCopyTo,
    initialDate: today,
    firstDate: DateTime(today.year - 1),
    lastDate: today,
  );
  if (day == null || !context.mounted) return false;
  await ref.read(foodActionsProvider).copyTo(entries, day);
  if (context.mounted) showRuvaSnack(context, l.diaryCopied(entries.length, DateFormat('EEE, d MMM').format(day)));
  return true;
}
