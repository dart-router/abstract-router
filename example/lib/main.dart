import 'package:abstract_router/abstract_router.dart';

void main() {
  AbstractRouter router = AbstractRouter();

  router.handle('/user/:id', (RouterContext context) async {
    print('context in handle [/user/:id]  is: ${context}' );
  });

  router.handle('/user/:name/abc', (RouterContext context) async {
    print('context in handle [/user/:name/abc]  is: ${context}' );
  });

  router.use('/user', [middleware1]);
  router.use('/user/:name', [middleware2]);

  print('=======route1=======');

  RouterContext context1 = router.parse('/user/id_is_abcdefg?abc=efg');
  context1.middlewares.forEach((RouteMiddleware middleware) {
    middleware(context1);
  });
  context1.handler(context1);
  print('=======route1 end=======\n');

  print('=======route2=======');
  RouterContext context2 = router.parse('/user/name_is_abcdefg/abc?abc=efg');
  context2.middlewares.forEach((RouteMiddleware middleware) {
    middleware(context2);
  });
  context2.handler(context2);
  print('=======route2 end=======\n');
}

Future<dynamic> middleware1(RouterContext context) async {
  print('context in middleware1: ${context}');
  context.params['middleware1 add some data'] = 'yes';
}

Future<dynamic> middleware2(RouterContext context) async {
  print('context in middleware2: ${context}');
  context.params['middleware2 add some data'] = 'yes';
}
