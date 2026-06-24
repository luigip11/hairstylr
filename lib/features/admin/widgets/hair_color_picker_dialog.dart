import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../data/hair_color_option.dart';
import '../data/majirel_hair_colors.dart';
import '../data/other_hair_colors.dart';
import 'admin_popup_selector.dart';

class HairColorPickerDialog extends StatefulWidget {
  const HairColorPickerDialog({
    super.key,
    required this.initialCompany,
    required this.initialColorCode,
  });

  final String initialCompany;
  final String initialColorCode;

  @override
  State<HairColorPickerDialog> createState() => _HairColorPickerDialogState();
}

class _HairColorPickerDialogState extends State<HairColorPickerDialog> {
  late String _company;
  HairColorOption? _selectedColor;

  @override
  void initState() {
    super.initState();
    _company = _colorCompanies.contains(widget.initialCompany)
        ? widget.initialCompany
        : 'Majirel';
    _selectedColor = _colorsForCompany(_company)
        .cast<HairColorOption?>()
        .firstWhere(
          (color) => color?.fullName == widget.initialColorCode,
          orElse: () => null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForCompany(_company);
    final categories = <String, List<HairColorOption>>{};
    for (final color in colors) {
      categories.putIfAbsent(color.category, () => []).add(color);
    }

    return AlertDialog(
      backgroundColor: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: const Text(
        'Palette colori',
        style: TextStyle(
          color: AppColors.bookingDeepBlue,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminPopupSelector<String>(
                value: _company,
                items: _colorCompanies
                    .map(
                      (company) => AdminPopupSelectorItem<String>(
                        value: company,
                        label: company,
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _company = value;
                    _selectedColor = null;
                  });
                },
              ),
              const SizedBox(height: 18),
              const _HairColorLegend(),
              const SizedBox(height: 18),
              ...categories.entries.map(
                (entry) => _HairColorCategorySection(
                  title: entry.key,
                  colors: entry.value,
                  selectedColor: _selectedColor,
                  onSelected: (color) {
                    setState(() {
                      _selectedColor = _selectedColor == color ? null : color;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _selectedColor == null
              ? null
              : () => Navigator.of(context).pop(_selectedColor),
          child: const Text('Salva'),
        ),
      ],
    );
  }

  List<HairColorOption> _colorsForCompany(String company) {
    if (company == 'Altro') {
      return otherHairColors;
    }
    return majirelHairColors;
  }
}

const _colorCompanies = ['Majirel', 'Altro'];

class _HairColorLegend extends StatelessWidget {
  const _HairColorLegend();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4, right: 4, bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'LEGENDA: ', style: _labelStyle),
            TextSpan(text: 'Colori - Codici - Anteprima colore'),
          ],
        ),
        style: TextStyle(
          color: AppColors.textGreyBlue,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    color: AppColors.bookingDeepBlue,
    fontWeight: FontWeight.w900,
  );
}

class _HairColorCategorySection extends StatelessWidget {
  const _HairColorCategorySection({
    required this.title,
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  final String title;
  final List<HairColorOption> colors;
  final HairColorOption? selectedColor;
  final ValueChanged<HairColorOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.bookingDeepBlue,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth < 560
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors
                    .map(
                      (color) => SizedBox(
                        width: cardWidth,
                        child: _HairColorOptionCard(
                          color: color,
                          selected: color == selectedColor,
                          onTap: () => onSelected(color),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HairColorOptionCard extends StatelessWidget {
  const _HairColorOptionCard({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final HairColorOption color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.softBlueTint : Colors.white,
          border: Border.all(
            color: selected
                ? AppColors.bookingDeepBlue
                : AppColors.borderBlueSoft,
            width: selected ? 1.8 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.previewColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.previewColor.withValues(alpha: 0.32),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: Text(
                color.code,
                style: const TextStyle(
                  color: AppColors.bookingDeepBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: Text(
                color.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSlate,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.bookingDeepBlue,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
