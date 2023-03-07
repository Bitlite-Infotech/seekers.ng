// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qixer/model/chat_messages_model.dart';
import 'package:qixer/service/common_service.dart';
import 'package:http/http.dart' as http;
import 'package:qixer/service/profile_service.dart';
import 'package:qixer/service/push_notification_service.dart';
import 'package:qixer/view/utils/others_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessagesService with ChangeNotifier {
  List messagesList = [];

  bool isloading = false;
  bool sendLoading = false;

  late int totalPages;
  int currentPage = 1;

  setCurrentPage(newValue) {
    currentPage = newValue;
    notifyListeners();
  }

  setTotalPage(newPageNumber) {
    totalPages = newPageNumber;
    notifyListeners();
  }

  setMessageListDefault() {
    messagesList = [];
    currentPage = 1;
    notifyListeners();
  }

  setLoadingTrue() {
    isloading = true;
    notifyListeners();
  }

  setLoadingFalse() {
    isloading = false;
    notifyListeners();
  }

  setSendLoadingTrue() {
    sendLoading = true;
    notifyListeners();
  }

  setSendLoadingFalse() {
    sendLoading = false;
    notifyListeners();
  }

  final ImagePicker _picker = ImagePicker();
  Future pickImage() async {
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      return imageFile;
    } else {
      return null;
    }
  }

  fetchMessages(context, {bool isrefresh = false, required receiverId}) async {
    if (isrefresh) {
      //making the list empty first to show loading bar (we are showing loading bar while the product list is empty)
      //we are make the list empty when the sub category or brand is selected because then the refresh is true
      messagesList = [];

      notifyListeners();

      Provider.of<ChatMessagesService>(context, listen: false)
          .setCurrentPage(currentPage);
    } else {}

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    var header = {
      //if header type is application/json then the data should be in jsonEncode method
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    var connection = await checkConnection();
    if (connection) {
      //if connection is ok

      var response = await http.get(
          Uri.parse(
              "$baseApi/user/chat/all-messages?to_user=$receiverId&page=$currentPage"),
          headers: header);

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['messages']['data'].isNotEmpty) {
        var data = ChatMessagesModel.fromJson(jsonDecode(response.body));

        setTotalPage(data.messages.lastPage);

        if (isrefresh) {
          print('refresh true');
          //if refreshed, then remove all service from list and insert new data
          //make the list empty first so that existing data doesn't stay
          // setServiceList(data.tickets.data, false);
        } else {
          print('add new data');

          //else add new data
          setMessageList(data.messages.data);
        }

        currentPage++;
        setCurrentPage(currentPage);
        return true;
      } else {
        print(response.body);
        return false;
      }
    }
  }

  setMessageList(dataList) {
    for (int i = 0; i < dataList.length; i++) {
      messagesList.add({
        'id': dataList[i].id,
        'message': dataList[i].message,
        'attachment': dataList[i].senderProfileImage,
        'fromUser': dataList[i].fromUser,
        'imagePicked':
            false //check if this image is just got picked from device in that case we will show it from device location
      });
    }
    notifyListeners();
  }

//Send new message ======>

  sendMessage(toUser, message, imagePath, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    var dio = Dio();
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Authorization'] = "Bearer $token";
    FormData formData;
    if (imagePath != null) {
      formData = FormData.fromMap({
        'to_user': toUser,
        'message': message,
        'file': await MultipartFile.fromFile(imagePath,
            filename: 'ticket$imagePath.jpg')
      });
    } else {
      formData = FormData.fromMap({
        'to_user': toUser,
        'message': message,
      });
    }

    var connection = await checkConnection();
    if (connection) {
      setSendLoadingTrue();
      //if connection is ok

      var response = await dio.post(
        '$baseApi/user/chat/send',
        data: formData,
      );
      setSendLoadingFalse();

      if (response.statusCode == 200) {
        print(response.data);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var currentUserId = prefs.getInt('userId')!;
        addNewMessage(message, imagePath, currentUserId);

        sendNotification(context, sellerId: toUser, msg: message);
        return true;
      } else {
        OthersHelper().showToast('Something went wrong', Colors.black);
        print(response.data);
        return false;
      }
    } else {
      OthersHelper()
          .showToast('Please check your internet connection', Colors.black);
      return false;
    }
  }

  addNewMessage(message, imagePath, userId) async {
    messagesList.insert(0, {
      'id': '',
      'message': message,
      'attachment': null,
      'fromUser': userId,
      'imagePicked':
          false //check if this image is just got picked from device in that case we will show it from device location
    });
    notifyListeners();
  }

  sendNotification(BuildContext context, {required sellerId, required msg}) {
    //Send notification to seller
    var username = Provider.of<ProfileService>(context, listen: false)
            .profileDetails
            .userDetails
            .name ??
        '';
    PushNotificationService().sendNotificationToSeller(context,
        sellerId: sellerId, title: "New chat message: $username", body: '$msg');
  }
}
