import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/routes/app_navigation.dart';
import 'package:simple_live_app/routes/route_path.dart';
import 'package:simple_live_core/simple_live_core.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DouyinSearchController extends BaseController {
  InAppWebViewController? webViewController;
  final TextEditingController manualController = TextEditingController();

  String? _extractRoomId(String text) {
    final uri = Uri.tryParse(text);
    if (uri != null && uri.host.contains("live.douyin.com")) {
      // 取第一个非空 path segment 作为房间号，忽略查询参数
      final seg = uri.pathSegments.firstWhere(
        (s) => s.isNotEmpty,
        orElse: () => "",
      );
      if (seg.isNotEmpty) {
        return seg;
      }
      // 兜底正则
      final match = RegExp(
        r"live\.douyin\.com/([\w\-]+)",
      ).firstMatch(uri.toString());
      return match?.group(1);
    }
    return null;
  }

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
  }

  RxList<LiveRoomItem> list = <LiveRoomItem>[].obs;

  String keyword = "";

  /// 搜索模式，0=直播间，1=主播
  var searchMode = 0.obs;
  final Site site;
  DouyinSearchController(this.site);

  var searchUrl = "https://www.douyin.com/search/dnf?type=live";

  void reloadWebView() {
    if (keyword.isEmpty) {
      return;
    }
    searchUrl =
        "https://www.douyin.com/search/${Uri.encodeComponent(keyword)}?type=live";
    if (Platform.isAndroid || Platform.isIOS) {
      webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(searchUrl)),
      );
    }
  }

  void goToRoomByInput() {
    final text = manualController.text.trim();
    if (text.isEmpty) {
      Get.snackbar('提示', '请输入房间号或直播间链接');
      return;
    }
    final uri = Uri.tryParse(text);
    if (uri != null && uri.host.contains("v.douyin.com")) {
      Get.snackbar('提示', '请使用 live.douyin.com 链接或房间号');
      return;
    }
    String? rid = _extractRoomId(text);
    rid ??= text; // 直接输入房间号
    if (rid.isEmpty) {
      Get.snackbar('提示', '未识别到房间号，请检查输入');
      return;
    }
    AppNavigator.toLiveRoomDetail(site: site, roomId: rid);
  }

  void onLoadStop(InAppWebViewController controller, Uri? uri) async {
    pageLoadding.value = false;
  }

  void onLoadStart(InAppWebViewController controller, Uri? uri) async {
    pageLoadding.value = true;
  }

  Future<bool?> onCreateWindow(
    InAppWebViewController controller,
    CreateWindowAction createWindowAction,
  ) async {
    if (createWindowAction.request.url?.host == "live.douyin.com") {
      {
        final id =
            _extractRoomId(createWindowAction.request.url.toString()) ?? "";

        AppNavigator.toLiveRoomDetail(site: site, roomId: id);
        return false;
      }
    }

    return false;
  }

  void openBrowser() {
    launchUrlString(searchUrl);
    Get.offAndToNamed(RoutePath.kTools);
  }

  @override
  void onClose() {
    manualController.dispose();
    super.onClose();
  }
}
