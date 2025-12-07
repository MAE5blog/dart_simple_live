import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/modules/search/douyin/douyin_search_controller.dart';
import 'package:simple_live_app/routes/app_navigation.dart';
import 'package:simple_live_app/widgets/keep_alive_wrapper.dart';
import 'package:simple_live_app/widgets/status/app_loadding_widget.dart';

class DouyinSearchView extends StatelessWidget {
  const DouyinSearchView({Key? key}) : super(key: key);
  DouyinSearchController get controller => Get.find<DouyinSearchController>();

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: Center(
        child: SingleChildScrollView(
          padding: AppStyle.edgeInsetsA12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "抖音搜索暂不可用，可直接输入房间号或 live.douyin.com 链接进入",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 420,
                child: TextField(
                  controller: controller.manualController,
                  decoration: const InputDecoration(
                    labelText: "房间号或直播间链接",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => controller.goToRoomByInput(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.goToRoomByInput,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text("直接进入直播间"),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: controller.openBrowser,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text("打开浏览器搜索"),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => controller.manualController.clear(),
                icon: const Icon(Icons.clear),
                label: const Text("清空输入"),
              ),
              const SizedBox(height: 12),
              if (Platform.isAndroid || Platform.isIOS)
                const Text(
                  "提示：官方搜索被限制，请直接输入房间号或 live 链接",
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
