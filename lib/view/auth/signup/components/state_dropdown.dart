import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qixer/service/country_states_service.dart';
import 'package:qixer/view/utils/constant_colors.dart';
import 'package:qixer/view/utils/others_helper.dart';

class StateDropdown extends StatelessWidget {
  const StateDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cc = ConstantColors();

    return Consumer<CountryStatesService>(
      builder: (context, provider, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          provider.statesDropdownList.isNotEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: cc.greyFive),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      // menuMaxHeight: 200,
                      isExpanded: true,
                      value: provider.selectedState,
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: cc.greyFour),
                      iconSize: 26,
                      elevation: 17,
                      style: TextStyle(color: cc.greyFour),
                      onChanged: (newValue) {
                        provider.setStatesValue(newValue);

                        //setting the id of selected value
                        provider.setSelectedStatesId(
                            provider.statesDropdownIndexList[
                                provider.statesDropdownList.indexOf(newValue)]);
                        // //fetch area based on selected country and state

                        provider.fetchArea(provider.selectedCountryId,
                            provider.selectedStateId, context);

                        // print(provider.statesDropdownIndexList[provider
                        //     .statesDropdownList
                        //     .indexOf(newValue)]);
                      },
                      items: provider.statesDropdownList
                          .map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                                color: cc.greyPrimary.withOpacity(.8)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [OthersHelper().showLoading(cc.primaryColor)],
                ),
        ],
      ),
    );
  }
}
