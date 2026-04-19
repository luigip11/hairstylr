import 'package:flutter/material.dart';

const bookingAccentBlue = Color(0xFF355DDB);

class BookingChoicePill extends StatelessWidget {
  const BookingChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? bookingAccentBlue : const Color(0xFFF1F5FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? bookingAccentBlue : const Color(0xFFD9E3FF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? bookingAccentBlue : const Color(0xFF294190),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
