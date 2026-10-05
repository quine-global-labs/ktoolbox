class ToolboxContainer {
  final String id;
  final String name;
  final String image;
  final String status;

  const ToolboxContainer({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
  });

  bool get isRunning => status.toLowerCase().startsWith('up') || status.toLowerCase() == 'running';

  factory ToolboxContainer.fromPodmanJson(Map<String, dynamic> json) {
    final names = json['Names'] as List<dynamic>? ?? const [];
    return ToolboxContainer(
      id: (json['Id'] as String? ?? '').substring(0, 12),
      name: names.isNotEmpty ? names.first as String : 'unknown',
      image: json['Image'] as String? ?? 'unknown',
      status: json['Status'] as String? ?? 'unknown',
    );
  }
}
