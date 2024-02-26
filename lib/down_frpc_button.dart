import 'package:flutter/material.dart';
import 'package:frp_http_client/controller/app_state.dart';

class DownFrpcButton extends StatelessWidget {
  const DownFrpcButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return FutureBuilder(
              future: AppState.to.downloadFrpc(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AlertDialog(
                    title: Text('下载中...'),
                    content: SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                } else {
                  if (snapshot.error != null) {
                    return AlertDialog(
                      title: const Text('下载失败'),
                      content: Text('${snapshot.error}'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    );
                  } else {
                    AppState.to.checkFrpc().whenComplete(() {
                      Navigator.of(context).pop();
                    });
                    return const AlertDialog(
                      title: Text('下载成功'),
                      content: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      },
      child: const Text('下载'),
    );
  }
}
