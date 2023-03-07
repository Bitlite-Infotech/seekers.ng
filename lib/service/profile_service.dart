import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qixer/model/profile_model.dart';
import 'package:qixer/service/common_service.dart';
import 'package:qixer/view/utils/others_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileService with ChangeNotifier {
  bool isloading = false;

  var profileDetails;
  var profileImage;

  List ordersList = [];

  setLoadingTrue() {
    isloading = true;
    notifyListeners();
  }

  setLoadingFalse() {
    isloading = false;
    notifyListeners();
  }

  setEverythingToDefault() {
    profileDetails = null;
    profileImage = null;
    ordersList = [];
    notifyListeners();
  }

  Future<bool> getProfileDetails({bool isFromProfileupdatePage = false}) async {
    if (isFromProfileupdatePage == true) {
      //if from update profile page then load it anyway

      setEverythingToDefault();
      await fetchData();
      return true;
    } else {
      //not from profile page. check if data already loaded
      if (profileDetails == null) {
        fetchData();
        return true;
      } else {
        print('profile data already loaded');
        return true;
      }
    }
  }

  Future<bool> fetchData() async {
    var connection = await checkConnection();
    if (!connection) return false;
    //internet connection is on
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    print('token is $token');

    setLoadingTrue();

    var header = {
      //if header type is application/json then the data should be in jsonEncode method
      "Accept": "application/json",
      // "Content-Type": "application/json"
      "Authorization": "Bearer $token",
    };

    var response =
        await http.get(Uri.parse('$baseApi/user/profile'), headers: header);

    if (response.statusCode == 201) {
      var data = ProfileModel.fromJson(jsonDecode(response.body));
      profileDetails = data;

      ordersList.add(profileDetails.pendingOrder);
      ordersList.add(profileDetails.activeOrder);
      ordersList.add(profileDetails.completeOrder);
      ordersList.add(profileDetails.totalOrder);

      if (jsonDecode(response.body)['profile_image'] is List) {
        //then dont do anything because it means image is missing from database
      } else {
        profileImage = jsonDecode(response.body)['profile_image']['img_url'];
      }

      setLoadingFalse();
      notifyListeners();
      return true;
    } else {
      print(response.body);
      profileDetails == 'error';
      setLoadingFalse();
      OthersHelper().showToast('Something went wrong', Colors.black);
      notifyListeners();

      return false;
    }
  }
}
