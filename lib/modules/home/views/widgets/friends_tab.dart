import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../controller/conversations_controller.dart';
import '../../controller/friends_controller.dart';
import '../../model/friend.dart';
import 'member_network_image.dart';

/// Friends tab (bottom nav index 2): a single, non-collapsible "Saved
/// profiles" section (GET friends, paged) with a message button (unread
/// badge) and a "Remove friend" menu per row. When nothing is saved the
/// caller-supplied [emptyState] is shown (still pull-to-refresh). The old
/// Friend Requests / My Friends / Sent Requests UI is kept as commented
/// `[OLD FLOW]` blocks.
class FriendsTab extends StatelessWidget {
  /// Shown when there are no saved profiles.
  final Widget emptyState;

  const FriendsTab({super.key, required this.emptyState});

  FriendsController get controller => Get.find<FriendsController>();

  /// Clears the floating bottom nav bar.
  static const double _bottomNavClearance = 80;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading = controller.isLoading.value;
  // [OLD FLOW – friend requests, disabled 2026-11]
      // final List<IncomingFriendRequest> requests =
      //     controller.friendRequests.toList();
      // final List<Friendship> friends = controller.friends.toList();
      // final List<SentFriendRequest> sent =
      //     controller.sentRequests.toList();
      // final int requestCount =
      //     math.max(controller.incomingTotal.value, requests.length);
      // final int friendCount =
      //     math.max(controller.friendsTotal.value, friends.length);
      // final int sentCount = math.max(controller.sentTotal.value, sent.length);
      // final bool allEmpty =
      //     requests.isEmpty && friends.isEmpty && sent.isEmpty;
  // [/OLD FLOW]
      final List<SavedProfile> saved = controller.saved.toList();
      final int savedCount =
          math.max(controller.savedTotal.value, saved.length);
      final bool allEmpty = saved.isEmpty;

