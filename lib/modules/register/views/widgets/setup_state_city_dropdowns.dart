import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/belgium_locations.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../controller/register_controller.dart';

/// State + City (Belgium) side by side for the onboarding location card.
/// Bound to [RegisterController.setupState] / [RegisterController.setupCity].
/// Same look and rules as Edit Profile's location dropdowns: "Select state" /
/// "Select city", City disabled until a state is picked, changing the state
/// resets the city (see [RegisterController.selectSetupState]), tiny loader
/// while the shared [BelgiumLocations] data loads. Location stays optional.
class SetupStateCityDropdowns extends StatefulWidget {
  const SetupStateCityDropdowns({super.key});

  @override
  State<SetupStateCityDropdowns> createState() =>
      _SetupStateCityDropdownsState();
}

class _SetupStateCityDropdownsState extends State<SetupStateCityDropdowns> {
  RegisterController get controller => Get.find<RegisterController>();

  @override
  void initState() {
    super.initState();
    // Shared single-flight loader: the big city file is decoded once per app
    // run, off the UI thread.
    BelgiumLocations.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _stateDropdown()),
        SizedBox(width: ScreenConstant.sizeSmall),
        Expanded(child: _cityDropdown()),
      ],
    );
  }

  TextStyle get _text =>
      TextStyles.loginTopText.copyWith(fontSize: FontSize.s14);

  Widget _hint(String text) => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _text.copyWith(color: CustomColor.color94A3B8),
      );

  Widget _shell({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      container: true,
      child: Container(
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
              icon,
              color: CustomColor.color64748B,
              size: ScreenConstant.smallIconSize,
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _arrow(bool loading) => loading
      ? SizedBox(
          width: ScreenConstant.smallIconSize,
          height: ScreenConstant.smallIconSize,
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(CustomColor.colorBE185D),
            ),
          ),
        )
      : Icon(
          Icons.keyboard_arrow_down,
          color: CustomColor.color64748B,
          size: ScreenConstant.smallIconSize,
        );

  Widget _stateDropdown() {
    return Obx(() {
      final bool loading = BelgiumLocations.instance.isLoading.value;
      BelgiumLocations.instance.isLoaded.value; // rebuild when loaded
      final List<csc.State> states = BelgiumLocations.instance.states;
      final csc.State? selected = controller.setupState.value;
      return _shell(
        label: 'State',
        icon: Icons.location_on_outlined,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            menuMaxHeight: 300,
            value: selected?.isoCode ?? '',
            icon: _arrow(loading),
            style: _text,
            items: [
              DropdownMenuItem<String>(
                value: '',
                child: _hint('Select state'),
              ),
              for (final csc.State st in states)
                DropdownMenuItem<String>(
                  value: st.isoCode,
                  child: Text(
                    st.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _text,
                  ),
                ),
            ],
            onChanged: loading
                ? null
                : (String? iso) => controller.selectSetupState(
                      states.firstWhereOrNull((s) => s.isoCode == iso),
                    ),
          ),
        ),
      );
    });
  }

  Widget _cityDropdown() {
    return Obx(() {
      final bool loading = BelgiumLocations.instance.isLoading.value;
      BelgiumLocations.instance.isLoaded.value; // rebuild when loaded
      final csc.State? state = controller.setupState.value;
      final csc.City? selected = controller.setupCity.value;
      final List<csc.City> cities = state == null
          ? const <csc.City>[]
          : BelgiumLocations.instance.citiesOf(state.isoCode);
      final bool enabled = state != null && !loading;
      return Opacity(
        opacity: state == null ? 0.5 : 1,
        child: _shell(
          label: 'City',
          icon: Icons.location_city_outlined,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              menuMaxHeight: 300,
              // Guard: a value not in the items list would assert.
              value: (selected != null &&
                      cities.any((c) => c.name == selected.name))
                  ? selected.name
                  : '',
              disabledHint:
                  _hint(state == null ? 'Select state first' : 'Select city'),
              icon: _arrow(loading),
              style: _text,
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: _hint('Select city'),
                ),
                for (final csc.City c in cities)
                  DropdownMenuItem<String>(
                    value: c.name,
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text,
                    ),
                  ),
              ],
              onChanged: enabled
                  ? (String? name) => controller.selectSetupCity(
                        cities.firstWhereOrNull((c) => c.name == name),
                      )
                  : null,
            ),
          ),
        ),
      );
    });
  }
}
