import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';
import 'package:restauran_menu/shared/widgets/app_image_loader.dart';

class PromoBanner extends StatefulWidget {
  final List<MenuItemEntity> items;
  const PromoBanner({super.key, required this.items});

  @override
  State<PromoBanner> createState() => PromoBannerState();
}

class PromoBannerState extends State<PromoBanner> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  List<MenuItemEntity> get _bannerItems => widget.items;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerItems.isEmpty || !_pageController.hasClients) return;

      int nextPage = (_currentPage + 1) % _bannerItems.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerItems.isEmpty) return const SizedBox.shrink();
    if (_currentPage >= _bannerItems.length) _currentPage = 0;
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _bannerItems.length,
            itemBuilder: (context, index) {
              final item = _bannerItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  gradient: RestaurantColors.bannerGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0.0,
                      child: item.imageUrl != null
                          ? ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF000000,
                                    ).withValues(alpha: 1.0),
                                    const Color(
                                      0xFF000000,
                                    ).withValues(alpha: 1.0),
                                    const Color(0xFF000000),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: AppImageLoader().load(
                                item.imageUrl ?? "",
                                width: MediaQuery.sizeOf(context).width < 560
                                    ? MediaQuery.sizeOf(context).width
                                    : 720,
                                //height: 210,
                                fit: BoxFit.cover,
                                alignment: AlignmentGeometry.center,
                              ),
                            )
                          : const Icon(
                              Icons.restaurant_menu_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              formatRupiah(item.price),
                              style: const TextStyle(
                                color: RestaurantColors.accentOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
