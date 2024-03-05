import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frp_http_client/common/constants.dart';
import 'package:frp_http_client/controller/app_state.dart';
import 'package:frp_http_client/controller/tunnel_controller.dart';
import 'package:frp_http_client/down_frpc_button.dart';
import 'package:get/get.dart';
import 'package:separated_row/separated_row.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/network_tunnel.dart';

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
                return const Center(child: CircularProgressIndicator());
              }
              if (AppState.to.frpcVersion.value == null) {
                return _buildDownloadTip(context);
              }

              return _buildRightContent(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRightContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeparatedRow(
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          children: [
            OutlinedButton(
              onPressed: () {
                _clickAdd(context);
              },
              child: const Text('创建穿透'),
            ),
            OutlinedButton(
              onPressed: () {
                TunnelController.to.startAllTunnels();
              },
              child: const Text('全部启动'),
            ),
            OutlinedButton(
              onPressed: () {
                TunnelController.to.stopAllTunnels();
              },
              child: const Text('全部停止'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildList(context))
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    Get.put(TunnelController());
    return Obx(
      () => DataTable(
        border: TableBorder.all(),
        columns: const <DataColumn>[
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('内网地址')),
          DataColumn(label: Text('访问地址 http(s)://')),
          DataColumn(label: Text('操作')),
        ],
        rows: TunnelController.to.tunnels.map((tunnel) {
          return DataRow(
            cells: [
              DataCell(Text(tunnel.status.name)),
              DataCell(Text('${tunnel.localIp}:${tunnel.localPort}')),
              DataCell(
                Tooltip(
                  message: "点击复制",
                  child: InkWell(
                    child: Text(tunnel.publicHostname),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: tunnel.publicHostname));
                      const snackBar = SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('已复制到剪贴板'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),
                ),
              ),
              DataCell(
                SeparatedRow(
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        tunnel.status == TunnelStatus.notStarted
                            ? TunnelController.to.startTunnel(tunnel)
                            : TunnelController.to.stopTunnel(tunnel);
                      },
                      child: tunnel.status == TunnelStatus.notStarted
                          ? const Text('启动')
                          : const Text('停止'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        debugPrint('tunnel.logs: ${tunnel.logs}');
                      },
                      child: const Text('日志'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        TunnelController.to.removeTunnel(tunnel);
                      },
                      child: const Text('删除'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _clickAdd(BuildContext context) {
    // subdomainHost
    final TextEditingController subdomainHostController =
        TextEditingController()..text = kDefaultSubdomainHost;
    final TextEditingController localIpController = TextEditingController()
      ..text = '127.0.0.1';
    final TextEditingController localPortController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('创建穿透'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subdomainHostController,
                decoration: const InputDecoration(
                  labelText: 'frps服务器域名',
                ),
              ),
              TextField(
                controller: localIpController,
                decoration: const InputDecoration(
                  labelText: '内网地址',
                ),
              ),
              TextField(
                autofocus: true,
                controller: localPortController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '内网端口',
                  hintText: '输入要穿透的端口',
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
                final localIp = localIpController.text;
                final localPort = localPortController.text;
                if (localIp.isEmpty || localPort.isEmpty) {
                  return;
                }
                TunnelController.to.addTunnel(NetworkTunnel(
                  localIp: localIp,
                  localPort: int.parse(localPort),
                  subdomainHost: subdomainHostController.text,
                ));
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDownloadTip(BuildContext context) {
    final isWindows = kDebugMode ? true : Platform.isWindows;

    return DefaultTextStyle(
      style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: 16,
            // color: colorScheme.error,
          ),
      child: Builder(builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
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
            ),
            const SizedBox(height: 8),
            const DownFrpcButton(),
            const Spacer(),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Tooltip(
                      message:
                          'https://github.com/yanhao98/frp-http-flutter-client',
                      child: Text.rich(
                        TextSpan(
                          text: '本软件',
                          style: DefaultTextStyle.of(context).style.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(
                                  'https://github.com/yanhao98/frp-http-flutter-client'));
                            },
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '和 frpc 程序都是开源的。关于 frpc 程序被误判为病毒的问题，'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Tooltip(
                      message:
                          '点击查看 frpc 程序被误判为病毒的问题。\nhttps://github.com/fatedier/frp/issues/3272',
                      child: Text.rich(
                        TextSpan(
                          text: '点击这里',
                          style: DefaultTextStyle.of(context).style.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(
                                  'https://github.com/fatedier/frp/issues/3272'));
                            },
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '查看解释。'),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
