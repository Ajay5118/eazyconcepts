import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:size_setter/size_setter.dart';
import 'package:threedotspiano/Utils/tools.dart';
import 'package:threedotspiano/ui/courses/m/module.dart';
import 'package:threedotspiano/ui/widgets/header_txt_widget.dart';
import 'package:threedotspiano/ui/widgets/loading_widget.dart';
import 'package:threedotspiano/ui/widgets/sub_txt_widget.dart';
import '../../generated/assets.dart';
import '../../repo/setting_repo.dart';
import 'modules_controller.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({super.key});

  @override
  State<ModulesPage> createState() => _PageState();
}

class _PageState extends State<ModulesPage> {
  final ModulesController _con = Get.put(ModulesController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.getModuleList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          Positioned(
            top: 0.h,
            left: 0,
            right: 0,
            child: divider(),
          ),
          Positioned(
            top: 190.h,
            left: 0,
            right: 0,
            child: divider(),
          ),
          Positioned(
            top: 425.h,
            left: 0,
            right: 0,
            child: divider(),
          ),
          body()
        ],
      ),
    );
  }

  Widget divider() {
    return Container(
      height: 10.px,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(0, 0, 0, 1),
            Color.fromRGBO(253, 195, 51, 1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  Widget body() {
    if (_con.isLoadingM.value) {
      return LoadingWidget(
        type: LoadingType.MODULE,
      );
    }
    if (!_con.isLoadingM.value && _con.moduleList.isEmpty) {
      return SubTxtWidget("No record found");
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        Module data = _con.moduleList[index];
        return SizedBox(
          width: 300.sp,
          child: Stack(
            children: [
              Positioned(
                  top: index.isEven ? 30.h : 270.h,
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      width: 600.px,
                      height: 300.px,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(253, 195, 51, 1),
                          Color.fromRGBO(246, 125, 45, 1)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )),
                      child: InkWell(
                        onTap: () {
                          _con.startContent(data.id,contentType.value.module);
                          Get.toNamed('/chapter', arguments: data);
                        },
                        child: Stack(children: [
                          Positioned(
                              top: 0,
                              right: -20.w,
                              bottom: 0,
                              child: Image.asset(Assets.imgModuleBg,opacity: AlwaysStoppedAnimation(0.5),)),
                          Positioned(
                              top: 0,
                              left: -20.w,
                              child: Image.asset(
                                Assets.imgRadialLines,
                                height: 300.px,
                                color: Colors.white,
                              )),
                          Center(
                            child: Row(
                              children: [
                                Image.asset(
                                  Assets.dummyModule1,
                                  width: 180.px,
                                  height: 180.px,
                                ),
                                Image.asset(
                                  Assets.imgMusicLine,
                                  height: 80.px,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 45.h,
                            left: 30.w,
                            right: 10.w,
                            child: HeaderTxtWidget(
                              'Module ${data.id}',
                              fontFamily: "CinDecor",
                              fontSize: 40.px,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              gradient: LinearGradient(colors: [
                                Color.fromRGBO(64, 4, 122, 1),
                                Color.fromRGBO(64, 4, 122, 1)
                              ]),
                            ),
                          ),
                          Positioned(
                              top: 180.h,
                              left: 40.w,
                              right: 20.w,
                              child: HeaderTxtWidget(
                                '${data.name}',
                                fontSize: 30.px,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                gradient: LinearGradient(colors: [
                                  Color.fromRGBO(64, 4, 122, 1),
                                  Color.fromRGBO(64, 4, 122, 1)
                                ]),
                              ))
                        ]),
                      ),
                    ),
                  ))
            ],
          ),
        );
      },
      itemCount: _con.moduleList.length,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
    );
  }
}
