import 'package:chat_x/device_manager/screen_constants.dart';
import 'dart:io';

import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/image_utils/image_utils.dart';
import '../../home/views/widgets/member_network_image.dart';
import '../model/gallery_photo_model.dart';

class ProfilePhotosScreen extends GetView<RegisterController> {
  const ProfilePhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onBack,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "STEP 4 OF 5",
              textAlign: TextAlign.center,
              style: TextStyles.policiesBadgeText,
            ),
            Text(
              "Profile Photos",
              textAlign: TextAlign.center,
              style: TextStyles.registerTitle,
            ),
          ],
        ),
        actions: [
          // Icon(
          //   Icons.lock_outline,
          //   size: ScreenConstant.smallIconSize,
          //   color: CustomColor.color94A3B8,
          // ),
          // SizedBox(width: ScreenConstant.defaultWidthTen),
          // Container(
          //   height: ScreenConstant.defaultHeightForty,
          //   width: ScreenConstant.defaultWidthForty,
          //   margin: EdgeInsets.only(right: ScreenConstant.sizeMedium),
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: CustomColor.colorFFF1F2,
          //     border: Border.all(color: CustomColor.colorFFE4E6, width: 2),
          //   ),
          //   child: Icon(
          //     Icons.person_outline,
          //     color: CustomColor.colorE11D48,
          //     size: ScreenConstant.smallIconSize - 2,
          //   ),
          // ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightTen,
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightThirty,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: ScreenConstant.defaultHeightTwentyThree,horizontal: ScreenConstant.defaultWidthTen),
                decoration: BoxDecoration(
                  color: CustomColor.colorWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.color717B96.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child:  _buildHeader(),
              ),

              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildMainPhoto(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildVaultHeader(),
              SizedBox(height: ScreenConstant.sizeMedium),
              _buildGallery(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildActionButtons(),
              SizedBox(height: ScreenConstant.defaultHeightThirty),
              _buildSaveButton(),
              SizedBox(height: ScreenConstant.defaultHeightFifteen),
              Center(child: _buildSkipLink()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Center(child: _buildFooter()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (1) Header: title + paragraph + discreet banner
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Curate Your Gallery",
          style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s20),
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        Text(
          "Your primary photo appears in verified searches. Add up to 15 "
          "gallery moments in your personal vault.",
          style: TextStyles.registerFieldNote.copyWith(
            color: CustomColor.color64748B,
            fontSize: FontSize.s13
          ),
        ),
        SizedBox(height: ScreenConstant.sizeMedium),
        Container(
          padding: EdgeInsets.all(ScreenConstant.sizeMedium),
          decoration: BoxDecoration(
            color: CustomColor.colorFFF1F2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CustomColor.colorFECDD3, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height:ScreenConstant.defaultHeightThirty,
                width: ScreenConstant.defaultWidthThirty,
                padding: EdgeInsets.all(ScreenConstant.sizeDefault),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.colorFFE4E6
                ),
                child: Image.asset(
                  ImageUtils.hundredPercentDiscreet,
                  height: ScreenConstant.minimumIconSize,
                  color: CustomColor.colorBE123C,
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "100% Discreet & Protected: ",
                        style: TextStyles.registerFieldNote.copyWith(
                          color: CustomColor.colorBE123C,
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            "Photos can be masked, blurred, or locked in your "
                            "vault anytime.",
                        style: TextStyles.registerFieldNote.copyWith(color: CustomColor.color1E293B, fontWeight: FontWeight.bold,),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (2) Main profile photo
  // ---------------------------------------------------------------------------
  Widget _buildMainPhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Main Profile Photo", style: TextStyles.registerFieldLabel),
            Text(" *", style: TextStyles.registerVerifyNoteHighlight),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeSmall,
                vertical: ScreenConstant.sizeExtraSmall / 1.5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                  colors: [
                    CustomColor.colorEC4899,
                    CustomColor.colorBE185D,
                    CustomColor.color9333EA,
                  ],
                ),
              ),
              child: Text(
                "PRIMARY / AVATAR",
                style: TextStyles.policiesBadgeText.copyWith(
                  color: CustomColor.colorWhite,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        // The main photo is not a drop target: it can only be changed by
        // picking/uploading a new image (keeps the avatar API flow simple).
        GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.onAddPhotoTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: ScreenConstant.defaultSizeThreeTwenty,
                    width: double.infinity,
                    child: Stack(
                children: [
                  Positioned.fill(
                    child: Obx(() {
                      final File? photo = controller.profileImage.value;
                      if (photo != null) {
                        return Image.file(
                          photo,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      }
                      // No local pick this session: server avatar URL
                      // (register / avatar-upload response).
                      final String url = controller.mainPhotoUrl;
                      if (url.isNotEmpty) {
                        return MemberNetworkImage(url: url);
                      }
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              CustomColor.color0F172A,
                              CustomColor.color334155,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              color: CustomColor.colorWhite,
                              size: ScreenConstant.texIconSize,
                            ),
                            SizedBox(height: ScreenConstant.sizeSmall),
                            Text(
                              "Add main photo",
                              style: TextStyles.registerFieldNote.copyWith(
                                color: CustomColor.colorWhite,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    top: ScreenConstant.sizeSmall,
                    left: ScreenConstant.sizeSmall,
                    child: _overlayPill(
                      icon: Icons.star,
                      label: "Main Feature",
                      bg: CustomColor.color0F172A.withOpacity(0.6),
                      fg: CustomColor.colorWhite,
                    ),
                  ),
                  Positioned(
                    top: ScreenConstant.sizeSmall,
                    right: ScreenConstant.sizeSmall,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.onMainPhotoMenu,
                      child: Container(
                        height: ScreenConstant.defaultHeightThirty,
                        width: ScreenConstant.defaultWidthThirty,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColor.color0F172A.withOpacity(0.6),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: CustomColor.colorWhite,
                          size: ScreenConstant.minimumIconSize + 3,
                        ),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   bottom: ScreenConstant.sizeSmall,
                  //   left: ScreenConstant.sizeSmall,
                  //   child: _overlayPill(
                  //     icon: Icons.drag_handle,
                  //     label: "Hold & Drag",
                  //     bg: CustomColor.color0F172A.withOpacity(0.6),
                  //     fg: CustomColor.colorWhite,
                  //   ),
                  // ),
                  // Positioned(
                  //   bottom: ScreenConstant.sizeSmall,
                  //   right: ScreenConstant.sizeSmall,
                  //   child: _overlayPill(
                  //     icon: Icons.center_focus_strong,
                  //     label: "Focus Mode",
                  //     bg: CustomColor.colorWhite,
                  //     fg: CustomColor.color0F172A,
                  //   ),
                  // ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }

  Widget _overlayPill({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenConstant.minimumIconSize - 2, color: fg),
          SizedBox(width: ScreenConstant.sizeExtraSmall / 2),
          Text(
            label,
            style: TextStyles.policiesBadgeText.copyWith(color: fg),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (3) Personal Vault Gallery header
  // ---------------------------------------------------------------------------
  Widget _buildVaultHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personal Vault Gallery",
                style: TextStyles.registerSectionTitle,
              ),
              SizedBox(height: 2),
              Text(
                "Private photos shared selectively or upon mutual match.",
                style: TextStyles.registerFieldNote,
              ),
            ],
          ),
        ),
        SizedBox(width: ScreenConstant.sizeSmall),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.sizeSmall,
            vertical: ScreenConstant.sizeExtraSmall / 1.5,
          ),
          decoration: BoxDecoration(
            color: CustomColor.colorFFF1F2,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Obx(
            () => Text(
              "${controller.galleryTotalCount} / ${RegisterController.kMaxGalleryPhotos}",
              style: TextStyles.policiesBadgeText.copyWith(
                color: CustomColor.colorBE123C,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (4) Gallery grid
  // ---------------------------------------------------------------------------
  Widget _buildGallery() {
    // GetBuilder only provides the screen-entry hook (LIST on open).
    // autoRemove: false — the controller is owned by the route binding.
    return GetBuilder<RegisterController>(
      autoRemove: false,
      initState: (_) => Future.microtask(controller.onGalleryScreenEnter),
      builder: (_) => _buildGalleryContent(),
    );
  }

  Widget _buildGalleryContent() {
    return Obx(() {
      final List<GalleryPhoto> photos = controller.galleryPhotos.toList();
      final List<PendingGalleryUpload> pending =
          controller.pendingGalleryUploads.toList();
      final Set<String> busy = controller.busyGalleryPhotoIds.toSet();
      final bool loading = controller.isGalleryLoading.value;
      final int count = photos.length + pending.length;
      const int maxSlots = RegisterController.kMaxGalleryPhotos;

      final List<Widget> tiles = [];
      // Server photos (position 1..n), then uploads still in flight.
      for (int i = 0; i < photos.length; i++) {
        tiles.add(_galleryThumb(i, photos[i], busy.contains(photos[i].id)));
      }
      for (final p in pending) {
        tiles.add(_pendingThumb(p));
      }

      if (count < maxSlots) {
        // One "Add Photo" tile occupying the next open slot.
        tiles.add(_addTile(count + 1));

        // Slots still free after the photos and the Add tile.
        final int freeAfterAdd = maxSlots - count - 1;
        // Show at most two empty "+" placeholders, then summarize the rest
        // (if any) as a single "+N more" tile.
        const int maxPlusTiles = 2;
        final int plusTiles =
            freeAfterAdd < maxPlusTiles ? freeAfterAdd : maxPlusTiles;
        for (int i = 0; i < plusTiles; i++) {
          tiles.add(_plusTile());
        }
        final int more = freeAfterAdd - plusTiles;
        if (more > 0) {
          tiles.add(_moreTile(more));
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First load: spinner instead of an empty grid.
          if (loading && photos.isEmpty)
            SizedBox(
              height: ScreenConstant.defaultSizeOneTen,
              width: double.infinity,
              child: Center(child: _roseSpinner()),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: ScreenConstant.sizeSmall,
              crossAxisSpacing: ScreenConstant.sizeSmall,
              childAspectRatio: 1,
              children: tiles,
            ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Row(
            children: [
              Icon(
                Icons.open_with,
                size: ScreenConstant.minimumIconSize,
                color: CustomColor.color94A3B8,
              ),
              SizedBox(width: ScreenConstant.sizeExtraSmall),
              Text(
                "Drag & drop photos to reorder slots.",
                style: TextStyles.registerFieldNote,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _galleryThumb(int index, GalleryPhoto photo, bool busy) {
    // DragTarget: dropping another thumbnail here reorders it to this slot.
    // Only accepts valid gallery indices (the main photo is not draggable);
    // tiles with a DELETE in flight neither accept nor start drags.
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) =>
          !busy &&
          details.data >= 0 &&
          details.data < controller.galleryPhotos.length &&
          details.data != index,
      onAcceptWithDetails: (details) =>
          controller.reorderGalleryPhoto(details.data, index),
      builder: (context, candidate, rejected) {
        final bool hovering = candidate.isNotEmpty;
        // Draggable: long-press to pick up this thumbnail (so it doesn't fight
        // the scroll view). Payload is the gallery index.
        return LongPressDraggable<int>(
          data: index,
          maxSimultaneousDrags: busy ? 0 : 1,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: _thumbFeedback(photo),
          childWhenDragging: _thumbPlaceholder(),
          child: _thumbContent(index, photo, highlight: hovering, busy: busy),
        );
      },
    );
  }

  Widget _roseSpinner() {
    return SizedBox(
      width: ScreenConstant.smallIconSize,
      height: ScreenConstant.smallIconSize,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(CustomColor.colorBE185D),
      ),
    );
  }

  /// Upload in flight: local preview dimmed under a spinner (no drag/remove).
  Widget _pendingThumb(PendingGalleryUpload pending) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(pending.file, fit: BoxFit.cover),
          Container(
            color: CustomColor.colorWhite.withOpacity(0.6),
            alignment: Alignment.center,
            child: _roseSpinner(),
          ),
        ],
      ),
    );
  }

  /// The visible thumbnail (image + #index badge + remove button).
  Widget _thumbContent(
    int index,
    GalleryPhoto photo, {
    bool highlight = false,
    bool busy = false,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: highlight
                    ? CustomColor.colorBE123C
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MemberNetworkImage(url: photo.url),
            ),
          ),
        ),
        if (busy)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: CustomColor.colorWhite.withOpacity(0.6),
                alignment: Alignment.center,
                child: _roseSpinner(),
              ),
            ),
          ),
        Positioned(
          top: ScreenConstant.sizeExtraSmall,
          left: ScreenConstant.sizeExtraSmall,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.sizeExtraSmall + 1,
              vertical: ScreenConstant.sizeExtraSmall / 2,
            ),
            decoration: BoxDecoration(
              color: CustomColor.color0F172A.withOpacity(0.6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              "#${index + 1}",
              style: TextStyles.policiesBadgeText.copyWith(
                color: CustomColor.colorWhite,
              ),
            ),
          ),
        ),
        if (!busy)
        Positioned(
          top: ScreenConstant.sizeExtraSmall,
          right: ScreenConstant.sizeExtraSmall,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.confirmRemoveGalleryPhoto(photo),
            child: Container(
              height: 22,
              width: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColor.colorWhite,
              ),
              child: Icon(
                Icons.close,
                size: ScreenConstant.minimumIconSize - 2,
                color: CustomColor.color0F172A,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Floating preview shown under the finger while dragging a thumbnail.
  Widget _thumbFeedback(GalleryPhoto photo) {
    final double side = ScreenConstant.defaultSizeOneTen;
    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.9,
        child: Container(
          height: side,
          width: side,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CustomColor.color0F172A.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MemberNetworkImage(url: photo.url),
          ),
        ),
      ),
    );
  }

  /// The empty gap left in the grid while a thumbnail is being dragged.
  Widget _thumbPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      ),
    );
  }

  Widget _addTile(int slot) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onAddGalleryPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: CustomColor.colorFFF1F2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColor.colorFECDD3, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              color: CustomColor.colorBE123C,
              size: ScreenConstant.smallIconSize,
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall / 2),
            Text(
              "Add Photo",
              style: TextStyles.policiesBadgeText.copyWith(
                color: CustomColor.colorBE123C,
              ),
            ),
            Text(
              "Slot $slot",
              style: TextStyles.registerFieldNote,
            ),
          ],
        ),
      ),
    );
  }

  Widget _plusTile() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onAddGalleryPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
        ),
        child: Icon(
          Icons.add,
          color: CustomColor.color94A3B8,
          size: ScreenConstant.smallIconSize,
        ),
      ),
    );
  }

  Widget _moreTile(int remaining) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onAddGalleryPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: CustomColor.colorFFF1F2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColor.colorFECDD3, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "+$remaining more",
              style: TextStyles.policiesBadgeText.copyWith(
                color: CustomColor.colorBE123C,
              ),
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall / 2),
            Text(
              "up to ${RegisterController.kMaxGalleryPhotos} slots",
              style: TextStyles.registerFieldNote,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (5) Action buttons row
  // ---------------------------------------------------------------------------
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            Icons.file_upload_outlined,
            "Upload",
            controller.onAddGalleryPhoto,
          ),
        ),
        SizedBox(width: ScreenConstant.sizeSmall),
        Expanded(
          child: _actionButton(
            Icons.photo_camera_outlined,
            "Camera",
            controller.onAddGalleryPhoto,
          ),
        ),
        SizedBox(width: ScreenConstant.sizeSmall),
        Expanded(
          child: _actionButton(
            Icons.swap_vert,
            "Reorder",
            controller.onReorderGallery,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ScreenConstant.sizeSmall),
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ScreenConstant.minimumIconSize + 2,
              color: CustomColor.color334155,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.registerFieldLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (6) Save & Continue button
  // ---------------------------------------------------------------------------
  Widget _buildSaveButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onSavePhotosContinue,
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: CustomColor.colorDB2777.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Save & Continue",
              style: TextStyles.loginButtonText.copyWith(
                color: CustomColor.colorWhite,
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Icon(
              Icons.arrow_forward,
              color: CustomColor.colorWhite,
              size: ScreenConstant.smallIconSize,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (7) Skip link
  // ---------------------------------------------------------------------------
  Widget _buildSkipLink() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onSkipPhotos,
      child: Text(
        "Skip photo upload for now",
        textAlign: TextAlign.center,
        style: TextStyles.paymentCancelLink,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (8) Footer security strip
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: ScreenConstant.sizeMedium,
        runSpacing: ScreenConstant.sizeExtraSmall,
        children: [
          _footerBadge(
            Icons.visibility_off,
            "Zero Indexing",
            CustomColor.colorBE185D,
          ),
          _footerBadge(
            Icons.gavel_outlined,
            "Belgian GDPR Protected",
            CustomColor.colorBE123C,
          ),
        ],
      ),
    );
  }

  Widget _footerBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: ScreenConstant.minimumIconSize - 2, color: color),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Text(text, style: TextStyles.registerFooterStrip),
      ],
    );
  }
}
