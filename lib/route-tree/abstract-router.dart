import 'route-tree.dart';
import 'types.dart';
import 'route-node.dart';

class AbstractRouter {
  final RouteTree routeTree = RouteTree();

  /**
   * 添加中间件
   */
  void use(String path, List<RouteMiddleware> middlewares, [String method = DEFAULT_METHOD]) {
    routeTree.addMiddlewares(path, middlewares, method);
  }

  /**
   * 添加处理器
   */
  void handle(String path, RouteHandler handler, [String method = DEFAULT_METHOD]) {
    routeTree.addRoute(path, handler, method);
  }

  // 添加
  RouterContext parse(String path, [String method = DEFAULT_METHOD]) {
    return routeTree.getContext(path, method);
  }
}