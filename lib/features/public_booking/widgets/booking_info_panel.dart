import 'package:flutter/material.dart';

import 'booking_section_shell.dart';

class BookingInfoPanel extends StatelessWidget {
  const BookingInfoPanel({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return BookingSectionShell(
      title: title,
      subtitle: body,
      child: const SizedBox.shrink(),
    );
  }
}
