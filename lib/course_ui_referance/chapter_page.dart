import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:size_setter/size_setter.dart';
import 'package:threedotspiano/ext/hex_color.dart';
import 'package:threedotspiano/generated/assets.dart';
import 'package:threedotspiano/ui/courses/m/chapter.dart';
import 'package:threedotspiano/ui/widgets/header_txt_widget.dart';

import '../../Utils/tools.dart';
import '../../repo/setting_repo.dart';
import '../dashboard/widgets/coin_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/sub_txt_widget.dart';
import 'm/module.dart';
import 'modules_controller.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({super.key});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  final ModulesController _con = Get.put(ModulesController());
  late Module module;

  @override
  void initState() {
    super.initState();
    module = Get.arguments;
    _con.getChapterList(module.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(253, 195, 51, 1),
                Color.fromRGBO(246, 125, 45, 1)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )),
        child: Stack(
          children: [
            Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Image.asset(
                  Assets.imgModuleBg,
                  opacity: AlwaysStoppedAnimation(0.3),
                )),
            Positioned(
                top: 0,
                left: 40,
                child: Image.asset(
                  Assets.imgRadialLines,
                  height: 90.sp,
                  color: Colors.white,
                )),
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: _heading(),
                toolbarHeight: 70.sp,
                actions: [
                  CoinWidget(
                    coinBg: Assets.imgCoinBg2,
                  )
                ],
              ),
              body: body(),
            )
          ],
        ),
      ),
    );
  }

  // ✅ NEW: Get visual opacity based on status
  double getChapterOpacity(String? status) {
    if (status == 'current') {
      return 1.0;  // ✅ Full brightness - highlight current chapter
    } else if (status == 'completed') {
      return 0.9; // ✅ Slightly dimmed - completed chapters
    } else {
      return 0.7;  // ✅ Dimmed - locked/future chapters
    }
  }

  Color getDividerColor(String status) {
    if (status == 'current') {
      return Color.fromRGBO(35, 10, 62, 1);
    }
    if (status == 'locked') {
      return Color.fromRGBO(140, 72, 205, 1);
    }
    return Color.fromRGBO(255, 255, 255, 1);
  }

  Widget divider(String status) {
    return Container(
      height: 15.px,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            if (status == 'current') ...{
              Color.fromRGBO(35, 10, 62, 1),
              Color.fromRGBO(140, 72, 205, 1),
              Colors.grey,
            } else if (status == 'locked') ...{
              Colors.grey,
              Colors.grey.shade500,
              Colors.white,
            } else ...{
              Colors.grey,
              Colors.grey.shade500,
              Colors.white
            }
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _heading() {
    return Row(
      children: [
        SizedBox(
          width: 50.sp,
          height: 50.sp,
          child: Image.asset(Assets.dummyModule1),
        ),
        2.pWidthBox,
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderTxtWidget(
                  'Module ${module.id}',
                  fontFamily: "CinDecor",
                  fontSize: 33.px,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(140, 72, 205, 1),
                      Color.fromRGBO(35, 10, 62, 1)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                HeaderTxtWidget(
                  '${module.name}',
                  fontFamily: "Cin",
                  fontSize: 45.px,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(140, 72, 205, 1),
                      Color.fromRGBO(35, 10, 62, 1)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
            ))
      ],
    );
  }

  Widget body() {
    Size size = MediaQuery.of(context).size;
    if (_con.isLoadingC.value) {
      return LoadingWidget(
        type: LoadingType.MODULE,
      );
    }
    if (!_con.isLoadingC.value && _con.chapterList.isEmpty) {
      return SubTxtWidget("No record found");
    }
    return ListView.builder(
      padding: EdgeInsets.only(left: 50),
      itemBuilder: (context, index) {
        Chapter chapter = _con.chapterList[index];

        // ✅ NEW: Get opacity for this chapter
        final chapterOpacity = getChapterOpacity(chapter.status);

        return Container(
          height: double.infinity,
          width: size.width / 3,
          child: Opacity(
            opacity: chapterOpacity, // ✅ Apply opacity to entire chapter
            child: InkWell(
              // ✅ FIXED: Allow all chapters to be tapped
              onTap: () {
                _con.startContent(chapter.id, contentType.value.chapter);
                Get.toNamed('/lesson', arguments: chapter);
              },
              child: Stack(
                children: [
                  // Divider between chapters
                  if (index != (_con.chapterList.length - 1))
                    Positioned(
                        top: 290.px,
                        left: 200.px,
                        right: 0,
                        child: divider(chapter.status!)),

                  // ✅ UNIFIED: All chapters use same layout, opacity differentiates them
                  if (chapter.status == "current") ...[
                    // ✅ FIXED: Stars for current chapters
                    if (chapter.avgRating != null && chapter.avgRating! > 0) ...[
                      // Star 1 (left)
                      if (chapter.avgRating! > 0)
                        Positioned(
                          top: 20.px,
                          left: 130.px,
                          child: Image.asset(
                            Assets.imgStar1,
                            fit: BoxFit.cover,
                            height: 60.px,
                            width: 60.px,
                          ),
                        ),
                      // Star 2 (middle, bigger)
                      if (chapter.avgRating! >= 2)
                        Positioned(
                          top: 0.px,
                          left: 180.px,
                          child: Image.asset(
                            Assets.imgStar2,
                            fit: BoxFit.cover,
                            height: 80.px,
                            width: 80.px,
                          ),
                        ),
                      // Star 3 (right)
                      if (chapter.avgRating! > 3)
                        Positioned(
                          top: 20.px,
                          left: 250.px,
                          child: Image.asset(
                            Assets.imgStar3,
                            fit: BoxFit.cover,
                            height: 60.px,
                            width: 60.px,
                          ),
                        ),
                    ],

                    // Current chapter badge (highlighted with full opacity)
                    Positioned(
                        top: 80.px,
                        left: -20.px,
                        child: Container(
                          height: 200.sp,
                          width: 200.sp,
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          alignment: AlignmentDirectional.center,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(Assets.imgChapterBgSelected))),
                          child: HeaderTxtWidget(
                            '${chapter.name}',
                            fontFamily: "CinDecor",
                            textAlign: TextAlign.center,
                            fontSize: 28.px,
                          ),
                        ))
                  ] else ...[
                    // ✅ FIXED: Completed and locked chapters with stars
                    if (chapter.avgRating != null && chapter.avgRating! > 0) ...[
                      // Star 1 (left)
                      if (chapter.avgRating! > 0)
                        Positioned(
                          top: 40.px,
                          left: 30.px,
                          child: Image.asset(
                            Assets.imgStar1,
                            fit: BoxFit.cover,
                            height: 88.px,
                            width: 88.px,
                          ),
                        ),
                      // Star 2 (middle, bigger)
                      if (chapter.avgRating! >= 2)
                        Positioned(
                          top: 10.px,
                          left: 90.px,
                          child: Image.asset(
                            Assets.imgStar2,
                            fit: BoxFit.cover,
                            height: 133.px,
                            width: 133.px,
                          ),
                        ),
                      // Star 3 (right)
                      if (chapter.avgRating! > 3)
                        Positioned(
                          top: 40.px,
                          left: 190.px,
                          child: Image.asset(
                            Assets.imgStar3,
                            fit: BoxFit.cover,
                            height: 88.px,
                            width: 88.px,
                          ),
                        ),

                      // Chapter badge with stars
                      Positioned(
                          top: 150.px,
                          child: Container(
                            height: 300.px,
                            width: 300.px,
                            alignment: AlignmentDirectional.center,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(Assets.imgChapterBg))),
                            child: HeaderTxtWidget(
                              '${chapter.name}',
                              fontFamily: "CinDecor",
                              textAlign: TextAlign.center,
                              fontSize: 28.px,
                            ),
                          )),
                    ] else ...[
                      // ✅ IMPROVED: Locked/not-started chapter (cleaner look)
                      Positioned(
                          top: 150.px,
                          child: Container(
                            height: 300.px,
                            width: 300.px,
                            padding: EdgeInsets.symmetric(horizontal: 20.px),
                            alignment: AlignmentDirectional.center,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        chapter.status == 'locked'
                                            ? Assets.imgChapterLock
                                            : Assets.imgChapterBg
                                    )
                                )
                            ),
                            child: HeaderTxtWidget(
                              '${chapter.name}',
                              fontFamily: "CinDecor",
                              textAlign: TextAlign.center,
                              fontSize: 28.px,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              // ✅ IMPROVED: Use gradient for locked, normal for others
                              gradient: chapter.status == 'locked'
                                  ? LinearGradient(colors: [
                                Colors.grey,
                                Colors.grey,
                              ])
                                  : null,
                            ),
                          ))
                    ]
                  ]
                ],
              ),
            ),
          ),
        );
      },
      itemCount: _con.chapterList.length,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
    );
  }
}