import 'exception.dart';
import 'types.dart';
import 'route_node.dart';
import '../utils/stack.dart';

// 路由解析树
class RouteTree {
  RouteNode root;

  int _middlewareSeq = 0;

  RouteTree() {
    this.root = RouteNode("/", level: 0, parent: null);
  }

  // 根据路径在树的分支上生成一个
  addRoute(final String path, final RouteHandler handler,
      [String method = DEFAULT_METHOD]) {
    assert(path != '' && handler != null);

    final Uri uri = Uri.parse(path);
    // 使用 / 拆分路径
    List<String> nodeKeys = uri.pathSegments;
    // 设置当前节点为根节点
    RouteNode currentNode = root;
    // 遍历所有的节点
    for (int i = 0, len = nodeKeys.length; i < len; i++) {
      final String nodeKey = nodeKeys[i];

      assert(nodeKey != '');

      RouteNode node = RouteNode(nodeKey, level: i + 1, parent: currentNode);

      if (i == len - 1) {
        node.setHandler(method, handler);
      }

      if (node.type == NodeType.wildcard && i < len - 1) {
        throw UnsupportRouteIdException(
            path, 'The * segment must be end of segments!');
      }

      // 记录当前节点
      currentNode = currentNode.findOrAddChild(node);
    }
  }

  void addMiddlewares(String path, List<RouteMiddleware> middlewares,
      [String method = DEFAULT_METHOD]) {
    assert(path != '' && middlewares != null && middlewares.isNotEmpty);

    if (path == '/') {
      root.middlewares[method] ??= [];
      root.middlewares[method].addAll(middlewares.map(
          (RouteMiddleware middleware) =>
              RouteMiddlewareWrap(_middlewareSeq++, middleware)));
      return;
    }

    final Uri uri = Uri.parse(path);
    // 使用 / 拆分路径
    List<String> nodeKeys = uri.pathSegments;
    // 设置当前节点为根节点
    RouteNode currentNode = root;
    // 遍历所有的节点
    for (int i = 0, len = nodeKeys.length; i < len; i++) {
      final String nodeKey = nodeKeys[i];

      assert(nodeKey != '');

      RouteNode node = RouteNode(nodeKey, level: i + 1, parent: currentNode);

      if (i == len - 1) {
        node.middlewares[method] ??= [];
        // 此处所有的节点都不会有处理器
        node.middlewares[method].addAll(middlewares.map(
            (RouteMiddleware middleware) =>
                RouteMiddlewareWrap(_middlewareSeq++, middleware)));
      }

      // 记录当前节点
      currentNode = currentNode.findOrAddChild(node);
    }
  }

  /**
   * 根据一个路径，获取路由上下文
   */
  RouterContext getContext(String path, [String method = DEFAULT_METHOD]) {
    assert(path != '');
    final Uri uri = Uri.parse(path);
    // 使用 / 拆分路径
    Stack<String> pathParts = Stack(uri.pathSegments);

    String pathPart;
    Stack<MatchResult> matchedResults = Stack([MatchResult(root)]);
    MatchResult lastMatchResult;
    bool hasEnded = false;
    while (pathParts.isNotEmpty && !hasEnded) {
      pathPart = pathParts.pop();

      if (pathPart == '') {
        //忽略空的部分路径
        continue;
      }

      lastMatchResult = matchedResults.top;
      RouteNode currentNode = lastMatchResult.node;

      MatchResult matchResult;

      if (!lastMatchResult.partChildrenHadMatch) {
        // 1. 在partChildren中匹配
        matchResult = currentNode.matchPartChildren(pathPart);
        lastMatchResult.partChildrenHadMatch = true;
      }

      // 2. 在paramChildren中匹配
      if (matchResult == null) {
        matchResult = currentNode.matchParamChildren(
            pathPart, lastMatchResult.paramChildIndex);
      }
      // 3. 在wildChildren中匹配
      if (matchResult == null) {
        matchResult = currentNode.matchWildcardChild(pathPart);
      }

      if (matchResult != null) {
        // 匹配到了路由节点

        // 将匹配上的结果入栈
        matchedResults.push(matchResult);

        // 该情况是当前段已匹配上了一个节点，接下来继续匹配下一个节点
        if (matchResult.node.type == NodeType.param) {
          lastMatchResult.paramChildIndex++;
        }

        if (matchResult.node.type == NodeType.wildcard) {
          pathParts.push(pathPart);
          hasEnded = true;
          // 匹配到通配节点，结束匹配
          break;
        }

        if (pathParts.isEmpty && matchResult.node.getHandler(method) == null) {
          // 已经匹配到路径最后了，但是没有找到对应的处理器函数，则需要检查回滚
          if (matchResult.node.isHandleNode) {
            // 匹配到了已绑定的路由，但是方法未能匹配，匹配已结束
            hasEnded = true;
          } else {
            pathParts.push(pathPart);
            matchedResults.pop();
            switch (_backtrackingCheck(pathParts, matchedResults)) {
              case _BacktrackingState.cant:
                // 回溯之前需要判断层级，需要判断是不是每一层都已经回溯完了，如果都回溯完了的话，就表明当前路径是 404 的情况
                // 不可回溯，如果可回溯的话，两个栈的状态都会回溯到正确位置
                // 完全不可回溯了，也就是整个匹配过程已结束，但并未匹配上带当前方法的处理器的路由
                return null;
                break;
              case _BacktrackingState.yes:
                // ignore this do next loop
                break;
              case _BacktrackingState.stop:
                hasEnded = true;
                break;
            }
          }
        }
      } else {
        // 当前这帧没有匹配上，则加回到栈中，然后再检查回溯条件
        pathParts.push(pathPart);
        switch (_backtrackingCheck(pathParts, matchedResults)) {
          case _BacktrackingState.cant:
            // 回溯之前需要判断层级，需要判断是不是每一层都已经回溯完了，如果都回溯完了的话，就表明当前路径是 404 的情况
            // 不可回溯，如果可回溯的话，两个栈的状态都会回溯到正确位置
            // 完全不可回溯了，也就是整个匹配过程已结束，但并未匹配上路由
            return null;
          case _BacktrackingState.yes:
            // ignore this do next loop
            break;
          case _BacktrackingState.stop:
            hasEnded = true;
            break;
        }
      }
    }

    if (matchedResults.isEmpty) {
      // 匹配完成之后，并未匹配到记录
      return null;
    }

    // 已经匹配上了，根据匹配结果集构造路由上下文
    RouterContext context =
        _generateRouterContext(pathParts, matchedResults, method);
    context.path = path;
    context.queries = uri.queryParametersAll.map(
        (String key, List<String> value) =>
            MapEntry(key, value.length == 1 ? value[0] : value));

    return context;
  }

