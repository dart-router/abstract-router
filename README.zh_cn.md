# 抽象路由

[![版本](https://img.shields.io/badge/version-1.0.7-blue.svg)](https://pub.dev/packages/abstract_router)
[![构建状态](https://travis-ci.org/dart-router/abstract-router.svg?branch=master)](https://travis-ci.org/dart-router/abstract-router)
![单元测试覆盖率](https://raw.githubusercontent.com/dart-router/abstract-router/master/coverage_badge.svg?sanitize=true)

[English Documentation](./README.md)

抽象路由的初衷是为了实现一个简单的路由系统，用于将URI映射到指定的处理函数，并且支持给路径绑定中间件。它根据URI解析携带的参数信息、中间件以及处理函数，将其放到`RouterContext`上下文中，供真实的路由系统支配。

[API文档 pub.dev](https://pub.dev/documentation/abstract_router/latest/)

[API文档 flutter-cn.io](https://pub.flutter-io.cn/documentation/abstract_router/latest/)

MIT License

Copyright (c) 2019 bullub

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
