// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../colors/app_colors.dart';
//
// class SettingsService extends GetxService {
//
//   ThemeData getLightTheme() {
//     // TODO change font dynamically
//     return ThemeData(
//         primaryColor: CustomColor.primaryBlue,
//         floatingActionButtonTheme: const FloatingActionButtonThemeData(
//             elevation: 0, foregroundColor: Colors.white),
//         brightness: Brightness.light,
//         canvasColor: CustomColor.white,
//         dividerColor: CustomColor.primaryBlue,
//         focusColor: CustomColor.primaryBlue,
//         hintColor: CustomColor.colorBgVoteCast,
//         appBarTheme:
//             const AppBarTheme(backgroundColor: CustomColor.primaryBlue),
//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(
//               foregroundColor: CustomColor.colorBgVoteCast),
//         ),
//         colorScheme: const ColorScheme.light(
//           primary: CustomColor.colorBgVoteCast,
//           secondary: CustomColor.colorBgVoteCast,
//         ),
//         textTheme: GoogleFonts.getTextTheme(
//           'Cairo',
//           const TextTheme(
//             titleMedium: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.primaryBlack,
//                 height: 1.3),
//             titleLarge: TextStyle(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.primaryBlue,
//                 height: 1.3),
//             headlineSmall: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.primaryBlue,
//                 height: 1.3),
//             headlineMedium: TextStyle(
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.w400,
//                 color: CustomColor.primaryBlue,
//                 height: 1.3),
//             displaySmall: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.primaryBlue,
//                 height: 1.3),
//             displayMedium: TextStyle(
//                 fontSize: 22.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.primaryBlue,
//                 height: 1.4),
//             displayLarge: TextStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.w300,
//                 color: CustomColor.primaryBlue,
//                 height: 1.4),
//             bodySmall: TextStyle(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.primaryBlack,
//                 height: 1.4),
//           ),
//         ));
//   }
//
//   ThemeData getDarkTheme() {
//     // TODO change font dynamically
//     return ThemeData(
//       canvasColor: CustomColor.primaryBlack,
//       primaryColor: CustomColor.white,
//       floatingActionButtonTheme:
//           const FloatingActionButtonThemeData(elevation: 0),
//       scaffoldBackgroundColor: const Color(0xFF2C2C2C),
//       brightness: Brightness.dark,
//       dividerColor: CustomColor.primaryBlack,
//       focusColor: CustomColor.primaryBlack,
//       hintColor: CustomColor.white,
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(foregroundColor: CustomColor.white),
//       ),
//       colorScheme: const ColorScheme.dark(
//         primary: CustomColor.white,
//         secondary: CustomColor.white,
//       ),
//       textTheme: GoogleFonts.getTextTheme(
//           'Cairo',
//           const TextTheme(
//             titleMedium: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.white,
//                 height: 1.3),
//             titleLarge: TextStyle(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.white,
//                 height: 1.3),
//             headlineSmall: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.white,
//                 height: 1.3),
//             headlineMedium: TextStyle(
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.w400,
//                 color: CustomColor.white,
//                 height: 1.3),
//             displaySmall: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.white,
//                 height: 1.3),
//             displayMedium: TextStyle(
//                 fontSize: 22.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.white,
//                 height: 1.4),
//             displayLarge: TextStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.w300,
//                 color: CustomColor.white,
//                 height: 1.4),
//             bodySmall: TextStyle(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.w700,
//                 color: CustomColor.white,
//                 height: 1.4),
//             bodyMedium: TextStyle(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.w400,
//                 color: CustomColor.white,
//                 height: 1.4),
//           )),
//     );
//   }
//
//   ThemeMode getThemeMode() {
//     String? themeMode = GetStorage().read<String>('theme_mode');
//     switch (themeMode) {
//       case 'ThemeMode.light':
//         SystemChrome.setSystemUIOverlayStyle(
//           SystemUiOverlayStyle.light
//               .copyWith(systemNavigationBarColor: Colors.white),
//         );
//         return ThemeMode.light;
//       case 'ThemeMode.dark':
//         SystemChrome.setSystemUIOverlayStyle(
//           SystemUiOverlayStyle.dark
//               .copyWith(systemNavigationBarColor: Colors.black87),
//         );
//         return ThemeMode.dark;
//       case 'ThemeMode.system':
//         return ThemeMode.system;
//       default:
//         if (homeController.toggleValue.value) {
//           SystemChrome.setSystemUIOverlayStyle(
//             SystemUiOverlayStyle.dark
//                 .copyWith(systemNavigationBarColor: Colors.black87),
//           );
//           return ThemeMode.dark;
//         } else {
//           SystemChrome.setSystemUIOverlayStyle(
//             SystemUiOverlayStyle.light
//                 .copyWith(systemNavigationBarColor: Colors.white),
//           );
//           return ThemeMode.light;
//         }
//     }
//   }
// }
