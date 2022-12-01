import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_esp32/set/style.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

late DatabaseReference _getref;

class ChatPage3 extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage3({required this.server});

  @override
  _ChatPage3 createState() => new _ChatPage3();
}

class _Message {
  int whom;
  var text;

  _Message(this.whom, this.text);
}

class _ChatPage3 extends State<ChatPage3> {
  String t = "";
  String h = "";
  var temp;
  TextEditingController _p1 = TextEditingController();
  TextEditingController _p2 = TextEditingController();
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  void clear() {
    t = "";
    h = "";
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
          backgroundColor: Colors.black87,
          title: (isConnecting
              ? Text('正在嘗試連接至 ' + serverName + '...')
              : isConnected
                  ? Text(serverName + '連接中 ')
                  : Text('已斷線 '))),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: [
                        Text("溫度:$t", style: TextStyle(fontSize: 20)),
                        Text("濕度:$h", style: TextStyle(fontSize: 20)),
                        ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black87),
                              fixedSize:
                                  MaterialStateProperty.all(Size(120, 20))),
                          onPressed: () async {
                            if (isConnected) {
                              Firebase.initializeApp();
                              _getref = FirebaseDatabase.instance
                                  .ref("data")
                                  .child("Temperature");
                              temp = await _getref.once();
                              t = temp.snapshot.value.toString();
                              _getref = FirebaseDatabase.instance
                                  .ref("data")
                                  .child("Humidity");
                              temp = await _getref.once();
                              h = temp.snapshot.value.toString();
                              Future.delayed(Duration(milliseconds: 1000), () {
                                setState(() {
                                  t = "";
                                  h = "";
                                  print("test");
                                });
                              });
                              setState(() {});
                            }
                          },
                          child: Text("查詢溫濕度"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 160,
                              child: reusableTextField("輸入客廳溫度", false, _p1),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(35))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black87),
                                  fixedSize:
                                      MaterialStateProperty.all(Size(30, 40))),
                              onPressed: isConnected
                                  ? () {
                                      if (_p1.text != "")
                                        _sendMessage('n211${_p1.text}p');
                                    }
                                  : null,
                              child: Icon(Icons.arrow_forward),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black87),
                                  fixedSize:
                                      MaterialStateProperty.all(Size(105, 40))),
                              onPressed: isConnected
                                  ? () => ({_sendMessage('n221p')})
                                  : null,
                              child: Text('開關',
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.white)),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black87),
                                  fixedSize:
                                      MaterialStateProperty.all(Size(105, 40))),
                              onPressed: isConnected
                                  ? () {
                                      _sendMessage('n231p');
                                    }
                                  : null,
                              child: Text('除溼',
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 160,
                              child: reusableTextField("輸入臥室溫度", false, _p2),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(35))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black87),
                                  fixedSize:
                                      MaterialStateProperty.all(Size(30, 40))),
                              onPressed: isConnected
                                  ? () => _sendMessage('n212${_p2.text}p')
                                  : null,
                              child: Icon(Icons.arrow_forward),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black87),
                                  fixedSize:
                                      MaterialStateProperty.all(Size(105, 40))),
                              onPressed: isConnected
                                  ? () => _sendMessage('n222p')
                                  : null,
                              child: Text('開關',
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.white)),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black87),
                                  fixedSize:
                                      MaterialStateProperty.all(Size(105, 40))),
                              onPressed: isConnected
                                  ? () => _sendMessage('n232p')
                                  : null,
                              child: Text('除溼',
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
