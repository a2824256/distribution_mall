import 'package:fluwx/fluwx.dart' as fluwx;

const APP_ID = "wxe6ff833092d5dd45";

initFluwx() async {
  await fluwx.registerWxApi(appId: "wxe6ff833092d5dd45");
}

Future<bool> isInstalledWx() async {
  var isInstalled = await fluwx.isWeChatInstalled();
  return isInstalled;
}

shareToWeChat() async{
  return await fluwx.shareToWeChat(fluwx.WeChatShareTextModel(
    text: "hello",
    transaction: "text${DateTime.now().millisecondsSinceEpoch}",
    scene: fluwx.WeChatScene.SESSION,
  ));
}
