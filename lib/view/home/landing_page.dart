import 'package:flutter/material.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:qixer/view/home/home.dart';
import 'package:qixer/view/notification/push_notification_helper.dart';
import 'package:qixer/view/tabs/saved_item_page.dart';
import 'package:qixer/view/tabs/search/search_tab.dart';
import 'package:qixer/view/tabs/settings/menu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../tabs/orders/orders_page.dart';
import '../utils/others_helper.dart';
import 'bottom_nav.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<LandingPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPusherBeams(context);
  }

  DateTime? currentBackPressTime;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  int _currentIndex = 0;
  //Bottom nav pages
  final List<Widget> _children = [
    const Homepage(),
    const OrdersPage(),
    const SavedItemPage(),
    const SearchTab(),
    const MenuPage(),
  ];

  //Notification alert
  //=================>
  initPusherBeams(BuildContext context) async {
    if (!kIsWeb) {
      await PusherBeams.instance
          .onMessageReceivedInTheForeground(_onMessageReceivedInTheForeground);
    }
    await _checkForInitialMessage(context);
    //init pusher instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('userId');

    await PusherBeams.instance.addDeviceInterest('debug-buyer$userId');
  }

  Future<void> _checkForInitialMessage(BuildContext context) async {
    final initialMessage = await PusherBeams.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotificationHelper().notificationAlert(
          context, 'Initial Message Is:', initialMessage.toString());
    }
  }

  void _onMessageReceivedInTheForeground(Map<Object?, Object?> data) {
    print('notification received');
    PushNotificationHelper().notificationAlert(
        context, data["title"].toString(), data["body"].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
          onWillPop: () {
            DateTime now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;
              OthersHelper().showToast("Press again to exit", Colors.black);
              return Future.value(false);
            }
            return Future.value(true);
          },
          child: _children[_currentIndex]),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTabTapped: onTabTapped,
      ),
    );
  }
}
