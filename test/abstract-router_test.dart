import 'package:abstract_router/abstract-router.dart';
import 'package:test/test.dart';

void main() {
  
  group('Test route handlers', () {
    AbstractRouter router = AbstractRouter();
    test('PartRoute sigle path segment', () {

      router.handle('/user', (RouterContext context) async {
        assert(context.path == '/user');
        assert(context.params.isEmpty);
        assert(context.queries.isEmpty);
        assert(context.routeId == context.path);
      });

      RouterContext context = router.parse('/user');
      context.handler(context);
    });
    test('PartRoute multi path segment', () {
      const String path = '/user/any/path/test';
      router.handle(path, (RouterContext context) async {
        assert(context.path == path);
        assert(context.params.isEmpty);
        assert(context.queries.isEmpty);
        assert(context.routeId == path);
      });

      RouterContext context = router.parse(path);
      context.handler(context);
    });

    test('ParamRoute has some path variables and queries', () {
      const String routeId = '/user/:any/:path/test';
      const String path = '/user/some/param/test?a=1&b=2&b=3';

      router.handle(routeId, (RouterContext context) async {
        assert(context.path == path);
        assert(context.params['any'] == 'some');
        assert(context.params['path'] == 'param');
        assert(context.queries['a'] == '1');
        assert(context.queries['b'] is List<String>);
        assert(context.queries['b'][0] == '2');
        assert(context.queries['b'][1] == '3');
        assert(context.routeId == routeId);
      });

      RouterContext context = router.parse(path);
      context.handler(context);
    });

    test('WildcardRoute has a wildcard at end', () {
      const String routeId = '/user/:any/:path/*somePart';
      const String path = '/user/some/param/test/some/segments/at/end';

      router.handle(routeId, (RouterContext context) async {
        assert(context.path == path);
        assert(context.params['any'] == 'some');
        assert(context.params['path'] == 'param');
        assert(context.params['somePart'] == 'test/some/segments/at/end');
        assert(context.queries.isEmpty);
        assert(context.routeId == routeId);
      });

      RouterContext context = router.parse(path);
      context.handler(context);
    });

  });

  group('Test route middlares', () {
    AbstractRouter router = AbstractRouter();
    test('Some middlewares at some path and middlewares sort', () {
      const String routeId = '/user/:any/:path/*somePart';
      const String routeId1 = '/admin/*somePath';
      const String path = '/user/some/param/test/some/segments/at/end';
      const String path1 = '/admin/abc/def/ghi/jk';

      router.handle(routeId, (RouterContext context) async {
        assert(context.path == path);
        assert(context.params['any'] == 'some');
        assert(context.params['path'] == 'param');
        assert(context.params['somePart'] == 'test/some/segments/at/end');
        assert(context.queries.isEmpty);
        assert(context.routeId == routeId);
      });

      router.handle(routeId1, (RouterContext context) async {
        assert(context.path == path1);
        assert(context.params['somePath'] == 'abc/def/ghi/jk');
        assert(context.queries.isEmpty);
        assert(context.routeId == routeId1);
      });

      List<RouteMiddleware> middlewares = [(RouterContext context) async { print('0'); }, (RouterContext context) async { print('1'); }, (RouterContext context) async { print('2'); }];

      router.use('/admin', middlewares.sublist(0,1));
      router.use('/user/:any', middlewares.sublist(1,2));
      router.use('/user/:any/:path', middlewares.sublist(2));

      RouterContext context = router.parse(path);
      assert(context.middlewares.length == 2);
      assert(context.middlewares[0] == middlewares[1]);
      assert(context.middlewares[1] == middlewares[2]);
      context.handler(context);

      RouterContext context1 = router.parse(path1);
      assert(context1.middlewares.length == 1);
      assert(context1.middlewares[0] == middlewares[0]);
      context1.handler(context1);
    });
  });
}
