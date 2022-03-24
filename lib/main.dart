import 'dart:async';
import 'dart:core';
import 'dart:core';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:converter/converter.dart';
import 'package:hex/hex.dart';
import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udp/udp.dart';
import 'package:udptest3/hex.dart';

import 'easy_udp_socket_base.dart';

void main() {
  runApp(const MyApp());
  start_broadcast_client(65535);
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: CupertinoButton(
              child: const Icon(
                CupertinoIcons.add,
                semanticLabel: "온",
              ),
              onPressed: () async {
                print('프린트');
                print('send');
                var socket = await RawDatagramSocket.bind('0.0.0.0', 65535);
                var b = hexStringToByteArray('FA1111010124FB');
                List<int> dataToSend = b; // 혹시해서 추가 지워도 상관 없음
                List<int> dataToSen = Uint8List(32);
                var bc = Uint8List(12); // 혹시해서 추가 지워도 상관 없음
                int sendre = socket.send(
                    dataToSend, InternetAddress("192.168.0.10"), 65535);
                // ignore: unused_local_variable
                StreamSubscription socketListen;
                socketListen = socket.listen((RawSocketEvent evt) {
                  // ignore: deprecated_member_use
                  if (evt == RawSocketEvent.read) {
                    Datagram packet = socket.receive();
                    print('Received NTP packet: ${packet != null}');
                    print('Received NTP packet: $sendre');
                    print('Received NTP packet: ${packet.data}');
                  }
                });

                socket.close();
                print('end');
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: CupertinoButton(
              child: const Icon(
                CupertinoIcons.add,
                semanticLabel: "off",
              ),
              onPressed: () async {
                print('프린트');
                print('send');

                var socket = await RawDatagramSocket.bind('0.0.0.0', 65535);
                var b = hexStringToByteArray('FA1111010023FB');
                socket.send(b, InternetAddress("192.168.0.10"), 65535);

                var bc = Uint8List(12);
                socket.listen((event) => {bc});

                socket.close();
                print(bc);
                print('end');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Util {
  static List<int> convertInt2Bytes(value, Endian order, int bytesSize) {
    try {
      final kMaxBytes = 16;
      var bytes = Uint8List(kMaxBytes)
        ..buffer.asByteData().setInt64(0, value, order);
      List<int> intArray;
      if (order == Endian.big) {
        intArray = bytes.sublist(kMaxBytes - bytesSize, kMaxBytes).toList();
      } else {
        intArray = bytes.sublist(0, bytesSize).toList();
      }
      return intArray;
    } catch (e) {
      print('util convert error: $e');
    }
    return null;
  }
}

int digitHex(String hex) {
  int char = hex.codeUnitAt(0);
  if (char >= '0'.codeUnitAt(0) && char <= '9'.codeUnitAt(0) ||
      char >= 'A'.codeUnitAt(0) && char <= 'F'.codeUnitAt(0)) {
    return int.parse(hex, radix: 16);
  } else {
    return -1;
  }
}

Uint8List hexStringToByteArray(String input) {
  String cleanInput = input;

  int len = cleanInput.length;

  if (len == 0) {
    return Uint8List(0);
  }
  Uint8List data;
  int startIdx;
  if (len % 2 != 0) {
    data = Uint8List((len ~/ 2) + 1);
    data[0] = digitHex(cleanInput[0]);
    startIdx = 1;
  } else {
    data = Uint8List((len ~/ 2));
    startIdx = 0;
  }

  for (int i = startIdx; i < len; i += 2) {
    data[(i + 1) ~/ 2] =
        (digitHex(cleanInput[i]) << 4) + digitHex(cleanInput[i + 1]);
  }
  return data;
}

start_broadcast_client(int port) async {
  // 무한으로 receive 받을 수 있을 거 같다.
  final socket = await EasyUDPSocket.bindBroadcast(port);
  var data = hexStringToByteArray("FA110112FB"); // 상태 데이터 코드
  while (true) {
    if (socket != null) {
      socket.send(data, '192.168.0.10', port);
      final resp = await socket.receive();
      print('Client $port received: ${resp.data}');

//////////////////////////////// 바이트를 헥사로 변경 ////////////////

      sleep(const Duration(
          seconds: 3)); // 자바에서 thread.sleep(1000) 과 같은 역할 시간 딜레이주는 것.
      List<int> cd = resp.data;
      var abcd = resp.data;
      var a = abcd.toString();

      // var aa = hex.decode(a);

      // print(aa);

      // print('ee = $ee');
      var av = a.split(', ');
      print('abcd = $abcd');
      print('av.split = $av');
      var ww = hex.encode(resp.data);
      print('ww = $ww');

      // print(hex.encode(asd));
      print(ww.toUpperCase());
      String www = ww.toUpperCase();
      print(www.split(''));
      var g = www.indexOf("FB");
      String resu = www.substring(0, g + 2);
      print(resu);
      convert(cd);
      // `close` method of EasyUDPSocket is awaitable.
      // await socket.close();
      print('Client $port closed');
    }
    print('while 종료');
  }
}

// String byte2hex(Uint8List a) {
//   var sb = a;
//   for (var b in a) {sb.append(String.format()  .fromCharCodes(sb); ("%02X ", b & 0xFF));
//   String ca = sb.toString();
//   int g = ca.indexOf("FB"); // fa 부터 fb 까지만 출력하는 변수
//   String resu = ca.substring(0, g + 2); // fa 부터 fb 까지만 출력하는 변수

//   return resu;
//   }
// }

// 실패
//  var bc = Uint8List(32);
//                 var receiver =
//                     await UDP.bind(Endpoint.loopback(port: Port(65535)));
//                 // receiving\listening
//                 socket.listen(
//                   (datagram) {
//                     var str = String.fromCharCodes(bc);
//                     stdout.write(str);
//                     var aaa = stdout.write(str);
//                     print('str=$str');

//                     print(bc);
//                   },
//                 );
//                 var des = socket.listen.toString();
//                 print('des== $des');

// Datagram re = socket.receive(dataToSen, dataToSen.length);
//                 if (re != null) {
//                   print(re.data);
//                 } else {
//                   print('안된다.');
//                 }
//                 print(dataToSen);
//                 print(dataToSend);
