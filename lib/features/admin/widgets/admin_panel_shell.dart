import 'package:flutter/material.dart';

class AdminPanelShell extends StatelessWidget {
  const AdminPanelShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.headerAction,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
              if (headerAction != null) ...[
                const SizedBox(width: 12),
                headerAction!,
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
