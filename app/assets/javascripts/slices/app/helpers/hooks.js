slices.HOOKS = {};

/*
 * Register a slices hook function.
 *
 * @param {String} key
 * @param {Function} fun
 */

slices.on = function(key, fun) {
  slices.HOOKS[key] = slices.HOOKS[key] || [];
  slices.HOOKS[key].push(fun);
};

/*
 * Trigger hooks for key.
 *
 * @param {String} key
 */

slices.trigger = function(key) {
  var hooks = slices.HOOKS[key];
  if (hooks) _.invoke(hooks, 'call');
};
