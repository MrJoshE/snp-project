class SnpResponse {

  final bool success;

  final int status;

  final dynamic payload;

  const SnpResponse({
    required this.success, 
    required this.status, 
    this.payload
  });

  factory SnpResponse.fromJson(Map<String, dynamic> json){
    return SnpResponse(
      success: json['success'], 
      status: json['status'], 
      payload: json['payload']
      );
  }
 
}