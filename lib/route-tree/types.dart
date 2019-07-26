/// 路由处理器 <br>
/// The function as handler for router.
typedef Future<dynamic> RouteHandler(RouterContext context);

/// 路由上下文 <br>
/// The router context for some path
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
/// 路由中间件 <br>
/// The function as middleware for router.
typedef Future<dynamic> RouteMiddleware (RouterContext context);
