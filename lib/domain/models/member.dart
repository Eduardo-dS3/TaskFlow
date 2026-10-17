/// Pessoa do time (ou usuário logado).
class Member {
  const Member({required this.id, required this.name, required this.role});

  final String id;
  final String name;
  final String role;

  /// Iniciais exibidas no avatar (ex.: "Mariana Souza" -> "MS").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 2).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  bool operator ==(Object other) => other is Member && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
