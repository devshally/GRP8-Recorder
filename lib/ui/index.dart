import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'bottom_nav/record.dart';
import 'bottom_nav/recordings.dart';

class Index extends StatefulWidget {
  static const String id = 'index_page';

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int currentIndex = 0;

  final List<Widget> _children = [
    SimpleRecorder(),
    Recordings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFFFFFF),
      body: _children[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Lora',
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Lora',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        selectedItemColor: Color(0XFFFFFFFF),
        unselectedItemColor: Color(0XFFCCCCCC),
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.mic_none,
              size: 30,
            ),
            activeIcon: Icon(
              Icons.mic,
              size: 30,
            ),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              size: 30,
            ),
            label: 'Recordings',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (!mounted) return;
    setState(() {
      currentIndex = index;
    });
  }
}
