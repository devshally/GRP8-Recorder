// Container(
// margin: const EdgeInsets.all(3),
// padding: const EdgeInsets.all(3),
// height: 80,
// width: double.infinity,
// alignment: Alignment.center,
// decoration: BoxDecoration(
// color: Color(0xFFFAF0E6),
// border: Border.all(
// color: Colors.indigo,
// width: 3,
// ),
// ),
// child: Row(children: [
// ElevatedButton(
// onPressed: getRecorderFn(),
// //color: Colors.white,
// //disabledColor: Colors.grey,
// child: Text(_mRecorder.isRecording ? 'Stop' : 'Record'),
// ),
// SizedBox(
// width: 20,
// ),
// Text(_mRecorder.isRecording
// ? 'Recording in progress'
//     : 'Recorder is stopped'),
// ]),
// ),
// Container(
// margin: const EdgeInsets.all(3),
// padding: const EdgeInsets.all(3),
// height: 80,
// width: double.infinity,
// alignment: Alignment.center,
// decoration: BoxDecoration(
// color: Color(0xFFFAF0E6),
// border: Border.all(
// color: Colors.indigo,
// width: 3,
// ),
// ),
// child: Row(children: [
// ElevatedButton(
// onPressed: getPlaybackFn(),
// //color: Colors.white,
// //disabledColor: Colors.grey,
// child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
// ),
// SizedBox(
// width: 20,
// ),
// Text(_mPlayer.isPlaying
// ? 'Playback in progress'
//     : 'Player is stopped'),
// ]),
// ),
// ],