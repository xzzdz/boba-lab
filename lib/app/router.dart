import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/transitions.dart';
import '../data/catalog.dart';
import '../features/builder/cup_builder_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/common/screen_parts.dart';
import '../features/menu/menu_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/success_screen.dart';
import '../features/orders/tracking_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/shell/home_shell.dart';
import '../features/splash/splash_screen.dart';

/// Routes. Tabs live in a [StatefulShellRoute] so each keeps its scroll
/// position; everything else is pushed over the tabs with its own transition.
GoRouter buildRouter({String? initialLocation}) {
  GoRoute tab(String path, Widget screen) => GoRoute(
    path: path,
    pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: screen),
  );

  return GoRouter(
    initialLocation: initialLocation ?? '/splash',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            bobaPage(context: context, state: state, transition: BobaTransition.fade, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            bobaPage(context: context, state: state, transition: BobaTransition.fade, child: const OnboardingScreen()),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, shell) => bobaPage(
          context: context,
          state: state,
          transition: BobaTransition.fade,
          child: HomeShell(shell: shell),
        ),
        branches: [
          StatefulShellBranch(routes: [tab('/menu', const MenuScreen())]),
          StatefulShellBranch(routes: [tab('/orders', const OrdersScreen())]),
          StatefulShellBranch(routes: [tab('/rewards', const RewardsScreen())]),
          StatefulShellBranch(routes: [tab('/profile', const ProfileScreen())]),
        ],
      ),
      GoRoute(
        path: '/build/:id',
        pageBuilder: (context, state) {
          final item = Catalog.item(state.pathParameters['id'] ?? '');
          return bobaPage(
            context: context,
            state: state,
            child: item == null ? const NotFoundScreen() : CupBuilderScreen(item: item),
          );
        },
      ),
      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) =>
            bobaPage(context: context, state: state, transition: BobaTransition.slide, child: const CartScreen()),
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            bobaPage(context: context, state: state, transition: BobaTransition.slide, child: const CheckoutScreen()),
      ),
      GoRoute(
        path: '/success/:number',
        pageBuilder: (context, state) => bobaPage(
          context: context,
          state: state,
          transition: BobaTransition.pop,
          child: SuccessScreen(number: state.pathParameters['number']!),
        ),
      ),
      GoRoute(
        path: '/track/:number',
        pageBuilder: (context, state) => bobaPage(
          context: context,
          state: state,
          transition: BobaTransition.pop,
          child: TrackingScreen(number: state.pathParameters['number']!),
        ),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
