import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frp_http_client/common/utils.dart';
import 'package:get/get.dart';

import 'controller/app_state.dart';

var count = 0;

class LeftWidget extends StatelessWidget {
  const LeftWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 256 - 56,
      child: Card(
        margin: const EdgeInsets.all(4)
            .copyWith(top: Platform.isMacOS ? 0 : 4, right: 2),
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              /* LeftItem(
                title: const Text('frps 服务器'),
                subtitle: Obx(() => Text("${AppState.to.frpsServer}")),
              ), */
              LeftItem(
                title: const Text('frpc 版本'),
                /* subtitle: Obx(
                  () {
                    debugPrint('[left_widget] count: ${++count}');
                    return Text(AppState.to.frpcVersion.value ?? '');
                  },
                ), */
                subtitle: Tooltip(
                  message: '打开程序所在目录',
                  child: InkWell(
                    onTap: () {
                      openFolder(AppState.to.frpcDirectory);
                    },
                    child: Obx(
                      () {
                        debugPrint('[left_widget] count: ${++count}');
                        return Text(AppState.to.frpcVersion.value ?? '');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftItem extends StatelessWidget {
  final Widget title;
  final Widget subtitle;

  const LeftItem({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(0)),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              child: title,
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!,
              child: subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
