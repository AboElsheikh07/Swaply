class NotifPrefModel {
  final String id;
  final String label;
  final String description;
  final bool defaultVal;

  const NotifPrefModel({
    required this.id,
    required this.label,
    required this.description,
    required this.defaultVal,
  });

  factory NotifPrefModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotifPrefModel(
      id: id,
      label: data['label'] ?? '',
      description: data['description'] ?? '',
      defaultVal: data['enabled'] ?? false,
    );
  }
}

class NotifChannelModel {
  final String id;
  final String label;
  final List<NotifPrefModel> prefs;

  const NotifChannelModel({
    required this.id,
    required this.label,
    required this.prefs,
  });
}
