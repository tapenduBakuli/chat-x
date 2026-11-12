import 'dart:io';

import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:chat_x/modules/register/model/lifestyle_options.dart';
import 'package:chat_x/modules/register/views/widgets/tick_select_row.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../../../utils/image_utils/image_utils.dart';
import '../../home/views/widgets/member_network_image.dart';
import '../../register/model/gallery_photo_model.dart';
import '../../register/views/widgets/intimate_desires_form.dart';

class EditProfileScreen extends GetView<RegisterController> {
  const EditProfileScreen({super.key});

  static const List<String> _genders = ['Woman', 'Man', 'Trans-man', 'trans-woman'];
  static const List<String> _orientations = [
    'Straight',
    'Bisexual',
    'Gay / Lesbian',
    'Pansexual',
    'Open-minded',
  ];
  static const List<String> _lookingForOptions = [
    'Intimate connection',
    'Casual dating',
    'Discreet exploration',
    'Regular meetups',
    'Deep friendship',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onBack,
          child: Icon(
            Icons.arrow_back,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Edit Profile",
              style: TextStyles.registerAppBarTitle,
            ),
            Text(
              "Update your profile details, photos, and preferences",
              style: TextStyles.registerFieldNote.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.defaultWidthTwenty,
                  vertical: ScreenConstant.defaultHeightFifteen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionWrapper(
                      title: "Main Avatar",
                      child: _buildAddPhoto(),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildSectionWrapper(
                      title: "Primary Profile Photo",
                      child: _buildMainPhoto(),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildSectionWrapper(
                      title: "Photo Gallery",
                      child: _buildGallerySection(),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildSectionWrapper(
                      title: "Profile Setup",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => controller.isProfileHydrating.value
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      bottom: ScreenConstant.sizeSmall,
                                    ),
                                    child: const LinearProgressIndicator(
                                      minHeight: 2,
                                      color: CustomColor.colorBE185D,
                                      backgroundColor: CustomColor.colorE2E8F0,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          _buildProfileNameField(),
                          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                          _buildGenderField(),
                          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                          _buildLifestyleFields(),
                          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                          _buildDobField(),
                          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                          _buildOrientationField(),
                          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                          _buildLookingForField(),
                          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                          _buildLocationField(),
                          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                          _buildAboutMeField(),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildSectionWrapper(
                      title: "Intimate Desires & Chemistry",
                      child: _buildIntimateDesiresSection(),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightThirty),
                    _buildBottomActionBar(),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSectionWrapper({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color0F172A.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.registerSectionTitle.copyWith(
              fontSize: 16,
              color: CustomColor.color0F172A,
            ),
          ),
          SizedBox(height: ScreenConstant.sizeMedium),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (1) Avatar Upload (_buildAddPhoto)
  // ---------------------------------------------------------------------------
  Widget _buildAddPhoto() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.onAddPhotoTap,
            child: SizedBox(
              height: ScreenConstant.defaultSizeOneTen,
              width: ScreenConstant.defaultSizeOneTen,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: ScreenConstant.defaultSizeOneTwenty,
                    width: ScreenConstant.defaultSizeOneTwenty,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CustomColor.colorEC4899,
                          CustomColor.colorF43F5E,
                          CustomColor.color9333EA,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Obx(() {
                        final File? photo = controller.profileImage.value;
                        // Local pick first, else the server avatar URL.
                        final String url = controller.mainPhotoUrl;
                        return Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CustomColor.colorWhite,
                          ),
                          child: photo != null
                              ? Image.file(
                                  photo,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : url.isNotEmpty
                              ? MemberNetworkImage(url: url)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageUtils.addPhoto,
                                      height: ScreenConstant.texIconSize,
                                      color: CustomColor.color475569,
                                    ),
                                    SizedBox(height: ScreenConstant.sizeExtraSmall),
                                    Text(
                                      "AVATAR",
                                      style:
                                          TextStyles.policiesBadgeText.copyWith(
                                        color: CustomColor.color334155,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(ScreenConstant.sizeExtraSmall),
                      decoration: const BoxDecoration(
                        color: CustomColor.colorBE185D,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: CustomColor.colorWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        Text(
          "Upload or change main profile avatar",
          style: TextStyles.registerFieldNote,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (2) Primary Profile Photo (_buildMainPhoto)
  // ---------------------------------------------------------------------------
  Widget _buildMainPhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Main Profile Photo", style: TextStyles.registerFieldLabel),
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
                "PRIMARY PHOTO",
                style: TextStyles.policiesBadgeText.copyWith(
                  color: CustomColor.colorWhite,
                  fontSize: 10,
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
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CustomColor.colorE2E8F0,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Obx(() {
                    final File? photo = controller.profileImage.value;
                    if (photo != null) {
                      return Image.file(
                        photo,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    }
                    // No local pick: server avatar (GET /users/me).
                    final String url = controller.mainPhotoUrl;
                    if (url.isNotEmpty) {
                      return MemberNetworkImage(url: url);
                    }
                    return Container(
                      color: CustomColor.colorF8FAFC,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: CustomColor.color94A3B8,
                          ),
                          SizedBox(height: ScreenConstant.sizeSmall),
                          Text(
                            "Tap to add main profile photo",
                            style: TextStyles.registerFieldNote,
                          ),
                        ],
                      ),
                    );
                  }),
                  Positioned(
                    bottom: ScreenConstant.sizeSmall,
                    right: ScreenConstant.sizeSmall,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenConstant.sizeMedium,
                        vertical: ScreenConstant.sizeExtraSmall + 1,
                      ),
                      decoration: BoxDecoration(
                        color: CustomColor.color0D1527.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 14,
                            color: CustomColor.colorWhite,
                          ),
                          SizedBox(width: ScreenConstant.sizeExtraSmall),
                          Text(
                            "Change",
                            style: TextStyle(
                              color: CustomColor.colorWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Liberation",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (3) Photo Gallery (_buildGallerySection)
  // ---------------------------------------------------------------------------
  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                "Photo Gallery (${controller.galleryTotalCount}/${RegisterController.kMaxGalleryPhotos})",
                style: TextStyles.registerFieldLabel,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeSmall,
                vertical: ScreenConstant.sizeExtraSmall / 1.5,
              ),
              decoration: BoxDecoration(
                color: CustomColor.colorECFDF5,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 11,
                    color: CustomColor.color059669,
                  ),
                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Photos are private",
                    style: TextStyles.policiesBadgeText.copyWith(
                      fontSize: 10,
                      color: CustomColor.color059669,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        _buildGalleryGrid(),
        SizedBox(height: ScreenConstant.sizeSmall),
        Row(
          children: [
            Icon(
              Icons.open_with,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Expanded(
              child: Text(
                "Long-press and drag to reorder",
                style: TextStyles.registerFieldNote,
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeMedium),
        GestureDetector(
          onTap: controller.onAddGalleryPhoto,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: ScreenConstant.sizeExtraSmall + 2,
            ),
            decoration: BoxDecoration(
              color: CustomColor.colorF1F5F9,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: CustomColor.colorE2E8F0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 16,
                  color: CustomColor.color334155,
                ),
                SizedBox(width: ScreenConstant.sizeExtraSmall),
                Text(
                  "Add Gallery Photo",
                  style: TextStyles.policiesPillText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryGrid() {
    // GetBuilder only provides the screen-entry hook (LIST + avatar lookup).
    // autoRemove: false — the controller is owned by the route binding.
    return GetBuilder<RegisterController>(
      autoRemove: false,
      initState: (_) => Future.microtask(controller.onEditProfileEnter),
      builder: (_) => _buildGalleryGridContent(),
    );
  }

  Widget _buildGalleryGridContent() {
    return Obx(() {
      final List<GalleryPhoto> photos = controller.galleryPhotos.toList();
      final List<PendingGalleryUpload> pending =
          controller.pendingGalleryUploads.toList();
      final Set<String> busy = controller.busyGalleryPhotoIds.toSet();
      final bool loading = controller.isGalleryLoading.value;
      final int count = photos.length + pending.length;
      const int maxSlots = RegisterController.kMaxGalleryPhotos;

      // First load: spinner instead of an empty grid.
      if (loading && photos.isEmpty) {
        return SizedBox(
          height: ScreenConstant.defaultSizeOneTen,
          width: double.infinity,
          child: Center(child: _roseSpinner()),
        );
      }

      final List<Widget> tiles = [];
      // Server photos (position 1..n), then uploads still in flight.
      for (int i = 0; i < photos.length; i++) {
        tiles.add(_galleryThumb(i, photos[i], busy.contains(photos[i].id)));
      }
      for (final p in pending) {
        tiles.add(_pendingThumb(p));
      }

      if (count < maxSlots) {
        tiles.add(_addTile(count + 1));
        final int freeAfterAdd = maxSlots - count - 1;
        const int maxPlusTiles = 2;
        final int plusTiles =
            freeAfterAdd < maxPlusTiles ? freeAfterAdd : maxPlusTiles;
        for (int i = 0; i < plusTiles; i++) {
          tiles.add(_plusTile());
        }
      }

      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: ScreenConstant.sizeSmall,
        crossAxisSpacing: ScreenConstant.sizeSmall,
        childAspectRatio: 1,
        children: tiles,
      );
    });
  }

  /// Long-press to pick up a thumbnail; drop it on another thumbnail to
  /// reorder. Drag & drop stays inside the gallery: the main photo is neither
  /// a drop target nor draggable. Only valid gallery indices are accepted.
  Widget _galleryThumb(int index, GalleryPhoto photo, bool busy) {
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
        return LongPressDraggable<int>(
          data: index,
          // Tiles with a DELETE in flight can't be dragged.
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
      borderRadius: BorderRadius.circular(14),
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

  /// Floating preview under the finger while dragging.
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
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: CustomColor.color0F172A.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: MemberNetworkImage(url: photo.url),
          ),
        ),
      ),
    );
  }

  /// Empty slot left behind while a thumbnail is being dragged.
  Widget _thumbPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColor.colorE2E8F0),
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: highlight
                    ? CustomColor.colorBE123C
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: MemberNetworkImage(url: photo.url),
            ),
          ),
        ),
        // DELETE in flight: dimmed tile with a spinner.
        if (busy)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: CustomColor.colorWhite.withOpacity(0.6),
                alignment: Alignment.center,
                child: _roseSpinner(),
              ),
            ),
          ),
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: CustomColor.color0F172A.withOpacity(0.6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              "#${index + 1}",
              style: TextStyles.policiesBadgeText.copyWith(
                color: CustomColor.colorWhite,
                fontSize: 10,
              ),
            ),
          ),
        ),
        if (!busy)
          Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.confirmRemoveGalleryPhoto(photo),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: CustomColor.color0F172A,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: CustomColor.colorWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addTile(int slotNumber) {
    return GestureDetector(
      onTap: controller.onAddGalleryPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: CustomColor.colorFFF1F2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CustomColor.colorFECDD3, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              size: 20,
              color: CustomColor.colorBE185D,
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              "Add Photo\n$slotNumber/${RegisterController.kMaxGalleryPhotos}",
              textAlign: TextAlign.center,
              style: TextStyles.policiesBadgeText.copyWith(
                fontSize: 9,
                color: CustomColor.colorBE185D,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _plusTile() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CustomColor.colorE2E8F0),
      ),
      child: Icon(
        Icons.add,
        size: 20,
        color: CustomColor.color94A3B8,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (4) Profile Setup Form Fields
  // ---------------------------------------------------------------------------
  Widget _buildProfileNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Profile Name"),
        // Read-only on Edit Profile: the PUT payload always sends the
        // original server name.
        Semantics(
          label: "Profile name, can't be changed",
          readOnly: true,
          child: SizedBox(
            height: ScreenConstant.defaultHeightFifty,
            child: CustomTextField(
              borderRadius: 26,
              controller: controller.profileNameController,
              hintText: "JerryTwo",
              readOnly: true,
              enabled: false,
              fillColor: CustomColor.colorF1F5F9,
              textStyle: TextStyles.loginFieldText
                  .copyWith(color: CustomColor.color94A3B8),
              borderColor: CustomColor.colorE2E8F0,
              prefix: Icon(
                Icons.person_outline,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.color94A3B8,
              ),
              suffix: Icon(
                Icons.lock_outline,
                size: ScreenConstant.minimumIconSize,
                color: CustomColor.color94A3B8,
              ),
            ),
          ),
        ),
        _lockedNote(),
      ],
    );
  }

  /// Small "Can't be changed" helper under the read-only fields.
  Widget _lockedNote() {
    return Padding(
      padding: EdgeInsets.only(top: ScreenConstant.sizeExtraSmall + 2),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 11,
            color: CustomColor.color94A3B8,
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text("Can't be changed", style: TextStyles.registerFieldNote),
        ],
      ),
    );
  }

  /// Editable single-select gender chips, pre-selected from GET /users/me.
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Gender"),
        _singleSelectChips(
          semanticsPrefix: "Gender",
          options: _genders,
          selected: () => controller.selectedGender.value,
          onSelect: controller.selectGender,
        ),
      ],
    );
  }

