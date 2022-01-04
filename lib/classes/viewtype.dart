enum Viewtype {
  list,
  grid,
}

extension ParseViewtypes on Viewtype {
  int toInt() {
    switch (this) {
      case Viewtype.list:
        return 0;
      case Viewtype.grid:
        return 1;
      default:
        return -1;
    }
  }
}
