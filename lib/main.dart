import 'package:camera/camera.dart';
import 'package:chat_x/routes/app_pages.dart';
import 'package:chat_x/utils/Store/HiveStore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'languages/LocalizationService.dart';
List<CameraDescription> cameras = [];
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStore().initBox();

  try {
    cameras = await availableCameras();
    print("Cameras:$cameras");
  } on CameraException catch (e) {
    if (e.description != null) {
      print('Error: ${e.code}\nError Message: ${e.description}');
    } else {
      print('Error: ${e.code}');
    }
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    GetMaterialApp(
      translations: LocalizationService(),
      supportedLocales: LocalizationService.locales,
      locale: LocalizationService.locale,
      fallbackLocale: LocalizationService.fallbackLocale,
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
      initialRoute:Theme1AppPages.INITIAL,
      getPages: Theme1AppPages.routes,
      localizationsDelegates: [
        MonthYearPickerLocalizations.delegate,
      ],
      // themeMode: settingsService.getThemeMode(),
      // theme: settingsService.getLightTheme(),
      // darkTheme: settingsService.getDarkTheme(),
    ),
  );
}
