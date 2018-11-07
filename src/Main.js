// This small FFI saves me from importing a large DOM library
exports.document = function() {
  return window.document;
};