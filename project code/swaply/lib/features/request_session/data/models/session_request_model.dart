class SessionRequestModel {
  final String mentorId;
  final String skill;
  final String date;
  final String time;
  final int durationMinutes;
  final String? message;
  final int totalCost;

  const SessionRequestModel({
    required this.mentorId,
    required this.skill,
    required this.date,
    required this.time,
    required this.durationMinutes,
    this.message,
    required this.totalCost,
  });

  Map<String, dynamic> toFirestore() => {
    'mentorId': mentorId,
    'skill': skill,
    'date': date,
    'time': time,
    'durationMinutes': durationMinutes,
    'message': message,
    'totalCost': totalCost,
    'status': 'pending',
  };
}

class DurationOption {
  final String label;
  final int value;
  const DurationOption({required this.label, required this.value});
}

const durationOptions = [
  DurationOption(label: '30 min', value: 30),
  DurationOption(label: '45 min', value: 45),
  DurationOption(label: '1 hr',   value: 60),
  DurationOption(label: '1.5 hr', value: 90),
];

const availableTimes = [
  '9:00 AM', '10:30 AM', '1:00 PM',
  '2:30 PM', '4:00 PM',  '5:30 PM', '7:00 PM',
];
