// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../device_manager/screen_constants.dart';
// import '../utils/TextStyles.dart';
// import '../utils/colors/app_colors.dart';
// import 'image_utils/image_utils.dart';
//
// enum Type {
//   suffixIcon,
//   normal2,
//   datePicker,
//   monthPicker,
//   datePickerWithPrefix,
//   timePickerWithPrefix,
//   phone,
//   normal,
//   textFieldWithSuffix,
//   searchField,
//   emailFieldWithOutPrefixAndSuffix,
//   stageName,
//   description,
// }
//
// class DefaultEditText extends StatefulWidget {
//   final Type type;
//   final String hintText;
//   final bool? obscureText;
//   final bool autofocus;
//   final TextInputType? keyboardType;
//   final bool? readOnly;
//   final FormFieldSetter<String>? onSaved;
//   final ValueChanged<String>? onChanged;
//   final FormFieldValidator<String>? validator;
//   final TextStyle? style;
//   final TextAlign? textAlign;
//   final IconData? iconData;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final Widget? suffix;
//   final String? errorText;
//   final TextEditingController? controller;
//   final caption;
//   final FocusNode? myFocusNode;
//   final prefixText;
//   final mobileNumber;
//   final readWriteStatus;
//   final onTap;
//   final labelText;
//   final autoValidate;
//   final autoSubmit;
//   final verified;
//   final suggestions;
//   final autoKey;
//   final isPast;
//
//   late final initialValue;
//   final double? boxHeight;
//   final double? boxWidth;
//   final bool? isReadOnly;
//   final bool? showDecoration;
//   final bool? suffixEnabled;
//   final bool? prefixEnabled;
//   final bool? showDecorationForCall;
//   final validationFunction;
//   bool onSubmit;
//   bool? showCountryFlag;
//   Color? fillColor;
//   TextStyle? hintStyle;
//   OutlineInputBorder? outlineInputBorder;
//
//   DefaultEditText(
//       {super.key,
//       this.obscureText = false,
//       this.validationFunction,
//       this.showCountryFlag,
//       this.onSubmit = false,
//       this.errorText,
//       this.suffix,
//       this.suffixIcon,
//       this.prefixIcon,
//       this.iconData,
//       this.textAlign,
//       this.style,
//       this.hintText = '',
//       this.autofocus = false,
//       this.keyboardType = TextInputType.text,
//       this.onSaved,
//       this.onChanged,
//       this.validator,
//       this.readOnly = false,
//       required this.type,
//       this.controller,
//       this.caption,
//       this.myFocusNode,
//       this.prefixText,
//       this.mobileNumber,
//       this.readWriteStatus,
//       this.onTap,
//       this.labelText,
//       this.autoValidate,
//       this.autoSubmit,
//       this.verified,
//       this.suggestions,
//       this.autoKey,
//       this.isPast,
//
//       this.initialValue,
//       this.boxHeight,
//       this.boxWidth,
//       this.isReadOnly = false,
//       this.showDecoration = false,
//       this.suffixEnabled = false,
//       this.prefixEnabled = false,
//       this.fillColor,
//       this.hintStyle,
//         this.outlineInputBorder,
//       this.showDecorationForCall = false});
//
//   @override
//   _DefaultEditTextState createState() => _DefaultEditTextState();
// }
//
// class _DefaultEditTextState extends State<DefaultEditText> {
//   late TextEditingController _controller;
//   late Type type;
//
//   var _value;
//
//   bool _errorFree = true;
//
//   bool validate = false;
//
//   get errorFree => _errorFree;
//
//   Type get _type => widget.type;
//   var searchTextField;
//
//   TextEditingController get _thisController =>
//       widget.controller ?? TextEditingController();
//   late GlobalKey<NavigatorState> navigatorKey;
//   bool indicator = true;
//
//   @override
//   void initState() {
//     super.initState();
//     navigatorKey = GlobalKey<NavigatorState>();
//   }
//
//   void _handleControllerChanged() {
//     if (_thisController.text != _value || _value.trim().isNotEmpty)
//       didChange(_thisController.text);
//   }
//
//   void didChange(value) {
//     setState(() {
//       _value = value;
//     });
//   }
//
//   @override
//   void didUpdateWidget(DefaultEditText oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.controller != oldWidget.controller) {
//       oldWidget.controller!.removeListener(_handleControllerChanged);
//       widget.controller!.addListener(_handleControllerChanged);
//
//       if (widget.controller == null) {
//         _controller =
//             TextEditingController.fromValue(oldWidget.controller!.value);
//       }
//       _thisController.text = widget.controller!.text;
//       if (oldWidget.controller == null) _controller;
//     }
//   }
//
//   @override
//   void dispose() {
//     // widget.controller!.removeListener(_handleControllerChanged);
//     super.dispose();
//   }
//
//   Widget build(BuildContext _context) {
//     switch (_type) {
//       case Type.suffixIcon:
//         {
//           return TextFormField(
//             controller: _thisController,
//             keyboardType: TextInputType.text,
//             autofocus: false,
//             maxLines:1,
//             onTap: () {
//               widget.onTap();
//             },
//             readOnly: true,
//             //autovalidateMode: AutovalidateMode.onUserInteraction,
//             style: TextStyles.smallHintText,
//             validator: widget.validationFunction,
//             decoration: InputDecoration(
//               hintText: "mm/dd/yyyy",
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack),
//               //filled: true,
//               suffixIcon: widget.suffixIcon,
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: CustomColor.homeGrey.withOpacity(0.4),
//                 ),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: CustomColor.homeGrey.withOpacity(0.4),
//                 ),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               disabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: CustomColor.homeGrey.withOpacity(0.4),
//                 ),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: CustomColor.orange.withOpacity(0.4),
//                 ),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: CustomColor.orange.withOpacity(0.4),
//                 ),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//             ),
//           );
//         }
//       case Type.normal2:
//         {
//           return TextFormField(textAlign: TextAlign.center,
//             controller: _thisController,
//             keyboardType: TextInputType.number,
//             autofocus: false,
//             maxLines: 1,
//             readOnly: widget.isReadOnly??false,
//             style: TextStyles.smallHintText,
//             validator: validateName,
//             inputFormatters: <TextInputFormatter>[
//               FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//             ],
//             onChanged: widget.onChanged,
//             decoration: InputDecoration(
//               fillColor: widget.fillColor,
//               contentPadding: EdgeInsets.zero,
//               hintText: widget.hintText,
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack),
//               //filled: true,
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: Colors.transparent,
//               ),),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                     color: Colors.transparent, width: 2),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               disabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                     color: Colors.transparent, width: 2),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.transparent,
//                 ),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                   color: Colors.transparent,
//                 ),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//             ),
//           );
//         }
//       case Type.datePickerWithPrefix:
//         {
//           return TextFormField(
//             controller: widget.controller,
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Icons.date_range),
//               hintText: widget.hintText,
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack),
//               focusColor: const Color.fromRGBO(18, 67, 63, 1),
//               fillColor: Colors.white,
//               hoverColor: const Color.fromRGBO(18, 67, 63, 1),
//               isDense: true,
//               contentPadding: const EdgeInsets.all(10),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               border: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//             ),
//             onTap: widget.onTap,
//           );
//         }
//       case Type.timePickerWithPrefix:
//         {
//           return TextFormField(
//             readOnly: widget.readOnly!,
//             controller: widget.controller,
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Icons.watch_later_outlined),
//               hintText: widget.hintText,
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack),
//               focusColor: const Color.fromRGBO(18, 67, 63, 1),
//               fillColor: Colors.white,
//               hoverColor: const Color.fromRGBO(18, 67, 63, 1),
//               isDense: true,
//               contentPadding: const EdgeInsets.all(10),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               border: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//             ),
//             onTap: widget.onTap,
//           );
//         }
//       case Type.datePicker:
//         {
//           return TextFormField(
//             controller: widget.controller,readOnly: widget.isReadOnly ?? false,
//             decoration: InputDecoration(
//               suffixIcon: const Icon(Icons.date_range),
//               hintText: widget.hintText,
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack),
//               focusColor: const Color.fromRGBO(18, 67, 63, 1),
//               fillColor: Colors.white,
//               hoverColor: const Color.fromRGBO(18, 67, 63, 1),
//               isDense: true,
//               contentPadding: const EdgeInsets.all(10),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               border: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//             ),
//             onTap: widget.onTap,
//           );
//         }
//          case Type.monthPicker:
//         {
//           return TextFormField(
//             controller: widget.controller,
//             decoration: InputDecoration(
//               suffixIcon: const Icon(Icons.date_range),
//               hintText: "mm/yyyy",
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack),
//               focusColor: const Color.fromRGBO(18, 67, 63, 1),
//               fillColor: Colors.white,
//               hoverColor: const Color.fromRGBO(18, 67, 63, 1),
//               isDense: true,
//               contentPadding: const EdgeInsets.all(10),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               border: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//             ),
//             onTap: widget.onTap,
//           );
//         }
//       case Type.phone:
//         {
//           return TextFormField(
//             controller: widget.controller,
//             keyboardType: TextInputType.phone,
// readOnly: widget.isReadOnly ?? false,
//             // maxLength: 14,
//             onChanged: widget.onChanged,
//             decoration: InputDecoration(
//               hintText: widget.hintText,
//
//               hintStyle: const TextStyle(),
//               focusColor: const Color.fromRGBO(18, 67, 63, 1),
//               fillColor: Colors.white,
//               hoverColor: const Color.fromRGBO(18, 67, 63, 1),
//               isDense: true,
//               contentPadding: const EdgeInsets.all(10),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               border: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//             ),
//           );
//         }
//       case Type.normal:
//         {
//           return TextFormField(
//             controller: widget.controller,
//             keyboardType: widget.keyboardType??TextInputType.number,
//             onChanged: widget.onChanged,
//             validator: widget.validator,
//             readOnly: widget.isReadOnly ?? false,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             decoration: InputDecoration(
//               hintText: widget.hintText,
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack),
//               focusColor: const Color.fromRGBO(18, 67, 63, 1),
//               fillColor: Colors.white,
//               hoverColor: const Color.fromRGBO(18, 67, 63, 1),
//               isDense: true,
//               contentPadding: const EdgeInsets.all(10),
//               errorBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 borderSide: BorderSide(
//                     color: Color(0xFFE8503A),
//                     width: 1,
//                     style: BorderStyle.solid),
//               ),
//               focusedErrorBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 borderSide: BorderSide(
//                     color: Color(0xFFE8503A),
//                     width: 1,
//                     style: BorderStyle.solid),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               border: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//               enabledBorder: widget.outlineInputBorder
//             ),
//           );
//         }
//       case Type.description:
//         {
//           return TextFormField(
//             onSaved: widget.onSaved,
//             onChanged: widget.onChanged,
//             initialValue: widget.initialValue,
//             controller: widget.controller,
//             //validator: passwordValidator,
//             keyboardType: TextInputType.text,
//             readOnly: widget.isReadOnly ?? false,
//             autofocus: false,
//             maxLines: 4,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             style: Get.textTheme.bodySmall,
//             decoration: InputDecoration(
//               fillColor: widget.fillColor ?? Get.theme.canvasColor,
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               labelText: widget.labelText,
//               hintText: widget.hintText ?? '',
//               hintStyle: TextStyles.subtitleExtraSmall.copyWith(
//                   fontSize: 14,
//                   color: CustomColor.primaryBlack
//                   ),
//               prefixIcon: widget.prefixIcon,
//               prefixIconConstraints: widget.iconData != null
//                   ? BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty,
//                       height: ScreenConstant.defaultWidthTwenty)
//                   : BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty, height: 0),
//               labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
//                   color: Get.theme.colorScheme.onSurface,
//                   fontFamily: 'NunitoSans'),
//               contentPadding: EdgeInsets.symmetric(
//                   vertical: ScreenConstant.defaultHeightTen,
//                   horizontal: ScreenConstant.defaultWidthTen),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               errorBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 borderSide: BorderSide(
//                     color: Color(0xFFE8503A),
//                     width: 1,
//                     style: BorderStyle.solid),
//               ),
//         enabledBorder: widget.outlineInputBorder,
//               focusedErrorBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//                 borderSide: BorderSide(
//                     color: Color(0xFFE8503A),
//                     width: 1,
//                     style: BorderStyle.solid),
//               ),
//
//             ),
//           );
//         }
//       case Type.textFieldWithSuffix:
//         {
//           return TextFormField(
//             onSaved: widget.onSaved,
//             onChanged: widget.onChanged,
//             initialValue: widget.initialValue,
//             //validator: passwordValidator,
//             keyboardType: TextInputType.text,
//             autofocus: false,
//             maxLines: 1,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             obscureText: indicator,
//             obscuringCharacter: '●',
//             style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                 color: Get.theme.colorScheme.onSurface,
//                 fontFamily: 'NunitoSans'),
//             decoration: InputDecoration(
//               fillColor: CustomColor.primaryOffWhiteColor,
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               labelText: widget.labelText,
//               hintText: widget.hintText ?? '',
//               hintStyle: TextStyles.hintTextStyle,
//               prefixIcon: widget.prefixIcon,
//               prefixIconConstraints: widget.iconData != null
//                   ? BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty,
//                       height: ScreenConstant.defaultWidthTwenty)
//                   : BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty, height: 0),
//               suffixIcon: IconButton(
//                 icon: indicator
//                     ? Image.asset(
//                         ImageUtils.passwordIcon,
//                         width: 20,
//                       )
//                     : Image.asset(
//                         ImageUtils.passwordVisible,
//                         width: 20,
//                       ),
//                 onPressed: toggle,
//               ),
//               labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
//                   color: Get.theme.colorScheme.onSurface,
//                   fontFamily: 'NunitoSans'),
//               contentPadding: EdgeInsets.symmetric(
//                   vertical: ScreenConstant.defaultHeightTwentyThree),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.1), width: 2),
//               ),
//             ),
//           );
//         }
//       case Type.searchField:
//         {
//           return TextFormField(
//             onSaved: widget.onSaved,
//             onChanged: widget.onChanged,
//             initialValue: widget.initialValue,
//             //validator: passwordValidator,
//             keyboardType: TextInputType.text,
//             autofocus: false,
//             maxLines: 1,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             obscureText: indicator,
//             obscuringCharacter: '●',
//             style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                 color: Get.theme.colorScheme.onSurface,
//                 fontFamily: 'NunitoSans'),
//             decoration: InputDecoration(
//               fillColor: CustomColor.white,
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               labelText: widget.labelText,
//               hintText: widget.hintText ?? '',
//               hintStyle: TextStyles.hintTextStyle,
//               prefixIcon: widget.prefixIcon,
//               prefixIconConstraints: widget.iconData != null
//                   ? BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty,
//                       height: ScreenConstant.defaultWidthTwenty)
//                   : BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty, height: 0),
//               suffixIcon: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: ScreenConstant.defaultHeightFifteen),
//                 child: Image.asset(
//                   ImageUtils.searchIcon,
//                   fit: BoxFit.contain,
//                   width: ScreenConstant.defaultWidthTen,
//                 ),
//               ),
//               labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
//                   color: Get.theme.colorScheme.onSurface,
//                   fontFamily: 'NunitoSans'),
//               contentPadding: EdgeInsets.symmetric(
//                   vertical: ScreenConstant.defaultHeightTen),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 borderSide: BorderSide(color: CustomColor.white, width: 2),
//               ),
//             ),
//           );
//         }
//       case Type.emailFieldWithOutPrefixAndSuffix:
//         {
//           return TextFormField(
//             onSaved: widget.onSaved,
//             onChanged: widget.onChanged,
//             initialValue: widget.initialValue,
//             //validator: passwordValidator,
//             keyboardType: TextInputType.text,
//             autofocus: false,
//             maxLines: 1,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             obscureText: indicator,
//             obscuringCharacter: '●',
//             style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                 color: Get.theme.colorScheme.onSurface,
//                 fontFamily: 'NunitoSans'),
//             decoration: InputDecoration(
//               fillColor: CustomColor.fillOffWhiteColor,
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               labelText: widget.labelText,
//               hintText: widget.hintText ?? '',
//               hintStyle: TextStyles.hintTextStyle
//                   .copyWith(color: CustomColor.secondaryBlack, fontSize: 16),
//               prefixIcon: widget.prefixIcon,
//               prefixIconConstraints: widget.iconData != null
//                   ? BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty,
//                       height: ScreenConstant.defaultWidthTwenty)
//                   : BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty, height: 0),
//               labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
//                   color: Get.theme.colorScheme.onSurface,
//                   fontFamily: 'NunitoSans'),
//               contentPadding: EdgeInsets.symmetric(
//                   vertical: ScreenConstant.defaultHeightTwentyThree),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.6),
//                     width: 2,
//                   )),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 borderSide: BorderSide(
//                     color: CustomColor.homeGrey.withOpacity(0.4), width: 2),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 borderSide: BorderSide(color: CustomColor.white, width: 2),
//               ),
//             ),
//           );
//         }
//       case Type.stageName:
//         {
//           return TextFormField(
//             onSaved: widget.onSaved,
//             onChanged: widget.onChanged,
//             initialValue: widget.initialValue,
//             controller: widget.controller,
//             //validator: passwordValidator,
//             keyboardType: TextInputType.text,
//             autofocus: false,
//             maxLines: 1,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             style: Get.textTheme.bodySmall,
//             decoration: InputDecoration(
//               fillColor: Get.theme.canvasColor,
//               filled: true,
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               labelText: widget.labelText,
//               hintText: widget.hintText ?? '',
//               hintStyle: Get.textTheme.bodyMedium,
//               prefixIcon: widget.prefixIcon,
//               prefixIconConstraints: widget.iconData != null
//                   ? BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty,
//                       height: ScreenConstant.defaultWidthTwenty)
//                   : BoxConstraints.expand(
//                       width: ScreenConstant.defaultWidthTwenty, height: 0),
//               labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
//                   color: Get.theme.colorScheme.onSurface,
//                   fontFamily: 'NunitoSans'),
//               contentPadding: EdgeInsets.symmetric(
//                   vertical: ScreenConstant.defaultHeightTwentyThree - 5),
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   borderSide: BorderSide(
//                     color: CustomColor.primaryBlue.withOpacity(0.6),
//                     width: 2,
//                   )),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: CustomColor.primaryBlue.withOpacity(0.4), width: 2),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide:
//                     BorderSide(color: CustomColor.primaryBlue, width: 2),
//               ),
//             ),
//           );
//         }
//     }
//   }
//
//   void toggle() {
//     setState(() {
//       indicator = !indicator;
//     });
//   }
//
//   String? validateName(String? value) {
//     if (value!.isEmpty) {
//       return "This field is required";
//     } else {
//       return null;
//     }
//   }
//
//   String? get validatePassword {
//     final value = widget.initialValue;
//     String pattern =
//         r"(^(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&.*':;â‚¬#])[A-Za-z\d@$!%*?&.*':;â‚¬#]{8,}$)";
//     RegExp regExp = RegExp(pattern);
//     if (value.isEmpty) {
//       if (widget.onSubmit) {
//         return "Password field can not be blank.";
//       } else {
//         return null;
//       }
//     }
//     return null;
//   }
// }
