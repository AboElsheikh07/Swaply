
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