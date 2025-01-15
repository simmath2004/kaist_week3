import 'package:flutter/material.dart';
import 'letter_open_screen.dart';
import 'custom_icon_button.dart';
import 'tab1.dart';
import 'tab2.dart';
import 'tab3.dart';
import 'tab4.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Tab1(),
    Tab2(),
    Tab3(),
    Tab4(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _iconColor(int index) {
    return _selectedIndex == index
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 76, 74, 74);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 110,
        child: BottomAppBar(
          color: Color(0xFF100014),
          shape: CircularOuterNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjusted alignment
            children: <Widget>[
              CustomIconButton(
                  iconPath: 'assets/images/icon1.png',
                  label: 'Home',
                  color: _iconColor(0),
                  onPressed: () => _onItemTapped(0)),
              CustomIconButton(
                  iconPath: 'assets/images/icon2.png',
                  label: 'Letter',
                  color: _iconColor(1),
                  onPressed: () => _onItemTapped(1)),
              CustomIconButton(
                  iconPath: 'assets/images/icon3.png',
                  label: 'Voice',
                  color: _iconColor(2),
                  onPressed: () => _onItemTapped(2)),
              CustomIconButton(
                  iconPath: 'assets/images/icon4.png',
                  label: 'My page',
                  color: _iconColor(3),
                  onPressed: () => _onItemTapped(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularOuterNotchedRectangle extends NotchedShape {
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null) {
      return Path()..addRect(host);
    }

    // Distance to the center of the floating action button
    double notchRadius = guest.width / 2;

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(guest.center.dx - notchRadius, host.top)
      ..arcToPoint(
        Offset(guest.center.dx + notchRadius, host.top),
        radius: Radius.circular(notchRadius),
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}
