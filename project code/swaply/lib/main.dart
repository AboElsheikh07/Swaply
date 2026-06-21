import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:swaply/features/sessions/presentation/controllers/sessions_controller.dart';
import 'package:swaply/features/sessions/data/repositories/session_repository.dart';
import 'package:swaply/root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swaply',
      initialBinding: BindingsBuilder(() {
        // Minimal startup registration so screens depending on
        // `currentUid` and `SessionsController` can function.
        // Replace this with your real auth flow (put actual UID after login).
        Get.put<String>('demo-uid', tag: 'currentUid');
        Get.lazyPut(
          () => SessionsController(
            currentUid: Get.find<String>(tag: 'currentUid'),
            repo: SessionRepository(),
          ),
        );
      }),
      
      home:  RootView(),
    );
  }
}
