import 'package:equatable/equatable.dart';

class SnpResponsePayload extends Equatable {
  final Map<String, dynamic> content;

  const SnpResponsePayload({required this.content});

  Map<String, dynamic> toJson() => {"content": content};
  factory SnpResponsePayload.fromJson(Map<String, dynamic> json) => SnpResponsePayload(
        content: json,
      );

  @override
  List<Object?> get props => [content];
}
