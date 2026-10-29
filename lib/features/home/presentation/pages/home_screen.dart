import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/home/presentation/provider/home_provider.dart';
import 'package:restauran_menu/features/home/presentation/widgets/user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeProvider _homeProvider;

  @override
  void initState() {
    super.initState();
    _homeProvider = sl<HomeProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ChangeNotifierProvider.value(
        value: _homeProvider,
        child: Consumer<HomeProvider>(
          builder: (context, home, _) {
            if (home.status == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (home.status == HomeStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      home.errorMessage ?? 'An error occurred',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => home.onGetAllUser(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (home.status == HomeStatus.success) {
              if (home.listUser == null) {
                return const Center(
                  child: Column(
                    children: [
                      Text(
                        'Welcome to Home Screen',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      Text('No have user', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {},
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('List User', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: false,
                          itemCount: home.listUser!.length,
                          itemBuilder: (context, index) {
                            final user = home.listUser![index];
                            return userCard(user: user);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Home Screen',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
