class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  String get firstName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!.split(' ').first;
    }
    return email.split('@').first;
  }
}
