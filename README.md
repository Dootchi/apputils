# apputils

面向自有 Flutter 项目的通用原生能力私库。当前内置反扒能力，后续能力按独立模块扩展。

## 接入

建议业务项目固定到明确的 tag：

```yaml
dependencies:
  apputils:
    git:
      url: git@github.com:Dootchi/apputils.git
      ref: v0.1.0
```

然后执行：

```shell
flutter pub get
```

平台要求：

- Android API 21 及以上；反扒原生库支持 `armeabi-v7a`、`arm64-v8a`。
- iOS 13.0 及以上；真实反扒 SDK 仅支持 arm64 真机。
- Android x86/x86_64 模拟器和 iOS 模拟器可正常编译，但调用反扒能力会返回
  `AppUtilsException(code: sdk_unavailable)`。

## 反扒能力

可以在应用启动时提前初始化：

```dart
import 'package:apputils/apputils.dart';

await AppUtils.instance.initialize();
```

也可以直接获取 ticket，此时 SDK 会自动进行一次幂等的延迟初始化：

```dart
try {
  final ticket = await AppUtils.instance.antiScraping.getTicket();
  // 把 ticket 附加到需要保护的业务请求中。
} on AppUtilsException catch (error) {
  // error.code: sdk_unavailable / initialization_failed / native_error
}
```

iOS SDK 还提供设备状态上报，Android 当前没有对应接口并固定返回 `false`：

```dart
final reported = await AppUtils.instance.antiScraping
    .reportDeviceStatus('your-label');
```

`initialize`、`getTicket` 和 iOS 上报都在原生串行后台队列执行，不阻塞 Flutter UI；
并发调用只会初始化一次。

## 扩展新能力

每项能力沿用以下边界：

```text
lib/src/<capability>/       强类型 Dart 门面
AppUtilsPlatform            跨平台契约
com.dootchi.apputils/<capability>
                            独立 MethodChannel
android/.../<Handler>.kt    Android 生命周期、线程和 SDK 适配
ios/Classes/<Handler>.m     iOS 生命周期、线程和 SDK 适配
```

新增能力时：

1. 在 `lib/src/<capability>/` 添加业务可读的强类型 API。
2. 在 `AppUtilsPlatform` 和 `MethodChannelAppUtils` 添加平台契约与独立通道。
3. Android/iOS 各增加一个 Handler，并由 `ApputilsPlugin` 注册。
4. 将能力入口挂到 `AppUtils.instance`，同时补齐单元测试和 example。

不要让业务代码直接依赖 MethodChannel 名称、参数 Map 或厂商 SDK 类型。

## 原生 SDK 与合规说明

当前打包版本：

- Android 内部版本 `2026073100`，原始 `libdpsdk.so` 未修改。
- iOS 内部版本 `2026080100`，真机 slice 未修改；仓库额外生成了仅用于编译的
  simulator 空实现，模拟器不会生成 ticket。

iOS 厂商包未附带隐私清单或数据采集说明，但其二进制引用了设备信息、磁盘空间、
传感器和 `NSUserDefaults` 等 API。发布 App Store 前必须让 SDK 提供方确认实际采集、
上传行为和 Apple Required Reason API 的准确理由，并据此更新
`ios/Resources/PrivacyInfo.xcprivacy`、在 Podspec 中启用该资源，以及更新宿主应用的隐私
声明。目前空清单不会被打入产物，避免错误声明“未采集数据”。不要填写与实际行为不符
的理由。

## 开发验证

```shell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

cd example/android
./gradlew :app:assembleDebug
```
