import 'package:flutter/material.dart';
import 'home_page.dart';
import 'reservaciones_page.dart';
import 'perfil_page.dart';
import '../widgets/custom_navbar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  int previousIndex = 0;

  final pages = [
    const HomePage(),
    const ReservacionesPage(),
    const PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final direction = currentIndex >= previousIndex ? 1.0 : -1.0;
          final offsetAnimation = Tween<Offset>(
            begin: Offset(0.05 * direction, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: pages[currentIndex],
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          setState(() {
            previousIndex = currentIndex;
            currentIndex = index;
          });
        },
      ),
    );
  }
}
