class SnpResponseValidationResponse {
  /// Whether the validation was successful
  final bool success;

  /// The error message
  final String? error;

  SnpResponseValidationResponse._({
    required this.success,
    this.error,
  });

  factory SnpResponseValidationResponse.success() => SnpResponseValidationResponse._(success: true);

  factory SnpResponseValidationResponse.failure(String property, String stage) => SnpResponseValidationResponse._(
        success: false,
        error: 'The following property caused the validation to fail: \t$property at stage: $stage check',
      );
}
