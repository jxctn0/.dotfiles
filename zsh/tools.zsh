pathcat() {
  echo "${1:-$PATH}" | tr ':' '\n'
}
