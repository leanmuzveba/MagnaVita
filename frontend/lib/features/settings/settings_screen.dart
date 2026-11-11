import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/update_checker.dart' show appVersion;
import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/pill_button.dart';
import '../../core/widgets/ruva_kit.dart';
import '../../core/widgets/ruva_logo.dart';
import '../../core/widgets/sheet.dart';
import '../../data/health_source.dart' show SourceTotals;
import '../../domain/settings.dart';
import '../../data/account.dart' show AuthFailure;
import '../account/auth_screen.dart';
import '../kitchen/kitchen_review_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../../state/providers.dart';

String unitsLabel(AppLocalizations l, UnitSystem u) => u == UnitSystem.metric ? l.unitsMetric : l.unitsImperial;

String dietLabel(AppLocalizations l, DietPreference d) => switch (d) {
  DietPreference.none => l.dietNone,
  DietPreference.vegetarian => l.dietVegetarian,
  DietPreference.vegan => l.dietVegan,
  DietPreference.pescatarian => l.dietPescatarian,
  DietPreference.halal => l.dietHalal,
};

String allergenLabel(AppLocalizations l, Allergen a) => switch (a) {
  Allergen.eggs => l.allergenEggs,
  Allergen.dairy => l.allergenDairy,
  Allergen.peanuts => l.allergenPeanuts,
  Allergen.treeNuts => l.allergenTreeNuts,
  Allergen.gluten => l.allergenGluten,
  Allergen.soy => l.allergenSoy,
  Allergen.fish => l.allergenFish,
  Allergen.shellfish => l.allergenShellfish,
  Allergen.sesame => l.allergenSesame,
};

