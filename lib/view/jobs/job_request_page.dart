import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qixer/service/jobs_service/job_conversation_service.dart';
import 'package:qixer/service/jobs_service/job_request_service.dart';
import 'package:qixer/view/booking/payment_choose_page.dart';
import 'package:qixer/view/jobs/job_conversation_page.dart';
import 'package:qixer/view/jobs/job_details_page.dart';
import 'package:qixer/view/utils/common_helper.dart';
import 'package:qixer/view/utils/constant_colors.dart';
import 'package:qixer/view/utils/constant_styles.dart';
import 'package:qixer/view/utils/others_helper.dart';

class JobRequestPage extends StatefulWidget {
  const JobRequestPage({Key? key}) : super(key: key);

  @override
  _JobRequestPageState createState() => _JobRequestPageState();
}

class _JobRequestPageState extends State<JobRequestPage> {
  @override
  void initState() {
    super.initState();
  }

  ConstantColors cc = ConstantColors();
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  List menuNames = ['View details', 'Conversation', 'Hire now'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHelper().appbarCommon('Job Requests', context, () {
        Navigator.pop(context);
      }),
      backgroundColor: cc.bgColor,
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        enablePullDown:
            context.watch<JobRequestService>().currentPage > 1 ? false : true,
        onRefresh: () async {
          final result =
              await Provider.of<JobRequestService>(context, listen: false)
                  .fetchJobRequestList(context);
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result =
              await Provider.of<JobRequestService>(context, listen: false)
                  .fetchJobRequestList(context);
          if (result) {
            debugPrint('loadcomplete ran');
            //loadcomplete function loads the data again
            refreshController.loadComplete();
          } else {
            debugPrint('no more data');
            refreshController.loadNoData();

            Future.delayed(const Duration(seconds: 1), () {
              //it will reset footer no data state to idle and will let us load again
              refreshController.resetNoData();
            });
          }
        },
        child: SingleChildScrollView(
          physics: physicsCommon,
          child: Consumer<JobRequestService>(
            builder: (context, provider, child) => provider
                    .jobReqList.isNotEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenPadding, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < provider.jobReqList.length; i++)
                          InkWell(
                            onTap: () {
                              print(
                                  'job request id ${provider.jobReqList[i].id}');
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(9)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CommonHelper().titleCommon(
                                              provider.jobReqList[i].job.title,
                                              fontsize: 15),
                                          sizedBoxCustom(8),
                                          CommonHelper().paragraphCommon(
                                              'Your offer: \$${provider.jobReqList[i].job.price}',
                                              TextAlign.left),
                                          sizedBoxCustom(6),
                                          CommonHelper().paragraphCommon(
                                              'Seller offer: \$${provider.jobReqList[i].expectedSalary}',
                                              TextAlign.left,
                                              color: cc.successColor),
                                        ]),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry>[
                                      //View details
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero, () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder:
                                                    (BuildContext context) =>
                                                        JobDetailsPage(
                                                  imageLink: placeHolderUrl,
                                                  jobId: provider
                                                      .jobReqList[i].job.id,
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                        child: Text(menuNames[0]),
                                      ),

                                      //Conversation
                                      PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero, () {
                                            //fetch message
                                            Provider.of<JobConversationService>(
                                                    context,
                                                    listen: false)
                                                .fetchMessages(
                                                    jobRequestId: provider
                                                        .jobReqList[i].id);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder:
                                                    (BuildContext context) =>
                                                        JobConversationPage(
                                                  title: provider
                                                      .jobReqList[i].job.title,
                                                  jobRequestId:
                                                      provider.jobReqList[i].id,
                                                  sellerId: provider
                                                      .jobReqList[i].sellerId,
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                        child: Text(menuNames[1]),
                                      ),

                                      //Hire now
                                      PopupMenuItem(
                                        onTap: () {
                                          //set price
                                          Provider.of<JobRequestService>(
                                                  context,
                                                  listen: false)
                                              .setSelectedJobPriceAndId(
                                                  price: provider.jobReqList[i]
                                                      .expectedSalary,
                                                  id: provider
                                                      .jobReqList[i].id);

                                          Future.delayed(Duration.zero, () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder:
                                                    (BuildContext context) =>
                                                        const PaymentChoosePage(
                                                  isFromHireJob: true,
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                        child: Text(menuNames[2]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : OthersHelper().showError(context, msg: 'No request found'),
          ),
        ),
      ),
    );
  }
}
