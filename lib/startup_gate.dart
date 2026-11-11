import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_shell_screen.dart';
import 'package:restauran_menu/features/auth/presentation/pages/login_screen.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/sidemenu/presentation/pages/kasir_menu_shell_screen.dart';
import 'package:restauran_menu/features/sidemenu/presentation/pages/kitchen_menu_shell_screen.dart';
import 'package:restauran_menu/features/sidemenu/presentation/pages/waiters_menu_shell_screen.dart';

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.authStatus) {
          case AuthStatus.loggedIn:
            if (auth.user != null && auth.user?.role != null) {
              if (auth.user!.role == "owner" || auth.user!.role == "manager") {
                return const AdminShellScreen();
              }
              if (auth.user!.role == "kasir" || auth.user!.role == "casheer") {
                //return const KasirShellScreen();
                return const KasirMenuShellScreen();
              }
              if (auth.user!.role == "waiter" || auth.user!.role == "waiters") {
                //return const WaiterShellScreen();
                return const WaitersMenuShellScreen();
              }
              if (auth.user!.role == "kitchen" || auth.user!.role == "dapur") {
                //return const KitchenDisplayScreen();
                return const KitchenMenuShellScreen();
              }
            }
            return const LoginScreen();
          case AuthStatus.loggedOut:
            return const LoginScreen();
          case AuthStatus.initial:
          case AuthStatus.error:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