  /// Editable lifestyle single-selects, pre-selected from state.
  Widget _buildLifestyleFields() {
    final fields = <(String, List<String>, RxString, void Function(String))>[
      ("Has children", LifestyleOptions.yesNo, controller.hasChildren,
          controller.selectHasChildren),
      ("Relationship status", LifestyleOptions.relationshipStatus,
          controller.relationshipStatus, controller.selectRelationshipStatus),
      ("Works", LifestyleOptions.yesNo, controller.works,
          controller.selectWorks),
      ("Own house", LifestyleOptions.yesNo, controller.ownHouse,
          controller.selectOwnHouse),
      ("Car", LifestyleOptions.yesNo, controller.hasCar,
          controller.selectHasCar),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          if (i > 0) SizedBox(height: ScreenConstant.sizeSmall),
          TickSelectRow(
            label: fields[i].$1,
            options: fields[i].$2,
            selected: () => fields[i].$3.value,
            onSelect: fields[i].$4,
            labelStyle: TextStyles.loginFieldLabel,
          ),
        ],
      ],
    );
  }

  /// Reusable editable single-select chips. [selected] must read an
  /// observable so the wrapping Obx rebuilds.
  Widget _singleSelectChips({
    required String semanticsPrefix,
    required List<String> options,
    required String Function() selected,
    required void Function(String) onSelect,
  }) {
    return Obx(() {
      final String current = selected();
      return Wrap(
        spacing: ScreenConstant.sizeSmall,
        runSpacing: ScreenConstant.sizeSmall,
        children: options.map((o) {
          final bool isSelected = current == o;
          return Semantics(
            button: true,
            selected: isSelected,
            label: "$semanticsPrefix: $o",
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => onSelect(o),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.sizeMedium,
                  vertical: ScreenConstant.sizeExtraSmall + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CustomColor.colorFFF1F2
                      : CustomColor.colorF8FAFC,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? CustomColor.colorBE123C
                        : CustomColor.colorE2E8F0,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  o,
                  style: TextStyles.policiesPillText.copyWith(
                    color: isSelected
                        ? CustomColor.colorBE123C
                        : CustomColor.color334155,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  /// Read-only single-select chips (gender / orientation): dimmed, taps
  /// ignored, still showing the hydrated [selected] value.
  Widget _readOnlyChips({
    required String semanticsLabel,
    required List<String> options,
    required String selected,
  }) {
    return Semantics(
      label: "$semanticsLabel: $selected, can't be changed",
      readOnly: true,
      excludeSemantics: true,
      child: Opacity(
        opacity: 0.6,
        child: IgnorePointer(
          child: Wrap(
            spacing: ScreenConstant.sizeSmall,
            runSpacing: ScreenConstant.sizeSmall,
            children: options.map((o) {
              final bool isSelected = selected == o;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.sizeMedium,
                  vertical: ScreenConstant.sizeExtraSmall + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CustomColor.colorFFF1F2
                      : CustomColor.colorF8FAFC,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? CustomColor.colorBE123C
                        : CustomColor.colorE2E8F0,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  o,
                  style: TextStyles.policiesPillText.copyWith(
                    color: isSelected
                        ? CustomColor.colorBE123C
                        : CustomColor.color334155,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDobField() {
    final int currentYear = DateTime.now().year;
    final List<int> days = List.generate(31, (i) => i + 1);
    final List<int> months = List.generate(12, (i) => i + 1);
    final List<String> monthNames = const [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    final List<int> years =
        List.generate(currentYear - 18 - 1950 + 1, (i) => currentYear - 18 - i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Date of Birth / Age Verification"),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _dropdown<int>(
                  value: controller.selectedDobDay.value,
                  hint: "Day",
                  items: days
                      .map(
                        (d) => DropdownMenuItem<int>(
                          value: d,
                          child: Text(
                            "$d",
                            style: TextStyles.loginTopText
                                .copyWith(fontSize: FontSize.s14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setDobDay,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                () => _dropdown<int>(
                  value: controller.selectedDobMonth.value,
                  hint: "Month",
                  items: months
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m,
                          child: Text(
                            monthNames[m - 1],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.loginTopText
                                .copyWith(fontSize: FontSize.s14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setDobMonth,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                () => _dropdown<int>(
                  value: controller.selectedDobYear.value,
                  hint: "Year",
                  items: years
                      .map(
                        (y) => DropdownMenuItem<int>(
                          value: y,
                          child: Text(
                            "$y",
                            style: TextStyles.loginTopText
                                .copyWith(fontSize: FontSize.s14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setDobYear,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall + 2),
        Text(
          "Your date of birth will be used for age verification.",
          style: TextStyles.registerFieldNote,
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: ScreenConstant.defaultHeightFifty,
      padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyles.loginTopText.copyWith(
              fontSize: FontSize.s14,
              color: CustomColor.color94A3B8,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: CustomColor.color64748B,
            size: ScreenConstant.smallIconSize,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildOrientationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Orientation"),
        Obx(
          () => Wrap(
            spacing: ScreenConstant.sizeSmall,
            runSpacing: ScreenConstant.sizeSmall,
            children: _orientations.map((opt) {
              final bool selected =
                  controller.selectedOrientation.value == opt;
              return GestureDetector(
                onTap: () => controller.selectOrientation(opt),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeMedium,
                    vertical: ScreenConstant.sizeExtraSmall + 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? CustomColor.colorFFF1F2
                        : CustomColor.colorF8FAFC,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: selected
                          ? CustomColor.colorBE123C
                          : CustomColor.colorE2E8F0,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyles.policiesPillText.copyWith(
                      color: selected
                          ? CustomColor.colorBE123C
                          : CustomColor.color334155,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLookingForField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Looking for"),
        Obx(
          () => Wrap(
            spacing: ScreenConstant.sizeSmall,
            runSpacing: ScreenConstant.sizeSmall,
            children: _lookingForOptions.map((opt) {
              // Same list the PUT payload (looking_for) and onboarding use.
              final bool selected = controller.selectedLookingFor.contains(opt);
              return GestureDetector(
                onTap: () => controller.toggleLookingFor(opt),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeMedium,
                    vertical: ScreenConstant.sizeExtraSmall + 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? CustomColor.colorFFF1F2
                        : CustomColor.colorF8FAFC,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: selected
                          ? CustomColor.colorBE123C
                          : CustomColor.colorE2E8F0,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyles.policiesPillText.copyWith(
                      color: selected
                          ? CustomColor.colorBE123C
                          : CustomColor.color334155,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label("Location"),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeSmall,
                vertical: ScreenConstant.sizeExtraSmall / 1.5,
              ),
              decoration: BoxDecoration(
                color: CustomColor.colorECFDF5,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 11,
                    color: CustomColor.color059669,
                  ),
                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Location hidden",
                    style: TextStyles.policiesBadgeText.copyWith(
                      fontSize: 10,
                      color: CustomColor.color059669,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          height: ScreenConstant.defaultHeightFifty,
          padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeMedium),
          decoration: BoxDecoration(
            color: CustomColor.colorF8FAFC,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: CustomColor.color64748B,
                size: ScreenConstant.smallIconSize,
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Expanded(
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      // null when no city is picked (value must be in items).
                      value: controller.selectedProfileCity.value.isEmpty
                          ? null
                          : controller.selectedProfileCity.value,
                      hint: Text(
                        "Select your city (optional)",
                        style: TextStyles.loginTopText.copyWith(
                          fontSize: FontSize.s14,
                          color: CustomColor.color94A3B8,
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: CustomColor.color64748B,
                        size: ScreenConstant.smallIconSize,
                      ),
                      style: TextStyles.loginTopText
                          .copyWith(fontSize: FontSize.s14),
                      items: controller.belgianCities
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.loginTopText
                                    .copyWith(fontSize: FontSize.s14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.onProfileCitySelected(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutMeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("About Me / Desires"),
        CustomTextField(
          borderRadius: 16,
          controller: controller.aboutMeController,
          hintText:
              "Passionate about meaningful conversations, exploring cozy cafes, art galleries, and authentic connections.",
          borderColor: CustomColor.colorE2E8F0,
          hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: 4,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (5) Intimate Desires & Chemistry
  // ---------------------------------------------------------------------------
  Widget _buildIntimateDesiresSection() {
    // Shared with the onboarding Intimate Desires screen so options, icons and
    // selection behavior are identical; bound to the same RegisterController.
    return const IntimateDesiresForm();
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
      child: Text(text, style: TextStyles.loginFieldLabel),
    );
  }

  // ---------------------------------------------------------------------------
  // (6) Bottom Action Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color0F172A.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.onBack,
            child: Container(
              height: ScreenConstant.defaultHeightFifty,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeLarge,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: CustomColor.colorE2E8F0,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.color0F172A,
                  ),
                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Back",
                    style: TextStyles.browseToggleLabel.copyWith(
                      color: CustomColor.color0F172A,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: ScreenConstant.sizeMedium),
          // Save & Continue -> PUT /users/me; shows the same spinner pill as
          // Login/Publish while saving and ignores taps meanwhile.
          Expanded(
            child: Obx(() {
              if (controller.isSavingEditProfile.value) {
                return Semantics(
                  label: "Saving profile",
                  child: Container(
                    height: ScreenConstant.defaultHeightSixty,
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
                  ),
                );
              }
              return buildLoginButton(
                "Save & Continue",
                true,
                controller.onSaveEditProfile,
                Icons.arrow_forward,
              );
            }),
          ),
        ],
      ),
    );
  }
}
