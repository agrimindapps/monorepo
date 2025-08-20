// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/agrihurbi_theme.dart';
import 'calc/calculos_page.dart';
import 'home_agricultura_page.dart';
import 'home_pecuaria_page.dart';
import 'pluviometro/home_page.dart';

class MobilePageMain extends StatefulWidget {
  const MobilePageMain({super.key});

  @override
  State<MobilePageMain> createState() => _MobilePageMainState();
}

class _MobilePageMainState extends State<MobilePageMain> {
  int _currentIndex = 0;

  // Keys for each tab's navigator
  final GlobalKey<NavigatorState> _agriculturaNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _pecuariaNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _calculosNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _ferramentasNavigatorKey =
      GlobalKey<NavigatorState>();
  Widget _buildTabNavigator(int index) {
    GlobalKey<NavigatorState> navigatorKey;
    Widget initialPage;

    switch (index) {
      case 0:
        navigatorKey = _agriculturaNavigatorKey;
        initialPage = const AgriculturaHomepage();
        break;
      case 1:
        navigatorKey = _pecuariaNavigatorKey;
        initialPage = const PecuariaHomepage();
        break;
      case 2:
        navigatorKey = _calculosNavigatorKey;
        initialPage = const CalculosPage();
        break;
      case 3:
        navigatorKey = _ferramentasNavigatorKey;
        initialPage = const PluviometriaHome();
        break;
      default:
        navigatorKey = _agriculturaNavigatorKey;
        initialPage = const AgriculturaHomepage();
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => initialPage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTabNavigator(0), // Agricultura
          _buildTabNavigator(1), // Pecuária
          _buildTabNavigator(2), // Cálculos
          _buildTabNavigator(3), // Ferramentas
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AgrihurbiTheme.agriculturaPrimary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Agricultura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pecuária',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Cálculos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Ferramentas',
          ),
        ],
      ),
    );
  }
}
