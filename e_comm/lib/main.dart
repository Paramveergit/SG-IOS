import 'package:e_comm/firebase_options.dart';
import 'package:e_comm/screens/auth-ui/splash-screen.dart';
import 'package:e_comm/utils/app-constant.dart';
import 'package:e_comm/utils/performance_optimizer.dart';
import 'package:e_comm/utils/cache_manager.dart';
import 'package:e_comm/theme/app_theme.dart';
import 'package:e_comm/services/navigation-service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FIX: these three lines - Firestore offline persistence, the
  // performance optimizer, and the image cache limiter - existed as
  // real files in this repo already but were never actually wired
  // into main(), discovered while checking why they showed up as
  // unreachable in a dead-code sweep. Matches Android's setup exactly.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  PerformanceOptimizer.init();
  CacheManager.limitCacheSize();
  
  // Initialize NavigationService for handling authentication redirects
  Get.put(NavigationService());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, 
      title: AppConstant.appMainName,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      builder: EasyLoading.init(),
    );
  }
}
