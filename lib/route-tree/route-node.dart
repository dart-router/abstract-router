import './types.dart';
import './exception.dart';

const String DEFAULT_METHOD = '__DEFAULT__';

class RouteNode {
  // 当前节点在树中的层数
  final int level;
  // 节点的值
  // String value = "";
  // 节点的键，存放到构造的
  final String key;

  // 一个路由节点，可能根据不同条件有多个处理器
  Map<String, RouteHandler> _handleMap = {};

  // 一个路由节点，可能根据不同条件有多个中间件
  final Map<String, List<RouteMiddlewareWrap>> middlewares = {};

  // 之所以需要三个存放子节点的数组，是因为不同的路由节点有优先级，其优先级顺序 part > param > wildcard
  // 普通路径部分节点
  final Map<String, RouteNode> partChildren = {};
  // 参数子节点
  final List<RouteNode> paramChildren = [];
  // 通配符子节点
  RouteNode wildcardChild;

  // 父节点
  final RouteNode parent;

  RouteNode(this.key, {this.level, this.parent});

  bool setDefaultHandler(RouteHandler handler) {
    return setHandler(DEFAULT_METHOD, handler);
  }

  RouteHandler getDefaultHandler() {
    return getHandler(DEFAULT_METHOD);
  }

  /**
   * 给节点设置处理器
   */
  bool setHandler(String key, RouteHandler handler) {
    if(_handleMap[key] == null) {
      _handleMap[key] = handler;
      return true;
    }
    return false;
  }

  /**
   * 根据key获取当前节点上的处理器
   */
  RouteHandler getHandler(String key) {
    return _handleMap[key];
  }

