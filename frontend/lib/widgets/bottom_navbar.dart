import 'package:flutter/material.dart';
import 'package:frontend/model/selected_index_model.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final selectedIndexProvider = Provider.of<SelectedIndexModel>(context);
    final selectedIndex = selectedIndexProvider.selectedIndex;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      iconSize: 26,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.map_outlined,
          ),
          label: '지도',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.coffee_outlined,
          ),
          activeIcon: Icon(
            Icons.coffee_rounded,
          ),
          label: '커피챗',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.forum_outlined,
          ),
          label: '채팅',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person_outlined,
          ),
          label: 'MY',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (index) {
        selectedIndexProvider.selectedIndex = index; // selectedIndex 갱신
      },
      showSelectedLabels: false,
      showUnselectedLabels: false,
      unselectedItemColor: Colors.black,
      selectedItemColor: const Color(0xffff6c3e),
    );
  }
}
