import 'package:snp_shared/snp_shared.dart';

class SnpResponseBuffer {
  final List<SnpResponse> _content;

  List<SnpResponse> get content => _content;

  int get size => _content.length;

  SnpResponse? get last => size == 0 ? null : _content[size - 1];

  SnpResponseBuffer() : _content = [];

  bool hasReceivedError() {
    try {
      _content.firstWhere((element) => element.success == false);
      return true;
    } catch (_) {
      return false;
    }
  }

  add(SnpResponse response) {
    /// We dont want the buffer to be larger than 2 responses
    if (_content.length >= 2) {
      throw ('Should only ever be 2 responses in the buffer max - ACK, Response');
    }

    /// If the buffer is empty we should be receiving an ACK or an error
    if (_content.isEmpty && response.status == 201) {
      throw ('Received a normal response instead of ACK. What the ACK???');
    }

    /// If the response is an ACK or an error or the buffer is not empty then
    /// add the response to the buffer.
    _content.add(response);
  }
}
