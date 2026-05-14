import 'package:flutter/material.dart';

class AdminPanelShell extends StatelessWidget {
  const AdminPanelShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.headerAction,
    this.expandChild = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? headerAction;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final titleStyle =
            (compact
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.titleLarge)!
                .copyWith(fontWeight: FontWeight.w800);

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(compact ? 18 : 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headerAction == null || !compact)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(title, style: titleStyle)),
                    if (headerAction != null) ...[
                      const SizedBox(width: 12),
                      headerAction!,
                    ],
                  ],
                )
              else ...[
                Text(title, style: titleStyle),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: headerAction!),
              ],
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              if (expandChild) Expanded(child: child) else child,
            ],
          ),
        );
      },
    );
  }
}
