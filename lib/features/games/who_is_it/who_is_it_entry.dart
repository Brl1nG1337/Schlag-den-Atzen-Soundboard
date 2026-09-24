class WhoIsItEntry {
  const WhoIsItEntry({
    required this.id,
    required this.name,
    required this.imageAsset,
    this.hint,
    this.category,
  });

  factory WhoIsItEntry.fromJson(Map<String, Object?> json) {
    final hint = _optionalString(json, 'hint');
    final category = _optionalString(json, 'category');

    return WhoIsItEntry(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      imageAsset: _requiredString(json, 'imageAsset'),
      hint: hint,
      category: category,
    );
  }

  final String id;
  final String name;
  final String imageAsset;
  final String? hint;
  final String? category;

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('"$key" fehlt oder ist leer.');
    }
    return value.trim();
  }

  static String? _optionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('"$key" muss ein Text sein.');
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