  bool get isHandleNode {
    return _handleMap.isNotEmpty;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! RouteNode) return false;
    RouteNode node = other;
    return key == node.key;
  }

  bool get isRoot {
    return null == parent;
  }

  bool get isLeaf {
    return partChildren.isEmpty && paramChildren.isEmpty && wildcardChild == null;
  }

  // 节点类型
  NodeType get type {
    if(key[0] == '*') {
      return NodeType.wildcard;
    } else if(key[0] == ':') {
      return NodeType.param;
    } else {
      return NodeType.part;
    }
  }



  /**
   * 查找或者添加节点，如果当前节点在子节点中可以被匹配到，则拿到对应节点，否则就添加节点到当前节点对应类型的子节点中
   * @param node 要添加的节点
   */
  RouteNode findOrAddChild(final RouteNode node, [String method = DEFAULT_METHOD]) {
    // 在当前节点的子节点中匹配
    RouteNode _node = matchChildNode(node);

    // 如果已经存在当前key标识的节点
    if(_node != null) {
      node.middlewares[method] ??= [];
      // 添加处理器和添加中间件是互斥的操作，同时只会是一种操作
      if(node.middlewares[method].isNotEmpty) { // 这种情况是在添加中间件节点的时候触发
         _node.middlewares[method] ??= [];
        _node.middlewares[method].addAll(node.middlewares[method]);
      } else if(node.getHandler(method) != null && _node.getHandler(method) == null) { // 这种情况是当添加处理器节点的时候触发
        _node.setHandler(method, node.getHandler(method));
      }

      return _node;
    }

    switch(node.type) {
      case NodeType.param:
        paramChildren.add(node);
        break;
      case NodeType.part:
        partChildren[node.key] = node;
        break;
      case NodeType.wildcard:
        wildcardChild = node;
        break;
    }

    return node;
  }

  void _checkHandlerConflict(final RouteNode other, [String method = DEFAULT_METHOD]) {
    if(other != null && getHandler(method) != null && other.getHandler(method) != null) {
      // 抛出路由冲突异常
      throw RouteConflictException(this, other);
    }
  }

  RouteNode matchChildNode(final RouteNode node, [String method = DEFAULT_METHOD]) {
    RouteNode _node;
    switch(node.type) {
      case NodeType.part:
        final RouteNode currentNode = partChildren[node.key];
        if (currentNode != null) {
          node._checkHandlerConflict(currentNode, method);
          _node = currentNode;
        }
        break;
      case NodeType.param:
        // 存在处理函数的节点
        RouteNode hasHandlerNode;
        // 匹配成功的节点
        RouteNode matchNode;
        // 当前循环遍历到的节点
        RouteNode currentNode;
        for(int i = 0, len = paramChildren.length; i < len; i ++) {
          currentNode = paramChildren[i];
          // 获得存在处理函数(handler)的节点
          if(currentNode.getHandler(method) != null) {
            hasHandlerNode = currentNode;
          }
          // 检查匹配，则返回
          if(currentNode == node) {
            matchNode = currentNode;
          }
        }
        // 检查处理函数冲突
        node._checkHandlerConflict(hasHandlerNode, method);
        _node = matchNode;
        break;
      case NodeType.wildcard:
        if(wildcardChild != null) {
          node._checkHandlerConflict(wildcardChild, method);
          _node = wildcardChild;
        }
        
        // currentNode = wildcardChildren;
        // // 存在处理函数的节点
        // RouteNode hasHandlerNode;
        // // 匹配成功的节点
        // RouteNode matchNode;
        // // 当前循环遍历到的节点
        // RouteNode currentNode;
        // for(int i = 0, len = wildcardChildren.length; i < len; i ++) {
        //   currentNode = wildcardChildren[i];
        //   // 获得存在处理函数(handler)的节点
        //   if(currentNode.getHandler(method) != null) {
        //     hasHandlerNode = currentNode;
        //   }
        //   // 检查匹配，则返回
        //   if(currentNode == node) {
        //     matchNode = currentNode;
        //   }
        // }
        // // 检查处理函数冲突
        // node._checkHandlerConflict(hasHandlerNode);
        break;
    }

    return _node;
  }

  /**
   * 路径部分直接匹配
   */
  MatchResult matchPartChildren(final String pathPart) {
    RouteNode node = partChildren[pathPart];

    if(null == node) {
      return null;
    }

    return MatchResult(node);
  }

  /**
   * 参数路由，从给定起始点开始匹配，可能会回溯
   */
  MatchResult matchParamChildren(final String pathPart, int start) {

    // assert(paramChildren.length > start, '待匹配的参数路由节点数必须必起始位置要大');
    // 待匹配的参数路由节点数必须必起始位置要大
    if(paramChildren.length - 1 < start) {
      return null;
    }

    RouteNode node = paramChildren[start];

    if(null == node) {
      return null;
    }

    return MatchResult(node, value: pathPart, nodeIndex: start);
  }

  /**
   * 参数路由，从给定起始点开始匹配，可能会回溯
   */
  MatchResult matchWildcardChild(final String pathPart) {

    // assert(paramChildren.length > start, '待匹配的参数路由节点数必须必起始位置要大');
    // 待匹配的参数路由节点数必须必起始位置要大
    // if(paramChildren.length - 1 < start) {
    //   return null;
    // }

    RouteNode node = wildcardChild;

    if(null == node) {
      return null;
    }

    return MatchResult(node, value: pathPart);
  }

  String get name {
    if(key[0] == '*' || key[0] == ':') {
      return key.substring(1);
    } else {
      return key;
    }
  }

  String get path {
    RouteNode node = this;
    List<String> pathArray = [];
    while(node.parent != null) {
      pathArray.insert(0, node.key);
      pathArray.insert(0, '/');
      node = node.parent;
    }
    return pathArray.join();
  }
}

class MatchResult {
  // 当前节点匹配上的值
  String value;
  // 匹配上的节点
  final RouteNode node;
  // 当前节点的索引
  int nodeIndex;
  // 当前节点下的参数子节点已经匹配到的下标索引
  int paramChildIndex;
  // 文本部分路径子节点是否已匹配过
  bool partChildrenHadMatch = false;
  
  MatchResult(this.node, {this.value = '', this.nodeIndex = 0, this.paramChildIndex = 0});

  bool get paramChildCanBacktracking {
    return paramChildIndex < node.paramChildren.length;
  }

  bool get wildcardCanBacktracking {
    return node.wildcardChild != null;
  }
}