      // First load: same spinner as the Explore tab.
      if (loading && allEmpty) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(
              CustomColor.colorBE185D,
            ),
          ),
        );
      }

      if (allEmpty) {
        return _buildEmpty();
      }

      return RefreshIndicator(
        color: CustomColor.colorBE185D,
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightTen,
            ScreenConstant.defaultWidthTwenty,
            _bottomNavClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Friends",
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s24,
                ),
              ),
              SizedBox(height: ScreenConstant.sizeExtraSmall),
              // [OLD FLOW – friend requests, disabled 2026-11]
              // Text(
              //   "Review incoming requests and keep in touch with your friends.",
              //   style: TextStyles.loginWelcomeSubtitle,
              // ),
              // [/OLD FLOW]
              Text(
                "Message the members you have saved.",
                style: TextStyles.loginWelcomeSubtitle,
              ),
              SizedBox(height: ScreenConstant.sizeMedium),
              // [OLD FLOW – friend requests, disabled 2026-11]
              // if (requests.isNotEmpty) ...[
              //   _section(
              //     icon: Icons.person_add_alt_1_outlined,
              //     title: "Friend Requests",
              //     count: requestCount,
              //     expanded: controller.requestsExpanded,
              //     cards: requests
              //         .map((r) => _requestCard(context, r))
              //         .toList(),
              //     footer: _loadMoreFooter(
              //       loading: controller.isLoadingMoreIncoming,
              //       hasMore: () => controller.hasMoreIncoming,
              //       onLoadMore: controller.loadMoreIncoming,
              //       semanticsLabel: "Load more friend requests",
              //     ),
              //   ),
              //   SizedBox(height: ScreenConstant.sizeMedium),
              // ],
              // if (friends.isNotEmpty) ...[
              //   _section(
              //     icon: Icons.people_outline,
              //     title: "My Friends",
              //     count: friendCount,
              //     expanded: controller.friendsExpanded,
              //     cards: friends.map((f) => _friendCard(context, f)).toList(),
              //     footer: _loadMoreFooter(
              //       loading: controller.isLoadingMoreFriends,
              //       hasMore: () => controller.hasMoreFriends,
              //       onLoadMore: controller.loadMoreFriends,
              //       semanticsLabel: "Load more friends",
              //     ),
              //   ),
              //   SizedBox(height: ScreenConstant.sizeMedium),
              // ],
              // if (sent.isNotEmpty)
              //   _section(
              //     icon: Icons.send_outlined,
              //     title: "Sent Requests",
              //     count: sentCount,
              //     expanded: controller.sentExpanded,
              //     cards: sent.map((s) => _sentCard(context, s)).toList(),
              //     footer: _loadMoreFooter(
              //       loading: controller.isLoadingMoreSent,
              //       hasMore: () => controller.hasMoreSent,
              //       onLoadMore: controller.loadMoreSent,
              //       semanticsLabel: "Load more sent requests",
              //     ),
              //   ),
              // [/OLD FLOW]
              Semantics(
                header: true,
                label: "Saved profiles, $savedCount",
                excludeSemantics: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenConstant.sizeExtraSmall,
                  ),
                  child: _sectionTitleRow(
                    Icons.bookmark_border,
                    "Saved profiles",
                    savedCount,
                  ),
                ),
              ),
              SizedBox(height: ScreenConstant.sizeSmall),
              ...saved.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
                  child: _savedCard(context, p),
                ),
              ),
              _loadMoreFooter(
                loading: controller.isLoadingMoreSaved,
                hasMore: () => controller.hasMoreSaved,
                onLoadMore: controller.loadMoreSaved,
                semanticsLabel: "Load more saved profiles",
              ),
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Empty state — the original placeholder, made pull-to-refreshable.
  // ---------------------------------------------------------------------------
  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: CustomColor.colorBE185D,
          onRefresh: controller.onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Center(child: emptyState),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shared building blocks (same look as the Accounts cards)
  // ---------------------------------------------------------------------------

  /// White rounded card with the standard soft shadow.
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeSmallHighest),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
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

  // [OLD FLOW – friend requests, disabled 2026-11]
  // /// Collapsible section: tappable header (count pill stays visible) and an
  // /// animated list of [cards]. [expanded] lives on the controller so the
  // /// state survives tab switches.
  // Widget _section({
  //   required IconData icon,
  //   required String title,
  //   required int count,
  //   required RxBool expanded,
  //   required List<Widget> cards,
  //   Widget? footer,
  // }) {
  //   return Obx(() {
  //     final bool isExpanded = expanded.value;
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _sectionHeader(
  //           icon,
  //           title,
  //           count,
  //           expanded: isExpanded,
  //           onToggle: expanded.toggle,
  //         ),
  //         AnimatedSize(
  //           duration: const Duration(milliseconds: 220),
  //           curve: Curves.easeInOut,
  //           alignment: Alignment.topCenter,
  //           child: isExpanded
  //               ? Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     SizedBox(height: ScreenConstant.sizeSmall),
  //                     ...cards.map(
  //                       (c) => Padding(
  //                         padding: EdgeInsets.only(
  //                           bottom: ScreenConstant.sizeSmall,
  //                         ),
  //                         child: c,
  //                       ),
  //                     ),
  //                     ?footer,
  //                   ],
  //                 )
  //               : const SizedBox(width: double.infinity),
  //         ),
  //       ],
  //     );
  //   });
  // }

  // /// Rose icon + bold title + gradient count pill + expand/collapse chevron.
  // /// The whole row is tappable.
  // Widget _sectionHeader(
  //   IconData icon,
  //   String title,
  //   int count, {
  //   required bool expanded,
  //   required VoidCallback onToggle,
  // }) {
  //   final String action = expanded ? "Collapse" : "Expand";
  //   return Semantics(
  //     button: true,
  //     expanded: expanded,
  //     label: "$title, $count. $action",
  //     excludeSemantics: true,
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         onTap: onToggle,
  //         borderRadius: BorderRadius.circular(12),
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(
  //             vertical: ScreenConstant.sizeExtraSmall,
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(child: _sectionTitleRow(icon, title, count)),
  //               Tooltip(
  //                 message: action,
  //                 child: AnimatedRotation(
  //                   turns: expanded ? 0 : -0.25,
  //                   duration: const Duration(milliseconds: 220),
  //                   curve: Curves.easeInOut,
  //                   child: Icon(
  //                     Icons.keyboard_arrow_down,
  //                     size: ScreenConstant.smallIconSize,
  //                     color: CustomColor.color64748B,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // [/OLD FLOW]

  Widget _sectionTitleRow(IconData icon, String title, int count) {
    return Row(
      children: [
        Icon(icon, size: ScreenConstant.smallIconSize,
            color: CustomColor.colorBE185D),
        SizedBox(width: ScreenConstant.sizeSmall),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.registerSectionTitle.copyWith(
              fontSize: FontSize.s16,
              color: CustomColor.color0F172A,
            ),
          ),
        ),
        SizedBox(width: ScreenConstant.sizeSmall),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.sizeSmall,
            vertical: ScreenConstant.sizeExtraSmall / 1.6,
          ),
          decoration: BoxDecoration(
            color: CustomColor.colorFCE7F3,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            "$count",
            style: TextStyles.registerFieldNote.copyWith(
              color: CustomColor.colorBE185D,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Circular avatar; initials when there is no photo. [showOnline] adds the
  /// green presence dot.
  Widget _avatar(FriendUser user, {bool showOnline = false}) {
    final double size = ScreenConstant.defaultWidthFifty;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CustomColor.colorFBCFE8, width: 1.5),
            ),
            child: ClipOval(
              child: user.avatarUrl.isNotEmpty
                  ? MemberNetworkImage(url: user.avatarUrl)
                  : Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CustomColor.colorBE185D,
                            CustomColor.color581C87,
                          ],
                        ),
                      ),
                      child: Text(
                        _initials(user.displayName),
                        style: TextStyles.registerSectionTitle.copyWith(
                          fontSize: FontSize.s16,
                          color: CustomColor.colorWhite,
                        ),
                      ),
                    ),
            ),
          ),
          if (showOnline && user.isOnline)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: ScreenConstant.sizeSmallHighest,
                height: ScreenConstant.sizeSmallHighest,
                decoration: BoxDecoration(
                  color: CustomColor.color10B981,
                  shape: BoxShape.circle,
                  border: Border.all(color: CustomColor.colorWhite, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// "Name, 33" (age omitted when unknown) + subtitle line.
  Widget _nameBlock(FriendUser user, {String? trailingNote}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.age > 0
                    ? "${user.displayName}, ${user.age}"
                    : user.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.registerSectionTitle.copyWith(
                  fontSize: FontSize.s15,
                  color: CustomColor.color0F172A,
                ),
              ),
            ),
            if (trailingNote != null) ...[
              SizedBox(width: ScreenConstant.sizeExtraSmall),
              Text(trailingNote, style: TextStyles.registerFieldNote),
            ],
          ],
        ),
        if (user.subtitle.isNotEmpty) ...[
          SizedBox(height: ScreenConstant.defaultHeightFour / 2),
          Text(
            user.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.loginWelcomeSubtitle.copyWith(
              fontSize: FontSize.s12,
            ),
          ),
        ],
      ],
    );
  }

  // [OLD FLOW – friend requests, disabled 2026-11]
  // // ---------------------------------------------------------------------------
  // // Friend Requests
  // // ---------------------------------------------------------------------------
  // Widget _requestCard(BuildContext context, IncomingFriendRequest req) {
  //   final FriendUser user = req.user;
  //   return _card(
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             _avatar(user),
  //             SizedBox(width: ScreenConstant.sizeSmallHighest),
  //             Expanded(
  //               child: _nameBlock(
  //                 user,
  //                 trailingNote:
  //                     user.since == null ? null : _timeAgo(user.since!),
  //               ),
  //             ),
  //             Obx(() {
  //               final bool busy =
  //                   controller.busyRequestIds.contains(req.requestId);
  //               final bool deleting =
  //                   controller.deletingRequestIds.contains(req.requestId);
  //               return _deleteRequestButton(context, req, busy, deleting);
  //             }),
  //           ],
  //         ),
  //         SizedBox(height: ScreenConstant.sizeSmallHighest),
  //         Obx(() {
  //           final bool busy =
  //               controller.busyRequestIds.contains(req.requestId);
  //           // Spinner on whichever button was pressed; all disabled.
  //           final bool declining =
  //               controller.decliningRequestIds.contains(req.requestId);
  //           final bool deleting =
  //               controller.deletingRequestIds.contains(req.requestId);
  //           return Row(
  //             children: [
  //               Expanded(
  //                   child: _acceptButton(req, busy,
  //                       showSpinner: busy && !declining && !deleting)),
  //               SizedBox(width: ScreenConstant.sizeSmall),
  //               Expanded(
  //                   child: _declineButton(req, busy, showSpinner: declining)),
  //             ],
  //           );
  //         }),
  //       ],
  //     ),
  //   );
  // }

  // /// Trash icon: deletes the request without accepting or rejecting it
  // /// (confirm dialog first). Disabled while any action on the row is in
  // /// flight; rose spinner while the delete itself is running.
  // Widget _deleteRequestButton(BuildContext context, IncomingFriendRequest req,
  //     bool busy, bool deleting) {
  //   return Semantics(
  //     button: true,
  //     enabled: !busy,
  //     label: deleting
  //         ? "Deleting request from ${req.user.displayName}"
  //         : "Delete request from ${req.user.displayName}",
  //     excludeSemantics: true,
  //     child: IconButton(
  //       tooltip: "Delete request",
  //       onPressed: busy ? null : () => _confirmDeleteRequest(context, req),
  //       icon: deleting
  //           ? const SizedBox(
  //               height: 18,
  //               width: 18,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2.2,
  //                 valueColor:
  //                     AlwaysStoppedAnimation<Color>(CustomColor.colorE11D48),
  //               ),
  //             )
  //           : Icon(
  //               Icons.delete_outline_outlined,
  //               color: CustomColor.colorE11D48,
  //             ),
  //     ),
  //   );
  // }

  // /// Same dialog look as the "Cancel request?" confirm.
  // void _confirmDeleteRequest(
  //     BuildContext context, IncomingFriendRequest req) {
  //   final FriendUser user = req.user;
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         backgroundColor: CustomColor.colorWhite,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "Delete request?",
  //           style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
  //         ),
  //         content: Text(
  //           "Delete the friend request from ${user.displayName}?",
  //           style: TextStyles.loginWelcomeSubtitle,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext),
  //             child: Text(
  //               "Keep",
  //               style: TextStyles.loginWelcome.copyWith(
  //                 fontSize: FontSize.s14,
  //                 color: CustomColor.color64748B,
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(dialogContext);
  //               // Async; the trash icon shows a spinner via deletingRequestIds.
  //               controller.deleteRequest(req);
  //             },
  //             child: Text(
  //               "Delete",
  //               style: TextStyles.loginWelcome.copyWith(
  //                 fontSize: FontSize.s14,
  //                 color: CustomColor.colorE11D48,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _acceptButton(IncomingFriendRequest req, bool busy,
  //     {required bool showSpinner}) {
  //   return Semantics(
  //     button: true,
  //     enabled: !busy,
  //     label: "Accept request from ${req.user.displayName}",
  //     excludeSemantics: true,
  //     child: GestureDetector(
  //       onTap: busy ? null : () => controller.acceptRequest(req),
  //       child: Container(
  //         height: ScreenConstant.defaultHeightForty,
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(100),
  //           gradient: const LinearGradient(
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //             colors: [
  //               CustomColor.colorBE185D,
  //               CustomColor.color581C87,
  //             ],
  //           ),
  //         ),
  //         // Same loader as Login: white spinner inside the gradient pill.
  //         child: showSpinner
  //             ? const SizedBox(
  //                 height: 18,
  //                 width: 18,
  //                 child: CircularProgressIndicator(
  //                   strokeWidth: 2.2,
  //                   valueColor:
  //                       AlwaysStoppedAnimation<Color>(CustomColor.colorWhite),
  //                 ),
  //               )
  //             : Text(
  //                 "Accept",
  //                 style: TextStyles.loginButtonText.copyWith(
  //                   fontSize: FontSize.s14,
  //                   color: CustomColor.colorWhite,
  //                 ),
  //               ),
  //       ),
  //     ),
  //   );
  // }

  // /// Grey spinner while declining (same as the Sent "Cancel" pill).
  // Widget _declineButton(IncomingFriendRequest req, bool busy,
  //     {required bool showSpinner}) {
  //   return Semantics(
  //     button: true,
  //     enabled: !busy,
  //     label: "Decline request from ${req.user.displayName}",
  //     excludeSemantics: true,
  //     child: GestureDetector(
  //       onTap: busy ? null : () => controller.declineRequest(req),
  //       child: Opacity(
  //         opacity: busy ? 0.5 : 1,
  //         child: Container(
  //           height: ScreenConstant.defaultHeightForty,
  //           alignment: Alignment.center,
  //           decoration: BoxDecoration(
  //             color: CustomColor.colorWhite,
  //             borderRadius: BorderRadius.circular(100),
  //             border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
  //           ),
  //           child: showSpinner
  //               ? const SizedBox(
  //                   height: 18,
  //                   width: 18,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2.2,
  //                     valueColor: AlwaysStoppedAnimation<Color>(
  //                       CustomColor.color475569,
  //                     ),
  //                   ),
  //                 )
  //               : Text(
  //                   "Decline",
  //                   style: TextStyles.loginButtonText.copyWith(
  //                     fontSize: FontSize.s14,
  //                     color: CustomColor.color475569,
  //                   ),
  //                 ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // [/OLD FLOW]

  // [OLD FLOW – friend requests, disabled 2026-11]
  // // ---------------------------------------------------------------------------
  // // My Friends
  // // ---------------------------------------------------------------------------
  // Widget _friendCard(BuildContext context, Friendship f) {
  //   final FriendUser user = f.user;
  //   return _card(
  //     child: Row(
  //       children: [
  //         _avatar(user, showOnline: true),
  //         SizedBox(width: ScreenConstant.sizeSmallHighest),
  //         Expanded(child: _nameBlock(user)),
  //         SizedBox(width: ScreenConstant.sizeExtraSmall),
  //         Obx(() {
  //           // Removing (keyed by the friend's user id): chat disabled and a
  //           // spinner replaces the "More" menu.
  //           final bool removing = controller.busyFriendIds.contains(user.id);
  //           // Opening the chat (POST conversations): spinner replaces the
  //           // chat icon; chat and the Remove menu are disabled.
  //           final bool opening = controller.openingChatIds.contains(user.id);
  //           final bool busy = removing || opening;
  //           final int unreadCount = _getUnreadCountForFriend(user.id);

  //           return Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Opacity(
  //                 opacity: removing ? 0.5 : 1,
  //                 child: Stack(
  //                   clipBehavior: Clip.none,
  //                   children: [
  //                     Material(
  //                       color: CustomColor.colorFDF2F8,
  //                       shape: const CircleBorder(),
  //                       child: IconButton(
  //                         tooltip: "Chat",
  //                         onPressed:
  //                             busy ? null : () => controller.openChat(user),
  //                         icon: opening
  //                             ? Semantics(
  //                                 label: "Opening chat with ${user.displayName}",
  //                                 excludeSemantics: true,
  //                                 child: const SizedBox(
  //                                   height: 18,
  //                                   width: 18,
  //                                   child: CircularProgressIndicator(
  //                                     strokeWidth: 2.2,
  //                                     valueColor: AlwaysStoppedAnimation<Color>(
  //                                       CustomColor.colorBE185D,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               )
  //                             : Icon(
  //                                 Icons.chat_bubble_outline,
  //                                 size: ScreenConstant.smallIconSize,
  //                                 color: CustomColor.colorBE185D,
  //                               ),
  //                       ),
  //                     ),
  //                     if (unreadCount > 0 && !opening)
  //                       Positioned(
  //                         top: -2,
  //                         right: -2,
  //                         child: _unreadBadge(unreadCount),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //               removing
  //                   ? _removingSpinner(user)
  //                   : _friendMenu(context, f, enabled: !opening),
  //             ],
  //           );
  //         }),
  //       ],
  //     ),
  //   );
  // }
  // [/OLD FLOW]

  // ---------------------------------------------------------------------------
  // Saved profiles
  // ---------------------------------------------------------------------------
  Widget _savedCard(BuildContext context, SavedProfile p) {
    final FriendUser user = p.user;
    // Whole-card tap opens the member details; the message icon and the menu
    // are their own buttons and win the gesture arena.
    return Semantics(
      button: true,
      label: "View ${user.displayName}'s profile",
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.openSavedProfileDetail(p),
          child: _card(
            child: Row(
              children: [
                _avatar(user, showOnline: true),
                SizedBox(width: ScreenConstant.sizeSmallHighest),
                Expanded(child: _nameBlock(user)),
                SizedBox(width: ScreenConstant.sizeExtraSmall),
          Obx(() {
            // Removing (keyed by the saved user's id): message disabled and a
            // spinner replaces the "More" menu.
            final bool removing = controller.busyFriendIds.contains(user.id);
            // Opening the chat (POST conversations): spinner replaces the
            // message icon; message and the Remove menu are disabled.
            final bool opening = controller.openingChatIds.contains(user.id);
            final bool busy = removing || opening;
            final int unreadCount = _getUnreadCountForFriend(user.id);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: removing ? 0.5 : 1,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: CustomColor.colorFDF2F8,
                        shape: const CircleBorder(),
                        child: Semantics(
                          button: true,
                          enabled: !busy,
                          label: unreadCount > 0
                              ? "Message ${user.displayName}, $unreadCount unread"
                              : "Message ${user.displayName}",
                          excludeSemantics: true,
                          child: IconButton(
                            tooltip: "Message",
                            onPressed:
                                busy ? null : () => controller.openChat(user),
                            icon: opening
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        CustomColor.colorBE185D,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.chat_bubble_outline,
                                    size: ScreenConstant.smallIconSize,
                                    color: CustomColor.colorBE185D,
                                  ),
                          ),
                        ),
                      ),
                      if (unreadCount > 0 && !opening)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: _unreadBadge(unreadCount),
                        ),
                    ],
                  ),
                ),
                removing
                    ? _removingSpinner(user)
                    : _savedMenu(context, p, enabled: !opening),
              ],
            );
          }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // [SUPERSEDED DRAFT – saved-card-details]
  // Widget _savedCard(BuildContext context, SavedProfile p) {
  //   final FriendUser user = p.user;
  //   return GestureDetector(
  //     behavior: HitTestBehavior.opaque,
  //     onTap: () => controller.openSavedProfileDetail(p),
  //     child: _card(
  //       child: Row(
  //         children: [
  //         _avatar(user, showOnline: true),
  //         SizedBox(width: ScreenConstant.sizeSmallHighest),
  //         Expanded(child: _nameBlock(user)),
  //         SizedBox(width: ScreenConstant.sizeExtraSmall),
  //         Obx(() {
  //           // Removing (keyed by the saved user's id): message disabled and a
  //           // spinner replaces the "More" menu.
  //           final bool removing = controller.busyFriendIds.contains(user.id);
  //           // Opening the chat (POST conversations): spinner replaces the
  //           // message icon; message and the Remove menu are disabled.
  //           final bool opening = controller.openingChatIds.contains(user.id);
  //           final bool busy = removing || opening;
  //           final int unreadCount = _getUnreadCountForFriend(user.id);
  //
  //           return Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Opacity(
  //                 opacity: removing ? 0.5 : 1,
  //                 child: Stack(
  //                   clipBehavior: Clip.none,
  //                   children: [
  //                     Material(
  //                       color: CustomColor.colorFDF2F8,
  //                       shape: const CircleBorder(),
  //                       child: Semantics(
  //                         button: true,
  //                         enabled: !busy,
  //                         label: unreadCount > 0
  //                             ? "Message ${user.displayName}, $unreadCount unread"
  //                             : "Message ${user.displayName}",
  //                         excludeSemantics: true,
  //                         child: IconButton(
  //                           tooltip: "Message",
  //                           onPressed:
  //                               busy ? null : () => controller.openChat(user),
  //                           icon: opening
  //                               ? const SizedBox(
  //                                   height: 18,
  //                                   width: 18,
  //                                   child: CircularProgressIndicator(
  //                                     strokeWidth: 2.2,
  //                                     valueColor: AlwaysStoppedAnimation<Color>(
  //                                       CustomColor.colorBE185D,
  //                                     ),
  //                                   ),
  //                                 )
  //                               : Icon(
  //                                   Icons.chat_bubble_outline,
  //                                   size: ScreenConstant.smallIconSize,
  //                                   color: CustomColor.colorBE185D,
  //                                 ),
  //                         ),
  //                       ),
  //                     ),
  //                     if (unreadCount > 0 && !opening)
  //                       Positioned(
  //                         top: -2,
  //                         right: -2,
  //                         child: _unreadBadge(unreadCount),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //               removing
  //                   ? _removingSpinner(user)
  //                   : _savedMenu(context, p, enabled: !opening),
  //             ],
  //           );
  //         }),
  //       ],
  //     ),
  //   );
  // }
  // }
  // [/SUPERSEDED DRAFT]

  int _getUnreadCountForFriend(String userId) {
    if (!Get.isRegistered<ConversationsController>()) return 0;
    final convsController = Get.find<ConversationsController>();
    final conv = convsController.conversations.firstWhereOrNull(
      (c) => c.otherUser.id == userId,
    );
    return conv?.unreadCount ?? 0;
  }

  Widget _unreadBadge(int count) {
    if (count <= 0) return const Offstage();
    final String label = count > 99 ? "99+" : "$count";
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CustomColor.colorBE185D, CustomColor.color581C87],
        ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CustomColor.colorWhite, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyles.registerFieldNote.copyWith(
          fontSize: 10,
          color: CustomColor.colorWhite,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }

  /// Grey spinner (same as the Sent "Cancel" pill) sized like the "More"
  /// button while the friend is being removed.
  Widget _removingSpinner(FriendUser user) {
    return Semantics(
      label: "Removing ${user.displayName}",
      excludeSemantics: true,
      child: SizedBox(
        width: ScreenConstant.defaultHeightForty,
        height: ScreenConstant.defaultHeightForty,
        child: const Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                CustomColor.color475569,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // [OLD FLOW – friend requests, disabled 2026-11]
  // /// "More" menu with the "Remove friend" action (confirm dialog first).
  // Widget _friendMenu(BuildContext context, Friendship f,
  //     {bool enabled = true}) {
  //   return PopupMenuButton<String>(
  //     enabled: enabled,
  //     tooltip: "More",
  //     icon: Icon(
  //       Icons.more_vert,
  //       size: ScreenConstant.smallIconSize,
  //       color: CustomColor.color64748B,
  //     ),
  //     color: CustomColor.colorWhite,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(14),
  //     ),
  //     onSelected: (value) {
  //       if (value == 'remove') _confirmRemove(context, f);
  //     },
  //     itemBuilder: (_) => [
  //       PopupMenuItem<String>(
  //         value: 'remove',
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.person_remove_outlined,
  //               size: ScreenConstant.smallIconSize,
  //               color: CustomColor.colorE11D48,
  //             ),
  //             SizedBox(width: ScreenConstant.sizeSmall),
  //             Text(
  //               "Remove friend",
  //               style: TextStyles.loginWelcome.copyWith(
  //                 fontSize: FontSize.s14,
  //                 color: CustomColor.colorE11D48,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // /// Same dialog look as the Accounts "Delete account?" confirm.
  // void _confirmRemove(BuildContext context, Friendship f) {
  //   final FriendUser user = f.user;
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         backgroundColor: CustomColor.colorWhite,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "Remove friend?",
  //           style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
  //         ),
  //         content: Text(
  //           "${user.displayName} will be removed from your friends list.",
  //           style: TextStyles.loginWelcomeSubtitle,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext),
  //             child: Text(
  //               "Cancel",
  //               style: TextStyles.loginWelcome.copyWith(
  //                 fontSize: FontSize.s14,
  //                 color: CustomColor.color64748B,
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(dialogContext);
  //               // Async; the row shows a spinner via busyFriendIds.
  //               controller.removeFriend(f);
  //             },
  //             child: Text(
  //               "Remove",
  //               style: TextStyles.loginWelcome.copyWith(
  //                 fontSize: FontSize.s14,
  //                 color: CustomColor.colorE11D48,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // [/OLD FLOW]

  /// "More" menu with the "Remove friend" action (confirm dialog first).
  Widget _savedMenu(BuildContext context, SavedProfile p,
      {bool enabled = true}) {
    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: "More",
      icon: Icon(
        Icons.more_vert,
        size: ScreenConstant.smallIconSize,
        color: CustomColor.color64748B,
      ),
      color: CustomColor.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) {
        if (value == 'remove') _confirmRemoveSaved(context, p);
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              Icon(
                Icons.person_remove_outlined,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.colorE11D48,
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Text(
                "Remove friend",
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.colorE11D48,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Same dialog look as the Accounts "Delete account?" confirm.
  void _confirmRemoveSaved(BuildContext context, SavedProfile p) {
    final FriendUser user = p.user;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColor.colorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Remove friend?",
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
          ),
          content: Text(
            "${user.displayName} will be removed from your saved profiles.",
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
                Navigator.pop(dialogContext);
                // Async; the row shows a spinner via busyFriendIds.
                controller.removeSaved(p);
              },
              child: Text(
                "Remove",
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

  // [OLD FLOW – friend requests, disabled 2026-11]
  // // ---------------------------------------------------------------------------
  // // Sent Requests
  // // ---------------------------------------------------------------------------
  // Widget _sentCard(BuildContext context, SentFriendRequest req) {
  //   final FriendUser user = req.user;
  //   return _card(
  //     child: Row(
  //       children: [
  //         _avatar(user),
  //         SizedBox(width: ScreenConstant.sizeSmallHighest),
  //         Expanded(
  //           child: _nameBlock(
  //             user,
  //             trailingNote:
  //                 user.since == null ? null : "Sent ${_timeAgo(user.since!)}",
  //           ),
  //         ),
  //         SizedBox(width: ScreenConstant.sizeSmall),
  //         Obx(() {
  //           final bool busy = controller.busySentIds.contains(req.requestId);
  //           return SizedBox(
  //             width: ScreenConstant.defaultWidthEighty,
  //             child: _cancelButton(context, req, busy),
  //           );
  //         }),
  //       ],
  //     ),
  //   );
  // }

  // /// Outlined pill matching "Decline"; grey spinner while cancelling.
  // Widget _cancelButton(
  //     BuildContext context, SentFriendRequest req, bool busy) {
  //   final FriendUser user = req.user;
  //   return Semantics(
  //     button: true,
  //     enabled: !busy,
  //     label: "Cancel request to ${user.displayName}",
  //     excludeSemantics: true,
  //     child: GestureDetector(
  //       onTap: busy ? null : () => _confirmCancel(context, req),
  //       child: Opacity(
  //         opacity: busy ? 0.5 : 1,
  //         child: Container(
  //           height: ScreenConstant.defaultHeightForty,
  //           alignment: Alignment.center,
  //           decoration: BoxDecoration(
  //             color: CustomColor.colorWhite,
  //             borderRadius: BorderRadius.circular(100),
  //             border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
  //           ),
  //           child: busy
  //               ? const SizedBox(
  //                   height: 18,
  //                   width: 18,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2.2,
  //                     valueColor: AlwaysStoppedAnimation<Color>(
  //                       CustomColor.color475569,
  //                     ),
  //                   ),
  //                 )
  //               : Text(
  //                   "Cancel",
  //                   style: TextStyles.loginButtonText.copyWith(
  //                     fontSize: FontSize.s14,
  //                     color: CustomColor.color475569,
  //                   ),
  //                 ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // /// Same dialog look as the "Remove friend?" confirm.
  // void _confirmCancel(BuildContext context, SentFriendRequest req) {
  //   final FriendUser user = req.user;
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) {
  //       return AlertDialog(
  //         backgroundColor: CustomColor.colorWhite,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Text(
  //           "Cancel request to ${user.displayName}?",
  //           style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
  //         ),
  //         content: Text(
  //           "${user.displayName} will no longer see your friend request.",
  //           style: TextStyles.loginWelcomeSubtitle,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext),
  //             child: Text(
  //               "Keep",
  //               style: TextStyles.loginWelcome.copyWith(
  //                 fontSize: FontSize.s14,
  //                 color: CustomColor.color64748B,
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(dialogContext);
  //               controller.cancelSentRequest(req);
  //             },
  //             child: Text(
  //               "Cancel request",
  //               style: TextStyles.loginWelcome.copyWith(
  //                 fontSize: FontSize.s14,
  //                 color: CustomColor.colorE11D48,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // [/OLD FLOW]

  /// End of a paged section: spinner while the next page loads, "Load more"
  /// while the server has more rows, otherwise nothing. [hasMore] is called
  /// inside the Obx so its Rx reads are tracked.
  Widget _loadMoreFooter({
    required RxBool loading,
    required bool Function() hasMore,
    required VoidCallback onLoadMore,
    required String semanticsLabel,
  }) {
    return Obx(() {
      if (loading.value) {
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
          child: const Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(CustomColor.colorBE185D),
              ),
            ),
          ),
        );
      }
      if (!hasMore()) return const SizedBox.shrink();
      return Center(
        child: Semantics(
          button: true,
          label: semanticsLabel,
          excludeSemantics: true,
          child: TextButton(
            onPressed: onLoadMore,
            child: Text(
              "Load more",
              style: TextStyles.loginWelcome.copyWith(
                fontSize: FontSize.s14,
                color: CustomColor.colorBE185D,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // [OLD FLOW – friend requests, disabled 2026-11]
  // /// "just now", "12m ago", "3h ago", "4d ago".
  // static String _timeAgo(DateTime since) {
  //   final diff = DateTime.now().difference(since);
  //   if (diff.inMinutes < 1) return 'just now';
  //   if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  //   if (diff.inDays < 1) return '${diff.inHours}h ago';
  //   return '${diff.inDays}d ago';
  // }
  // [/OLD FLOW]
}
