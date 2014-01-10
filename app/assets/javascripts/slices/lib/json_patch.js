if (JSON && JSON.stringify) {

  JSON.nativeStringify = JSON.stringify;

  JSON.stringify = function(object) {
    return JSON.nativeStringify(object).replace(/\\u000a/g, '\\n');
  }

}