/// Settings (MagnaVita design): profile card, preferences, optional reminders,
/// privacy & data, about & safety.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.onChangeTarget});
  final VoidCallback onChangeTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final prefs = ref.watch(notificationPrefsProvider).value;
    if (settings == null || prefs == null) return const Center(child: CircularProgressIndicator());
    final l = context.l10n;
    NotificationPreference pref(NotificationType t) => prefs.firstWhere((p) => p.type == t);
    final target = pref(NotificationType.targetReached);
    final daily = pref(NotificationType.dailyReminder);
    final water = pref(NotificationType.waterReminder);
    final review = pref(NotificationType.monthlyReview);
    final dailyTime = TimeOfDay(hour: daily.hour ?? 20, minute: daily.minute ?? 0);
    void change(AppSettings Function(AppSettings) edit) => ref.read(settingsProvider.notifier).change(edit);

    Future<void> setPref(NotificationPreference p) async {
      final ok = await ref.read(notificationPrefsProvider.notifier).set(p);
      if (!ok && context.mounted) showRuvaSnack(context, l.settingsNotificationsBlocked);
    }

    final allergies = settings.allergies.isEmpty
        ? l.allergiesNone
        : (settings.allergies.toList()..sort((a, b) => a.index - b.index)).map((a) => allergenLabel(l, a)).join(', ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(header: true, child: Text(l.navSettings, style: AppText.title.copyWith(fontSize: 24))),
            ),
            const RuvaLogo(size: 40, semanticLabel: null),
          ],
        ),
        const SizedBox(height: 20),
        _ProfileCard(
          settings: settings,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
        ),
        const SizedBox(height: 12),
        _Group(
          children: [
            _NavRow(
              icon: Icons.calendar_month_outlined,
              title: l.navHistory,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: SafeArea(child: HistoryScreen())),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionLabel(l.accountSection),
        _Group(
          children: [
            if (ref.watch(accountProvider).value case final account?) ...[
              _NavRow(icon: Icons.account_circle_outlined, title: account.email ?? account.name, subtitle: l.accountSignedIn),
              _NavRow(icon: Icons.logout, title: l.accountSignOut, onTap: () => _confirmSignOut(context, ref)),
              _NavRow(
                icon: Icons.person_remove_outlined,
                title: l.accountDelete,
                subtitle: l.accountDeleteSub,
                danger: true,
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
            ] else
              _NavRow(
                icon: Icons.login,
                title: l.accountSignInOrCreate,
                subtitle: l.accountLocalSub,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => const AuthScreen(fromSettings: true))),
              ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionLabel(l.settingsPreferences),
        _Group(
          children: [
            _NavRow(
              icon: Icons.straighten,
              title: l.settingsUnits,
              value: unitsLabel(l, settings.units),
              onTap: () => _pickOne<UnitSystem>(
                context,
                title: l.settingsUnits,
                options: UnitSystem.values,
                current: settings.units,
                label: (u) => unitsLabel(l, u),
                onSelected: (u) => change((s) => s.copyWith(units: u)),
              ),
            ),
            _NavRow(
              icon: Icons.eco_outlined,
              title: l.settingsDiet,
              value: dietLabel(l, settings.diet),
              onTap: () => _pickOne<DietPreference>(
                context,
                title: l.settingsDiet,
                options: DietPreference.values,
                current: settings.diet,
                label: (d) => dietLabel(l, d),
                onSelected: (d) => change((s) => s.copyWith(diet: d)),
              ),
            ),
            _NavRow(
              icon: Icons.error_outline,
              title: l.settingsAllergies,
              value: allergies,
              onTap: () => showAppSheet<void>(context, (_) => const _AllergiesSheet()),
            ),
            _NavRow(
              icon: Icons.timer_outlined,
              title: l.settingsTarget,
              value: formatTarget(Duration(minutes: settings.targetMinutes)),
              onTap: onChangeTarget,
            ),
            _ToggleRow(
              title: l.settings24h,
              value: settings.use24HourTime,
              onChanged: (v) => change((s) => s.copyWith(use24HourTime: v)),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionLabel(l.watchSection),
        _Group(
          children: [
            _NavRow(
              icon: Icons.watch_outlined,
              title: l.watchTitle,
              value: switch (ref.watch(watchStatusProvider).value) {
                WatchStatus.linked => l.watchLinked,
                WatchStatus.needsPermission => l.watchNeedsPermission,
                WatchStatus.unavailable => l.watchUnavailableShort,
                _ => l.watchOff,
              },
              onTap: () => showAppSheet<void>(context, (_) => const _WatchSheet()),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionLabel(l.settingsRemindersOptional),
        _Group(
          children: [
            _ToggleRow(
              title: l.settingsTargetReached,
              subtitle: l.settingsTargetReachedSub,
              value: target.enabled,
              onChanged: (v) => setPref(target.copyWith(enabled: v)),
            ),
            _ToggleRow(
              title: l.settingsDailyReminder,
              subtitle: daily.enabled
                  ? l.settingsEveryDayAt(
                      MaterialLocalizations.of(context)
                          .formatTimeOfDay(dailyTime, alwaysUse24HourFormat: settings.use24HourTime),
                    )
                  : null,
              value: daily.enabled,
              onChanged: (v) => setPref(daily.copyWith(enabled: v, hour: dailyTime.hour, minute: dailyTime.minute)),
            ),
            if (daily.enabled)
              _NavRow(
                icon: Icons.schedule,
                title: l.settingsReminderTime,
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: dailyTime);
                  if (t != null) await setPref(daily.copyWith(hour: t.hour, minute: t.minute));
                },
              ),
            _ToggleRow(
              title: l.settingsWaterReminders,
              subtitle: l.settingsWaterRemindersSub,
              value: water.enabled,
              onChanged: (v) => setPref(water.copyWith(enabled: v)),
            ),
            _ToggleRow(
              title: l.settingsMonthlyReview,
              subtitle: l.settingsMonthlyReviewSub,
              value: review.enabled,
              onChanged: (v) => setPref(review.copyWith(enabled: v)),
            ),
            _NavRow(
              icon: Icons.fact_check_outlined,
              title: l.settingsReviewNow,
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const KitchenReviewScreen())),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionLabel(l.settingsPrivacy),
        _Group(
          children: [
            _NavRow(
              icon: Icons.cloud_upload_outlined,
              title: l.settingsBackup,
              subtitle: l.settingsBackupSub,
              onTap: () => _backup(context, ref),
            ),
            _NavRow(
              icon: Icons.settings_backup_restore,
              title: l.settingsRestore,
              subtitle: l.settingsRestoreSub,
              onTap: () => _confirmRestore(context, ref),
            ),
            _NavRow(
              icon: Icons.delete_outline,
              title: l.settingsDeleteAll,
              subtitle: l.settingsDeleteAllSub,
              danger: true,
              onTap: () => _confirmDelete(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionLabel(l.settingsAboutSafety),
        _Group(
          children: [
            _NavRow(
              icon: Icons.menu_book_outlined,
              title: l.settingsHowItWorks,
              onTap: () => _info(context, l.settingsHowItWorks, l.settingsHowItWorksBody),
            ),
            _NavRow(
              icon: Icons.health_and_safety_outlined,
              title: l.settingsNotMedical,
              onTap: () => _info(context, l.settingsNotMedical, l.settingsNotMedicalSub),
            ),
            _NavRow(
              icon: Icons.photo_camera_outlined,
              title: l.settingsPhotoKey,
              value: switch (ref.watch(geminiKeyProvider).value) {
                null => l.settingsPhotoKeyNone,
                (own: true, key: _) => l.settingsPhotoKeyOwn,
                _ => l.settingsPhotoKeyBuiltIn,
              },
              onTap: () => showAppSheet<void>(context, (_) => const _PhotoKeySheet()),
            ),
            _NavRow(
              icon: Icons.restaurant_menu_outlined,
              title: l.settingsFoodData,
              onTap: () => _info(context, l.settingsFoodData, l.settingsFoodDataSub),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l.settingsFooter, textAlign: TextAlign.center, style: AppText.small),
        const SizedBox(height: 6),
        Text(l.appVersion(appVersion), textAlign: TextAlign.center, style: AppText.small),
      ],
    );
  }

  Future<void> _pickOne<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required T current,
    required String Function(T) label,
    required ValueChanged<T> onSelected,
  }) => showAppSheet<void>(
    context,
    (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(title, style: AppText.title.copyWith(fontSize: 19))),
        const SizedBox(height: 8),
        for (final o in options)
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: 52,
            selected: o == current,
            title: Text(label(o), style: AppText.body.copyWith(fontSize: 15)),
            trailing: Icon(
              o == current ? Icons.check_circle : Icons.circle_outlined,
              color: o == current ? AppColors.primary : AppColors.muted,
            ),
            onTap: () {
              onSelected(o);
              Navigator.pop(ctx);
            },
          ),
      ],
    ),
  );

  Future<void> _info(BuildContext context, String title, String body) => showAppSheet<void>(
    context,
    (_) => Gap16Column(
      children: [
        Semantics(header: true, child: Text(title, style: AppText.title.copyWith(fontSize: 19))),
        Text(body, style: AppText.body),
      ],
    ),
  );

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final day = DateFormat('yyyy-MM-dd').format(ref.read(clockProvider)());
    try {
      final bytes = await ref.read(sessionActionsProvider).backup();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'application/octet-stream', name: 'magnavita-backup-$day.db')],
        ),
      );
    } on Exception {
      if (context.mounted) showRuvaSnack(context, context.l10n.backupFailed);
    }
  }

  Future<void> _confirmRestore(BuildContext context, WidgetRef ref) => showAppSheet<void>(
    context,
    (ctx) => Gap16Column(
      children: [
        Semantics(header: true, child: Text(ctx.l10n.restoreTitle, style: AppText.title)),
        Text(ctx.l10n.restoreBody, style: AppText.body.copyWith(color: AppColors.textSecondary)),
        Row(
          children: [
            Expanded(
              child: PillButton(label: ctx.l10n.cancel, outlined: true, onPressed: () => Navigator.pop(ctx)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PillButton(
                label: ctx.l10n.restorePick,
                onPressed: () async {
                  Navigator.pop(ctx);
                  final l = context.l10n;
                  final bytes = await ref.read(backupPickerProvider)();
                  if (bytes == null) return;
                  final ok = await ref.read(sessionActionsProvider).restore(bytes).catchError((_) => false);
                  if (context.mounted) showRuvaSnack(context, ok ? l.restoreDone : l.restoreNotBackup);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) => _confirm(
    context,
    title: context.l10n.accountSignOutTitle,
    body: context.l10n.accountSignOutBody,
    action: context.l10n.accountSignOut,
    run: () => ref.read(accountActionsProvider).signOut(),
  );

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) => _confirm(
    context,
    title: context.l10n.accountDeleteTitle,
    body: context.l10n.accountDeleteBody,
    action: context.l10n.accountDelete,
    run: () => ref.read(accountActionsProvider).deleteAccount(),
  );

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    required Future<void> Function() run,
  }) => showAppSheet<void>(
    context,
    (ctx) => Gap16Column(
      children: [
        Semantics(header: true, child: Text(title, style: AppText.title)),
        Text(body, style: AppText.body.copyWith(color: AppColors.textSecondary)),
        Row(
          children: [
            Expanded(
              child: PillButton(label: ctx.l10n.cancel, outlined: true, onPressed: () => Navigator.pop(ctx)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PillButton(
                label: action,
                onPressed: () async {
                  Navigator.pop(ctx);
                  final l = context.l10n;
                  try {
                    await run();
                  } on AuthFailure catch (e) {
                    if (context.mounted) showRuvaSnack(context, authProblemText(l, e.problem));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) => showAppSheet<void>(
    context,
    (ctx) => Gap16Column(
      children: [
        Semantics(header: true, child: Text(ctx.l10n.deleteAllTitle, style: AppText.title)),
        Text(ctx.l10n.deleteAllBody, style: AppText.body.copyWith(color: AppColors.textSecondary)),
        Row(
          children: [
            Expanded(
              child: PillButton(label: ctx.l10n.cancel, outlined: true, onPressed: () => Navigator.pop(ctx)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PillButton(
                label: ctx.l10n.deleteAll,
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(sessionActionsProvider).deleteEverything();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.settings, required this.onTap});
  final AppSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final name = settings.userName.trim();
    final initials = name.isEmpty
        ? null
        : name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
    final since = settings.memberSince;
    return ForestCard(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: '${name.isEmpty ? l.profileAddName : name}. ${l.profileEditHint}',
        excludeSemantics: true,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
              child: initials == null
                  ? const Icon(Icons.person_outline, color: AppColors.primary, size: 30)
                  : Text(initials, style: AppText.title.copyWith(fontSize: 19, color: AppColors.primary)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (since != null)
                    MonoLabel(
                      l.profileMemberSince(DateFormat('MMM y').format(since.toLocal())),
                      color: AppColors.accent,
                      size: 10,
                    ),
                  const SizedBox(height: 6),
                  Text(
                    name.isEmpty ? l.profileAddName : name,
                    style: AppText.title.copyWith(fontSize: 19, color: AppColors.white),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}

class ProfileNameSheet extends ConsumerStatefulWidget {
  const ProfileNameSheet({super.key, required this.initial});
  final String initial;

  @override
  ConsumerState<ProfileNameSheet> createState() => _ProfileNameSheetState();
}

class _ProfileNameSheetState extends ConsumerState<ProfileNameSheet> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.profileTitle, style: AppText.title)),
        Text(l.profileOptional, style: AppText.small),
        RuvaTextField(controller: _name, label: l.profileNameLabel, autofocus: true),
        PrimaryButton(
          label: l.save,
          onPressed: () async {
            await ref.read(settingsProvider.notifier).change((s) => s.copyWith(userName: _name.text.trim()));
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

/// Paste your own Gemini key (stored only in this phone's app data), or
/// clear it to use the one built into the app.
class _PhotoKeySheet extends ConsumerStatefulWidget {
  const _PhotoKeySheet();

  @override
  ConsumerState<_PhotoKeySheet> createState() => _PhotoKeySheetState();
}

class _PhotoKeySheetState extends ConsumerState<_PhotoKeySheet> {
  final _key = TextEditingController();

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _set(String? value) async {
    await ref.read(settingsRepositoryProvider).setApiKey('gemini', value);
    ref.invalidate(geminiKeyProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final own = ref.watch(geminiKeyProvider).value?.own ?? false;
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.settingsPhotoKey, style: AppText.title)),
        Text(l.settingsPhotoKeyBody, style: AppText.body),
        TextField(
          controller: _key,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: l.settingsPhotoKeyField,
            filled: true,
            fillColor: AppColors.lime200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        PrimaryButton(label: l.save, onPressed: () => _set(_key.text)),
        if (own) TextButton(onPressed: () => _set(null), child: Text(l.settingsPhotoKeyClear)),
      ],
    );
  }
}

/// Connect a watch through Health Connect (Mi Fitness for Xiaomi watches).
class _WatchSheet extends ConsumerWidget {
  const _WatchSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final status = ref.watch(watchStatusProvider).value ?? WatchStatus.off;
    final actions = ref.read(watchActionsProvider);
    return Gap16Column(
      children: [
        Semantics(header: true, child: Text(l.watchTitle, style: AppText.title)),
        Text(l.watchIntro, style: AppText.body),
        Text(l.watchSteps, style: AppText.small.copyWith(fontSize: 13.5)),
        if (status == WatchStatus.unavailable) ...[
          Text(l.watchUnavailable, style: AppText.small.copyWith(color: AppColors.errorText)),
          PrimaryButton(label: l.watchInstall, onPressed: () => ref.read(healthSourceProvider).install()),
        ] else if (status == WatchStatus.linked) ...[
          Text(l.watchLinkedBody, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
          MonoLabel(l.watchFromApps),
          if (ref.watch(watchBreakdownProvider).value ?? const <SourceTotals>[] case final apps)
            if (apps.isEmpty)
              Text(l.watchNoData, style: AppText.small)
            else
              for (final a in apps)
                Text(
                  [
                    '${a.used ? '✓ ' : ''}${a.name}',
                    if (a.steps != null) l.watchAppSteps(a.steps!),
                    if (a.activeKcal != null) l.watchAppActive(a.activeKcal!),
                    if (a.totalKcal != null) l.watchAppTotal(a.totalKcal!),
                  ].join(' · '),
                  style: AppText.small.copyWith(fontSize: 13, fontWeight: a.used ? FontWeight.w600 : FontWeight.w400),
                ),
          Text(l.watchUsedNote, style: AppText.small.copyWith(fontSize: 12)),
          TextButton.icon(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: actions.refresh,
            icon: const Icon(Icons.refresh),
            label: Text(l.watchRefresh),
          ),
          TextButton(
            onPressed: () async {
              await actions.disconnect();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.watchDisconnect),
          ),
        ] else
          PrimaryButton(
            label: l.watchConnect,
            onPressed: () async {
              final result = await actions.connect();
              if (!context.mounted) return;
              if (result == WatchStatus.linked) {
                Navigator.pop(context);
                showRuvaSnack(context, l.watchConnected);
              } else if (result == WatchStatus.needsPermission) {
                showRuvaSnack(context, l.watchDenied);
              }
            },
          ),
        Text(l.watchPrivacy, style: AppText.small.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _AllergiesSheet extends ConsumerWidget {
  const _AllergiesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final selected = ref.watch(settingsProvider).value?.allergies ?? const {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(l.settingsAllergies, style: AppText.title.copyWith(fontSize: 19))),
        const SizedBox(height: 6),
        Text(l.allergiesHint, style: AppText.small),
        const SizedBox(height: 8),
        for (final a in Allergen.values)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            value: selected.contains(a),
            title: Text(allergenLabel(l, a), style: AppText.body.copyWith(fontSize: 15)),
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .change((s) => s.copyWith(allergies: v! ? {...s.allergies, a} : ({...s.allergies}..remove(a)))),
          ),
        const SizedBox(height: 8),
        PrimaryButton(label: l.done, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6, bottom: 12),
    child: Semantics(header: true, child: MonoLabel(text)),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => RuvaCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.divider),
          children[i],
        ],
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.title, this.value, this.subtitle, this.onTap, this.danger = false});

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: [title, ?value, ?subtitle].join(', '),
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconBubble(
                icon: icon,
                size: 36,
                background: danger ? const Color(0xFFFCE3DE) : AppColors.primary,
                foreground: danger ? AppColors.errorText : AppColors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.link.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: danger ? AppColors.errorText : AppColors.text,
                      ),
                    ),
                    if (subtitle != null) Text(subtitle!, style: AppText.small),
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
              ],
              if (onTap != null) ...[const SizedBox(width: 8), const Icon(Icons.chevron_right, color: AppColors.muted)],
            ],
          ),
        ),
      ),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.title, required this.value, required this.onChanged, this.subtitle});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.link.copyWith(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
                      ),
                      const SizedBox(height: 3),
                      Text(subtitle ?? l.settingsCurrentState(value ? l.on : l.off), style: AppText.small),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: AppColors.accent,
                  activeThumbColor: AppColors.primary,
                  inactiveTrackColor: AppColors.divider,
                  inactiveThumbColor: AppColors.white,
                  trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
