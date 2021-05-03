import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

String formatTime(int milliseconds) {
  var secs = milliseconds ~/ 1000;
  var hours = (secs ~/ 3600).toString().padLeft(2, '0');
  var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
  var seconds = (secs % 60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}

TextEditingController _fileName = new TextEditingController();
AutovalidateMode validate = AutovalidateMode.onUserInteraction;

typedef _Fn = void Function();

class SimpleRecorder extends StatefulWidget {
  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  Stopwatch _stopwatch;
  Timer _timer;

  @override
  void initState() {
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    super.initState();
    _stopwatch = Stopwatch();
    _timer = new Timer.periodic(new Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    _mRecorder.closeAudioSession();
    _mRecorder = null;
    _timer.cancel();
    _fileName.clear();
    _stopwatch.reset();
    super.dispose();
  }

  InputDecoration kFieldDecoration = InputDecoration(
    labelText: '',
    labelStyle: TextStyle(
      fontFamily: 'Circular Std Book',
      fontSize: 15,
      color: Color(0XFF1F1F1F),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(15),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(15),
      ),
      borderSide: BorderSide(
        width: 1.5,
        color: Colors.deepOrange,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(15),
      ),
      borderSide: BorderSide(
        width: 1.5,
        color: Color(0XFFD70F0F),
      ),
    ),
  );

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
      var storage = await Permission.storage.request();
      if (storage != PermissionStatus.granted) {
        await Permission.storage.request();
      }
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  void record() async {
    try {
      bool hasPermissions = await Permission.microphone.isGranted &&
          await Permission.storage.isGranted;
      if (hasPermissions) {
        String path = _fileName.text;
        if (!_fileName.text.contains('/')) {
          var appDocDirectory = await getApplicationDocumentsDirectory();
          path = appDocDirectory.path + '/' + _fileName.text + '.aac';
        }
        await _mRecorder.startRecorder(toFile: path).then((value) {
          setState(() {});
        });
        handleStartStop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.indigoAccent,
            content: Text('Recording started'),
          ),
        );
        print(path);
      } else {
        await [
          Permission.microphone,
          Permission.storage,
        ].request();
      }
    } catch (e) {
      if (e.toString().substring(0, 44) ==
          'Exception: A file already exists at the path') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.indigoAccent,
            content: Text('File name already exists'),
          ),
        );
      }
    }
  }

  void stopRecorder() async {
    await _mRecorder.stopRecorder().then((value) {
      handleStartStop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.indigoAccent,
          content: Text('Recording has stopped'),
        ),
      );
      setState(() {
        // var url = value;
        _mplaybackReady = true;
        _fileName.clear();
        _stopwatch.reset();
      });
    });
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    _mPlayer.startPlayer(whenFinished: () {
      setState(() {});
    }).then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer.stopPlayer().then((value) {
      setState(() {});
    });
  }

  void pauseRecorder() async {
    await _mRecorder.pauseRecorder().then((value) {
      setState(() {});
    });
    handleStartStop();
  }

  void resumeRecorder() async {
    await _mRecorder.resumeRecorder().then((value) {
      setState(() {});
    });
    handleStartStop();
  }

  void toggleRecording() {
    if (_mRecorder.isRecording) {
      stopRecorder();
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Name Recording'),
          content: Container(
            child: TextFormField(
              keyboardType: TextInputType.text,
              controller: _fileName,
              autovalidateMode: validate,
              validator: (value) {
                return value.length < 1 ? "Please enter a filename" : null;
              },
              style: TextStyle(
                fontFamily: 'Circular Std Book',
                fontSize: 15,
                color: Color(0XFF1F1F1F),
              ),
              decoration: kFieldDecoration.copyWith(labelText: 'Filename'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                Navigator.pop(context);
                record();
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  void togglePausePlay() {
    if (_mRecorder.isRecording) {
      pauseRecorder();
    } else
      resumeRecorder();
  }

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped ? record : stopRecorder;
  }

  recording() {
    return _mRecorder.isStopped ? record : stopRecorder;
  }

  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped ? play : stopPlayer;
  }

  void handleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    setState(() {}); // re-render the page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Grp8 Recorder'),
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Center(
                    child: Container(
                      height: 120.0,
                      width: 250.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white38,
                      ),
                      child: Center(
                        child: Text(formatTime(_stopwatch.elapsedMilliseconds),
                            style: TextStyle(fontSize: 48.0)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        togglePausePlay();
                      },
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(360.0),
                          color: Colors.white38,
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              toggleRecording();
                            },
                            child: FaIcon(
                              _stopwatch.isRunning
                                  ? FontAwesomeIcons.stopCircle
                                  : FontAwesomeIcons.microphone,
                              color: _stopwatch.isRunning
                                  ? Colors.black
                                  : Colors.red,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        togglePausePlay();
                      },
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(360.0),
                          color: Colors.white38,
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              togglePausePlay();
                            },
                            child: FaIcon(
                              _stopwatch.isRunning
                                  ? FontAwesomeIcons.pause
                                  : FontAwesomeIcons.play,
                              color: _stopwatch.isRunning
                                  ? Colors.black
                                  : Colors.black,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
