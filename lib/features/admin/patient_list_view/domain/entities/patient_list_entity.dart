class PatientListEntity {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  const PatientListEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // Get initials from name
  String get initials {
    if (name.isEmpty) return 'PA';
    
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0].length >= 2 
          ? parts[0].substring(0, 2).toUpperCase()
          : parts[0].toUpperCase();
    }
    
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Format registration date
  String getFormattedDate() {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${days[createdAt.weekday % 7]}, ${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }
}
