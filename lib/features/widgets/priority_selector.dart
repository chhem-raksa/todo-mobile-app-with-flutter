import 'package:flutter/material.dart';
import '../models/task_enums.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildPriorityChip(
                label: 'Low',
                priority: TaskPriority.low,
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                icon: Icons.arrow_downward_rounded,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildPriorityChip(
                label: 'Medium',
                priority: TaskPriority.medium,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                icon: Icons.remove_rounded,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildPriorityChip(
                label: 'High',
                priority: TaskPriority.high,
                color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                icon: Icons.arrow_upward_rounded,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPriorityChip({
    required String label,
    required TaskPriority priority,
    required Color color,
    required IconData icon,
    required Color backgroundColor,
  }) {
    final isSelected = selectedPriority == priority;

    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[400], size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
