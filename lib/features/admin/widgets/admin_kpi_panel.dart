import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

class AdminKpiPanel extends StatelessWidget {
  const AdminKpiPanel({
    super.key,
    required this.label,
    required this.value,
    this.detail,
  });

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.adminDarkGreen,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.adminMintText)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          detail == null
              ? const SizedBox()
              : Text(
                  detail!,
                  style: const TextStyle(color: AppColors.adminMintLight),
                ),
        ],
      ),
    );
  }
}
