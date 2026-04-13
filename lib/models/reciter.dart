class Reciter {
  final String id; // The folder name on EveryAyah server
  final String name; // Readable name
  final String bitrate; // Audio quality
  final String? style; // Murattal, Mujawwad, etc.

  Reciter({
    required this.id,
    required this.name,
    this.bitrate = "128kbps",
    this.style,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'] as String,
      name: json['name'] as String,
      bitrate: json['bitrate'] as String? ?? "128kbps",
      style: json['style'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bitrate': bitrate,
    'style': style,
  };
}

