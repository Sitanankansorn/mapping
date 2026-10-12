import 'package:flutter/material.dart';
import '../models/bangkok_places.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'explore_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

/// Shell hosting the bottom NavigationBar and swapping between Thailand tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0; // 0: Map, 1: Explore, 2: Saved, 3: Dashboard, 4: Profile
  BangkokPlace? _selectedPlaceForMap;

  void _switchTab(int i) {
    setState(() => _index = i);
  }

  void _openPlaceOnMap(BangkokPlace place) {
    setState(() {
      _selectedPlaceForMap = place;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      MapScreen(
        key: _selectedPlaceForMap != null
            ? ValueKey(_selectedPlaceForMap!.id)
            : null,
        initialSelectedPlace: _selectedPlaceForMap,
      ),
      ExploreScreen(onPlaceSelected: _openPlaceOnMap),
      SavedScreen(onSelectPlaceOnMap: _openPlaceOnMap),
      HomeScreen(onOpenMap: () => _switchTab(0)),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _switchTab,
        animationDuration: const Duration(milliseconds: 350),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
