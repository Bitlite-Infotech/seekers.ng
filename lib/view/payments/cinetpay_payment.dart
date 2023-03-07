// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qixer/service/booking_services/place_order_service.dart';
import 'package:qixer/service/payment_gateway_list_service.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class CinetPayPayment extends StatelessWidget {
  CinetPayPayment(
      {Key? key,
      required this.amount,
      required this.name,
      required this.phone,
      required this.email,
      required this.isFromOrderExtraAccept,
      required this.isFromWalletDeposite,
      required this.isFromHireJob})
      : super(key: key);

  final amount;
  final name;
  final phone;
  final email;
  final isFromOrderExtraAccept;
  final isFromWalletDeposite;
  final isFromHireJob;

  String? url;
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(microseconds: 600), () {
      Provider.of<PlaceOrderService>(context, listen: false).setLoadingFalse();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinetpay'),
      ),
      body: FutureBuilder(
          future: waitForIt(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return const Center(
                child: Text('Loding failed.'),
              );
            }
            if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(
                child: Text('Loding failed.'),
              );
            }
            return WebView(
              // onWebViewCreated: ((controller) {
              //   _controller = controller;
              // }),
              onWebResourceError: (error) {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return const AlertDialog(
                        title: Text('Loading failed!'),
                        content: Text('Failed to load payment page.'),
                      );
                    });

                Navigator.pop(context);
              },

              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,

              onPageFinished: (value) async {},
            );
          }),
    );
  }

  waitForIt(BuildContext context) async {
    final url = Uri.parse('https://api-checkout.cinetpay.com/v2/payment');
    final header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization":
      //     'Bearer EAAAEOuLQObrVwJvCvoio3H13b8Ssqz1ighmTBKZvIENW9qxirHGHkqsGcPBC1uN',
      // Above is API server key for the Midtrans account, encoded to base64
    };

    String apiKey =
        Provider.of<PaymentGatewayListService>(context, listen: false)
            .secretKey;

    String siteId =
        Provider.of<PaymentGatewayListService>(context, listen: false)
            .publicKey;

    // final apiKey = '12912847765bc0db748fdd44.40081707';
    // final siteId = '445160';

    final response = await http.post(url,
        headers: header,
        body: jsonEncode({
          "apikey": apiKey,
          "site_id": siteId,
          "transaction_id": DateTime.now().toString(),
          "amount": double.parse(amount).toInt(),
          "currency": "USD",
          "alternative_currency": "USD",
          "description": " Qixer Payment ",
          "customer_id": "1",
          "customer_name": name + " first name",
          "customer_surname": name + " surname",
          "customer_email": email,
          "customer_phone_number": phone,
          "customer_address": 'Dhaka',
          "customer_city": "Dhaka",
          "customer_country": "BD",
          "customer_state": "BD",
          "customer_zip_code": "1220",
          "channels": "ALL"
        }));
    print(response.body);
    if (response.statusCode == 200) {
      this.url = jsonDecode(response.body)['data']['payment_url'];
      print(this.url);
      return;
    }

    return true;
  }

  Future<bool> verifyPayment(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    print(response.body.contains('successful'));
    return response.body.contains('successful');
  }
}
