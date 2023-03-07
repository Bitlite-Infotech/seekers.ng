import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qixer/service/all_services_service.dart';
import 'package:qixer/service/country_states_service.dart';
import 'package:qixer/view/services/components/service_filter_dropdown_helper.dart';
import 'package:qixer/view/utils/common_helper.dart';
import 'package:qixer/view/utils/constant_colors.dart';
import 'package:qixer/view/utils/others_helper.dart';

class JobEditDropdowns extends StatefulWidget {
  const JobEditDropdowns({Key? key}) : super(key: key);

  @override
  State<JobEditDropdowns> createState() => _JobEditDropdownsState();
}

class _JobEditDropdownsState extends State<JobEditDropdowns> {
  @override
  void initState() {
    super.initState();
    //fetch country
    Provider.of<CountryStatesService>(context, listen: false)
        .fetchCountries(context);

    Provider.of<AllServicesService>(context, listen: false)
        .fetchCategories(context);
  }

  @override
  Widget build(BuildContext context) {
    ConstantColors cc = ConstantColors();
    return Consumer<AllServicesService>(
      builder: (context, filterProvider, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //dropdown and search box
          const SizedBox(
            width: 17,
          ),

          // Category dropdown ===============>
          ServiceFilterDropdownHelper().categoryDropdown(cc, context),

          const SizedBox(
            height: 25,
          ),

          // States dropdown ===============>
          ServiceFilterDropdownHelper().subCategoryDropdown(cc, context),

          const SizedBox(
            height: 25,
          ),

          Consumer<CountryStatesService>(
              builder: (context, provider, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //dropdown and search box

                      // Country dropdown ===============>
                      CommonHelper().labelCommon("Choose country"),
                      provider.countryDropdownList.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                border: Border.all(color: cc.greyFive),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  // menuMaxHeight: 200,
                                  // isExpanded: true,
                                  value: provider.selectedCountry,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                                      color: cc.greyFour),
                                  iconSize: 26,
                                  elevation: 17,
                                  style: TextStyle(color: cc.greyFour),
                                  onChanged: (newValue) {
                                    provider.setCountryValue(newValue);

                                    // setting the id of selected value
                                    provider.setSelectedCountryId(
                                        provider.countryDropdownIndexList[
                                            provider.countryDropdownList
                                                .indexOf(newValue)]);

                                    //fetch states based on selected country
                                    provider.fetchStates(
                                        provider.selectedCountryId, context);
                                  },
                                  items: provider.countryDropdownList
                                      .map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            color:
                                                cc.greyPrimary.withOpacity(.8)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                OthersHelper().showLoading(cc.primaryColor)
                              ],
                            ),

                      const SizedBox(
                        height: 25,
                      ),
                      // States dropdown ===============>
                      CommonHelper().labelCommon("Choose city"),
                      provider.statesDropdownList.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                border: Border.all(color: cc.greyFive),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  // menuMaxHeight: 200,
                                  // isExpanded: true,
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
                                            provider.statesDropdownList
                                                .indexOf(newValue)]);
                                    // //fetch area based on selected country and state

                                    provider.fetchArea(
                                        provider.selectedCountryId,
                                        provider.selectedStateId,
                                        context);

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
                                            color:
                                                cc.greyPrimary.withOpacity(.8)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                OthersHelper().showLoading(cc.primaryColor)
                              ],
                            ),
                    ],
                  ))
        ],
      ),
    );
  }
}
