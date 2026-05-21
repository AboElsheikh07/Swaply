import 'package:get/get.dart';
import '../features/sessions/presentation/screens/sessions_screen.dart';
import '../features/sessions/presentation/screens/request_session_screen.dart';
import '../features/sessions/presentation/controllers/sessions_controller.dart';
import '../features/sessions/data/repositories/session_repository.dart';

/// Add these entries to your existing GetMaterialApp routes list.
///
/// Example:
///   GetMaterialApp(
///     getPages: [
///       ...AppRouter.sessionRoutes,
///       // ... other routes
///     ],
///   )
abstract class AppRouter {
  AppRouter._();

  static final sessionRoutes = <GetPage>[
    GetPage(
      name: '/sessions',
      page: () => const SessionsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SessionsController(
            currentUid: Get.find<String>(
              tag: 'currentUid',
            ), // inject logged-in uid
            repo: SessionRepository(),
          ),
        );
      }),
    ),
    GetPage(
      name: '/request-session',
      page: () {
        // MentorArg is passed via Get.toNamed('/request-session', arguments: mentorArg)
        final mentor = Get.arguments as MentorArg;
        return RequestSessionScreen(mentor: mentor);
      },
      // Ensure the SessionsController is available when opening this route
      // directly (e.g. navigated from outside the Sessions screen).
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => SessionsController(
            currentUid: Get.find<String>(tag: 'currentUid'),
            repo: SessionRepository(),
          ),
        );
      }),
    ),
  ];
}
