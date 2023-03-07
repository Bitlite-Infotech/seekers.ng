import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qixer/service/my_orders_service.dart';
import 'package:qixer/service/order_details_service.dart';
import 'package:qixer/service/rtl_service.dart';

import 'package:qixer/view/tabs/orders/order_details_page.dart';
import 'package:qixer/view/utils/common_helper.dart';
import 'package:qixer/view/utils/constant_colors.dart';
import 'package:qixer/view/utils/constant_styles.dart';
import 'package:qixer/view/utils/others_helper.dart';

import 'orders_helper.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<MyOrdersService>(context, listen: false).fetchMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    ConstantColors cc = ConstantColors();

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: physicsCommon,
            child: Consumer<MyOrdersService>(
              builder: (context, provider, child) => Container(
                padding: EdgeInsets.symmetric(horizontal: screenPadding),
                child: provider.isLoading == false
                    ? provider.myServices != 'error'
                        ? provider.myServices.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    CommonHelper().titleCommon('My Orders'),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    // for (int i = 0;
                                    //     i < provider.myServices.length;
                                    //     i++)
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: provider.myServices.length,
                                        itemBuilder: ((context, i) => InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute<void>(
                                                      builder: (BuildContext
                                                              context) =>
                                                          OrderDetailsPage(
                                                              orderId: provider
                                                                  .myServices[i]
                                                                  .id),
                                                    ));
                                                //             );
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                margin: const EdgeInsets.only(
                                                  top: 20,
                                                  bottom: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: cc.borderColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Column(children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(15, 6, 0, 0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        AutoSizeText(
                                                          '#${provider.myServices[i].id}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color:
                                                                cc.primaryColor,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            OrdersHelper().statusCapsule(
                                                                OrderDetailsService()
                                                                    .getOrderStatus(provider
                                                                        .myServices[
                                                                            i]
                                                                        .status),
                                                                cc.greyFour),

                                                            //popup button
                                                            PopupMenuButton(
                                                              itemBuilder: (BuildContext
                                                                      context) =>
                                                                  <PopupMenuEntry>[
                                                                for (int j = 0;
                                                                    j <
                                                                        OrdersHelper()
                                                                            .ordersPopupMenuList
                                                                            .length;
                                                                    j++)
                                                                  PopupMenuItem(
                                                                    onTap: () {
                                                                      Future.delayed(
                                                                          Duration
                                                                              .zero,
                                                                          () {
                                                                        //

                                                                        if (j ==
                                                                                1 &&
                                                                            (provider.myServices[i].paymentStatus == 'complete' ||
                                                                                provider.myServices[i].status != 0)) {
                                                                          //0 means pending
                                                                          OthersHelper().showToast(
                                                                              'You can not cancel this order',
                                                                              Colors.black);
                                                                          return;
                                                                        }
                                                                        OrdersHelper().navigateMyOrders(
                                                                            context,
                                                                            index:
                                                                                j,
                                                                            serviceId:
                                                                                provider.myServices[i].serviceId,
                                                                            orderId: provider.myServices[i].id);
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                        OrdersHelper()
                                                                            .ordersPopupMenuList[j]),
                                                                  ),
                                                              ],
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),

                                                  //Divider
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 6, bottom: 17),
                                                    child: CommonHelper()
                                                        .dividerCommon(),
                                                  ),

                                                  provider.myServices[i].date !=
                                                          "00.00.00"
                                                      ? Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15),
                                                          child: Column(
                                                            children: [
                                                              OrdersHelper()
                                                                  .orderRow(
                                                                'assets/svg/calendar.svg',
                                                                'Date',
                                                                provider
                                                                    .myServices[
                                                                        i]
                                                                    .date,
                                                              ),
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        14),
                                                                child: CommonHelper()
                                                                    .dividerCommon(),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),

                                                  provider.myServices[i]
                                                              .schedule !=
                                                          "00.00.00"
                                                      ? Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15),
                                                          child: Column(
                                                            children: [
                                                              OrdersHelper()
                                                                  .orderRow(
                                                                'assets/svg/clock.svg',
                                                                'Schedule',
                                                                provider
                                                                    .myServices[
                                                                        i]
                                                                    .schedule,
                                                              ),
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        14),
                                                                child: CommonHelper()
                                                                    .dividerCommon(),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),

                                                  Container(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        15, 0, 15, 15),
                                                    child: Consumer<RtlService>(
                                                      builder: (context, rtlP,
                                                              child) =>
                                                          OrdersHelper()
                                                              .orderRow(
                                                        'assets/svg/bill.svg',
                                                        'Billed',
                                                        rtlP.currencyDirection ==
                                                                'left'
                                                            ? '${rtlP.currency}${provider.myServices[i].total.toStringAsFixed(2)}'
                                                            : '${provider.myServices[i].total.toStringAsFixed(2)}${rtlP.currency}',
                                                      ),
                                                    ),
                                                  )
                                                ]),
                                              ),
                                            )))

                                    //
                                  ])
                            : CommonHelper()
                                .nothingfound(context, "No active order")
                        : CommonHelper()
                            .nothingfound(context, "No active order")
                    : Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height - 120,
                        child: OthersHelper().showLoading(cc.primaryColor)),
              ),
            ),
          ),
        ));
  }
}
