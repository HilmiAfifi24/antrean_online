class DoctorEntity {
  final String id;
  final String name;
  final String specialization;
  final String phone;
  final String email;
  final bool isActive;

  DoctorEntity({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    required this.email,
    required this.isActive,
  });

  // Get initials for avatar
  String get initials {
    if (name.isEmpty) return 'DR';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    
    // If single name or invalid split, take first 2 characters
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    
    // If name only has 1 character
    return name[0].toUpperCase();
  }

  // Get display specialization
  String get displaySpecialization {
    return specialization.isEmpty ? 'Dokter Umum' : specialization;
  }
}
