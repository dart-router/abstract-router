# 抽象路由

[![构建状态](https://travis-ci.org/dart-router/abstract-router.svg?branch=master)](https://travis-ci.org/dart-router/abstract-router)

[English Documentation](./README.md)

抽象路由的初衷是为了实现一个简单的路由系统，用于将URI映射到指定的处理函数，并且支持给路径绑定中间件。它根据URI解析携带的参数信息、中间件以及处理函数，将其放到`RouterContext`上下文中，供真实的路由系统支配。

[API文档](doc/api/index.html)

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
