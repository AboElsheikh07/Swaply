
const durations = [
  _DurationOption('30 min', 30),
  _DurationOption('45 min', 45),
  _DurationOption('1 hr', 60),
  _DurationOption('1.5 hr', 90),
];

const times = [
  '9:00 AM',
  '10:30 AM',
  '1:00 PM',
  '2:30 PM',
  '4:00 PM',
  '5:30 PM',
  '7:00 PM',
];

class _DurationOption {
  final String label;
  final int value;
  const _DurationOption(this.label, this.value);
}

class DayOption {
  final DateTime date;
  DayOption({required this.date});

  String get dow {  //day on week
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
List<int> parseTime(String time) {
  final parts = time.split(':');
  int hour = int.parse(parts[0]);
  final minuteParts = parts[1].split(' ');
  final minute = int.parse(minuteParts[0]);
  final period = minuteParts[1]; // AM or PM

  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  return [hour, minute];
}