import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart' as window_size;



class PlatformService {
  // 平台类型枚举
  static const String PLATFORM_WEB = 'web';
  static const String PLATFORM_WINDOWS = 'windows';
  static const String PLATFORM_LINUX = 'linux';
  static const String PLATFORM_MACOS = 'macos';
  static const String PLATFORM_ANDROID = 'android';
  static const String PLATFORM_IOS = 'ios';

  // 获取当前平台
  static String get currentPlatform {
    if (kIsWeb) {
      return PLATFORM_WEB;
    } else if (Platform.isWindows) {
      return PLATFORM_WINDOWS;
    } else if (Platform.isLinux) {
      return PLATFORM_LINUX;
    } else if (Platform.isMacOS) {
      return PLATFORM_MACOS;
    } else if (Platform.isAndroid) {
      return PLATFORM_ANDROID;
    } else if (Platform.isIOS) {
      return PLATFORM_IOS;
    } else {
      return 'unknown';
    }
  }

  // 检查是否为桌面平台
  static bool get isDesktop {
    return !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  // 检查是否为移动平台
  static bool get isMobile {
    return Platform.isAndroid || Platform.isIOS;
  }

  // 检查是否为Web平台
  static bool get isWeb {
    return kIsWeb;
  }

  // 设置窗口大小
  static Future<void> setWindowSize(int width, int height) async {
    if (isDesktop) {
      try {
        window_size.setWindowMinSize(Size(width.toDouble(), height.toDouble()));
        window_size.setWindowMaxSize(Size(width.toDouble(), height.toDouble()));
        window_size.setWindowFrame(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
      } catch (e) {
        // 忽略错误
      }
    }
  }

  // 设置窗口标题
  static void setWindowTitle(String title) {
    if (isDesktop) {
      try {
        window_size.setWindowTitle(title);
      } catch (e) {
        // 忽略错误
      }
    }
  }

  // 显示通知
  static void showNotification(String title, String body) {
    // 桌面平台可以使用系统通知
    // 这里可以集成第三方通知库
  }

  // 获取屏幕尺寸
  static Size getScreenSize() {
    // 桌面平台返回默认尺寸
    return Size(800, 600);
  }

  // 打开URL
  static void openUrl(String url) {
    // 桌面平台可以使用url_launcher库
    // 这里可以集成url_launcher
  }

  // 获取应用版本
  static String getAppVersion() {
    // 这里可以返回应用版本
    // 实际实现需要根据平台不同而不同
    return '1.0.0';
  }

  // 检查更新
  static Future<bool> checkForUpdates() async {
    // 这里可以实现检查更新的逻辑
    // 实际实现需要根据平台不同而不同
    return false;
  }

  // 获取系统信息
  static Map<String, dynamic> getSystemInfo() {
    final info = <String, dynamic>{
      'platform': currentPlatform,
      'appVersion': getAppVersion(),
      'os': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
    };

    return info;
  }
}
