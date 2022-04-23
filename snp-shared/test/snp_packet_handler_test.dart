// import 'package:snp_shared/handlers/snp_packet_handler.dart';
// import 'package:snp_shared/snp_shared.dart';
// import 'package:test/test.dart';

// void main() {
//   group('[SnpPacketHandler]', () {
//     test('Can convert a response into packets', () {
//       final response = SnpResponse(
//         success: true,
//         status: 201,
//         payload: SnpSuccessPayload(
//           response: 'this is a payload',
//           requests: 10,
//         ),
//       );

//       final packets = SnpPacketHandler.convertResponseToPackets(response);
//       final bytes = SnpPacketHandler.getBytesFromPacketList(packets);

//       // ---- SEND PACKETS ----

//       // ---- RECEIVED PACKETS ----
//       final packetList = SnpPacketHandler.getPacketListFromBytes(bytes);
//       final actualResponse = SnpPacketHandler.getResponseFromPacketList(packetList);

//       expect(response, actualResponse);
//     });

//     test('Can convert a request into packets', () {
//       final request = SnpRequest.create(type: "AUTH", body: {
//         "token": 'josh',
//       });

//       final packets = SnpPacketHandler.convertRequestToPackets(request);
//       final bytes = SnpPacketHandler.getBytesFromPacketList(packets);

//       // ---- SEND PACKETS ----

//       // ---- RECEIVED PACKETS ----

//       final packetList = SnpPacketHandler.getPacketListFromBytes(bytes);
//       final actualRequest = SnpPacketHandler.getRequestFromPacketList(packetList);

//       expect(request, actualRequest);
//     });
//   });
// }
