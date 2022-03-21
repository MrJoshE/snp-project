class SnpResponse {

  final bool success;

  final int status;

  final dynamic payload;

  const SnpResponse({
    required this.success, 
    required this.status, 
    this.payload
  });
 
}