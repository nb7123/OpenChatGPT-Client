# OpenChatGPT

一个完全开源的、跨平台的 ChatGPT 客户端（需要对接/配置OpenAI API_KEY），支持Android/iOS/macOS/Windows/Linux/Fuchsia。

## 项目简介

是 [OpenAI](https://zh.wikipedia.org/wiki/OpenAI) 开发的 [人工智能](https://zh.wikipedia.org/wiki/人工智能)[聊天机器人](https://zh.wikipedia.org/wiki/聊天機器人) 程序，于2022年11月推出。而除了可以用人类自然对话方式来互动，还可以用于甚为复杂的语言工作，包括自动生成[文本](https://zh.wikipedia.org/wiki/文本)、自动问答、自动[摘要](https://zh.wikipedia.org/wiki/摘要)等多种任务。

由于 OpenAI 对部分国家的限制，很多人无法直接方便的使用其功能。这个项目就是为了解决这个问题，开发一个开源的客户端（Flutter实现）和服务端（Go实现）程序以及如何部署应用和使用，您可以直接使用我们发布的应用 [**Axion**](https://www.easy-ai.us/)或是自行构建。

* 这里放应用商店的信息＋支持我们

客户端可以独立使用，但是防止您的API_KEY泄漏，建议[部署](这里是部署的链接)对应的服务端程序，将API_KEY配置在服务端使用。

* 这里描述下主要功能和引用下Prompts的项目，以表感谢

* 这里放动画图，显示如何使用App

## Build

服务端和客户端需要分别构建。客户端是由Flutter实现，服务端由Go实现。因此，构建之前需要先配置好您的开发环境。

[**Flutter**](https://docs.flutter.dev/get-started/install) 环境搭建。

[**Go**](https://go.dev/doc/install) 环境搭建。

### 客户端构建

**Android (APK)**　详细构建过程请参考[官方文档](https://docs.flutter.dev/deployment/android)。

```
flutter build apk
```

**iOS** 详细构建过程请参考[官方文档](https://docs.flutter.dev/deployment/ios)。

```
flutter build ipa
```

**macOS** 详细构建过程请参考[官方文档](https://docs.flutter.dev/deployment/macos)。

```
flutter build macos
```

**Windows** 详细构建过程请参考[官方文档](https://docs.flutter.dev/deployment/windows)。

```
flutter build windows
```

**Linux** 详细构建过程请参考[官方文档](https://docs.flutter.dev/deployment/linux)。

如果您不是专业的开发人员，可以直接使用我们的已发布 App 来支持我们：

。。。

## 贡献

如何贡献：Prompt贡献和代码贡献

## 许可证

明确你的项目的许可证类型。

## 常见问题

欢迎反馈至issuse区。

## 联系方式

提供你的联系信息，这样其他人可以与你取得联系。

你可以根据你的项目需求，自由地适应和调整上述结构和内容。

## 感谢您的支持

[**Axion 官网**](https://www.easy-ai.us/)

![Apple]()

![Android]()