extension ListExtensions<T> on List<T> {
  T get secondLast {
    return this[length - 2]; // Return the second to last element
  }
}
