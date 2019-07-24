import './route-node.dart';

// 当路由产生冲突的时候抛出异常.
class RouteConflictException implements Exception {
  final RouteNode node1;
  final RouteNode node2;

  // @pragma("vm:entry-point")
  const RouteConflictException(this.node1, this.node2);

  String toString() {
    return 'RouteConflictException: 【${node1.path}】 与 【${node2.path}】 产生了路由冲突，这会导致路由系统存在歧义路由，请检查您的代码！';
  }
}

// 当路由产生冲突的时候抛出异常.
class UnsupportRouteIdException implements Exception {
  final String routeId;
  final String reason;

  const UnsupportRouteIdException(this.routeId, this.reason);

  String toString() {
    return 'UnsupportRouteIdException: The Route path 【${routeId}】 not support. Because of: ${reason}';
  }
}