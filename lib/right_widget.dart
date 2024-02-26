import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:frp_http_client/controller/app_state.dart';
import 'package:frp_http_client/down_frpc_button.dart';
import 'package:get/get.dart';
import 'package:separated_row/separated_row.dart';
import 'package:url_launcher/url_launcher.dart';

class RightWidget extends StatelessWidget {
  const RightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(
            () {
              if (!AppState.to.ready.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (AppState.to.frpcVersion.value == null) {
                return _buildDownloadTip(context);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SeparatedRow(
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('创建穿透'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: TextEditingController()
                                        ..text = '127.0.0.1',
                                      decoration: const InputDecoration(
                                        labelText: '内网地址',
                                      ),
                                    ),
                                    const TextField(
                                      decoration: InputDecoration(
                                        labelText: '内网端口',
                                        hintText: '请输入内网端口',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('创建穿透'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('全部启动'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('全部停止'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          /* final process = await Process.start(
                        AppState.to.executableFilePath.value,
                        [
                          'http',
                          '--server-addr=146.56.128.30',
                          '--server-port=7000',
                          '--local-ip=127.0.0.1',
                          '--local-port=80',
                          '--sd=flutter-dev',
                          '--proxy-name=flutter-dev'
                        ],
                      );

                      // 监听标准输出流
                      process.stdout.transform(utf8.decoder).listen((data) {
                        debugPrint('标准输出: $data');
                      });

                      // 监听错误输出流
                      process.stderr.transform(utf8.decoder).listen((data) {
                        debugPrint('错误输出: $data');
                      });

                      final exitCode = await process.exitCode;
                      debugPrint('Exit code: $exitCode'); */
                        },
                        child: const Text('测试按钮'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildList(context),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Column _buildDownloadTip(BuildContext context) {
    final isWindows = kDebugMode ? true : Platform.isWindows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(
                fontSize: 16,
                // color: colorScheme.error,
              ),
          child: Builder(builder: (context) {
            return RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(text: 'frpc 程序未找到，点击下载按钮下载 frpc 程序。'),
                  if (isWindows) ...[
                    TextSpan(
                        text: '\n如果下载后还是无法找到，请将工作目录',
                        style: DefaultTextStyle.of(context).style),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Tooltip(
                        message: '点击查看如何操作，如果电脑还有其他安全软件，请自行搜索如何添加排除项/白名单。',
                        child: InkWell(
                          onTap: () {
                            launchUrl(Uri.parse(
                                'https://support.microsoft.com/zh-cn/windows/将排除项添加到-windows-安全中心-811816c0-4dfd-af4a-47e4-c301afe13b26#ID0EBF=Windows_11'));
                          },
                          child: Text(
                            '添加到 Windows 安全中心的排除项中',
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(
                      text: '。再次点击下载按钮。\n',
                    ),
                    WidgetSpan(
                      child: Tooltip(
                        message: '点击复制',
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: AppState.to.frpcDirectory));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 3),
                                behavior: SnackBarBehavior.floating,
                                content: Text('工作目录已复制到剪贴板'),
                              ),
                            );
                          },
                          child: Text(
                            '工作目录：${AppState.to.frpcDirectory}',
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        const DownFrpcButton(),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return DataTable(
      border: TableBorder.all(),
      columns: const <DataColumn>[
        DataColumn(
          label: Text('状态'),
        ),
        DataColumn(
          label: Text('内网地址'),
        ),
        DataColumn(
          label: Text('访问地址 http(s)://'),
        ),
        DataColumn(
          label: Text('操作'),
        ),
      ],
      rows: [
        ...List.generate(
          0,
          (index) => DataRow(
            cells: [
              const DataCell(
                Text('已启动'),
              ),
              const DataCell(
                Text('127.0.0.1:8080'),
              ),
              DataCell(
                Tooltip(
                  message: "点击复制",
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                            text: "http://161A51D1-8080.frp.oo1.dev"
                                .toLowerCase()),
                      );
                      const snackBar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('已复制到剪贴板'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: Text("161A51D1-8080.frp.oo1.dev".toLowerCase()),
                  ),
                ),
              ),
              DataCell(
                SeparatedRow(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: Text(index.isEven ? '停止' : '启动'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('删除'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
