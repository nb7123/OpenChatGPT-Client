# OpenChatGPT

一个完全开源的、跨平台的 ChatGPT 客户端（需要对接/配置OpenAI API_KEY），支持 **Android** / **iOS** / **macOS** / **Windows** / **Linux** / **Fuchsia**。

## 项目简介

由于 OpenAI 对部分国家的限制，很多人无法直接方便的使用其功能。为了解决这个问题，我开发一个开源的客户端（Flutter实现）和服务端（Go实现）程序。

您可以自由的使用这里面的所有代码。

客户端可以独立使用，但是防止您的API_KEY泄漏，建议部署对应的[服务端](https://github.com/nb7123/OpenChatGPT-server)程序，然后配置您自己的服务器，将 ***API_KEY*** 配置在服务端使用。

* 如果您需要优秀的**Prompt**，可以参考[这里](https://github.com/f/awesome-chatgpt-prompts)。

![ScreenShot](./resources/screenshot.jpg)

## 环境

服务端和客户端需要分别构建。客户端是由Flutter实现，服务端由 Go 实现。因此，构建之前需要先配置好您的开发环境。

*你也可以直接使用我们的产品 [**Axion**](https://www.easy-ai.us/) 😊😊😊*.

[**Flutter**](https://docs.flutter.dev/get-started/install) 环境搭建。

[**Go**](https://go.dev/doc/install) 环境搭建。

### 构建

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

如果您不是专业的开发人员，*你也可以直接使用我们的产品 [**Axion**](https://www.easy-ai.us/) 😊😊😊*

## 贡献

欢迎贡献代码。

## 许可证

完全自由使用。

## 常见问题

欢迎反馈至issuse区。

## 联系我

* **Email**: nb7123@gmail.com
* [**Twitter**](https://twitter.com/harrys_hemmings?t=yn91b_EqsgFOZu8QpY_hRA&s=05)

## 感谢您的支持

欢迎使用我们的产品  [**Axion**](https://www.easy-ai.us/)

![](/Users/didi/Code/Github/Easy-AI/open_chatgpt/resources/google-play.png) 

[**Google Play**](https://play.google.com/store/apps/details?id=com.easyai.chat)

![](/Users/didi/Code/Github/Easy-AI/open_chatgpt/resources/apple-store.png) 

[**Apple Store**](https://apps.apple.com/cn/app/axion-powerful-ai-chatbot/id6452236314)