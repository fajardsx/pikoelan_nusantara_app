import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_shell_screen.dart';
import 'package:restauran_menu/features/auth/presentation/pages/login_screen.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/kasir/presentation/pages/kasir_shell_screen.dart';
import 'package:restauran_menu/features/kitchen/presentation/pages/kitchen_display_screen.dart';
import 'package:restauran_menu/features/waiters/presentation/pages/waiter_shell_screen.dart';

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
                // const RoleSelectionScreen();
              }
              if (auth.user!.role == "kasir") {
                return const KasirShellScreen();
              }
              if (auth.user!.role == "waiter") {
                return const WaiterShellScreen();
              }
              if (auth.user!.role == "kitchen") {
                return const KitchenDisplayScreen();
              }
            }
            return const LoginScreen();
          //return const RoleSelectionScreen();
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
