import 'route-tree/route_tree.dart';
import 'route-tree/types.dart';
import 'route-tree/route_node.dart';

export 'route-tree/types.dart';
/// 抽象的路由系统，其包含绑定路径处理器、中间件以及根据路由信息解析路径获得上下文 <br>
/// An abstract routing system that includes a bound path processor, middleware, and context for resolving paths based on routing information.
class AbstractRouter {
  final RouteTree _routeTree = RouteTree();

  /// 添加中间件 <br>
  /// Add Some middlewares with some path.
  /// eg: 
  /// ```dart
  /// AbstractRouter router = AbstractRouter();
  /// router.use('/some/path', [(RouterContext context) async {
  ///   print(context);
  /// }]);
  /// ```
  void use(String path, List<RouteMiddleware> middlewares, [String method = DEFAULT_METHOD]) {
    _routeTree.addMiddlewares(path, middlewares, method);
  }

  /// 添加路径处理器函数 <br>
  /// Add path processor function.
  /// ```dart
  /// AbstractRouter router = AbstractRouter();
  /// router.handle('/some/path', (RouterContext context) async {
  ///   print(context);
  /// });
  /// ```
  void handle(String path, RouteHandler handler, [String method = DEFAULT_METHOD]) {
    _routeTree.addRoute(path, handler, method);
  }

  ///根据路径和方法解析出路由上下文 <br>
  /// Parse the routing context based on the path and method.
  /// The [path] to be parsed.
  /// eg:
  /// ```dart
  /// router.handle('/some/:path/*subpathes', (RouterContext context) async {
  ///   print(context.routeId);  //  /some/:path/*subpathes
  ///   print(context.params['path']);  // variables
  ///   print(context.params['subpathes']); // other/paths/for/this
  ///   print(context.queries['abc']);  // def
  ///   print(context.queries[bcd]);   // ["1", "2"]
  ///   print(context.middlewares);    // []
  /// });
  /// RouterContext context = router.parse('/some/variables/other/paths/for/this?abc=def&bcd=1&bcd=2');
  /// context.handler(context);
  /// ```
  RouterContext parse(String path, [String method = DEFAULT_METHOD]) {
    return _routeTree.getContext(path, method);
  }
}
