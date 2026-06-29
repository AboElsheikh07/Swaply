import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swaply/features/home/presentation/screens/home_screen.dart';
import 'package:swaply/features/chat/presentation/screens/messages_screen.dart';
import 'package:swaply/features/profile/presentation/screens/profile_screen.dart';
import 'package:swaply/features/sessions/presentation/screens/sessions_screen/sessions_screen.dart';

import 'package:swaply/l10n/app_localizations.dart';

class RootView extends StatefulWidget {
  final int? index;
   const RootView({super.key,this.index});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  late PageController controller;
  late List<Widget> screens;
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.index ?? 0;
    controller = PageController(initialPage: currentIndex);
    screens = [
      HomeScreen(),
      SessionsScreen(),
      // RequestSessionScreen(
      //   mentor: UserModel(
      //     id: "frgrejgejgnjelrgnl",
      //     username: "Teacher Reem",
      //     avatarUrl: "",
      //     skillsCanTeach: ["Python", "Flutter", "Music"],
      //     skillsWantsToLearn: ["Flutter"],
      //     pricePerHour: 10,
      //     balance: 50,
      //     heldBalance: 0,
      //     onboardingComplete: true,
      //     isPublic: true,
      //     ratingAvg: 4 / 5,
      //     ratingCount: 30,
      //   ),
      // ),
      ConversationsScreen(),
      ProfileScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: PageView(
        physics: BouncingScrollPhysics(),
        onPageChanged: (value) => setState(() => currentIndex = value),
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          onTap: (value) => setState(() {
            currentIndex = value;
            controller.animateToPage(
              value,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }),

          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.date_range_outlined),
              label: l10n.sessions,
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2),
              label: l10n.messages,
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
