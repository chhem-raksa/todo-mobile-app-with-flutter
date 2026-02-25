// lib/widgets/date_time_selector.dart
import 'package:flutter/material.dart';
class DateTimeSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final Color color;

  const DateTimeSelector({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildButton(
                context,
                label: selectedDate != null
                    ? _formatDate(selectedDate!)
                    : 'Pick date',
                icon: Icons.calendar_today_outlined,
                onTap: onPickDate,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildButton(
                context,
                label: selectedTime != null
                    ? selectedTime!.format(context)
                    : 'Pick time',
                icon: Icons.access_time_outlined,
                onTap: onPickTime,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
