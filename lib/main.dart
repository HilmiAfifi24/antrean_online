import 'package:antrean_online/core/routes/app_pages.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Use Debug provider for development/emulator
  // Switch to PlayIntegrity for production release
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Antrean Online - Klinik PENS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          appBar: AppBar(title: Text('Page Not Found')),
          body: Center(
            child: Text('The page you are looking for does not exist.'),
          ),
        ),
      ),
      // initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}
