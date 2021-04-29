import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../utils/size_config.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Recordings extends StatefulWidget {
  static const String id = 'recordings_page';

  @override
  _RecordingsState createState() => _RecordingsState();
}

class _RecordingsState extends State<Recordings> {
  String directory;
  List files = [];

  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;

  @override
  void initState() {
    super.initState();
    _listFiles();
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    super.dispose();
  }

  void play(fileName) async {
    await _mPlayer.startPlayer(
        fromURI: fileName,
        codec: Codec.aacMP4,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer() async {
    if (_mPlayer != null) {
      await _mPlayer.stopPlayer();
    }
  }

  Future<String> _listFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = Directory("$directory/").listSync();
    });
  }

  void delete(String fileName) {
    final fileToDelete = Directory(fileName);
    fileToDelete.deleteSync(recursive: true);
    _listFiles();
    recordings();
  }

  List<Widget> recordings() {
    List<Widget> allRecordings = [
      Container(),
    ];
    try {
      if (files == []) {
        return allRecordings;
      }
      for (var item in files.reversed) {
        String fileName = item.toString().split("'")[1];
        if (item.toString().substring(0, 4) == 'File' &&
            (fileName.substring(fileName.length - 3) == 'aac' ||
                fileName.substring(fileName.length - 3) == 'wav')) {
          allRecordings.add(
            Container(
              width: SizeConfig.screenWidth,
              height: 55,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0XFF1F1F1F),
                    width: 1,
                  ),
                ),
                color: Color(0XFFFFFFFF),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: SizeConfig.screenWidth - 175,
                      child: Text(
                        fileName.split('/').last,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Circular Std Book',
                          fontSize: 16,
                          color: Color(0XFF1F1F1F),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.play_arrow,
                          ),
                          onPressed: () {
                            play(fileName);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: () {
                            stopPlayer();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                          ),
                          onPressed: () {
                            delete(fileName);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
    }
    return allRecordings;
  }

  Future refresh() async {
    _listFiles();
    recordings();
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0XFFFFFFFF),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.centerRight,
                colors: [Colors.redAccent, Colors.indigo],
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                children: recordings(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
