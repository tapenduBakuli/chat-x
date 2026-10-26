import 'dart:core';

import 'package:flutter/material.dart';

class DeviceManager {
  static DeviceManager instance = DeviceManager();

  num width;
  num height;
  bool allowFontScaling;

  static late MediaQueryData _mediaQueryData;
  static late num _screenWidth;
  static late num _screenHeight;
  static late num _pixelRatio;
  static late num _statusBarHeight;
  static late num _bottomBarHeight;
  static late num _textScaleFactor;

  DeviceManager({
    this.width = 1080,
    this.height = 1920,
    this.allowFontScaling = false,
  });

  static DeviceManager getInstance() {
    return instance;
  }

  void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _mediaQueryData = mediaQuery;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomBarHeight = _mediaQueryData.padding.bottom;
    _textScaleFactor = mediaQuery.textScaleFactor;
  }

  static MediaQueryData get mediaQueryData => _mediaQueryData;

  static double get textScaleFactory => _textScaleFactor as double;

  static double get pixelRatio => _pixelRatio as double;

  static double get screenWidthDp => _screenWidth as double;

  static double get screenHeightDp => _screenHeight as double;

  static double get screenWidth => _screenWidth * _pixelRatio as double;

  static double get screenHeight => _screenHeight * _pixelRatio as double;

  static double get statusBarHeight => _statusBarHeight * _pixelRatio as double;

  static double get bottomBarHeight => _bottomBarHeight * _pixelRatio as double;

  get scaleWidth => _screenWidth / instance.width;

  get scaleHeight => _screenHeight / instance.height;

  setWidth(double width) => width * scaleWidth;

  setHeight(double height) => height * scaleHeight;

  setSp(double fontSize) => allowFontScaling
      ? setWidth(fontSize)
      : setWidth(fontSize) / _textScaleFactor;
}
