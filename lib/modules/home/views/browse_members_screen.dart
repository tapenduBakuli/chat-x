import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_text_field.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../controller/home_controller.dart';
import '../model/member.dart';
import 'widgets/member_network_image.dart';
import 'widgets/reset_password_dialogs.dart';

/// The authenticated home: browse member profiles in a Grid or a Tinder-style
/// Deck, filterable by city. Light/whitish aesthetic with rose accents, reused
/// from the auth flow. The header and city chips stay pinned; only the body
/// (grid/deck) area reacts to state.
class BrowseMembersScreen extends GetView<HomeController> {
  const BrowseMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                switch (controller.selectedNavIndex.value) {
                  case 0:
                    return _buildExploreTab();
                  case 1:
                    return _buildChatTab();
                  case 2:
                    return _buildFriendsTab();
                  case 3:
                    return _buildAccountsTab();
                  case 4:
                    return _buildBlockedTab();
                  default:
                    return _buildExploreTab();
                }
              }),
            ),
            Positioned(
              left: ScreenConstant.defaultWidthTen,
              right: ScreenConstant.defaultWidthTen,
              bottom: 0,
              child: Obx(() => _buildBottomNavBar()),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Views
  // ---------------------------------------------------------------------------
  Widget _buildExploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchRow(),
        SizedBox(height: ScreenConstant.defaultHeightTen),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    CustomColor.colorBE185D,
                  ),
                ),
              );
            }
            if (controller.filteredMembers.isEmpty) {
              return _emptyFiltered();
            }
            return controller.viewMode.value == HomeViewMode.grid
                ? _buildGrid()
                : _buildDeck();
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildChatTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
       Icon(Icons.chat_bubble_outline_outlined,color: CustomColor.color64748B,size: ScreenConstant.miniIconSize,),
        Text("No conversation yet.",  style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s16),),
        Text("Start conversation directly by browsing members in search.",  style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s12,color: CustomColor.color64748B),),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenConstant.defaultWidthNinetyEight),
          child: Container(height: ScreenConstant.defaultHeightForty,child: _buildContinueButton()),
        )
      ],
    );
  }


  Widget _buildFriendsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline_outlined,color: CustomColor.color64748B,size: ScreenConstant.miniIconSize,),
        Text("No friends yet.",  style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s16),),
        Text("Start conversation directly by browsing members in search.",  style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s12,color: CustomColor.color64748B),),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenConstant.defaultWidthNinetyEight),
          child: Container(height: ScreenConstant.defaultHeightForty,child: _buildContinueButton()),
        )
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Accounts tab — scrollable page of settings cards. Most sections are
  // static/demo (APIs land later); only the invisible toggle, plan highlight,
  // the show-password toggles, and the reset-password dialog flow are live.
  // ---------------------------------------------------------------------------
  Widget _buildAccountsTab() {
    // Builder gives the dialogs a Navigator-aware context beneath the
    // Navigator (same trick used by _buildSearchRow).
    return Builder(
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightTen,
            ScreenConstant.defaultWidthTwenty,
            110, // clears the floating bottom nav
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header. // STATIC
              Text(
                "Accounts",
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s24,
                ),
              ),
              SizedBox(height: ScreenConstant.sizeExtraSmall),
              Text(
                "Manage your verified banking credentials, subscription "
                "passes, privacy, password, and security policy.",
                style: TextStyles.loginWelcomeSubtitle,
              ),
              SizedBox(height: ScreenConstant.sizeMedium),
              _accountsBankingCard(),
              SizedBox(height: ScreenConstant.sizeMedium),
              _accountsSubscriptionCard(),
              SizedBox(height: ScreenConstant.sizeMedium),
              _accountsEmailPrivacyCard(),
              SizedBox(height: ScreenConstant.sizeMedium),
              _accountsChangePasswordCard(context),
              SizedBox(height: ScreenConstant.sizeMedium),
              _accountsDangerZoneCard(context),
            ],
          ),
        );
      },
    );
  }

  // --- Shared Accounts-card building blocks ----------------------------------

  /// White rounded card with the standard soft shadow. [borderColor] adds an
  /// optional tinted border (used by the Danger Zone card).
  Widget _accountCard({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color717B96.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Section header: a small rose (or custom-colored) icon + bold title, with
  /// an optional right-aligned trailing widget (pill or link).
  Widget _accountSectionHeader(
    IconData icon,
    String title, {
    Color iconColor = CustomColor.colorBE185D,
    Color? titleColor,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: ScreenConstant.smallIconSize, color: iconColor),
        SizedBox(width: ScreenConstant.sizeSmall),
        Expanded(
          child: Text(
            title,
            style: TextStyles.registerSectionTitle.copyWith(
              fontSize: FontSize.s14,
              color: titleColor,
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: ScreenConstant.sizeSmall),
          trailing,
        ],
      ],
    );
  }

  /// Light-filled inner tile (colorF8FAFC + border) used inside cards.
  Widget _innerTile({required Widget child, Color? fill, Color? border}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeSmallHighest),
      decoration: BoxDecoration(
        color: fill ?? CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border ?? CustomColor.colorE2E8F0),
      ),
      child: child,
    );
  }

  /// Small rounded pill (e.g. "Verified 18+ Account").
  Widget _pill(
    String text, {
    required Color bg,
    required Color fg,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: ScreenConstant.minimumIconSize - 1, color: fg),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
          ],
          Text(
            text,
            style: TextStyles.registerFieldNote.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Section 1: Verified Banking Credentials (STATIC) ----------------------
  Widget _accountsBankingCard() {
    return _accountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accountSectionHeader(
            Icons.credit_card_outlined,
            "Verified Banking Credentials",
            trailing: _pill(
              "Verified 18+ Account",
              bg: CustomColor.colorECFDF5,
              fg: CustomColor.color059669,
              icon: Icons.verified_user_outlined,
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Two inner tiles. // STATIC
          _innerTile(
            child: _bankingTileContent(
              "PAYMENT PROVIDER",
              "BANCONTACT (SEPA / Bancontact)",
            ),
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          _innerTile(
            child: _bankingTileContent(
              "MASKED MANDATE IDENTIFIER",
              "BE76 •••• •••• 7890",
            ),
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          // Rose guarantee strip. // STATIC
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ScreenConstant.sizeSmallHighest),
            decoration: BoxDecoration(
              color: CustomColor.colorFFF1F2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.colorBE123C,
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyles.registerFieldNote.copyWith(
                        color: CustomColor.color334155,
                      ),
                      children: const [
                        TextSpan(
                          text: "Bank Guarantee: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Stored securely under CX-NETWORK BV in "
                              "compliance with Belgian financial regulations. "
                              "Zero unauthorized recurring debits.",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankingTileContent(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.registerFieldNote.copyWith(
            color: CustomColor.color94A3B8,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall / 1.5),
        Text(
          value,
          style: TextStyles.browseToggleLabel.copyWith(
            color: CustomColor.color0F172A,
            fontSize: FontSize.s14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- Section 2: Manage Subscription & Passes (STATIC/DEMO) -----------------
  Widget _accountsSubscriptionCard() {
    return _accountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accountSectionHeader(
            Icons.auto_awesome,
            "Manage Subscription & Passes",
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // DEMO copy.
          Text(
            "ChatX is designed to remain extremely accessible: €9.99 per "
            "month across all options. Pay month-by-month or choose 1, 3, or "
            "6 months upfront with identical monthly pricing. Cancel anytime "
            "with 1 click.",
            style: TextStyles.registerFieldNote.copyWith(
              color: CustomColor.color64748B,
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Active pass strip. // DEMO
          _innerTile(
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.colorBE185D,
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyles.browseToggleLabel.copyWith(
                        color: CustomColor.color334155,
                        fontSize: FontSize.s13,
                      ),
                      children: [
                        const TextSpan(text: "Active Pass: "),
                        TextSpan(
                          text: "1-Month Single Pass (€9.99)",
                          style: TextStyle(
                            color: CustomColor.colorBE185D,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Four plan cards in a horizontal scroll row. // DEMO
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _planCard(
                  index: 0,
                  name: "Monthly",
                  sub: "Cancel anytime",
                  price: "€9.99",
                  period: "/ month",
                  badge: _planBadge(
                    "Popular",
                    bg: CustomColor.colorFFF1F2,
                    fg: CustomColor.colorBE185D,
                  ),
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                _planCard(
                  index: 1,
                  name: "1 Month",
                  sub: "One-time pass",
                  price: "€9.99",
                  period: "single charge",
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                _planCard(
                  index: 2,
                  name: "3 Months",
                  sub: "€9.99 / month",
                  price: "€29.97",
                  period: "for 3 months",
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                _planCard(
                  index: 3,
                  name: "6 Months",
                  sub: "€9.99 / month",
                  price: "€59.94",
                  period: "for 6 months",
                  badge: _planBadge(
                    "VIP Pass",
                    bg: CustomColor.color9333EA.withOpacity(0.12),
                    fg: CustomColor.color9333EA,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planBadge(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyles.registerFieldNote.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _planCard({
    required int index,
    required String name,
    required String sub,
    required String price,
    required String period,
    Widget? badge,
  }) {
    return Obx(() {
      final bool selected = controller.selectedPlanIndex.value == index;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.selectPlan(index),
        child: Container(
          width: 160,
          padding: EdgeInsets.all(ScreenConstant.sizeSmallHighest),
          decoration: BoxDecoration(
            color: selected
                ? CustomColor.colorFFF1F2
                : CustomColor.colorF8FAFC,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? CustomColor.colorBE185D
                  : CustomColor.colorE2E8F0,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyles.browseToggleLabel.copyWith(
                        color: CustomColor.color0F172A,
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (badge != null) badge,
                ],
              ),
              SizedBox(height: ScreenConstant.sizeExtraSmall / 1.5),
              Text(
                sub,
                style: TextStyles.registerFieldNote.copyWith(
                  color: CustomColor.color64748B,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenConstant.sizeSmall,
                ),
                child: Divider(
                  height: 1,
                  color: CustomColor.colorE2E8F0,
                ),
              ),
              Text(
                price,
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s18,
                  color: CustomColor.colorBE185D,
                ),
              ),
              SizedBox(height: ScreenConstant.sizeExtraSmall / 2),
              Text(
                period,
                style: TextStyles.registerFieldNote.copyWith(
                  color: CustomColor.color94A3B8,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // --- Section 3: Registered Email Address & Privacy -------------------------
  Widget _accountsEmailPrivacyCard() {
    return _accountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accountSectionHeader(
            Icons.mail_outline,
            "Registered Email Address & Privacy",
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Email tile. // STATIC
          _innerTile(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "user@chatx.be",
                        style: TextStyle(
                          fontFamily: "monospace",
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.bold,
                          color: CustomColor.color0F172A,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeSmall),
                    _pill(
                      "Hidden from Public",
                      bg: CustomColor.colorECFDF5,
                      fg: CustomColor.color059669,
                      icon: Icons.visibility_off_outlined,
                    ),
                  ],
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                Text(
                  "Your email is permanently shielded from other members and "
                  "never displayed in search or chat.",
                  style: TextStyles.registerFieldNote.copyWith(
                    color: CustomColor.color64748B,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Invisibility row. INTERACTIVE — leading icon swaps with state.
          Obx(
            () => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  controller.isAccountInvisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.colorBE185D,
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Make Account Invisible",
                        style: TextStyles.browseToggleLabel.copyWith(
                          color: CustomColor.color0F172A,
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ScreenConstant.sizeExtraSmall / 1.5),
                      Text(
                        "When invisible, your profile is completely hidden "
                        "from Search, Discovery, and suggestions.",
                        style: TextStyles.registerFieldNote.copyWith(
                          color: CustomColor.color64748B,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ScreenConstant.sizeSmall),
                Switch(
                  value: controller.isAccountInvisible.value,
                  onChanged: controller.toggleInvisible,
                  activeColor: CustomColor.colorWhite,
                  activeTrackColor: CustomColor.colorBE185D,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section 4: Change Password (design + dialog triggers) -----------------
  Widget _accountsChangePasswordCard(BuildContext context) {
    return _accountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accountSectionHeader(
            Icons.vpn_key_outlined,
            "Change Password",
            trailing: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showResetEmailDialog(context, controller),
              child: Text(
                "Forgot Password?",
                style: TextStyles.loginForgotPassword.copyWith(
                  fontSize: FontSize.s12,
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          _changePwdField(
            controller.changeCurrentPasswordController,
            "Current Password",
          ),
          SizedBox(height: ScreenConstant.sizeExtraSmall),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showResetEmailDialog(context, controller),
              child: Text(
                "Forgot your password?",
                style: TextStyles.loginForgotPassword.copyWith(
                  fontSize: FontSize.s12,
                ),
              ),
            ),
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          _changePwdField(
            controller.changeNewPasswordController,
            "New Password (minimum 8 characters)",
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          _changePwdField(
            controller.changeConfirmPasswordController,
            "Confirm New Password",
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          // Show-passwords toggle (local state; flips all three fields).
          Obx(
            () => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.toggleShowChangePwd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.showChangePwd.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: ScreenConstant.minimumIconSize + 2,
                    color: CustomColor.color64748B,
                  ),
                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Show passwords",
                    style: TextStyles.registerFieldLabel.copyWith(
                      color: CustomColor.color64748B,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          buildLoginButton(
            "Update Password",
            true,
            () {
              // TODO: wire change-password API
              Get.snackbar(
                'Coming soon',
                'Password change will be available soon.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            Icons.lock_outline,
            height: ScreenConstant.defaultHeightFifty,
            fontSize: FontSize.s14,
            iconSize: ScreenConstant.minimumIconSize,
          ),
        ],
      ),
    );
  }

  Widget _changePwdField(TextEditingController ctrl, String hint) {
    return Obx(
      () => SizedBox(
        height: ScreenConstant.defaultHeightFifty + 5,
        child: CustomTextField(
          borderRadius: 100,
          controller: ctrl,
          hintText: hint,
          hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s13),
          obscureText: !controller.showChangePwd.value,
          textInputAction: TextInputAction.next,
          borderColor: CustomColor.colorE2E8F0,
          fillColor: CustomColor.colorF8FAFC,
          prefix: Icon(
            Icons.lock_outline,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color64748B,
          ),
        ),
      ),
    );
  }

  // --- Section 5: Danger Zone: Delete Account --------------------------------
  Widget _accountsDangerZoneCard(BuildContext context) {
    return _accountCard(
      borderColor: CustomColor.colorFECDD3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accountSectionHeader(
            Icons.delete_outline,
            "Danger Zone: Delete Account",
            iconColor: CustomColor.colorE11D48,
            titleColor: CustomColor.colorE11D48,
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Policy tile. // STATIC
          _innerTile(
            fill: CustomColor.colorFFF1F2,
            border: CustomColor.colorFECDD3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: ScreenConstant.smallIconSize,
                      color: CustomColor.colorBE123C,
                    ),
                    SizedBox(width: ScreenConstant.sizeSmall),
                    Text(
                      "Security Archive Policy",
                      style: TextStyles.browseToggleLabel.copyWith(
                        color: CustomColor.color0F172A,
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                Text(
                  "If your account is deleted, your profile information and "
                  "past chat histories are securely archived for safety, "
                  "harassment prevention, and regulatory audit compliance.",
                  style: TextStyles.registerFieldNote.copyWith(
                    color: CustomColor.color334155,
                  ),
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                RichText(
                  text: TextSpan(
                    style: TextStyles.registerFieldNote.copyWith(
                      color: CustomColor.color334155,
                    ),
                    children: const [
                      TextSpan(
                        text: "Re-Registration Notice: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "If a person registers again with the same "
                            "banking details, a new verified account is "
                            "created and previous records are linked as a "
                            "verified secondary instance of the same banking "
                            "mandate.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Solid RED button (not the rose gradient).
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _confirmDeleteAccount(context),
            child: Container(
              height: ScreenConstant.defaultHeightFifty,
              decoration: BoxDecoration(
                color: CustomColor.colorE11D48,
                borderRadius: BorderRadius.circular(100),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.colorWhite,
                  ),
                  SizedBox(width: ScreenConstant.sizeSmall),
                  Text(
                    "Delete My Account",
                    style: TextStyles.loginButtonText.copyWith(
                      fontSize: FontSize.s14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColor.colorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Delete account?",
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
          ),
          content: Text(
            "This action cannot be undone. Your profile will be removed and "
            "securely archived per the security policy.",
            style: TextStyles.loginWelcomeSubtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.color64748B,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: wire delete-account API
                Navigator.pop(dialogContext);
                Get.snackbar(
                  'Coming soon',
                  'Account deletion will be available soon.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text(
                "Delete",
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.colorE11D48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlockedTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.block,color: CustomColor.color64748B,size: ScreenConstant.miniIconSize,),
        Text("No blocked people.",  style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s16),),
        Text("Start conversation directly by browsing members in search.",  style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s12,color: CustomColor.color64748B),),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenConstant.defaultWidthNinetyEight),
          child: Container(height: ScreenConstant.defaultHeightForty,child: _buildContinueButton()),
        )
      ],
    );
  }


  Widget _buildContinueButton() {
    return buildLoginButton("Search Member", false, (){controller.selectedNavIndex.value = 0;}, null);
  }

  Widget _buildBlankTab(String title, IconData icon) {
    return Column(
      children: [
        // _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: CustomColor.color94A3B8,
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                Text(
                  title,
                  style: TextStyles.registerTitle.copyWith(
                    color: CustomColor.color64748B,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Floating Bottom Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavBar() {
    final int selectedIndex = controller.selectedNavIndex.value;

    return Container(
    //  height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FA),
        borderRadius: BorderRadius.circular(80),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color0F172A.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _navNavItem(
              index: 0,
              icon: Icons.explore_outlined,
              label: "Search",
              isSelected: selectedIndex == 0,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 1,
              icon: Icons.mark_chat_unread_outlined,
              label: "Chat",
              isSelected: selectedIndex == 1,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 2,
              icon: Icons.people_outline,
              label: "Friends",
              isSelected: selectedIndex == 2,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 3,
              icon: Icons.account_circle_outlined,
              label: "Accounts",
              isSelected: selectedIndex == 3,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 4,
              icon: Icons.block,
              label: "Blocked",
              isSelected: selectedIndex == 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final Color unselectedColor = CustomColor.color0F172A.withOpacity(0.4);

    final Icon iconWidget = Icon(
      icon,
      size: 15,
      // When selected, the ShaderMask paints the gradient; the base color must
      // be white/opaque so the shader shows through fully.
      color: isSelected ? CustomColor.colorWhite : unselectedColor,
    );

    final Text textWidget = Text(
      label,
      style: TextStyle(
        color: isSelected ? CustomColor.colorWhite : unselectedColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: "Liberation",
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.selectNavTab(index),
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        duration: const Duration(milliseconds: 200),
        // No background fill — selection is shown by tinting the icon + label
        // with the rose→purple gradient instead.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSelected ? _gradientTint(iconWidget) : iconWidget,
            isSelected ? _gradientTint(textWidget) : textWidget,
          ],
        ),
      ),
    );
  }

  /// Paints the rose→purple gradient onto [child] (icon or text) using a
  /// ShaderMask, so the glyph itself is gradient-colored.
  Widget _gradientTint(Widget child) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          CustomColor.colorBE185D,
          CustomColor.color581C87,
        ],
      ).createShader(bounds),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Profile Popup Menu
  // ---------------------------------------------------------------------------
  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: CustomColor.colorWhite,
      elevation: 12,
      onSelected: (value) {
        if (value == 'logout') {
          controller.onLogout();
        }else if (value == 'profile') {
          print("Profile");
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "JerryTwo",
                style: TextStyles.policiesItemTitle.copyWith(
                  fontSize: 16,
                  color: CustomColor.color0F172A,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: CustomColor.color059669,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Verified 18+ Member",
                    style: TextStyle(
                      color: CustomColor.color059669,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Liberation",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'profile',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: CustomColor.colorBE123C),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Profile",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'banking',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.credit_card_outlined, size: 20, color: CustomColor.colorBE123C),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Banking and Subscription Details",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'security',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: CustomColor.colorBE123C),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Security",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'blocked',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.block_outlined, size: 20, color: CustomColor.color64748B),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Blocked Members",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'logout',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 20, color: CustomColor.colorE11D48),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Log Out",
                  style: TextStyle(
                    color: CustomColor.colorE11D48,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Liberation",
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        width: ScreenConstant.defaultWidthForty,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColor.colorFFF1F2,
          border: Border.all(color: CustomColor.colorFFE4E6, width: 2),
        ),
        child: Icon(
          Icons.person_outline,
          color: CustomColor.colorE11D48,
          size: ScreenConstant.smallIconSize - 2,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenConstant.defaultWidthTen,
        ScreenConstant.defaultHeightTen,
        ScreenConstant.defaultWidthTen,
        ScreenConstant.sizeSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow pill with reactive online count.
          Row(
            children: [
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmall,
                    vertical: ScreenConstant.sizeExtraSmall / 1.2,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.colorECFDF5,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: CustomColor.color10B981,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Text(
                        "Active Members in Belgium",
                        style: TextStyles.registerZeroRisk,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Text(
                        "• ${controller.onlineCount} members online",
                        style: TextStyles.registerZeroRisk.copyWith(
                          color: CustomColor.color059669,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              _buildProfileMenu(),
            ],
          ),
          SizedBox(height: ScreenConstant.defaultHeightTen),
          // Title row with the view toggle + refresh.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Browse Members",
                  style: TextStyles.registerTitle.copyWith(
                    fontSize: FontSize.s18,
                  ),
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Obx(() => _viewToggle()),
              // SizedBox(width: ScreenConstant.sizeSmall),
              // _refreshButton(),
            ],
          ),
          // SizedBox(height: ScreenConstant.sizeExtraSmall),
          // Text(
          //   "Verified active members across Belgium. For discretion, exact "
          //   "locations remain hidden.",
          //   style: TextStyles.registerFieldNote,
          // ),
        ],
      ),
    );
  }

  Widget _viewToggle() {
    final mode = controller.viewMode.value;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CustomColor.colorE2E8F0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _togglePill(
            label: "Grid",
            icon: Icons.grid_view_rounded,
            active: mode == HomeViewMode.grid,
            onTap: () => controller.setViewMode(HomeViewMode.grid),
          ),
          _togglePill(
            label: "Deck",
            icon: Icons.style_outlined,
            active: mode == HomeViewMode.deck,
            onTap: () => controller.setViewMode(HomeViewMode.deck),
          ),
        ],
      ),
    );
  }

  Widget _togglePill({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeSmall,
          vertical: ScreenConstant.sizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: active ? CustomColor.colorBE185D : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ScreenConstant.minimumIconSize,
              color: active ? CustomColor.colorWhite : CustomColor.color64748B,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Text(
              label,
              style: TextStyles.browseToggleLabel.copyWith(
                color:
                    active ? CustomColor.colorWhite : CustomColor.color334155,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _refreshButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.reload,
      child: Container(
        height: ScreenConstant.defaultHeightThirty,
        width: ScreenConstant.defaultWidthThirty,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          //border: Border.all(color: CustomColor.colorE2E8F0),
        ),
        child: Icon(
          Icons.refresh,
          size: ScreenConstant.smallIconSize,
          color: CustomColor.colorBE185D,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search row (search box + city dropdown + Filters button)
  // ---------------------------------------------------------------------------
  Widget _buildSearchRow() {
    // Wrapped in a Builder so the city picker / filter sheet get a context
    // beneath the Navigator without changing the context-free tab method.
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.defaultWidthTen,
          ),
          child: Row(
            children: [
              // (a) Search box — grows to fill remaining width.
              Expanded(
                child: Container(
                  height: ScreenConstant.defaultHeightForty,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.colorF8FAFC,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: CustomColor.colorE2E8F0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: ScreenConstant.smallIconSize,
                        color: CustomColor.color94A3B8,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.setSearchQuery,
                          cursorColor: CustomColor.colorDB2777,
                          style: TextStyles.browseToggleLabel.copyWith(
                            color: CustomColor.color0F172A,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText:
                                "Search verified members by name, city, interests...",
                            hintStyle: TextStyles.browseToggleLabel.copyWith(
                              color: CustomColor.color94A3B8,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              // (b) City dropdown pill.
              _cityPill(context),
              //SizedBox(width: ScreenConstant.sizeSmall),
              // (c) Filters pill.
              _filtersPill(context),
            ],
          ),
        );
      },
    );
  }

  Widget _cityPill(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCityPicker(context),
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeSmall),
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: CustomColor.colorE2E8F0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE185D,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 70),
              child: Obx(
                () => Text(
                  controller.selectedCity.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.browseToggleLabel.copyWith(
                    color: CustomColor.color334155,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color64748B,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtersPill(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openFilterSheet(context),
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeSmall),
        // decoration: BoxDecoration(
        //   color: CustomColor.colorWhite,
        //   borderRadius: BorderRadius.circular(100),
        //   border: Border.all(color: CustomColor.colorE2E8F0),
        // ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE185D,
            ),
            // SizedBox(width: ScreenConstant.sizeExtraSmall),
            // Text(
            //   "Filters",
            //   style: TextStyles.browseToggleLabel.copyWith(
            //     color: CustomColor.colorBE123C,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // City picker bottom-sheet (reused by the header pill and the filter sheet)
  // ---------------------------------------------------------------------------
  void _openCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CustomColor.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ScreenConstant.sizeMedium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.defaultWidthTwenty,
                  ),
                  child: Text(
                    "Select City",
                    style: TextStyles.registerSectionTitle,
                  ),
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                Flexible(
                  child: Obx(() {
                    final selected = controller.selectedCity.value;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.cities.length,
                      itemBuilder: (_, index) {
                        final city = controller.cities[index];
                        final active = city == selected;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            controller.selectCity(city);
                            Navigator.pop(sheetContext);
                          },
                          child: Container(
                            color: active
                                ? CustomColor.colorFFF1F2
                                : Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenConstant.defaultWidthTwenty,
                              vertical: ScreenConstant.sizeMedium,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    city,
                                    style:
                                        TextStyles.browseToggleLabel.copyWith(
                                      color: active
                                          ? CustomColor.colorBE123C
                                          : CustomColor.color334155,
                                      fontWeight: active
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (active)
                                  Icon(
                                    Icons.check,
                                    size: ScreenConstant.minimumIconSize,
                                    color: CustomColor.colorBE123C,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Filter bottom-sheet: "Regional Search & Match Criteria"
  // ---------------------------------------------------------------------------
  void _openFilterSheet(BuildContext context) {
    // Seed the sheet controls from the currently-applied filters so edits
    // start from the active state and only take effect on "Apply Criteria".
    controller.initDraftFromApplied();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CustomColor.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Cap the sheet so it never covers the status bar / notch — leave a
        // gap at the top and let the content scroll within.
        final double maxSheetHeight =
            MediaQuery.of(sheetContext).size.height * 0.9;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SafeArea(
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
                  // Header row.
                  Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: ScreenConstant.smallIconSize,
                        color: CustomColor.colorBE185D,
                      ),
                      SizedBox(width: ScreenConstant.sizeSmall),
                      Expanded(
                        child: Text(
                          "Regional Search & Match Criteria",
                          style: TextStyles.registerSectionTitle.copyWith(
                            fontSize: FontSize.s16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close,
                          size: ScreenConstant.smallIconSize,
                          color: CustomColor.color64748B,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Location & Search Radius (draft until Apply).
                  Obx(
                    () => Text(
                      "Location & Search Radius: "
                      "${controller.draftSearchRadiusKm.value.round()} km",
                      style: TextStyles.registerFieldLabel,
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  _sheetCityField(sheetContext),
                  Obx(
                    () => Slider(
                      value: controller.draftSearchRadiusKm.value,
                      min: 1,
                      max: 100,
                      activeColor: CustomColor.colorBE185D,
                      inactiveColor: CustomColor.colorE2E8F0,
                      onChanged: controller.setSearchRadius,
                    ),
                  ),
                  Text(
                    "Radius is approximate and used for display only.",
                    style: TextStyles.registerFieldNote,
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Gender.
                  Text("Gender", style: TextStyles.registerFieldLabel),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Obx(
                    () => Wrap(
                      spacing: ScreenConstant.sizeSmall,
                      runSpacing: ScreenConstant.sizeSmall,
                      children: const ['All', 'Female', 'Male', 'Other']
                          .map(
                            (g) => _genderFilterPill(
                              g,
                              controller.draftGenderFilter.value == g,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Age range.
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Age Range:",
                            style: TextStyles.registerFieldLabel,
                          ),
                        ),
                        Text(
                          "${controller.draftAgeRange.value.start.round()} – "
                          "${controller.draftAgeRange.value.end.round()} years",
                          style: TextStyles.registerFieldLabel.copyWith(
                            color: CustomColor.colorBE123C,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => RangeSlider(
                      values: controller.draftAgeRange.value,
                      min: 18,
                      max: 80,
                      activeColor: CustomColor.colorBE185D,
                      inactiveColor: CustomColor.colorE2E8F0,
                      labels: RangeLabels(
                        controller.draftAgeRange.value.start.round().toString(),
                        controller.draftAgeRange.value.end.round().toString(),
                      ),
                      onChanged: controller.setAgeRange,
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Interests.
                  Text(
                    "Include Interests Criteria:",
                    style: TextStyles.registerFieldLabel,
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Obx(
                    () => Wrap(
                      spacing: ScreenConstant.sizeSmall,
                      runSpacing: ScreenConstant.sizeSmall,
                      children: HomeController.interestOptions
                          .map(
                            (label) => _interestChip(
                              label,
                              controller.draftSelectedInterests
                                  .contains(label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  Divider(color: CustomColor.colorE2E8F0),
                  SizedBox(height: ScreenConstant.sizeSmall),

                  // Footer: Reset link + Apply CTA.
                  Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: controller.resetFilters,
                        child: Text(
                          "Reset to Default",
                          style: TextStyles.browseToggleLabel.copyWith(
                            color: CustomColor.colorBE185D,
                            decorationColor: CustomColor.colorBE185D,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenConstant.sizeMedium),
                      Expanded(
                        child: buildLoginButton(
                          "Apply Criteria",
                          true,
                          () {
                            controller.applyFilters();
                            Navigator.pop(sheetContext);
                          },
                          Icons.check,
                          height: ScreenConstant.defaultHeightFifty,
                          fontSize: FontSize.s14,
                          iconSize: ScreenConstant.minimumIconSize,
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// City field inside the filter sheet; reuses the shared city picker.
  Widget _sheetCityField(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCityPicker(context),
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeMedium),
        decoration: BoxDecoration(
          color: CustomColor.colorF8FAFC,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColor.colorE2E8F0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE185D,
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                () => Text(
                  controller.selectedCity.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.browseToggleLabel.copyWith(
                    color: CustomColor.color334155,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color64748B,
            ),
          ],
        ),
      ),
    );
  }

  /// Gender pill: selected uses the rose→purple gradient; unselected is light.
  Widget _genderFilterPill(String label, bool selected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.setGenderFilter(label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeLarge,
          vertical: ScreenConstant.sizeSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? null : CustomColor.colorFFF1F2,
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    CustomColor.colorBE185D,
                    CustomColor.color581C87,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : CustomColor.colorE2E8F0,
          ),
        ),
        child: Text(
          label,
          style: TextStyles.browseToggleLabel.copyWith(
            color: selected ? CustomColor.colorWhite : CustomColor.color334155,
          ),
        ),
      ),
    );
  }

  /// Interest chip mirroring the register-flow selectable chip visual.
  Widget _interestChip(String label, bool selected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.toggleInterest(label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeMedium,
          vertical: ScreenConstant.sizeSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? CustomColor.colorFFF1F2 : CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? CustomColor.colorBE123C
                : CustomColor.colorE2E8F0,
          ),
        ),
        child: Text(
          label,
          style: TextStyles.browseToggleLabel.copyWith(
            color: selected ? CustomColor.colorBE123C : CustomColor.color334155,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid
  // ---------------------------------------------------------------------------
  Widget _buildGrid() {
    final members = controller.filteredMembers;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        ScreenConstant.defaultWidthTwenty,
        ScreenConstant.sizeSmall,
        ScreenConstant.defaultWidthTwenty,
        90,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: ScreenConstant.sizeMedium,
        mainAxisSpacing: ScreenConstant.sizeMedium,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) => _gridCard(members[index]),
    );
  }

  Widget _gridCard(Member member) {
    final photoCount = member.photoUrls.length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.openMemberDetail(member),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: MemberNetworkImage(url: member.firstPhotoUrl),
            ),
            // Bottom scrim for readable white text.
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        CustomColor.color0F172A,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Top-left "Active" pill.
            Positioned(
              top: ScreenConstant.sizeSmall,
              left: ScreenConstant.sizeSmall,
              child: _smallPill(
                bg: CustomColor.color0D1527,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: CustomColor.color10B981,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall),
                    Text(
                      "Active",
                      style: TextStyles.policiesBadgeText.copyWith(
                        color: CustomColor.colorWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top-right photo count (only when > 1 photo).
            if (photoCount > 1)
              Positioned(
                top: ScreenConstant.sizeSmall,
                right: ScreenConstant.sizeSmall,
                child: _smallPill(
                  bg: CustomColor.color0D1527,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: ScreenConstant.minimumIconSize,
                        color: CustomColor.colorWhite,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Text(
                        "$photoCount",
                        style: TextStyles.policiesBadgeText.copyWith(
                          color: CustomColor.colorWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Bottom-left name/age + gender pill.
            Positioned(
              left: ScreenConstant.sizeSmall,
              right: ScreenConstant.sizeSmall,
              bottom: ScreenConstant.sizeSmall,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${member.displayName}, ${member.age}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColor.colorWhite,
                      fontSize: FontSize.s16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Liberation",
                    ),
                  ),
                  if (member.genderLabel.isNotEmpty) ...[
                    SizedBox(height: ScreenConstant.sizeExtraSmall),
                    _genderPill(member.genderLabel),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderPill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyles.policiesBadgeText.copyWith(
          color: CustomColor.colorWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _smallPill({required Color bg, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Deck
  // ---------------------------------------------------------------------------
  Widget _buildDeck() {
    final member = controller.currentDeckMember;
    if (member == null) {
      return _deckExhausted();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenConstant.defaultWidthTwenty,
        ScreenConstant.sizeSmall,
        ScreenConstant.defaultWidthTwenty,
        80,
      ),
      child: Column(
        children: [
          Expanded(
            child: Dismissible(
              key: ValueKey(member.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  controller.likeCurrent();
                } else {
                  controller.passCurrent();
                }
                // Let deckIndex drive the rebuild instead of removing a child.
                return false;
              },
              child: _deckCard(member),
            ),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          _deckActions(member),
          SizedBox(height: ScreenConstant.sizeMedium),
          Text(
            "Showing active members deck • Like or pass",
            style: TextStyles.registerFieldNote,
          ),
        ],
      ),
    );
  }

  Widget _deckCard(Member member) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: MemberNetworkImage(url: member.firstPhotoUrl),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      CustomColor.color0F172A,
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Top-left presence + city pill.
          Positioned(
            top: ScreenConstant.sizeMedium,
            left: ScreenConstant.sizeMedium,
            child: _smallPill(
              bg: CustomColor.color0D1527,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: CustomColor.color10B981,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Active • ${member.profile.city}",
                    style: TextStyles.policiesBadgeText.copyWith(
                      color: CustomColor.colorWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom identity + bio + interests.
          Positioned(
            left: ScreenConstant.sizeMedium,
            right: ScreenConstant.sizeMedium,
            bottom: ScreenConstant.sizeMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${member.displayName}, ${member.age}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomColor.colorWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Liberation",
                  ),
                ),
                if (member.profile.bio.isNotEmpty) ...[
                  SizedBox(height: ScreenConstant.sizeExtraSmall),
                  Text(
                    member.profile.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColor.colorWhite.withOpacity(0.9),
                      fontSize: FontSize.s13,
                      fontFamily: "Liberation",
                      height: 1.4,
                    ),
                  ),
                ],
                if (member.profile.interests.isNotEmpty) ...[
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Wrap(
                    spacing: ScreenConstant.sizeExtraSmall,
                    runSpacing: ScreenConstant.sizeExtraSmall,
                    children: member.profile.interests
                        .take(3)
                        .map(_deckInterestChip)
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deckInterestChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.2,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyles.policiesBadgeText.copyWith(
          color: CustomColor.colorWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _deckActions(Member member) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleAction(
          icon: Icons.close,
          bg: CustomColor.colorWhite,
          iconColor: CustomColor.color64748B,
          border: CustomColor.colorE2E8F0,
          onTap: controller.passCurrent,
        ),
        SizedBox(width: ScreenConstant.sizeLarge),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.openMemberDetail(member),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.sizeLarge,
              vertical: ScreenConstant.sizeSmall,
            ),
            decoration: BoxDecoration(
              color: CustomColor.colorWhite,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: CustomColor.colorE2E8F0),
            ),
            child: Text(
              "View Details",
              style: TextStyles.browseToggleLabel,
            ),
          ),
        ),
        SizedBox(width: ScreenConstant.sizeLarge),
        _circleAction(
          icon: Icons.favorite,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [CustomColor.colorBE185D, CustomColor.color581C87],
          ),
          iconColor: CustomColor.colorWhite,
          onTap: controller.likeCurrent,
        ),
      ],
    );
  }

  Widget _circleAction({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Color? bg,
    Color? border,
    Gradient? gradient,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: ScreenConstant.defaultHeightSixty,
        width: ScreenConstant.defaultHeightSixty,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gradient == null ? bg : null,
          gradient: gradient,
          border: border == null ? null : Border.all(color: border),
        ),
        child: Icon(
          icon,
          size: ScreenConstant.smallIconSize,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _deckExhausted() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenConstant.defaultWidthTwenty),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: ScreenConstant.defaultIconSize,
              color: CustomColor.color10B981,
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Text(
              "You're all caught up",
              style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s20),
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              "You've seen every active member in this view.",
              textAlign: TextAlign.center,
              style: TextStyles.registerFieldNote,
            ),
            SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
            buildLoginButton(
              "Start over",
              true,
              controller.resetDeck,
              Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty filtered state
  // ---------------------------------------------------------------------------
  Widget _emptyFiltered() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenConstant.defaultWidthTwenty),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: ScreenConstant.defaultIconSize,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Text(
              "No members found",
              style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s20),
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              "No active members match your search and filters right now. "
              "Try adjusting the search, city, or filters.",
              textAlign: TextAlign.center,
              style: TextStyles.registerFieldNote,
            ),
          ],
        ),
      ),
    );
  }
}
