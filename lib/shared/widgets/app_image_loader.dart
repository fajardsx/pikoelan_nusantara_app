import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'file_image_stub.dart'
    if (dart.library.io) 'file_image_io.dart'
    as file_img;

class AppImageLoader {
  AppImageLoader._internal();
  static final AppImageLoader _instance = AppImageLoader._internal();
  factory AppImageLoader() => _instance;

  Widget load(
    String source, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    Widget? placeholder,
    Widget? errorWidget,
    AlignmentGeometry alignment = AlignmentGeometry.center,
  }) {
    final normalized = resolveUrl(source.trim());
    if (normalized.isEmpty) return errorWidget ?? _defErr(width, height);
    if (_isSvg(normalized)) {
      return _svg(
        normalized,
        width: width,
        height: height,
        fit: fit,
        color: color,
        placeholder: placeholder,
      );
    }
    if (_isNetwork(normalized)) {
      return _net(
        normalized,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        alignment: alignment,
      );
    }
    if (!kIsWeb && _isFile(normalized)) {
      return _file(
        normalized,
        width: width,
        height: height,
        fit: fit,
        errorWidget: errorWidget,
      );
    }
    if (kIsWeb && _isRelative(normalized)) {
      final abs = resolveUrl(normalized);
      if (_isNetwork(abs)) {
        return _net(
          abs,
          width: width,
          height: height,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
        );
      }
      return errorWidget ?? _defErr(width, height);
    }
    return _asset(
      normalized,
      width: width,
      height: height,
      fit: fit,
      errorWidget: errorWidget,
    );
  }

  static String resolveUrl(String source) {
    final s = source.trim();
    if (s.isEmpty) return s;
    if (s.startsWith('http://') ||
        s.startsWith('https://') ||
        s.startsWith('data:image') ||
        s.startsWith('blob:')) {
      return s;
    }
    if (s.startsWith('//')) return 'https:$s';
    if (s.startsWith('assets/') ||
        s.startsWith('packages/') ||
        s.startsWith('icons/') ||
        s == 'favicon.png') {
      return s;
    }
    return s;
    // final base = (EnviServices.baseUrl ?? '').trim();
    // if (base.isEmpty) return s;
    // final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    // return s.startsWith('/') ? '$b$s' : '$b/$s';
  }

  bool _isSvg(String p) => p.toLowerCase().split('?').first.endsWith('.svg');
  bool _isNetwork(String p) =>
      p.startsWith('http://') || p.startsWith('https://');
  bool _isFile(String s) =>
      s.startsWith('/data/user') ||
      s.startsWith('file://') ||
      s.startsWith('/storage/');
  bool _isRelative(String s) {
    final l = s.toLowerCase().split('?').first;
    return s.startsWith('/') ||
        s.startsWith('uploads/') ||
        s.startsWith('api/') ||
        s.startsWith('storage/') ||
        s.startsWith('images/') ||
        l.endsWith('.png') ||
        l.endsWith('.jpg') ||
        l.endsWith('.jpeg') ||
        l.endsWith('.webp') ||
        l.endsWith('.gif') ||
        l.endsWith('.bmp');
  }

  Widget _svg(
    String s, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    Widget? placeholder,
  }) {
    final cf = color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null;
    if (_isNetwork(s)) {
      return SvgPicture.network(
        s,
        width: width,
        height: height,
        fit: fit,
        colorFilter: cf,
        placeholderBuilder: (_) => placeholder ?? _defHold(width, height),
      );
    }
    return SvgPicture.asset(
      s,
      width: width,
      height: height,
      fit: fit,
      colorFilter: cf,
    );
  }

  Widget _net(
    String s, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    AlignmentGeometry alignment = AlignmentGeometry.center,
  }) {
    if (kIsWeb) {
      return Image.network(
        s,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        frameBuilder: (ctx, child, frame, wasSynchronouslyLoaded) {
          if (frame == null) {
            return placeholder ?? _defHold(width, height);
          }
          return child;
        },
        loadingBuilder: (ctx, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _defHold(width, height);
        },
        errorBuilder: (ctx, error, stackTrace) {
          return errorWidget ?? _defErr(width, height);
        },
      );
    }
    return CachedNetworkImage(
      imageUrl: s,
      width: width,
      height: height,
      fit: fit,
      cacheKey: s,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
      placeholder: (_, _) => placeholder ?? _defHold(width, height),
      errorWidget: (_, _, _) {
        debugPrint('[AppImageLoader] gagal load: $s');
        return errorWidget ?? _defErr(width, height);
      },
    );
  }

  Widget _asset(
    String s, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return Image.asset(
      s,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => errorWidget ?? _defErr(width, height),
    );
  }

  Widget _file(
    String s, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return file_img.buildFileImage(
      s,
      width: width,
      height: height,
      fit: fit,
      errorWidget: errorWidget,
    );
  }

  Widget _defHold(double? w, double? h) => SizedBox(
    width: w,
    height: h,
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
  Widget _defErr(double? w, double? h) => SizedBox(
    width: w,
    height: h,
    child: const Icon(Icons.broken_image, color: Colors.grey),
  );
}
