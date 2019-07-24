
class Stack<T> {

  List<T> _data;

  Stack([List<T> data]){
    data ??= [];
    this._data = data.reversed.toList();
  }

  void push(T item) {
    _data.add(item);
  }

  T pop() {
    assert(isNotEmpty, 'Can\'t pop anything, the stack have no element!');

    return _data.removeLast();
  }

  T get top {
    return _data.last;
  }

  String join(final String sep) {
    return _data.reversed.join(sep);
  }

  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;

}