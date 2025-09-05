abstract class AdminRepository {
  Future<Map<String, int>> getDashboardStats();
  Future<List<Map<String, dynamic>>> getRecentActivities();
  Future<void> logActivity({
    required String title,
    required String subtitle,
    required String type,
  });
}