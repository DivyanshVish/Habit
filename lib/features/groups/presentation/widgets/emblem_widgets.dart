import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';

/// A group's picture. The app has no image upload, so a group picks one of a
/// dozen icons and eight calm colours. Colours come from fixed lists here, and
/// the icon is always shown too, so identity never relies on colour alone.
class EmblemStyle {
  const EmblemStyle._();

  static const Map<String, IconData> icons = {
    'fitness': Icons.fitness_center,
    'book': Icons.menu_book_outlined,
    'run': Icons.directions_run,
    'heart': Icons.favorite_border,
    'star': Icons.star_border,
    'leaf': Icons.eco_outlined,
    'coffee': Icons.coffee_outlined,
    'music': Icons.music_note,
    'study': Icons.school_outlined,
    'water': Icons.water_drop_outlined,
    'sleep': Icons.bedtime_outlined,
    'people': Icons.groups_outlined,
  };

  static const Map<String, String> names = {
    'fitness': 'Fitness',
    'book': 'Reading',
    'run': 'Running',
    'heart': 'Heart',
    'star': 'Star',
    'leaf': 'Nature',
    'coffee': 'Coffee',
    'music': 'Music',
    'study': 'Study',
    'water': 'Water',
    'sleep': 'Sleep',
    'people': 'People',
  };

  static const List<Color> colors = AppTokens.emblemPalette;

  static const Color onColor = AppTokens.emblemOn;

  static IconData iconFor(GroupEmblem emblem) =>
      icons[emblem.icon] ?? Icons.groups_outlined;

  static Color colorFor(GroupEmblem emblem) =>
      colors[emblem.color.clamp(0, colors.length - 1)];
}

class EmblemAvatar extends StatelessWidget {
  const EmblemAvatar({this.emblem, this.size = 44, super.key});

  final GroupEmblem? emblem;
  final double size;

  @override
  Widget build(BuildContext context) {
    final value = emblem ?? GroupEmblem.fallback;
    return Semantics(
      label: 'Group picture, ${EmblemStyle.names[value.icon] ?? 'People'}',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: EmblemStyle.colorFor(value),
            borderRadius: BorderRadius.circular(context.tokens.radii.control),
          ),
          child: Icon(
            EmblemStyle.iconFor(value),
            size: size * 0.55,
            color: EmblemStyle.onColor,
          ),
        ),
      ),
    );
  }
}

/// Pick an icon and a colour. Both are buttons with a visible selected state
/// (a check mark), not just a colour change.
class EmblemPicker extends StatelessWidget {
  const EmblemPicker({required this.value, required this.onChanged, super.key});

  final GroupEmblem value;
  final ValueChanged<GroupEmblem> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: EmblemAvatar(emblem: value, size: 72)),
        SizedBox(height: tokens.space.s16),
        Wrap(
          spacing: tokens.space.s8,
          runSpacing: tokens.space.s8,
          children: [
            for (final icon in GroupEmblem.icons)
              _Choice(
                key: ValueKey('emblem-icon-$icon'),
                label: EmblemStyle.names[icon] ?? icon,
                selected: value.icon == icon,
                onTap: () =>
                    onChanged(GroupEmblem(icon: icon, color: value.color)),
                child: Icon(
                  EmblemStyle.icons[icon] ?? Icons.groups_outlined,
                  size: 22,
                ),
              ),
          ],
        ),
        SizedBox(height: tokens.space.s12),
        Wrap(
          spacing: tokens.space.s8,
          runSpacing: tokens.space.s8,
          children: [
            for (var color = 0; color < GroupEmblem.colorCount; color++)
              _Choice(
                key: ValueKey('emblem-color-$color'),
                label: 'Colour ${color + 1}',
                selected: value.color == color,
                onTap: () =>
                    onChanged(GroupEmblem(icon: value.icon, color: color)),
                background: EmblemStyle.colors[color],
              ),
          ],
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.child,
    this.background,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label${selected ? ', selected' : ''}',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.radii.control),
          child: Container(
            // 48dp: the minimum comfortable touch target.
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: background ?? (selected ? tokens.accentTint : null),
              borderRadius: BorderRadius.circular(tokens.radii.control),
              border: Border.all(
                color: selected ? tokens.accent : tokens.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Center(
              child: selected && child == null
                  ? const Icon(
                      Icons.check,
                      size: 20,
                      color: EmblemStyle.onColor,
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}
