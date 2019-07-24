
typedef Future<dynamic> RouteHandler(RouterContext context);

enum NodeType {
  // 路径的一部分
  part,
  // 参数节点
  param,
  // 通配符参数
  wildcard,
}

// 抽象路由上下文
class RouterContext {
  // 访问路由时的路径
  String path;
  // 在添加路由处理器的时候的路径串
  String routeId;

  // 通过解析路径得到的参数
  Map<String, String> params;
  // 通过解析query string得到的参数
  Map<String, dynamic> queries;

  // 当前上下文包含的中间件
  List<RouteMiddleware> middlewares = [];

  // 当前上下文对应的路由处理函数
  RouteHandler handler;

  RouterContext({this.path, this.routeId, this.params, this.queries, this.handler});

  @override
  toString() {
    return '{path=${path}, routeId=${routeId}, params=${params}, queries=${queries}}';
  }
}

typedef Future<dynamic> RouteMiddleware (RouterContext context);

class RouteMiddlewareWrap {
  final int seq;
  final RouteMiddleware handleFunc;

  RouteMiddlewareWrap(this.seq, this.handleFunc);

}