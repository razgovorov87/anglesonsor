import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class MeasuringPage extends StatefulWidget {
  const MeasuringPage({Key? key}) : super(key: key);

  @override
  _MeasuringPageState createState() => _MeasuringPageState();
}

class _MeasuringPageState extends State<MeasuringPage> {
  List? _pillars = [];
  final titleController = TextEditingController();

  bool _validate = false;
  bool isMeasuring = false;
  bool isSave = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
        ),
        title: Text(
          'Новая линия',
          style: GoogleFonts.cuprum(
            textStyle: TextStyle(color: Colors.black87),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 21),
                        blurRadius: 53,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Название линии',
                      errorText: _validate ? 'Обязательное поле' : null,
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      suffixIcon: Icon(Icons.edit),
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                    ),
                    child: ListView.builder(
                      itemCount: _pillars!.length,
                      itemBuilder: (context, int index) {
                        return MeasuringItem(
                          x: _pillars![index]['x'],
                          y: _pillars![index]['y'],
                          status: _pillars![index]['status'],
                          index: index,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Center(
                child: TextButton(
                  onPressed: () async {
                    if (await WiFiForIoTPlugin.isConnected() == false) {
                      _showToast(
                          context, 'Проверьте подключение к точке доступа');
                    } else {
                      setState(() {
                        isMeasuring = true;
                      });
                      _getData();
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        !isMeasuring ? 'Новый замер' : 'Ожидание данных...',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isSave = true;
          });
          _saveData();
        },
        child: !isSave
            ? Icon(Icons.save)
            : Container(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  void _getData() {
    Socket.connect('192.168.1.1', 5000).then((socket) {
      socket.listen((data) async {
        var result = utf8.decode(data);
        final parsedJson = json.decode(result);
        Position position = await Geolocator.getCurrentPosition();
        final tcpresult = {
          'id': _pillars!.length + 1,
          'x': parsedJson['X'],
          'y': parsedJson['Y'],
          'lng': position.longitude,
          'lat': position.latitude,
          'status':
              parsedJson['X'] >= 1 || parsedJson['Y'] >= 1 ? 'invalid' : 'valid'
        };

        setState(() {
          _pillars!.add(tcpresult);
          isMeasuring = false;
        });
      });
    });
  }

  void _saveData() async {
    if (titleController.text.isEmpty) {
      _showToast(context, 'Введите название');
      setState(() {
        titleController.text.isEmpty ? _validate = true : _validate = false;
        isSave = false;
      });
    } else if (_pillars!.length == 0) {
      _showToast(context, 'Проведите замеры');
      setState(() {
        isSave = false;
      });
    } else {
      if (await WiFiForIoTPlugin.getSSID() == 'ANGLE_SENSOR') {
        WiFiForIoTPlugin.disconnect();
      }

      final CollectionReference linesCollection =
          FirebaseFirestore.instance.collection('lines');
      linesCollection.add({
        'title': titleController.text,
        'pillars': _pillars,
        'createdAt': new DateTime.now(),
      });
      setState(() {
        isSave = false;
      });
      setState(() {
        _validate = false;
        titleController.text = '';
        _pillars = [];
        isSave = false;
      });
      _showToast(context, 'Линия успешно сохранена!');
    }
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text(text),
    ));
  }
}

class MeasuringItem extends StatelessWidget {
  double x;
  double y;
  int index;
  String status;

  MeasuringItem(
      {required this.x,
      required this.y,
      required this.status,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.zero,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                (index + 1).toString(),
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Откл. X: ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      x.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: -1 > x || x > 1 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Откл. Y: ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      y.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: -1 > y || y > 1 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Icon(
              status == 'invalid' ? Icons.warning : Icons.check,
              color: status == 'invalid' ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
