import 'package:get/get.dart';
import 'package:threedotspiano/ui/courses/m/chapter.dart';
import '../../repo/quiz_repo.dart';
import '../../repo/setting_repo.dart';
import '../../repo/song_repo.dart';
import 'm/lesson.dart';
import 'm/module.dart';


class ModulesController extends GetxController {
  RxList<Module> moduleList = RxList();
  RxList<Chapter> chapterList = RxList();
  RxList<Lesson> lessonList = RxList();
  RxBool isLoadingM = false.obs;
  RxBool isLoadingC = false.obs;
  RxBool isLoadingL = false.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void getModuleList() {
    isLoadingM.value = true;
    getModulesList().then(
      (value) {
        isLoadingM.value = false;
        moduleList.value = value;
      },
    );
  }

  void getChapterList(id) {
    isLoadingC.value = true;
    getChaptersList(id).then(
      (value) {
        isLoadingC.value = false;
        chapterList.value = value;
      },
    );
  }


  

  void getLessonList(id) {
    isLoadingL.value = true;
    getLessonsList(id).then(
      (value) {
        isLoadingL.value = false;
        lessonList.value = value;
      },
    );
  }

  void setUserLessonProgressStatus(id) {
    setUserLessonProgress(id, "current").then(
      (value) {},
    );
  }

  void setUserPracticeProgressStatus(id) {
    setUserLessonProgress(id, "current").then(
      (value) {},
    );
  }
  void startContent(object_id,content_type_id) {
    startContentListener(
        {"content_type_id": content_type_id, "object_id": object_id})
        .then(
          (value) {
        },
    );
  }
}
