import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime initialMonth;
  final DateTime? selected;
  final Set<DateTime> bookedDates;
  final ValueChanged<DateTime> onSelect;
  const CalendarWidget({
    super.key,
    required this.initialMonth,
    required this.onSelect,
    this.selected,
    this.bookedDates = const {},
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _month;
  static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7; // Sun=0
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final today = _stripTime(DateTime.now());
    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) cells.add(const SizedBox.shrink());
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      final isSel = widget.selected != null && _stripTime(widget.selected!) == date;
      final isBooked = widget.bookedDates.contains(date);
      final isPast = date.isBefore(today);
      cells.add(
        GestureDetector(
          onTap: isPast ? null : () => widget.onSelect(date),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSel
                  ? AppTheme.primaryBlue
                  : isBooked
                      ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '$d',
              style: TextStyle(
                color: isSel
                    ? Colors.white
                    : isPast
                        ? AppTheme.textMuted.withValues(alpha: 0.5)
                        : AppTheme.textDark,
                fontWeight: isSel || isBooked ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Text('${_monthNames[_month.month - 1]} ${_month.year}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
                IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
              ],
            ),
            Row(
              children: _labels
                  .map((l) => Expanded(
                        child: Center(
                          child: Text(l, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: cells,
            ),
          ],
        ),
      ),
    );
  }
}
