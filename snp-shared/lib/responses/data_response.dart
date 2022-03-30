class DataResponse<T> {

  final bool isSuccessful;

  final T? content;

  final String? failure;

  const DataResponse({
    required this.isSuccessful,
    required this.content,
    required this.failure,
  });


  factory DataResponse.success(T content){
    return DataResponse<T>(
      isSuccessful: true,
      content: content,
      failure: null,
    );
  }

  factory DataResponse.failure(String failure){
    return DataResponse(
      isSuccessful: false,
      content: null,
      failure: null,
    );
  }
}