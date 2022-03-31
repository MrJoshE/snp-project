import 'dart:io';

abstract class SnpServer {
  static List<String> validAuthTokens = [
    'josh',
  ];

  /// Method will be used to start the socket server and start listening for clients.
  Future initialize();

  /// Method will be used to handle the connection of a new socket client.
  void onConnect(Socket socket);

  /// Method will handle the socket server closing.
  void onClose();

  /// Method will any errors on the server.
  void onError();

  /// Method will handling disposing of the sever.
  void dispose();
}
