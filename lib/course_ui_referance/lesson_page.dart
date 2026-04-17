import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:size_setter/size_setter.dart';
import 'package:threedotspiano/ext/hex_color.dart';
import 'package:threedotspiano/generated/assets.dart';
import 'package:threedotspiano/ui/courses/m/lesson.dart';
import 'package:threedotspiano/ui/widgets/header_txt_widget.dart';

import '../../repo/setting_repo.dart';
import '../widgets/loading_widget.dart';
import '../widgets/sub_txt_widget.dart';
import 'm/chapter.dart';
import 'modules_controller.dart';

class LessonPage extends StatefulWidget {
  LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  final ModulesController _con = Get.put(ModulesController());
  late Chapter chapter;
  @override
  void initState() {
    super.initState();
    chapter = Get.arguments;
    _con.getLessonList(chapter.id);
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
                left: 0,
                child: Image.asset(
                  Assets.imgCpBg2,
                  fit: BoxFit.fitHeight,
                )),
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: _heading(),
                toolbarHeight: 70,
              ),
              body: body(),
            )
          ],
        ),
      ),
    );
  }

  Color getDividerColor(int index) {
    if (index <= 1) {
      return Color.fromRGBO(35, 10, 62, 1);
    }
    if (index >= 2) {
      return Color.fromRGBO(140, 72, 205, 1);
    }
    return Color.fromRGBO(255, 255, 255, 1);
  }

  Widget divider() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(colors:  [
            Color.fromRGBO(35, 10, 62, 1),
            Color.fromRGBO(140, 72, 205, 1),
            Color.fromRGBO(35, 10, 62, 1),
          ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              )),
      child:  SizedBox(height: 20.px),
    );
  }

  Widget _heading() {
    return Stack(
      children: [
        HeaderTxtWidget(
          'Chapter ${chapter.id}',
          fontFamily: "CinDecor",
          fontSize: 50.px,
          fontWeight: FontWeight.normal,
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(140, 72, 205, 1),
              Color.fromRGBO(35, 10, 62, 1)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        Center(
          child: HeaderTxtWidget(
            '${chapter.name}',
            fontFamily: "CinDecor",
            fontSize: 59.px,
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(140, 72, 205, 1),
                Color.fromRGBO(35, 10, 62, 1)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        )
      ],
    );
  }

  Widget body() {
    if (_con.isLoadingL.value) {
      return LoadingWidget(
        type: LoadingType.MODULE,
      );
    }
    if (!_con.isLoadingL.value && _con.lessonList.isEmpty) {
      return SubTxtWidget("No record found");
    }
    return ListView.builder(
      padding: EdgeInsets.only(left: 50),
      itemBuilder: (context, index) {
        Lesson lesson = _con.lessonList[index];
        return Container(
          width: 130.w,
          height: 400.h,
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            onTap: () {
              if (lesson.type == "quiz") {
                _con.startContent(lesson.id,contentType.value.quiz);
                Get.toNamed('/quiz', arguments: lesson);
              }  else if (lesson.type == "lesson") {
                _con.startContent(lesson.id, contentType.value.lesson);
                Get.toNamed('/tutorial', arguments: {
                  'lesson': lesson,
                  'contentTypeId': contentType.value.lesson
                });
              }else {
                _con.startContent(lesson.id,contentType.value.practice);
                Get.toNamed('/practice', arguments: lesson);
              }
            },
            child:Stack(
              children: [
                if (lesson.rating != null) ...{
                  Positioned(
                    top: -30.px,
                    left: 55.px,
                    child: SizedBox(
                      height: 100.h,
                      width: 60.w,
                      child: Stack(
                        children: [
                          if (lesson.rating > 0)
                          Positioned(
                            top: 40.px,
                            left: 20.px,
                            child: Image.asset(
                              Assets.imgStar1,
                              fit: BoxFit.cover,
                              height: 88.px,
                              width: 88.px,
                            ),
                          ),
                          if (lesson.rating >= 1)
                          Positioned(
                            top: 0.px,
                            left: 70.px,
                            child: Image.asset(
                              Assets.imgStar2,
                              fit: BoxFit.cover,
                              height: 133.px,
                              width: 133.px,
                            ),
                          ),
                          if (lesson.rating > 1)
                          Positioned(
                            top: 40.px,
                            right: 10.px,
                            child: Image.asset(
                              Assets.imgStar3,
                              fit: BoxFit.cover,
                              height: 88.px,
                              width: 88.px,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                },
                if(_con.lessonList.length - 1!=index)
                Positioned(
                  top: 350.h,
                  left: 80.w,
                  right: 0,
                  child: divider(),
                ),
                Positioned(
                  top: 70.px,
                  left: -70.px,
                  right: 130.px,
                  child:  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.imgCardBorder),
                            fit: BoxFit.fill)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (lesson.type == "quiz")
                          Image.asset(
                            Assets.imgPlay,
                            height: 50.px,
                          ),
                        if (lesson.type == "lesson")
                          Image.asset(
                            Assets.imgPiano,
                            height: 50.px,
                          ),
                        if (lesson.type == "practice")
                          Image.asset(
                            Assets.imgPlay,
                            height: 50.px,
                          ),
                        Expanded(
                            child: HeaderTxtWidget(
                              '${lesson.type}',
                              fontFamily: "CinDecor",
                              fontSize: 30.px,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.normal,
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(140, 72, 205, 1),
                                  Color.fromRGBO(35, 10, 62, 1)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            )),
                      ],
                    ),
                  ),),
                Positioned(
                  top: 310.h,
                  child: Image.asset(
                    Assets.imgShadow,
                    opacity: AlwaysStoppedAnimation(0.7),
                    height: 300.h,
                  ),
                ),
                Positioned(
                  top: 160.h,
                  left: -15.px,
                  child: Container(
                    height: 400.px,
                    width: 400.px,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.imgChapterCard),
                            fit: BoxFit.contain)),
                    child: Stack(
                      children: [
                        if (lesson.type == "lesson")
                          Positioned(
                            top: 73.px,
                            left: 80.px,
                            child: Image.asset(
                              Assets.imgCcc,
                              width: 52.w,
                            ),
                          ),
                        if (lesson.type == "practice")
                          Positioned(
                            top: 73.px,
                            left: 80.px,
                            child: Image.asset(
                              Assets.imgLession,
                              width: 52.w,
                            ),
                          ),
                        if (lesson.type == "quiz")
                          Positioned(
                            top: 80.px,
                            left: 90.px,
                            child: Image.asset(
                              Assets.imgPractice,
                              width: 45.w,
                            ),
                          )
                      ],
                    ),
                  ),
                ),

              ],
            )
          ),
        );
      },
      itemCount: _con.lessonList.length,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
    );
  }
}
