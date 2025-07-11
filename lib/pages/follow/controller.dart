import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class FollowController extends GetxController with GetTickerProviderStateMixin {
  late int mid;
  String? name;
  late bool isOwner;

  late final Rx<LoadingState> followState = LoadingState.loading().obs;
  late final RxList<MemberTagItemModel> tabs = <MemberTagItemModel>[].obs;
  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    int ownerMid = Accounts.main.mid;
    mid = Get.parameters['mid'] != null
        ? int.parse(Get.parameters['mid']!)
        : ownerMid;
    isOwner = ownerMid == mid;
    name = Get.parameters['name'] ?? Get.find<AccountService>().name.value;
    if (isOwner) {
      queryFollowUpTags();
    }
  }

  Future<void> queryFollowUpTags() async {
    var res = await MemberHttp.followUpTags();
    if (res['status']) {
      tabs
        ..clear()
        ..addAll(res['data'])
        ..insert(0, MemberTagItemModel(name: '全部关注'));
      int initialIndex = 0;
      if (tabController != null) {
        initialIndex = tabController!.index.clamp(0, tabs.length - 1);
        tabController!.dispose();
      }
      tabController = TabController(
        initialIndex: initialIndex,
        length: tabs.length,
        vsync: this,
      );
      followState.value = Success(tabs.hashCode);
    } else {
      followState.value = Error(res['msg']);
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  Future<void> onCreateTag(String tagName) async {
    final res = await MemberHttp.createFollowTag(tagName);
    if (res['status']) {
      followState.value = LoadingState.loading();
      queryFollowUpTags();
      SmartDialog.showToast('创建成功');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  Future<void> onUpdateTag(MemberTagItemModel item, String tagName) async {
    final res = await MemberHttp.updateFollowTag(item.tagid, tagName);
    if (res['status']) {
      item.name = tagName;
      tabs.refresh();
      SmartDialog.showToast('修改成功');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  Future<void> onDelTag(int? tagid) async {
    final res = await MemberHttp.delFollowTag(tagid);
    if (res['status']) {
      followState.value = LoadingState.loading();
      queryFollowUpTags();
      SmartDialog.showToast('删除成功');
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }
}
