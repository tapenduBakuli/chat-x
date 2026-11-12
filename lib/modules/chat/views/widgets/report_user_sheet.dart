import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../../../utils/custom_widgets/universal_button.dart';
import '../../model/report_model.dart';
import '../../services/report_service.dart';

/// GetX controller driving the Report User flow.
class ReportController extends GetxController {
  final String reportedUserId;
  final String displayName;

  ReportController({
    required this.reportedUserId,
    required this.displayName,
  });

  final TextEditingController otherTextController = TextEditingController();
  final RxList<ReportReason> reasons = <ReportReason>[].obs;
  final Rxn<ReportReason> selectedReason = Rxn<ReportReason>();
  final RxBool isLoadingReasons = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadReasons();
  }

  Future<void> loadReasons() async {
    isLoadingReasons.value = true;
    errorMessage.value = '';

    final res = await ReportService.instance.fetchReasons();
    if (res.success && res.reasons.isNotEmpty) {
      reasons.assignAll(res.reasons);
      isLoadingReasons.value = false;
    } else {
      errorMessage.value = res.message.isNotEmpty
          ? res.message
          : 'Could not load report reasons.';
      isLoadingReasons.value = false;
    }
  }

  bool get isOther => selectedReason.value?.code.toLowerCase() == 'other';

  Future<void> submitReport(BuildContext context) async {
    final reason = selectedReason.value;
    if (reason == null || isSubmitting.value) return;

    final String customText = otherTextController.text.trim();

    if (isOther && customText.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter a reason for reporting.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String reasonText = isOther ? customText : reason.label;

    final nav = Navigator.of(context);
    isSubmitting.value = true;

    final res = await ReportService.instance.submitReport(
      reportedUserId: reportedUserId,
      reasonCode: reason.code,
      reasonText: reasonText,
    );

    isSubmitting.value = false;

    if (res.success) {
      nav.pop();
      Get.snackbar(
        'Report Submitted',
        res.message.isNotEmpty ? res.message : 'Report submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Could not submit report',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

/// Opens the Report User modal bottom sheet for [reportedUserId].
void showReportUserBottomSheet({
  required BuildContext context,
  required String reportedUserId,
  required String displayName,
}) {
  final controller = Get.put(
    ReportController(
      reportedUserId: reportedUserId,
      displayName: displayName,
    ),
    tag: reportedUserId,
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: CustomColor.colorWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: ReportUserSheet(
          controller: controller,
          displayName: displayName,
        ),
      );
    },
  );
}

/// Modal bottom sheet widget driven by GetX state.
class ReportUserSheet extends StatelessWidget {
  final ReportController controller;
  final String displayName;

  const ReportUserSheet({
    super.key,
    required this.controller,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          ScreenConstant.defaultWidthTwenty,
          ScreenConstant.sizeMedium,
          ScreenConstant.defaultWidthTwenty,
          ScreenConstant.sizeLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.colorBE185D,
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                Expanded(
                  child: Text(
                    "Report $displayName",
                    style: TextStyles.registerSectionTitle.copyWith(
                      fontSize: FontSize.s16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.color64748B,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Text(
              "Help us keep ChatX safe. Select a reason for reporting this user.",
              style: TextStyles.loginWelcomeSubtitle.copyWith(
                fontSize: FontSize.s13,
              ),
            ),
            SizedBox(height: ScreenConstant.sizeLarge),

            Obx(() {
              if (controller.isLoadingReasons.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenConstant.sizeLarge,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CustomColor.colorBE185D,
                      ),
                    ),
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Column(
                  children: [
                    Text(
                      controller.errorMessage.value,
                      style: TextStyles.registerFieldNote.copyWith(
                        color: CustomColor.colorE11D48,
                      ),
                    ),
                    SizedBox(height: ScreenConstant.sizeSmall),
                    TextButton(
                      onPressed: controller.loadReasons,
                      child: const Text("Retry"),
                    ),
                  ],
                );
              }

              final bool isOther = controller.isOther;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reasons Dropdown
                  Text(
                    "Reason",
                    style: TextStyles.registerFieldLabel,
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  DropdownButtonFormField<ReportReason>(
                    initialValue: controller.selectedReason.value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CustomColor.colorF8FAFC,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: ScreenConstant.sizeMedium,
                        vertical: ScreenConstant.sizeSmall,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: CustomColor.colorE2E8F0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: CustomColor.colorE2E8F0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: CustomColor.colorBE185D,
                          width: 1.5,
                        ),
                      ),
                    ),
                    hint: Text(
                      "Select a reason",
                      style: TextStyles.loginFieldHint,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: CustomColor.color64748B,
                      size: ScreenConstant.smallIconSize,
                    ),
                    isExpanded: true,
                    items: controller.reasons.map((r) {
                      return DropdownMenuItem<ReportReason>(
                        value: r,
                        child: Text(
                          r.label,
                          style: TextStyles.loginFieldText.copyWith(
                            fontSize: FontSize.s14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedReason.value = val;
                    },
                  ),
                  SizedBox(height: ScreenConstant.sizeMedium),

                  // Conditional Text Input Field when 'Other' is selected
                  if (isOther) ...[
                    Text(
                      "Specify Reason",
                      style: TextStyles.registerFieldLabel,
                    ),
                    SizedBox(height: ScreenConstant.sizeSmall),
                    TextField(
                      controller: controller.otherTextController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Please describe the issue in detail...",
                        hintStyle: TextStyles.loginFieldHint,
                        filled: true,
                        fillColor: CustomColor.colorF8FAFC,
                        contentPadding:
                            EdgeInsets.all(ScreenConstant.sizeMedium),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: CustomColor.colorE2E8F0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: CustomColor.colorE2E8F0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: CustomColor.colorBE185D,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenConstant.sizeMedium),
                  ],

                  SizedBox(height: ScreenConstant.sizeSmall),

                  // Submit Button
                  controller.isSubmitting.value
                      ? Container(
                          height: ScreenConstant.defaultHeightFifty,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                CustomColor.colorBE185D,
                                CustomColor.color581C87,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                CustomColor.colorWhite,
                              ),
                            ),
                          ),
                        )
                      : buildLoginButton(
                          "Submit Report",
                          controller.selectedReason.value != null,
                          () => controller.submitReport(context),
                          Icons.send_outlined,
                          height: ScreenConstant.defaultHeightFifty,
                          fontSize: FontSize.s14,
                          iconSize: ScreenConstant.minimumIconSize,
                        ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
