extension ListExtension<T> on List<T> {
  T removeFirst() {
    return removeAt(0);
  }

  T get secondLast {
    return this[length - 2]; // Return the second to last element
  }
}
