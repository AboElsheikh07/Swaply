import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/features/sessions/presentation/screens/home_screen.dart';
import 'package:swaply/features/sessions/presentation/screens/messages_screen.dart';
import 'package:swaply/features/sessions/presentation/screens/profile_screen.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen.dart';

class RootView extends StatefulWidget {
  RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  PageController controller = PageController();
  late List<Widget> screens;
  int currentIndex = 0;

  @override
  void initState() {
    controller = PageController(initialPage: currentIndex);
    screens = {
      HomeScreen(),
      SessionsScreen(),
      MessagesScreen(),
      ProfileScreen(),
    }.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (value) => setState(() => currentIndex = value),
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          onTap: (value) => setState(() {
            currentIndex = value;
            controller.jumpToPage(value);
          }),

          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade700,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_restaurant_outlined),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
