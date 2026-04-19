import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class AdminPopupSelectorItem<T> {
  const AdminPopupSelectorItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? iconColor;
}

class AdminPopupSelector<T> extends StatefulWidget {
  const AdminPopupSelector({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width,
  });

  final T value;
  final List<AdminPopupSelectorItem<T>> items;
  final ValueChanged<T> onChanged;
  final double? width;

  @override
  State<AdminPopupSelector<T>> createState() => _AdminPopupSelectorState<T>();
}

class _AdminPopupSelectorState<T> extends State<AdminPopupSelector<T>> {
  final GlobalKey _triggerKey = GlobalKey();
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final selectedItem = _selectedItem;

    return SizedBox(
      width: widget.width,
      child: InkWell(
        key: _triggerKey,
        borderRadius: BorderRadius.circular(16),
        onTap: _openMenu,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isOpen ? AppTheme.accentBlue : const Color(0xFFD9E5F8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                if (selectedItem.icon != null) ...[
                  Icon(
                    selectedItem.icon,
                    size: 18,
                    color: selectedItem.iconColor ?? AppTheme.accentBlueDark,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    selectedItem.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentBlueDark,
                    ),
                  ),
                ),
                Icon(
                  _isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.accentBlueDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AdminPopupSelectorItem<T> get _selectedItem {
    for (final item in widget.items) {
      if (item.value == widget.value) {
        return item;
      }
    }

    return widget.items.first;
  }

  Future<void> _openMenu() async {
    final triggerContext = _triggerKey.currentContext;
    if (triggerContext == null) {
      return;
    }

    final triggerBox = triggerContext.findRenderObject() as RenderBox;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final triggerOffset = triggerBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );

    setState(() {
      _isOpen = true;
    });

    final selectedValue = await showMenu<T>(
      context: context,
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      constraints: BoxConstraints.tightFor(width: triggerBox.size.width),
      position: RelativeRect.fromLTRB(
        triggerOffset.dx,
        triggerOffset.dy + triggerBox.size.height + 6,
        overlayBox.size.width - triggerOffset.dx - triggerBox.size.width,
        overlayBox.size.height - triggerOffset.dy,
      ),
      items: widget.items
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: item.value == widget.value
                      ? const Color(0xFFEAF1FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 18,
                          color: item.value == widget.value
                              ? AppTheme.accentBlueDark
                              : item.iconColor ?? AppTheme.accentBlueDark,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: item.value == widget.value
                                ? AppTheme.accentBlueDark
                                : const Color(0xFF2F3950),
                            fontWeight: item.value == widget.value
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.value == widget.value)
                        const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppTheme.accentBlueDark,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );

    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }

    if (selectedValue != null) {
      widget.onChanged(selectedValue);
    }
  }
}
