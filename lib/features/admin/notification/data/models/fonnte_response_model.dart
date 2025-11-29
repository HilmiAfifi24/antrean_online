class FonnteResponseModel {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  FonnteResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory FonnteResponseModel.fromJson(Map<String, dynamic> json) {
    return FonnteResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? json['reason'] as String? ?? 'Unknown error',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
