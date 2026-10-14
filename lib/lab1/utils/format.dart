const _months = [
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

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatHourMinute(int hour, int minute) =>
    '${_two(hour)}:${_two(minute)}';

String formatTime(DateTime d) => formatHourMinute(d.hour, d.minute);

String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  return '${d.inHours}h ${_two(d.inMinutes % 60)}m';
}
