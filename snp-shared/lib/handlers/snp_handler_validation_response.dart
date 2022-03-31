class SnpHandlerValidationResponse {
  /// Whether the validation was successful
  final bool success;

  /// The error message
  final String? error;

  final String? stage;

  final String? property;

  SnpHandlerValidationResponse._({
    required this.success,
    this.error,
    this.stage,
    this.property,
  });

  factory SnpHandlerValidationResponse.success() => SnpHandlerValidationResponse._(success: true);

  factory SnpHandlerValidationResponse.failure(String property, String stage) => SnpHandlerValidationResponse._(
        success: false,
        stage: stage,
        property: property,
        error: 'The following property caused the validation to fail: \t$property at stage: $stage check',
      );
}