  RouterContext _generateRouterContext(final Stack<String> pathParts,
      final Stack<MatchResult> matchedResults, final String method) {
    String routeId = matchedResults.top.node.path;
    RouteHandler handler = matchedResults.top.node.getHandler(method);
    Map<String, String> params = {};
    List<RouteMiddlewareWrap> middlewareWraps = [];

    while (matchedResults.isNotEmpty) {
      MatchResult matchResult = matchedResults.pop();
      // 此处中间件的顺序有问题，需要修复
      if (method != DEFAULT_METHOD) {
        if (matchResult.node.middlewares[DEFAULT_METHOD] != null) {
          middlewareWraps.addAll(matchResult.node.middlewares[DEFAULT_METHOD]);
        }
      }
      if (matchResult.node.middlewares[method] != null) {
        middlewareWraps.addAll(matchResult.node.middlewares[method]);
      }
      switch (matchResult.node.type) {
        case NodeType.part:
          // ignore this
          break;
        case NodeType.param:
          params[matchResult.node.name] = matchResult.value;
          break;
        case NodeType.wildcard:
          params[matchResult.node.name] = pathParts.join('/');
          break;
      }
    }

    RouterContext context = RouterContext(routeId: routeId, handler: handler);
    middlewareWraps.sort((RouteMiddlewareWrap wm1, RouteMiddlewareWrap wm2) =>
        wm1.seq - wm2.seq);
    context.middlewares.addAll(middlewareWraps.map(
        (RouteMiddlewareWrap middlewareWrap) => middlewareWrap.handleFunc));
    context.params = params;

    return context;
  }

  _BacktrackingState _backtrackingCheck(
      final Stack<String> pathParts, final Stack<MatchResult> matchedResults) {
    // print('back');
    MatchResult lastMatchResult;
    while (matchedResults.isNotEmpty) {
      lastMatchResult = matchedResults.top;

      if (lastMatchResult.node.type == NodeType.wildcard) {
        // 如果当前回溯到的节点自身是通配节点的话，那就不用再往回回溯了，直接结束
        return _BacktrackingState.stop;
      }

      if (lastMatchResult.paramChildCanBacktracking) {
        // 参数子节点可以回溯，则回溯到此位置，继续匹配
        // lastMatchResult.paramChildIndex ++;
        return _BacktrackingState.yes;
      } else if (lastMatchResult.wildcardCanBacktracking) {
        // 有通配节点可回溯
        return _BacktrackingState.yes;
      } else {
        // 当前帧不可回溯
        if (lastMatchResult.node.type == NodeType.part) {
          pathParts.push(lastMatchResult.node.key);
        } else {
          pathParts.push(lastMatchResult.value);
        }
        matchedResults.pop();
      }
    }
    // 最终不可回溯
    return _BacktrackingState.cant;
  }
}

enum _BacktrackingState {
  // 不能回溯
  cant,
  // 可以回溯
  yes,
  // 停止回溯，已经匹配完成
  stop
}
