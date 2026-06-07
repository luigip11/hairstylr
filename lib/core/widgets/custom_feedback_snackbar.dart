import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum CustomFeedbackSnackbarVariant { info, success, error }

class CustomFeedbackSnackbar extends StatelessWidget {
  const CustomFeedbackSnackbar({
    super.key,
    required this.message,
    required this.variant,
  });

  final String message;
  final CustomFeedbackSnackbarVariant variant;

  static void show(
    BuildContext context, {
    required String message,
    required CustomFeedbackSnackbarVariant variant,
  }) {
    final style = _styleFor(variant);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          backgroundColor: style.backgroundColor,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          padding: EdgeInsets.zero,
          content: CustomFeedbackSnackbar(message: message, variant: variant),
        ),
      );
  }

  static void showGlobal({
    required String message,
    required CustomFeedbackSnackbarVariant variant,
  }) {
    final style = _styleFor(variant);
    Get.closeCurrentSnackbar();
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: style.backgroundColor,
        boxShadows: const [],
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        padding: EdgeInsets.zero,
        borderRadius: 18,
        messageText: CustomFeedbackSnackbar(message: message, variant: variant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(variant);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
        child: Row(
          children: [
            IconButton.filled(
              tooltip: style.tooltip,
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: style.iconBackgroundColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(40, 40),
              ),
              icon: Icon(style.icon, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: style.foregroundColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _CustomFeedbackSnackbarStyle _styleFor(
    CustomFeedbackSnackbarVariant variant,
  ) {
    return switch (variant) {
      CustomFeedbackSnackbarVariant.info => const _CustomFeedbackSnackbarStyle(
        icon: Icons.info_outline_rounded,
        tooltip: 'Informazione',
        backgroundColor: Color(0xFFEAF1FF),
        borderColor: Color(0xFFB9C9F7),
        foregroundColor: Color(0xFF1A2850),
        iconBackgroundColor: Color(0xFF355DDB),
      ),
      CustomFeedbackSnackbarVariant.success =>
        const _CustomFeedbackSnackbarStyle(
          icon: Icons.info_outline_rounded,
          tooltip: 'Conferma',
          backgroundColor: Color(0xFFE8F7EF),
          borderColor: Color(0xFF9ED8B6),
          foregroundColor: Color(0xFF17462A),
          iconBackgroundColor: Color(0xFF238551),
        ),
      CustomFeedbackSnackbarVariant.error => const _CustomFeedbackSnackbarStyle(
        icon: Icons.warning_amber_rounded,
        tooltip: 'Errore',
        backgroundColor: Color(0xFFFFE7E7),
        borderColor: Color(0xFFF0A7A7),
        foregroundColor: Color(0xFF6D1F1F),
        iconBackgroundColor: Color(0xFFB33535),
      ),
    };
  }
}

class _CustomFeedbackSnackbarStyle {
  const _CustomFeedbackSnackbarStyle({
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.iconBackgroundColor,
  });

  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color iconBackgroundColor;
}
