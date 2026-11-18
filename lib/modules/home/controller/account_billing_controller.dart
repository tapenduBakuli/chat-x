import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/Store/HiveStore.dart';
import '../../../utils/card_input_utils.dart';
import '../../register/model/payment_method_response_model.dart';
import '../../register/services/payment_services.dart';
import '../model/subscription_info.dart';
import '../services/billing_services.dart';

enum BillingLoadState { idle, loading, loaded, empty, error }

/// Accounts tab billing: subscription (GET subscriptions/me) and the saved
/// payment method (GET / DELETE / POST users/me/payment-method). The two loads
/// are independent; one failing never blocks the other.
class AccountBillingController extends GetxController {
  static const Duration _throttle = Duration(seconds: 10);

  final Rx<BillingLoadState> subscriptionState = BillingLoadState.idle.obs;
  final Rx<BillingLoadState> paymentState = BillingLoadState.idle.obs;
  final Rxn<SubscriptionInfo> subscription = Rxn<SubscriptionInfo>();
  final Rxn<PaymentMethodData> paymentMethod = Rxn<PaymentMethodData>();
  final RxString subscriptionError = ''.obs;
  final RxString paymentError = ''.obs;

  final RxBool isDeleting = false.obs;
  final RxBool isSaving = false.obs;
  final RxnString saveError = RxnString();

  // Save-form state (owned here so the dialog needs no disposal).
  final TextEditingController cardholderCtrl = TextEditingController();
  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController cvvCtrl = TextEditingController();
  final RxnInt expiryMonth = RxnInt();
  final RxnInt expiryYear = RxnInt();

  DateTime? _lastFetch;
  bool _isFetching = false;
  bool _hasLoaded = false;

  /// Called from HomeController.selectNavTab(3).
  Future<void> onTabOpened() => refreshAll(force: !_hasLoaded);

  /// Fetches both cards in parallel. Throttled to once per 10 s unless [force].
  Future<void> refreshAll({bool force = false}) async {
    if (_isFetching) return;
    final now = DateTime.now();
    if (!force &&
        _lastFetch != null &&
        now.difference(_lastFetch!) < _throttle) {
      return;
    }
    final token = HiveStore().getString(Keys.ACCESSTOKEN);
    if (token == null || token.toString().isEmpty) return;
    _isFetching = true;
    _lastFetch = now;
    try {
      await Future.wait([loadSubscription(), loadPaymentMethod()]);
      final bool subOk = subscriptionState.value != BillingLoadState.error;
      final bool payOk = paymentState.value != BillingLoadState.error;
      if (!subOk && !payOk) {
        _lastFetch = null; // next tab entry retries immediately
      } else {
        _hasLoaded = true;
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadSubscription() async {
    if (subscription.value == null) {
      subscriptionState.value = BillingLoadState.loading;
    }
    final res = await BillingService.instance.fetchSubscription();
    if (res.success && res.data != null) {
      subscription.value = res.data;
      subscriptionState.value = BillingLoadState.loaded;
    } else if (subscription.value != null) {
      // Keep the last known data on a failed refresh.
      subscriptionState.value = BillingLoadState.loaded;
    } else {
      subscriptionError.value = res.message;
      subscriptionState.value = BillingLoadState.error;
    }
  }

  Future<void> loadPaymentMethod() async {
    if (paymentMethod.value == null) {
      paymentState.value = BillingLoadState.loading;
    }
    final res = await BillingService.instance.fetchPaymentMethod();
    if (res.success) {
      paymentMethod.value = res.data;
      paymentState.value =
          res.data == null ? BillingLoadState.empty : BillingLoadState.loaded;
    } else if (paymentMethod.value != null) {
      paymentState.value = BillingLoadState.loaded;
    } else {
      paymentError.value = res.message;
      paymentState.value = BillingLoadState.error;
    }
  }

  Future<void> retrySubscription() => loadSubscription();
  Future<void> retryPaymentMethod() => loadPaymentMethod();

  /// DELETE the saved card. True on success (caller then shows the mandatory
  /// save modal). On failure the card is left as is.
  Future<bool> deletePaymentMethod() async {
    if (isDeleting.value) return false;
    isDeleting.value = true;
    try {
      final res = await BillingService.instance.deletePaymentMethod();
      if (res.success) {
        paymentMethod.value = null;
        paymentState.value = BillingLoadState.empty;
        Get.snackbar(
          'Payment method deleted',
          res.message.isEmpty ? 'Your saved card was removed.' : res.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      Get.snackbar('Could not delete', res.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  void resetSaveForm() {
    cardholderCtrl.clear();
    cardNumberCtrl.clear();
    cvvCtrl.clear();
    expiryMonth.value = null;
    expiryYear.value = null;
    saveError.value = null;
  }

  /// Validates then POSTs the card via the shared onboarding service.
  Future<bool> savePaymentMethod() async {
    if (isSaving.value) return false;
    final String? err = validateCardholderName(cardholderCtrl.text) ??
        validateCardNumber(cardNumberCtrl.text) ??
        validateExpiry(expiryMonth.value, expiryYear.value) ??
        validateCvv(cvvCtrl.text);
    if (err != null) {
      saveError.value = err;
      return false;
    }
    saveError.value = null;
    isSaving.value = true;
    try {
      final res = await PaymentService.instance.saveCardPaymentMethod(
        cardNumber: stripCardNumber(cardNumberCtrl.text),
        cardholderName: cardholderCtrl.text.trim(),
        expiryMonth: expiryMonth.value!,
        expiryYear: expiryYear.value!,
        cvv: cvvCtrl.text.trim(),
      );
      if (res.success) {
        Get.snackbar(
          'Payment method saved',
          res.message.isEmpty ? 'Payment method saved' : res.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        resetSaveForm();
        if (res.data != null) {
          paymentMethod.value = res.data;
          paymentState.value = BillingLoadState.loaded;
        } else {
          await loadPaymentMethod();
        }
        return true;
      }
      saveError.value = res.message;
      Get.snackbar('Could not save', res.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    cardholderCtrl.dispose();
    cardNumberCtrl.dispose();
    cvvCtrl.dispose();
    super.onClose();
  }
}
