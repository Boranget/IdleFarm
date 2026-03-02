import 'dart:io';
import 'package:flutter/material.dart';
import 'views/home_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 初始化Flutter绑定
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // 获取屏幕信息
  final window = WidgetsBinding.instance.window;
  final screen = window.physicalSize;
  final devicePixelRatio = window.devicePixelRatio;

  // 计算逻辑像素尺寸
  final screenWidth = screen.width / devicePixelRatio;
  final screenHeight = screen.height / devicePixelRatio;

  // 根据屏幕大小动态计算窗口尺寸
  Size windowSize;
  Size minWindowSize;

  // 参考QQ的自适应逻辑
  if (screenWidth >= 1920 && screenHeight >= 1080) {
    // 大屏幕 (1080p及以上)
    windowSize = const Size(600, 800);
    minWindowSize = const Size(400, 600);
  } else if (screenWidth >= 1366 && screenHeight >= 768) {
    // 中等屏幕 (768p-1080p)
    windowSize = const Size(500, 700);
    minWindowSize = const Size(350, 550);
  } else {
    // 小屏幕 (768p以下)
    windowSize = const Size(400, 600);
    minWindowSize = const Size(300, 500);
  }

  // 确保窗口不会超出屏幕边界
  final maxWidth = screenWidth * 0.8; // 最大不超过屏幕宽度的80%
  final maxHeight = screenHeight * 0.8; // 最大不超过屏幕高度的80%

  windowSize = Size(
    windowSize.width > maxWidth ? maxWidth : windowSize.width,
    windowSize.height > maxHeight ? maxHeight : windowSize.height,
  );

  WindowOptions windowOptions = WindowOptions(
    size: windowSize,
    minimumSize: minWindowSize,
    center: true, // 居中显示
    title: "IdleFarm",
    titleBarStyle: TitleBarStyle.normal,
  );

  // 关键修改：先隐藏窗口，设置好尺寸后再显示
  await windowManager.hide(); // 先隐藏窗口

  windowManager.setMaximizable(false);
  if (Platform.isWindows) {
    // 设置窗口图标
    // 注意：需要在assets文件夹中添加ic_launch.png图标
  }

  // 设置窗口选项但不立即显示
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setSize(windowSize);
    await windowManager.setMinimumSize(minWindowSize);
    await windowManager.center();
    await windowManager.show(); // 最后再显示窗口
    await windowManager.focus();
  });

  // 运行应用
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IdleFarm',
      theme: ThemeData(
        // 极简文字界面风格 - 更宽敞的设计
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFF5F5F5), // 浅灰色背景
          primary: Color(0xFF9E9E9E), // 中性灰色
          secondary: Color(0xFFBDBDBD),
          background: Color(0xFFF5F5F5),
          surface: Colors.white,
          onPrimary: Color(0xFF212121),
          onSecondary: Color(0xFF212121),
          onBackground: Color(0xFF212121),
          onSurface: Color(0xFF212121),
        ),
        useMaterial3: true,
        // 简洁的字体设置
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF212121),
            fontFamily: 'Roboto',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
            fontFamily: 'Roboto',
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF212121),
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            color: Color(0xFF212121),
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        // 极简的按钮样式 - 非彩色
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFE0E0E0), // 浅灰色
            foregroundColor: Color(0xFF212121), // 深灰色文字
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Color(0xFFBDBDBD), width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: TextStyle(fontFamily: 'Roboto'),
          ),
        ),
        // 极简的卡片样式 - 增加留白
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          margin: EdgeInsets.symmetric(vertical: 16),
        ),
        // 极简的底部导航栏样式
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF212121),
          unselectedItemColor: Color(0xFFBDBDBD),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
