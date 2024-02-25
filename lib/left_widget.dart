import './controller/app_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

var count = 0;

class LeftWidget extends StatelessWidget {
  const LeftWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 256 - 56,
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Obx(() {
                debugPrint('count: ${++count}');
                return LeftItem(
                  title: 'frps 服务器',
                  subtitle: AppState.to.frpsServer.value,
                );
              }),
              Obx(
                () => LeftItem(
                  title: 'frpc 版本',
                  subtitle: AppState.to.frpcInfo.value.version.toString(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LeftItem extends StatelessWidget {
  final String title;
  final String subtitle;

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
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
