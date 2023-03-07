// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qixer/service/common_service.dart';
import 'package:qixer/view/utils/others_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService with ChangeNotifier {
  bool pusherCredentialLoaded = false;

  //
  sendNotificationToSeller(BuildContext context,
      {required sellerId, required title, required body}) async {
    var pUrl = Provider.of<PushNotificationService>(context, listen: false)
        .pusherApiUrl;

    var pToken = Provider.of<PushNotificationService>(context, listen: false)
        .pusherToken;
    var header = {
      //if header type is application/json then the data should be in jsonEncode method
      // "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "$pToken",
    };

    var data = jsonEncode({
      "interests": ["debug-seller$sellerId"],
      "fcm": {
        "notification": {"title": "$title", "body": "$body"}
      }
    });

    var response =
        await http.post(Uri.parse(pUrl), headers: header, body: data);

    if (response.statusCode == 200) {
      print('send notification to seller success');
    } else {
      print('send notification to seller failed');
      print(response.body);
    }
  }

  //get pusher credential
  //======================>

  var apiKey;
  var secret;
  var pusherToken;
  var pusherApiUrl;
  var pusherCluster;
  var pusherInstance;

  Future<bool> fetchPusherCredential({context}) async {
    var connection = await checkConnection();
    if (!connection) return false;
    if (pusherCredentialLoaded == true) return false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var header = {
      //if header type is application/json then the data should be in jsonEncode method
      "Accept": "application/json",
      // "Content-Type": "application/json"
      "Authorization": "Bearer $token",
    };

    var response = await http.get(
        Uri.parse("$baseApi/user/chat/pusher/credentials"),
        headers: header);

    if (response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      pusherCredentialLoaded = true;
      apiKey = jsonData['pusher_app_key'];
      secret = jsonData['pusher_app_secret'];
      pusherToken = jsonData['pusher_app_push_notification_auth_token'];
      pusherApiUrl = jsonData['pusher_app_push_notification_auth_url'];
      pusherCluster = jsonData['pusher_app_cluster'];
      pusherInstance = jsonData['pusher_app_push_notification_instanceId'];

      notifyListeners();
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
}
