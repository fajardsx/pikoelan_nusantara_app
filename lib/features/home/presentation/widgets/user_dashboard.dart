import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';

import '../../../../core/themes/app_fonts.dart';
import '../../../../routes/name_route.dart';
import '../../../../routes/navigator.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late AuthProvider _provider;

  @override
  void initState() {
    _provider = sl<AuthProvider>();
    _provider.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: ChangeNotifierProvider.value(
        value: _provider,
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hi, ${auth.user!.name}', style: appFonts.ts),
                      TextButton(
                        onPressed: () {
                          NavigationService.navigateTo(NameRoute.profile);
                        },
                        child: Text("Detail", style: appFonts.ts),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: () {
                      NavigationService.navigateTo(
                        NameRoute.chat,
                        arguments: {
                          "userId": auth.user!.id.toString(),
                          "userName": auth.user!.name,
                        },
                      );
                      //ChatService().sendMessage("test");
                    },
                    child: Text("Chat", style: appFonts.ts),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
