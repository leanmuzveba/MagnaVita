import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Shared building blocks from the MagnaVita screen designs (docs/ruva designs):
/// rounded cards, one forest hero card per screen, lime-pale pill chips,
/// mono eyebrows and a back/title header. Sized for 48 px tap targets.

/// Small uppercase eyebrow label (JetBrains Mono).
class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {super.key, this.color = AppColors.textSecondary, this.size = 11});
  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppText.overline.copyWith(color: color, fontSize: size, letterSpacing: 1.4),
  );
}

/// White rounded card with the brand's soft shadow; tappable when [onTap] is set.
class RuvaCard extends StatelessWidget {
  const RuvaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.white,
    this.radius = 20,
    this.bordered = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;
  final bool bordered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: bordered ? Border.all(color: AppColors.divider) : null,
      boxShadow: AppShadows.card,
    ),
    child: Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

/// The one forest "hero" card per screen.
class ForestCard extends StatelessWidget {
  const ForestCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      RuvaCard(color: AppColors.primary, radius: 24, padding: padding, onTap: onTap, child: child);
}

/// White 70%: secondary text on forest.
const onForestMuted = Color(0xB3FFFFFF);

/// Pill chip: forest when selected, lime-pale (or white outlined) otherwise.
class RuvaChip extends StatelessWidget {
  const RuvaChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
    this.outlined = false,
    this.trailingCheck = false,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outlined;
  final bool trailingCheck;
  final bool dense; // 32 px pill (still a 48 px tap area)

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : (outlined ? AppColors.white : AppColors.lime200);
    final fg = selected ? AppColors.white : AppColors.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        // 48 px tap target around the 40 px pill.
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: dense ? 8 : 4),
          child: Material(
            color: bg,
            shape: StadiumBorder(
              side: outlined && !selected ? const BorderSide(color: AppColors.divider) : BorderSide.none,
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: dense ? 32 : 40),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: selected ? const Color(0x33FFFFFF) : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 12, color: selected ? AppColors.white : AppColors.accent),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            style: AppText.body.copyWith(
                              fontSize: dense ? 12 : 13,
                              fontWeight: FontWeight.w500,
                              color: fg,
                            ),
                          ),
                        ),
                      ),
                      if (trailingCheck && selected) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check, size: 16, color: fg),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of chips with 10 px gaps.
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children, this.padding = const EdgeInsets.symmetric(horizontal: 20)});
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: padding,
    child: Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 10), children[i]],
      ],
    ),
  );
}

/// Full-width pill button (48 px): forest, or lime-pale when [light].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.light = false, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool light;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: light ? AppColors.lime200 : AppColors.primary,
        foregroundColor: light ? AppColors.primary : AppColors.white,
        shape: const StadiumBorder(),
        textStyle: AppText.link.copyWith(fontSize: 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    ),
  );
}

/// Circular icon button (48 px tap target around a [size] disc).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.size = 40,
    this.background = AppColors.primary,
    this.foreground = AppColors.white,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: SizedBox.square(
          dimension: size < 48 ? 48 : size,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: background, shape: BoxShape.circle),
              child: Icon(icon, color: foreground, size: size * 0.55),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Round icon on a soft disc (list leading icons).
class IconBubble extends StatelessWidget {
  const IconBubble({
    super.key,
    required this.icon,
    this.size = 42,
    this.background = AppColors.lime200,
    this.foreground = AppColors.primary,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
    child: Icon(icon, color: foreground, size: size * 0.46),
  );
}

/// − value + stepper pill.
class ValueStepper extends StatelessWidget {
  const ValueStepper({
    super.key,
    required this.label,
    required this.onMinus,
    required this.onPlus,
    required this.minusTooltip,
    required this.plusTooltip,
    this.large = false,
  });

  final String label;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final String minusTooltip;
  final String plusTooltip;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final btnBg = large ? AppColors.white : Colors.transparent;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: large ? AppColors.background : AppColors.divider),
      ),
      child: Row(
        mainAxisSize: large ? MainAxisSize.max : MainAxisSize.min,
        children: [
          RoundIconButton(
            icon: Icons.remove,
            onTap: onMinus,
            tooltip: minusTooltip,
            size: large ? 40 : 34,
            background: btnBg,
            foreground: AppColors.primary,
          ),
          if (large)
            Expanded(
              child: Center(
                child: Semantics(liveRegion: true, child: Text(label, style: AppText.title.copyWith(fontSize: 19))),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Semantics(liveRegion: true, child: Text(label, style: AppText.cardValue.copyWith(fontSize: 15))),
            ),
          RoundIconButton(
            icon: Icons.add,
            onTap: onPlus,
            tooltip: plusTooltip,
            size: large ? 40 : 34,
            background: btnBg,
            foreground: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Lime-pale filled text field (brand: inputs are lime pills with a soft stroke).
class RuvaTextField extends StatelessWidget {
  const RuvaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.keyboardType,
    this.bold = false,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
    this.autofocus = false,
    this.obscureText = false,
    this.suffix,
    this.autofillHints,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool bold;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool obscureText;
  final Widget? suffix;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MonoLabel(label),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        autofocus: autofocus,
        onChanged: onChanged,
        obscureText: obscureText,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        style: bold ? AppText.cardValue : AppText.body.copyWith(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.body.copyWith(color: AppColors.textSecondary),
          errorText: errorText,
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.lime200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primaryMid, width: 2),
          ),
        ),
      ),
    ],
  );
}

/// Pill search field.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
    this.onSubmitted,
    this.dense = false,
  });
  final String hint;
  final bool dense;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    textInputAction: onSubmitted == null ? null : TextInputAction.search,
    style: dense ? AppText.body.copyWith(fontSize: 14) : AppText.body,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: AppText.body.copyWith(color: AppColors.textSecondary, fontSize: dense ? 14 : null),
      isDense: dense,
      prefixIcon: Icon(Icons.search, color: AppColors.primary, size: dense ? 20 : null),
      filled: true,
      fillColor: AppColors.lime200,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: AppColors.primaryMid, width: 2),
      ),
    ),
  );
}

/// Back button + optional eyebrow and title, optional trailing widget.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.trailing,
    this.leading,
    this.centered = false,
    this.large = false,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading; // shown where Back goes when there's nothing to go back to
  final bool centered;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final block = Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[MonoLabel(eyebrow!), const SizedBox(height: 4)],
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: AppText.title.copyWith(fontSize: large ? 25 : 19, height: 1.15),
          ),
        ),
        if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: AppText.dateLine)],
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: canPop
                ? IconButton(
                    tooltip: context.l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left_rounded, size: 30, color: AppColors.primary),
                  )
                : leading,
          ),
          Expanded(child: centered ? Center(child: block) : block),
          SizedBox(width: 48, child: trailing),
        ],
      ),
    );
  }
}

void showRuvaSnack(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
