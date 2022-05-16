(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.br.ad === region.aW.ad)
	{
		return 'on line ' + region.br.ad;
	}
	return 'on lines ' + region.br.ad + ' through ' + region.aW.ad;
}



// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);




// STRINGS


var _Parser_isSubString = F5(function(smallString, offset, row, col, bigString)
{
	var smallLength = smallString.length;
	var isGood = offset + smallLength <= bigString.length;

	for (var i = 0; isGood && i < smallLength; )
	{
		var code = bigString.charCodeAt(offset);
		isGood =
			smallString[i++] === bigString[offset++]
			&& (
				code === 0x000A /* \n */
					? ( row++, col=1 )
					: ( col++, (code & 0xF800) === 0xD800 ? smallString[i++] === bigString[offset++] : 1 )
			)
	}

	return _Utils_Tuple3(isGood ? offset : -1, row, col);
});



// CHARS


var _Parser_isSubChar = F3(function(predicate, offset, string)
{
	return (
		string.length <= offset
			? -1
			:
		(string.charCodeAt(offset) & 0xF800) === 0xD800
			? (predicate(_Utils_chr(string.substr(offset, 2))) ? offset + 2 : -1)
			:
		(predicate(_Utils_chr(string[offset]))
			? ((string[offset] === '\n') ? -2 : (offset + 1))
			: -1
		)
	);
});


var _Parser_isAsciiCode = F3(function(code, offset, string)
{
	return string.charCodeAt(offset) === code;
});



// NUMBERS


var _Parser_chompBase10 = F2(function(offset, string)
{
	for (; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (code < 0x30 || 0x39 < code)
		{
			return offset;
		}
	}
	return offset;
});


var _Parser_consumeBase = F3(function(base, offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var digit = string.charCodeAt(offset) - 0x30;
		if (digit < 0 || base <= digit) break;
		total = base * total + digit;
	}
	return _Utils_Tuple2(offset, total);
});


var _Parser_consumeBase16 = F2(function(offset, string)
{
	for (var total = 0; offset < string.length; offset++)
	{
		var code = string.charCodeAt(offset);
		if (0x30 <= code && code <= 0x39)
		{
			total = 16 * total + code - 0x30;
		}
		else if (0x41 <= code && code <= 0x46)
		{
			total = 16 * total + code - 55;
		}
		else if (0x61 <= code && code <= 0x66)
		{
			total = 16 * total + code - 87;
		}
		else
		{
			break;
		}
	}
	return _Utils_Tuple2(offset, total);
});



// FIND STRING


var _Parser_findSubString = F5(function(smallString, offset, row, col, bigString)
{
	var newOffset = bigString.indexOf(smallString, offset);
	var target = newOffset < 0 ? bigString.length : newOffset + smallString.length;

	while (offset < target)
	{
		var code = bigString.charCodeAt(offset++);
		code === 0x000A /* \n */
			? ( col=1, row++ )
			: ( col++, (code & 0xF800) === 0xD800 && offset++ )
	}

	return _Utils_Tuple3(newOffset, row, col);
});



var _Bitwise_and = F2(function(a, b)
{
	return a & b;
});

var _Bitwise_or = F2(function(a, b)
{
	return a | b;
});

var _Bitwise_xor = F2(function(a, b)
{
	return a ^ b;
});

function _Bitwise_complement(a)
{
	return ~a;
};

var _Bitwise_shiftLeftBy = F2(function(offset, a)
{
	return a << offset;
});

var _Bitwise_shiftRightBy = F2(function(offset, a)
{
	return a >> offset;
});

var _Bitwise_shiftRightZfBy = F2(function(offset, a)
{
	return a >>> offset;
});



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.b_,
		impl.ch,
		impl.ce,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Basics$GT = 2;
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.k) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.m),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.m);
		} else {
			var treeLen = builder.k * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.n) : builder.n;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.k);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.m) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.m);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{n: nodeList, k: (len / $elm$core$Array$branchFactor) | 0, m: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$decodeValue = _Json_run;
var $elm$project_metadata_utils$Elm$Docs$Module = F6(
	function (name, comment, unions, aliases, values, binops) {
		return {Z: aliases, aM: binops, ag: comment, i: name, af: unions, X: values};
	});
var $elm$project_metadata_utils$Elm$Docs$Alias = F4(
	function (name, comment, args, tipe) {
		return {T: args, ag: comment, i: name, ak: tipe};
	});
var $elm$json$Json$Decode$andThen = _Json_andThen;
var $elm$json$Json$Decode$fail = _Json_fail;
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$parser$Parser$DeadEnd = F3(
	function (row, col, problem) {
		return {aO: col, bf: problem, bn: row};
	});
var $elm$parser$Parser$problemToDeadEnd = function (p) {
	return A3($elm$parser$Parser$DeadEnd, p.bn, p.aO, p.bf);
};
var $elm$parser$Parser$Advanced$bagToList = F2(
	function (bag, list) {
		bagToList:
		while (true) {
			switch (bag.$) {
				case 0:
					return list;
				case 1:
					var bag1 = bag.a;
					var x = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$core$List$cons, x, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
				default:
					var bag1 = bag.a;
					var bag2 = bag.b;
					var $temp$bag = bag1,
						$temp$list = A2($elm$parser$Parser$Advanced$bagToList, bag2, list);
					bag = $temp$bag;
					list = $temp$list;
					continue bagToList;
			}
		}
	});
var $elm$parser$Parser$Advanced$run = F2(
	function (_v0, src) {
		var parse = _v0;
		var _v1 = parse(
			{aO: 1, f: _List_Nil, h: 1, e: 0, bn: 1, d: src});
		if (!_v1.$) {
			var value = _v1.b;
			return $elm$core$Result$Ok(value);
		} else {
			var bag = _v1.b;
			return $elm$core$Result$Err(
				A2($elm$parser$Parser$Advanced$bagToList, bag, _List_Nil));
		}
	});
var $elm$parser$Parser$run = F2(
	function (parser, source) {
		var _v0 = A2($elm$parser$Parser$Advanced$run, parser, source);
		if (!_v0.$) {
			var a = _v0.a;
			return $elm$core$Result$Ok(a);
		} else {
			var problems = _v0.a;
			return $elm$core$Result$Err(
				A2($elm$core$List$map, $elm$parser$Parser$problemToDeadEnd, problems));
		}
	});
var $elm$parser$Parser$Done = function (a) {
	return {$: 1, a: a};
};
var $elm$parser$Parser$Forbidden = 0;
var $elm$project_metadata_utils$Elm$Type$Lambda = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$parser$Parser$Loop = function (a) {
	return {$: 0, a: a};
};
var $elm$project_metadata_utils$Elm$Type$Record = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $elm$project_metadata_utils$Elm$Type$Type = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$project_metadata_utils$Elm$Type$Var = function (a) {
	return {$: 0, a: a};
};
var $elm$parser$Parser$Advanced$Bad = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$Good = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$parser$Parser$Advanced$Parser = $elm$core$Basics$identity;
var $elm$parser$Parser$Advanced$andThen = F2(
	function (callback, _v0) {
		var parseA = _v0;
		return function (s0) {
			var _v1 = parseA(s0);
			if (_v1.$ === 1) {
				var p = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p1 = _v1.a;
				var a = _v1.b;
				var s1 = _v1.c;
				var _v2 = callback(a);
				var parseB = _v2;
				var _v3 = parseB(s1);
				if (_v3.$ === 1) {
					var p2 = _v3.a;
					var x = _v3.b;
					return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
				} else {
					var p2 = _v3.a;
					var b = _v3.b;
					var s2 = _v3.c;
					return A3($elm$parser$Parser$Advanced$Good, p1 || p2, b, s2);
				}
			}
		};
	});
var $elm$parser$Parser$andThen = $elm$parser$Parser$Advanced$andThen;
var $elm$parser$Parser$ExpectingSymbol = function (a) {
	return {$: 8, a: a};
};
var $elm$parser$Parser$Advanced$Token = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$AddRight = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$DeadEnd = F4(
	function (row, col, problem, contextStack) {
		return {aO: col, bQ: contextStack, bf: problem, bn: row};
	});
var $elm$parser$Parser$Advanced$Empty = {$: 0};
var $elm$parser$Parser$Advanced$fromState = F2(
	function (s, x) {
		return A2(
			$elm$parser$Parser$Advanced$AddRight,
			$elm$parser$Parser$Advanced$Empty,
			A4($elm$parser$Parser$Advanced$DeadEnd, s.bn, s.aO, x, s.f));
	});
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$parser$Parser$Advanced$isSubString = _Parser_isSubString;
var $elm$core$Basics$negate = function (n) {
	return -n;
};
var $elm$core$Basics$not = _Basics_not;
var $elm$parser$Parser$Advanced$token = function (_v0) {
	var str = _v0.a;
	var expecting = _v0.b;
	var progress = !$elm$core$String$isEmpty(str);
	return function (s) {
		var _v1 = A5($elm$parser$Parser$Advanced$isSubString, str, s.e, s.bn, s.aO, s.d);
		var newOffset = _v1.a;
		var newRow = _v1.b;
		var newCol = _v1.c;
		return _Utils_eq(newOffset, -1) ? A2(
			$elm$parser$Parser$Advanced$Bad,
			false,
			A2($elm$parser$Parser$Advanced$fromState, s, expecting)) : A3(
			$elm$parser$Parser$Advanced$Good,
			progress,
			0,
			{aO: newCol, f: s.f, h: s.h, e: newOffset, bn: newRow, d: s.d});
	};
};
var $elm$parser$Parser$Advanced$symbol = $elm$parser$Parser$Advanced$token;
var $elm$parser$Parser$symbol = function (str) {
	return $elm$parser$Parser$Advanced$symbol(
		A2(
			$elm$parser$Parser$Advanced$Token,
			str,
			$elm$parser$Parser$ExpectingSymbol(str)));
};
var $elm$project_metadata_utils$Elm$Type$arrow = $elm$parser$Parser$symbol('->');
var $elm$parser$Parser$Advanced$backtrackable = function (_v0) {
	var parse = _v0;
	return function (s0) {
		var _v1 = parse(s0);
		if (_v1.$ === 1) {
			var x = _v1.b;
			return A2($elm$parser$Parser$Advanced$Bad, false, x);
		} else {
			var a = _v1.b;
			var s1 = _v1.c;
			return A3($elm$parser$Parser$Advanced$Good, false, a, s1);
		}
	};
};
var $elm$parser$Parser$backtrackable = $elm$parser$Parser$Advanced$backtrackable;
var $elm$project_metadata_utils$Elm$Type$comma = $elm$parser$Parser$symbol(',');
var $elm$core$Basics$always = F2(
	function (a, _v0) {
		return a;
	});
var $elm$parser$Parser$Advanced$map2 = F3(
	function (func, _v0, _v1) {
		var parseA = _v0;
		var parseB = _v1;
		return function (s0) {
			var _v2 = parseA(s0);
			if (_v2.$ === 1) {
				var p = _v2.a;
				var x = _v2.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p1 = _v2.a;
				var a = _v2.b;
				var s1 = _v2.c;
				var _v3 = parseB(s1);
				if (_v3.$ === 1) {
					var p2 = _v3.a;
					var x = _v3.b;
					return A2($elm$parser$Parser$Advanced$Bad, p1 || p2, x);
				} else {
					var p2 = _v3.a;
					var b = _v3.b;
					var s2 = _v3.c;
					return A3(
						$elm$parser$Parser$Advanced$Good,
						p1 || p2,
						A2(func, a, b),
						s2);
				}
			}
		};
	});
var $elm$parser$Parser$Advanced$ignorer = F2(
	function (keepParser, ignoreParser) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$always, keepParser, ignoreParser);
	});
var $elm$parser$Parser$ignorer = $elm$parser$Parser$Advanced$ignorer;
var $elm$parser$Parser$Advanced$keeper = F2(
	function (parseFunc, parseArg) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$core$Basics$apL, parseFunc, parseArg);
	});
var $elm$parser$Parser$keeper = $elm$parser$Parser$Advanced$keeper;
var $elm$core$Set$Set_elm_builtin = $elm$core$Basics$identity;
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$core$Set$empty = $elm$core$Dict$empty;
var $elm$project_metadata_utils$Elm$Type$isInnerVarChar = function (_char) {
	return $elm$core$Char$isAlphaNum(_char) || (_char === '_');
};
var $elm$parser$Parser$ExpectingVariable = {$: 7};
var $elm$parser$Parser$Advanced$isSubChar = _Parser_isSubChar;
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$member = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$get, key, dict);
		if (!_v0.$) {
			return true;
		} else {
			return false;
		}
	});
var $elm$core$Set$member = F2(
	function (key, _v0) {
		var dict = _v0;
		return A2($elm$core$Dict$member, key, dict);
	});
var $elm$core$String$slice = _String_slice;
var $elm$parser$Parser$Advanced$varHelp = F7(
	function (isGood, offset, row, col, src, indent, context) {
		varHelp:
		while (true) {
			var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, offset, src);
			if (_Utils_eq(newOffset, -1)) {
				return {aO: col, f: context, h: indent, e: offset, bn: row, d: src};
			} else {
				if (_Utils_eq(newOffset, -2)) {
					var $temp$isGood = isGood,
						$temp$offset = offset + 1,
						$temp$row = row + 1,
						$temp$col = 1,
						$temp$src = src,
						$temp$indent = indent,
						$temp$context = context;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					src = $temp$src;
					indent = $temp$indent;
					context = $temp$context;
					continue varHelp;
				} else {
					var $temp$isGood = isGood,
						$temp$offset = newOffset,
						$temp$row = row,
						$temp$col = col + 1,
						$temp$src = src,
						$temp$indent = indent,
						$temp$context = context;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					src = $temp$src;
					indent = $temp$indent;
					context = $temp$context;
					continue varHelp;
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$variable = function (i) {
	return function (s) {
		var firstOffset = A3($elm$parser$Parser$Advanced$isSubChar, i.br, s.e, s.d);
		if (_Utils_eq(firstOffset, -1)) {
			return A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, i.aY));
		} else {
			var s1 = _Utils_eq(firstOffset, -2) ? A7($elm$parser$Parser$Advanced$varHelp, i.a4, s.e + 1, s.bn + 1, 1, s.d, s.h, s.f) : A7($elm$parser$Parser$Advanced$varHelp, i.a4, firstOffset, s.bn, s.aO + 1, s.d, s.h, s.f);
			var name = A3($elm$core$String$slice, s.e, s1.e, s.d);
			return A2($elm$core$Set$member, name, i.bm) ? A2(
				$elm$parser$Parser$Advanced$Bad,
				false,
				A2($elm$parser$Parser$Advanced$fromState, s, i.aY)) : A3($elm$parser$Parser$Advanced$Good, true, name, s1);
		}
	};
};
var $elm$parser$Parser$variable = function (i) {
	return $elm$parser$Parser$Advanced$variable(
		{aY: $elm$parser$Parser$ExpectingVariable, a4: i.a4, bm: i.bm, br: i.br});
};
var $elm$project_metadata_utils$Elm$Type$var = function (isFirst) {
	return $elm$parser$Parser$variable(
		{a4: $elm$project_metadata_utils$Elm$Type$isInnerVarChar, bm: $elm$core$Set$empty, br: isFirst});
};
var $elm$project_metadata_utils$Elm$Type$lowVar = $elm$project_metadata_utils$Elm$Type$var($elm$core$Char$isLower);
var $elm$parser$Parser$Advanced$Append = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $elm$parser$Parser$Advanced$oneOfHelp = F3(
	function (s0, bag, parsers) {
		oneOfHelp:
		while (true) {
			if (!parsers.b) {
				return A2($elm$parser$Parser$Advanced$Bad, false, bag);
			} else {
				var parse = parsers.a;
				var remainingParsers = parsers.b;
				var _v1 = parse(s0);
				if (!_v1.$) {
					var step = _v1;
					return step;
				} else {
					var step = _v1;
					var p = step.a;
					var x = step.b;
					if (p) {
						return step;
					} else {
						var $temp$s0 = s0,
							$temp$bag = A2($elm$parser$Parser$Advanced$Append, bag, x),
							$temp$parsers = remainingParsers;
						s0 = $temp$s0;
						bag = $temp$bag;
						parsers = $temp$parsers;
						continue oneOfHelp;
					}
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$oneOf = function (parsers) {
	return function (s) {
		return A3($elm$parser$Parser$Advanced$oneOfHelp, s, $elm$parser$Parser$Advanced$Empty, parsers);
	};
};
var $elm$parser$Parser$oneOf = $elm$parser$Parser$Advanced$oneOf;
var $elm$parser$Parser$Advanced$chompWhileHelp = F5(
	function (isGood, offset, row, col, s0) {
		chompWhileHelp:
		while (true) {
			var newOffset = A3($elm$parser$Parser$Advanced$isSubChar, isGood, offset, s0.d);
			if (_Utils_eq(newOffset, -1)) {
				return A3(
					$elm$parser$Parser$Advanced$Good,
					_Utils_cmp(s0.e, offset) < 0,
					0,
					{aO: col, f: s0.f, h: s0.h, e: offset, bn: row, d: s0.d});
			} else {
				if (_Utils_eq(newOffset, -2)) {
					var $temp$isGood = isGood,
						$temp$offset = offset + 1,
						$temp$row = row + 1,
						$temp$col = 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				} else {
					var $temp$isGood = isGood,
						$temp$offset = newOffset,
						$temp$row = row,
						$temp$col = col + 1,
						$temp$s0 = s0;
					isGood = $temp$isGood;
					offset = $temp$offset;
					row = $temp$row;
					col = $temp$col;
					s0 = $temp$s0;
					continue chompWhileHelp;
				}
			}
		}
	});
var $elm$parser$Parser$Advanced$chompWhile = function (isGood) {
	return function (s) {
		return A5($elm$parser$Parser$Advanced$chompWhileHelp, isGood, s.e, s.bn, s.aO, s);
	};
};
var $elm$parser$Parser$chompWhile = $elm$parser$Parser$Advanced$chompWhile;
var $elm$project_metadata_utils$Elm$Type$spaces = $elm$parser$Parser$chompWhile(
	function (_char) {
		return _char === ' ';
	});
var $elm$parser$Parser$Advanced$succeed = function (a) {
	return function (s) {
		return A3($elm$parser$Parser$Advanced$Good, false, a, s);
	};
};
var $elm$parser$Parser$succeed = $elm$parser$Parser$Advanced$succeed;
var $elm$project_metadata_utils$Elm$Type$extension = $elm$parser$Parser$oneOf(
	_List_fromArray(
		[
			A2(
			$elm$parser$Parser$keeper,
			$elm$parser$Parser$succeed($elm$core$Maybe$Just),
			A2(
				$elm$parser$Parser$ignorer,
				A2(
					$elm$parser$Parser$ignorer,
					A2(
						$elm$parser$Parser$ignorer,
						$elm$parser$Parser$backtrackable($elm$project_metadata_utils$Elm$Type$lowVar),
						$elm$parser$Parser$backtrackable($elm$project_metadata_utils$Elm$Type$spaces)),
					$elm$parser$Parser$symbol('|')),
				$elm$project_metadata_utils$Elm$Type$spaces)),
			$elm$parser$Parser$succeed($elm$core$Maybe$Nothing)
		]));
var $elm$parser$Parser$Advanced$lazy = function (thunk) {
	return function (s) {
		var _v0 = thunk(0);
		var parse = _v0;
		return parse(s);
	};
};
var $elm$parser$Parser$lazy = $elm$parser$Parser$Advanced$lazy;
var $elm$parser$Parser$Advanced$loopHelp = F4(
	function (p, state, callback, s0) {
		loopHelp:
		while (true) {
			var _v0 = callback(state);
			var parse = _v0;
			var _v1 = parse(s0);
			if (!_v1.$) {
				var p1 = _v1.a;
				var step = _v1.b;
				var s1 = _v1.c;
				if (!step.$) {
					var newState = step.a;
					var $temp$p = p || p1,
						$temp$state = newState,
						$temp$callback = callback,
						$temp$s0 = s1;
					p = $temp$p;
					state = $temp$state;
					callback = $temp$callback;
					s0 = $temp$s0;
					continue loopHelp;
				} else {
					var result = step.a;
					return A3($elm$parser$Parser$Advanced$Good, p || p1, result, s1);
				}
			} else {
				var p1 = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p || p1, x);
			}
		}
	});
var $elm$parser$Parser$Advanced$loop = F2(
	function (state, callback) {
		return function (s) {
			return A4($elm$parser$Parser$Advanced$loopHelp, false, state, callback, s);
		};
	});
var $elm$parser$Parser$Advanced$map = F2(
	function (func, _v0) {
		var parse = _v0;
		return function (s0) {
			var _v1 = parse(s0);
			if (!_v1.$) {
				var p = _v1.a;
				var a = _v1.b;
				var s1 = _v1.c;
				return A3(
					$elm$parser$Parser$Advanced$Good,
					p,
					func(a),
					s1);
			} else {
				var p = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			}
		};
	});
var $elm$parser$Parser$map = $elm$parser$Parser$Advanced$map;
var $elm$parser$Parser$Advanced$Done = function (a) {
	return {$: 1, a: a};
};
var $elm$parser$Parser$Advanced$Loop = function (a) {
	return {$: 0, a: a};
};
var $elm$parser$Parser$toAdvancedStep = function (step) {
	if (!step.$) {
		var s = step.a;
		return $elm$parser$Parser$Advanced$Loop(s);
	} else {
		var a = step.a;
		return $elm$parser$Parser$Advanced$Done(a);
	}
};
var $elm$parser$Parser$loop = F2(
	function (state, callback) {
		return A2(
			$elm$parser$Parser$Advanced$loop,
			state,
			function (s) {
				return A2(
					$elm$parser$Parser$map,
					$elm$parser$Parser$toAdvancedStep,
					callback(s));
			});
	});
var $elm$core$Tuple$pair = F2(
	function (a, b) {
		return _Utils_Tuple2(a, b);
	});
var $elm$project_metadata_utils$Elm$Type$capVar = $elm$project_metadata_utils$Elm$Type$var($elm$core$Char$isUpper);
var $elm$parser$Parser$Advanced$mapChompedString = F2(
	function (func, _v0) {
		var parse = _v0;
		return function (s0) {
			var _v1 = parse(s0);
			if (_v1.$ === 1) {
				var p = _v1.a;
				var x = _v1.b;
				return A2($elm$parser$Parser$Advanced$Bad, p, x);
			} else {
				var p = _v1.a;
				var a = _v1.b;
				var s1 = _v1.c;
				return A3(
					$elm$parser$Parser$Advanced$Good,
					p,
					A2(
						func,
						A3($elm$core$String$slice, s0.e, s1.e, s0.d),
						a),
					s1);
			}
		};
	});
var $elm$parser$Parser$Advanced$getChompedString = function (parser) {
	return A2($elm$parser$Parser$Advanced$mapChompedString, $elm$core$Basics$always, parser);
};
var $elm$parser$Parser$getChompedString = $elm$parser$Parser$Advanced$getChompedString;
var $elm$project_metadata_utils$Elm$Type$qualifiedCapVarHelp = function (_v0) {
	return $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$ignorer,
				A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed(
						$elm$parser$Parser$Loop(0)),
					$elm$parser$Parser$symbol('.')),
				$elm$project_metadata_utils$Elm$Type$capVar),
				$elm$parser$Parser$succeed(
				$elm$parser$Parser$Done(0))
			]));
};
var $elm$project_metadata_utils$Elm$Type$qualifiedCapVar = $elm$parser$Parser$getChompedString(
	A2(
		$elm$parser$Parser$ignorer,
		$elm$project_metadata_utils$Elm$Type$capVar,
		A2($elm$parser$Parser$loop, 0, $elm$project_metadata_utils$Elm$Type$qualifiedCapVarHelp)));
var $elm$parser$Parser$Advanced$revAlways = F2(
	function (_v0, b) {
		return b;
	});
var $elm$parser$Parser$Advanced$skip = F2(
	function (iParser, kParser) {
		return A3($elm$parser$Parser$Advanced$map2, $elm$parser$Parser$Advanced$revAlways, iParser, kParser);
	});
var $elm$parser$Parser$Advanced$sequenceEndForbidden = F5(
	function (ender, ws, parseItem, sep, revItems) {
		var chompRest = function (item) {
			return A5(
				$elm$parser$Parser$Advanced$sequenceEndForbidden,
				ender,
				ws,
				parseItem,
				sep,
				A2($elm$core$List$cons, item, revItems));
		};
		return A2(
			$elm$parser$Parser$Advanced$skip,
			ws,
			$elm$parser$Parser$Advanced$oneOf(
				_List_fromArray(
					[
						A2(
						$elm$parser$Parser$Advanced$skip,
						sep,
						A2(
							$elm$parser$Parser$Advanced$skip,
							ws,
							A2(
								$elm$parser$Parser$Advanced$map,
								function (item) {
									return $elm$parser$Parser$Advanced$Loop(
										A2($elm$core$List$cons, item, revItems));
								},
								parseItem))),
						A2(
						$elm$parser$Parser$Advanced$map,
						function (_v0) {
							return $elm$parser$Parser$Advanced$Done(
								$elm$core$List$reverse(revItems));
						},
						ender)
					])));
	});
var $elm$parser$Parser$Advanced$sequenceEndMandatory = F4(
	function (ws, parseItem, sep, revItems) {
		return $elm$parser$Parser$Advanced$oneOf(
			_List_fromArray(
				[
					A2(
					$elm$parser$Parser$Advanced$map,
					function (item) {
						return $elm$parser$Parser$Advanced$Loop(
							A2($elm$core$List$cons, item, revItems));
					},
					A2(
						$elm$parser$Parser$Advanced$ignorer,
						parseItem,
						A2(
							$elm$parser$Parser$Advanced$ignorer,
							ws,
							A2($elm$parser$Parser$Advanced$ignorer, sep, ws)))),
					A2(
					$elm$parser$Parser$Advanced$map,
					function (_v0) {
						return $elm$parser$Parser$Advanced$Done(
							$elm$core$List$reverse(revItems));
					},
					$elm$parser$Parser$Advanced$succeed(0))
				]));
	});
var $elm$parser$Parser$Advanced$sequenceEndOptional = F5(
	function (ender, ws, parseItem, sep, revItems) {
		var parseEnd = A2(
			$elm$parser$Parser$Advanced$map,
			function (_v0) {
				return $elm$parser$Parser$Advanced$Done(
					$elm$core$List$reverse(revItems));
			},
			ender);
		return A2(
			$elm$parser$Parser$Advanced$skip,
			ws,
			$elm$parser$Parser$Advanced$oneOf(
				_List_fromArray(
					[
						A2(
						$elm$parser$Parser$Advanced$skip,
						sep,
						A2(
							$elm$parser$Parser$Advanced$skip,
							ws,
							$elm$parser$Parser$Advanced$oneOf(
								_List_fromArray(
									[
										A2(
										$elm$parser$Parser$Advanced$map,
										function (item) {
											return $elm$parser$Parser$Advanced$Loop(
												A2($elm$core$List$cons, item, revItems));
										},
										parseItem),
										parseEnd
									])))),
						parseEnd
					])));
	});
var $elm$parser$Parser$Advanced$sequenceEnd = F5(
	function (ender, ws, parseItem, sep, trailing) {
		var chompRest = function (item) {
			switch (trailing) {
				case 0:
					return A2(
						$elm$parser$Parser$Advanced$loop,
						_List_fromArray(
							[item]),
						A4($elm$parser$Parser$Advanced$sequenceEndForbidden, ender, ws, parseItem, sep));
				case 1:
					return A2(
						$elm$parser$Parser$Advanced$loop,
						_List_fromArray(
							[item]),
						A4($elm$parser$Parser$Advanced$sequenceEndOptional, ender, ws, parseItem, sep));
				default:
					return A2(
						$elm$parser$Parser$Advanced$ignorer,
						A2(
							$elm$parser$Parser$Advanced$skip,
							ws,
							A2(
								$elm$parser$Parser$Advanced$skip,
								sep,
								A2(
									$elm$parser$Parser$Advanced$skip,
									ws,
									A2(
										$elm$parser$Parser$Advanced$loop,
										_List_fromArray(
											[item]),
										A3($elm$parser$Parser$Advanced$sequenceEndMandatory, ws, parseItem, sep))))),
						ender);
			}
		};
		return $elm$parser$Parser$Advanced$oneOf(
			_List_fromArray(
				[
					A2($elm$parser$Parser$Advanced$andThen, chompRest, parseItem),
					A2(
					$elm$parser$Parser$Advanced$map,
					function (_v0) {
						return _List_Nil;
					},
					ender)
				]));
	});
var $elm$parser$Parser$Advanced$sequence = function (i) {
	return A2(
		$elm$parser$Parser$Advanced$skip,
		$elm$parser$Parser$Advanced$token(i.br),
		A2(
			$elm$parser$Parser$Advanced$skip,
			i.bq,
			A5(
				$elm$parser$Parser$Advanced$sequenceEnd,
				$elm$parser$Parser$Advanced$token(i.aW),
				i.bq,
				i.a6,
				$elm$parser$Parser$Advanced$token(i.bp),
				i.bA)));
};
var $elm$parser$Parser$Advanced$Forbidden = 0;
var $elm$parser$Parser$Advanced$Mandatory = 2;
var $elm$parser$Parser$Advanced$Optional = 1;
var $elm$parser$Parser$toAdvancedTrailing = function (trailing) {
	switch (trailing) {
		case 0:
			return 0;
		case 1:
			return 1;
		default:
			return 2;
	}
};
var $elm$parser$Parser$Expecting = function (a) {
	return {$: 0, a: a};
};
var $elm$parser$Parser$toToken = function (str) {
	return A2(
		$elm$parser$Parser$Advanced$Token,
		str,
		$elm$parser$Parser$Expecting(str));
};
var $elm$parser$Parser$sequence = function (i) {
	return $elm$parser$Parser$Advanced$sequence(
		{
			aW: $elm$parser$Parser$toToken(i.aW),
			a6: i.a6,
			bp: $elm$parser$Parser$toToken(i.bp),
			bq: i.bq,
			br: $elm$parser$Parser$toToken(i.br),
			bA: $elm$parser$Parser$toAdvancedTrailing(i.bA)
		});
};
var $elm$project_metadata_utils$Elm$Type$Tuple = function (a) {
	return {$: 2, a: a};
};
var $elm$project_metadata_utils$Elm$Type$tuplize = function (args) {
	if (args.b && (!args.b.b)) {
		var arg = args.a;
		return arg;
	} else {
		return $elm$project_metadata_utils$Elm$Type$Tuple(args);
	}
};
var $elm$project_metadata_utils$Elm$Type$chompArgs = function (revArgs) {
	return $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$map,
				function (arg) {
					return $elm$parser$Parser$Loop(
						A2($elm$core$List$cons, arg, revArgs));
				},
				A2(
					$elm$parser$Parser$keeper,
					A2(
						$elm$parser$Parser$ignorer,
						$elm$parser$Parser$succeed($elm$core$Basics$identity),
						$elm$parser$Parser$backtrackable($elm$project_metadata_utils$Elm$Type$spaces)),
					$elm$project_metadata_utils$Elm$Type$cyclic$term())),
				A2(
				$elm$parser$Parser$map,
				function (_v2) {
					return $elm$parser$Parser$Done(
						$elm$core$List$reverse(revArgs));
				},
				$elm$parser$Parser$succeed(0))
			]));
};
var $elm$project_metadata_utils$Elm$Type$recordEndHelp = function (revFields) {
	return $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$keeper,
				A2(
					$elm$parser$Parser$ignorer,
					A2(
						$elm$parser$Parser$ignorer,
						$elm$parser$Parser$succeed(
							function (f) {
								return $elm$parser$Parser$Loop(
									A2($elm$core$List$cons, f, revFields));
							}),
						$elm$project_metadata_utils$Elm$Type$comma),
					$elm$project_metadata_utils$Elm$Type$spaces),
				A2(
					$elm$parser$Parser$ignorer,
					$elm$project_metadata_utils$Elm$Type$cyclic$field(),
					$elm$project_metadata_utils$Elm$Type$spaces)),
				A2(
				$elm$parser$Parser$keeper,
				$elm$parser$Parser$succeed(
					function (_v1) {
						return $elm$parser$Parser$Done(
							$elm$core$List$reverse(revFields));
					}),
				$elm$parser$Parser$symbol('}'))
			]));
};
var $elm$project_metadata_utils$Elm$Type$tipeHelp = function (t) {
	return $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$map,
				$elm$project_metadata_utils$Elm$Type$Lambda(t),
				$elm$project_metadata_utils$Elm$Type$cyclic$arrowAndType()),
				$elm$parser$Parser$succeed(t)
			]));
};
function $elm$project_metadata_utils$Elm$Type$cyclic$arrowAndType() {
	return A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$ignorer,
			A2(
				$elm$parser$Parser$ignorer,
				A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed($elm$core$Basics$identity),
					$elm$parser$Parser$backtrackable($elm$project_metadata_utils$Elm$Type$spaces)),
				$elm$project_metadata_utils$Elm$Type$arrow),
			$elm$project_metadata_utils$Elm$Type$spaces),
		$elm$project_metadata_utils$Elm$Type$cyclic$tipe());
}
function $elm$project_metadata_utils$Elm$Type$cyclic$tipeTerm() {
	return $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				A2($elm$parser$Parser$map, $elm$project_metadata_utils$Elm$Type$Var, $elm$project_metadata_utils$Elm$Type$lowVar),
				A2(
				$elm$parser$Parser$keeper,
				A2(
					$elm$parser$Parser$keeper,
					$elm$parser$Parser$succeed($elm$project_metadata_utils$Elm$Type$Type),
					$elm$project_metadata_utils$Elm$Type$qualifiedCapVar),
				A2($elm$parser$Parser$loop, _List_Nil, $elm$project_metadata_utils$Elm$Type$chompArgs)),
				$elm$project_metadata_utils$Elm$Type$cyclic$record(),
				$elm$project_metadata_utils$Elm$Type$cyclic$tuple()
			]));
}
function $elm$project_metadata_utils$Elm$Type$cyclic$term() {
	return $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				A2($elm$parser$Parser$map, $elm$project_metadata_utils$Elm$Type$Var, $elm$project_metadata_utils$Elm$Type$lowVar),
				A2(
				$elm$parser$Parser$map,
				function (name) {
					return A2($elm$project_metadata_utils$Elm$Type$Type, name, _List_Nil);
				},
				$elm$project_metadata_utils$Elm$Type$qualifiedCapVar),
				$elm$project_metadata_utils$Elm$Type$cyclic$record(),
				$elm$project_metadata_utils$Elm$Type$cyclic$tuple()
			]));
}
function $elm$project_metadata_utils$Elm$Type$cyclic$record() {
	return A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			A2(
				$elm$parser$Parser$ignorer,
				A2(
					$elm$parser$Parser$ignorer,
					$elm$parser$Parser$succeed(
						F2(
							function (ext, fs) {
								return A2($elm$project_metadata_utils$Elm$Type$Record, fs, ext);
							})),
					$elm$parser$Parser$symbol('{')),
				$elm$project_metadata_utils$Elm$Type$spaces),
			$elm$project_metadata_utils$Elm$Type$extension),
		$elm$project_metadata_utils$Elm$Type$cyclic$recordEnd());
}
function $elm$project_metadata_utils$Elm$Type$cyclic$recordEnd() {
	return $elm$parser$Parser$oneOf(
		_List_fromArray(
			[
				A2(
				$elm$parser$Parser$andThen,
				function (f) {
					return A2(
						$elm$parser$Parser$loop,
						_List_fromArray(
							[f]),
						$elm$project_metadata_utils$Elm$Type$recordEndHelp);
				},
				A2(
					$elm$parser$Parser$ignorer,
					$elm$project_metadata_utils$Elm$Type$cyclic$field(),
					$elm$project_metadata_utils$Elm$Type$spaces)),
				A2(
				$elm$parser$Parser$ignorer,
				$elm$parser$Parser$succeed(_List_Nil),
				$elm$parser$Parser$symbol('}'))
			]));
}
function $elm$project_metadata_utils$Elm$Type$cyclic$field() {
	return A2(
		$elm$parser$Parser$keeper,
		A2(
			$elm$parser$Parser$keeper,
			$elm$parser$Parser$succeed($elm$core$Tuple$pair),
			A2(
				$elm$parser$Parser$ignorer,
				A2(
					$elm$parser$Parser$ignorer,
					A2($elm$parser$Parser$ignorer, $elm$project_metadata_utils$Elm$Type$lowVar, $elm$project_metadata_utils$Elm$Type$spaces),
					$elm$parser$Parser$symbol(':')),
				$elm$project_metadata_utils$Elm$Type$spaces)),
		$elm$project_metadata_utils$Elm$Type$cyclic$tipe());
}
function $elm$project_metadata_utils$Elm$Type$cyclic$tuple() {
	return A2(
		$elm$parser$Parser$map,
		$elm$project_metadata_utils$Elm$Type$tuplize,
		$elm$parser$Parser$sequence(
			{
				aW: ')',
				a6: $elm$project_metadata_utils$Elm$Type$cyclic$tipe(),
				bp: ',',
				bq: $elm$project_metadata_utils$Elm$Type$spaces,
				br: '(',
				bA: 0
			}));
}
function $elm$project_metadata_utils$Elm$Type$cyclic$tipe() {
	return $elm$parser$Parser$lazy(
		function (_v0) {
			return A2(
				$elm$parser$Parser$andThen,
				$elm$project_metadata_utils$Elm$Type$tipeHelp,
				$elm$project_metadata_utils$Elm$Type$cyclic$tipeTerm());
		});
}
var $elm$project_metadata_utils$Elm$Type$arrowAndType = $elm$project_metadata_utils$Elm$Type$cyclic$arrowAndType();
$elm$project_metadata_utils$Elm$Type$cyclic$arrowAndType = function () {
	return $elm$project_metadata_utils$Elm$Type$arrowAndType;
};
var $elm$project_metadata_utils$Elm$Type$tipeTerm = $elm$project_metadata_utils$Elm$Type$cyclic$tipeTerm();
$elm$project_metadata_utils$Elm$Type$cyclic$tipeTerm = function () {
	return $elm$project_metadata_utils$Elm$Type$tipeTerm;
};
var $elm$project_metadata_utils$Elm$Type$term = $elm$project_metadata_utils$Elm$Type$cyclic$term();
$elm$project_metadata_utils$Elm$Type$cyclic$term = function () {
	return $elm$project_metadata_utils$Elm$Type$term;
};
var $elm$project_metadata_utils$Elm$Type$record = $elm$project_metadata_utils$Elm$Type$cyclic$record();
$elm$project_metadata_utils$Elm$Type$cyclic$record = function () {
	return $elm$project_metadata_utils$Elm$Type$record;
};
var $elm$project_metadata_utils$Elm$Type$recordEnd = $elm$project_metadata_utils$Elm$Type$cyclic$recordEnd();
$elm$project_metadata_utils$Elm$Type$cyclic$recordEnd = function () {
	return $elm$project_metadata_utils$Elm$Type$recordEnd;
};
var $elm$project_metadata_utils$Elm$Type$field = $elm$project_metadata_utils$Elm$Type$cyclic$field();
$elm$project_metadata_utils$Elm$Type$cyclic$field = function () {
	return $elm$project_metadata_utils$Elm$Type$field;
};
var $elm$project_metadata_utils$Elm$Type$tuple = $elm$project_metadata_utils$Elm$Type$cyclic$tuple();
$elm$project_metadata_utils$Elm$Type$cyclic$tuple = function () {
	return $elm$project_metadata_utils$Elm$Type$tuple;
};
var $elm$project_metadata_utils$Elm$Type$tipe = $elm$project_metadata_utils$Elm$Type$cyclic$tipe();
$elm$project_metadata_utils$Elm$Type$cyclic$tipe = function () {
	return $elm$project_metadata_utils$Elm$Type$tipe;
};
var $elm$project_metadata_utils$Elm$Type$parse = function (source) {
	return A2($elm$parser$Parser$run, $elm$project_metadata_utils$Elm$Type$tipe, source);
};
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$project_metadata_utils$Elm$Type$decoderHelp = function (string) {
	var _v0 = $elm$project_metadata_utils$Elm$Type$parse(string);
	if (_v0.$ === 1) {
		var error = _v0.a;
		return $elm$json$Json$Decode$fail('TODO');
	} else {
		var actualType = _v0.a;
		return $elm$json$Json$Decode$succeed(actualType);
	}
};
var $elm$json$Json$Decode$string = _Json_decodeString;
var $elm$project_metadata_utils$Elm$Type$decoder = A2($elm$json$Json$Decode$andThen, $elm$project_metadata_utils$Elm$Type$decoderHelp, $elm$json$Json$Decode$string);
var $elm$json$Json$Decode$field = _Json_decodeField;
var $elm$json$Json$Decode$list = _Json_decodeList;
var $elm$json$Json$Decode$map4 = _Json_map4;
var $elm$project_metadata_utils$Elm$Docs$aliasDecoder = A5(
	$elm$json$Json$Decode$map4,
	$elm$project_metadata_utils$Elm$Docs$Alias,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'comment', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$field,
		'args',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string)),
	A2($elm$json$Json$Decode$field, 'type', $elm$project_metadata_utils$Elm$Type$decoder));
var $elm$project_metadata_utils$Elm$Docs$Binop = F5(
	function (name, comment, tipe, associativity, precedence) {
		return {bJ: associativity, ag: comment, i: name, P: precedence, ak: tipe};
	});
var $elm$project_metadata_utils$Elm$Docs$Left = 0;
var $elm$project_metadata_utils$Elm$Docs$None = 1;
var $elm$project_metadata_utils$Elm$Docs$Right = 2;
var $elm$project_metadata_utils$Elm$Docs$toAssoc = function (str) {
	switch (str) {
		case 'left':
			return $elm$json$Json$Decode$succeed(0);
		case 'non':
			return $elm$json$Json$Decode$succeed(1);
		case 'right':
			return $elm$json$Json$Decode$succeed(2);
		default:
			return $elm$json$Json$Decode$fail('expecting one of the following values: left, non, right');
	}
};
var $elm$project_metadata_utils$Elm$Docs$assocDecoder = A2($elm$json$Json$Decode$andThen, $elm$project_metadata_utils$Elm$Docs$toAssoc, $elm$json$Json$Decode$string);
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$map5 = _Json_map5;
var $elm$project_metadata_utils$Elm$Docs$binopDecoder = A6(
	$elm$json$Json$Decode$map5,
	$elm$project_metadata_utils$Elm$Docs$Binop,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'comment', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'type', $elm$project_metadata_utils$Elm$Type$decoder),
	A2($elm$json$Json$Decode$field, 'associativity', $elm$project_metadata_utils$Elm$Docs$assocDecoder),
	A2($elm$json$Json$Decode$field, 'precedence', $elm$json$Json$Decode$int));
var $elm$json$Json$Decode$map6 = _Json_map6;
var $elm$project_metadata_utils$Elm$Docs$Union = F4(
	function (name, comment, args, tags) {
		return {T: args, ag: comment, i: name, bw: tags};
	});
var $elm$json$Json$Decode$index = _Json_decodeIndex;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$project_metadata_utils$Elm$Docs$tagDecoder = A3(
	$elm$json$Json$Decode$map2,
	F2(
		function (a, b) {
			return _Utils_Tuple2(a, b);
		}),
	A2($elm$json$Json$Decode$index, 0, $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$index,
		1,
		$elm$json$Json$Decode$list($elm$project_metadata_utils$Elm$Type$decoder)));
var $elm$project_metadata_utils$Elm$Docs$unionDecoder = A5(
	$elm$json$Json$Decode$map4,
	$elm$project_metadata_utils$Elm$Docs$Union,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'comment', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$field,
		'args',
		$elm$json$Json$Decode$list($elm$json$Json$Decode$string)),
	A2(
		$elm$json$Json$Decode$field,
		'cases',
		$elm$json$Json$Decode$list($elm$project_metadata_utils$Elm$Docs$tagDecoder)));
var $elm$project_metadata_utils$Elm$Docs$Value = F3(
	function (name, comment, tipe) {
		return {ag: comment, i: name, ak: tipe};
	});
var $elm$json$Json$Decode$map3 = _Json_map3;
var $elm$project_metadata_utils$Elm$Docs$valueDecoder = A4(
	$elm$json$Json$Decode$map3,
	$elm$project_metadata_utils$Elm$Docs$Value,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'comment', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'type', $elm$project_metadata_utils$Elm$Type$decoder));
var $elm$project_metadata_utils$Elm$Docs$decoder = A7(
	$elm$json$Json$Decode$map6,
	$elm$project_metadata_utils$Elm$Docs$Module,
	A2($elm$json$Json$Decode$field, 'name', $elm$json$Json$Decode$string),
	A2($elm$json$Json$Decode$field, 'comment', $elm$json$Json$Decode$string),
	A2(
		$elm$json$Json$Decode$field,
		'unions',
		$elm$json$Json$Decode$list($elm$project_metadata_utils$Elm$Docs$unionDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'aliases',
		$elm$json$Json$Decode$list($elm$project_metadata_utils$Elm$Docs$aliasDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'values',
		$elm$json$Json$Decode$list($elm$project_metadata_utils$Elm$Docs$valueDecoder)),
	A2(
		$elm$json$Json$Decode$field,
		'binops',
		$elm$json$Json$Decode$list($elm$project_metadata_utils$Elm$Docs$binopDecoder)));
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Elm$Gen$onFailureSend = _Platform_outgoingPort(
	'onFailureSend',
	function ($) {
		return $elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'description',
					$elm$json$Json$Encode$string($.bR)),
					_Utils_Tuple2(
					'title',
					$elm$json$Json$Encode$string($.cf))
				]));
	});
var $author$project$Elm$Gen$error = function (err) {
	return $author$project$Elm$Gen$onFailureSend(err);
};
var $author$project$Elm$Gen$encodeFile = function (file) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'path',
				$elm$json$Json$Encode$string(file.bc)),
				_Utils_Tuple2(
				'contents',
				$elm$json$Json$Encode$string(file.aQ))
			]));
};
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $author$project$Elm$Gen$onSuccessSend = _Platform_outgoingPort(
	'onSuccessSend',
	$elm$json$Json$Encode$list($elm$core$Basics$identity));
var $author$project$Elm$Gen$files = function (list) {
	return $author$project$Elm$Gen$onSuccessSend(
		A2($elm$core$List$map, $author$project$Elm$Gen$encodeFile, list));
};
var $stil4m$elm_syntax$Elm$Syntax$Expression$Application = function (a) {
	return {$: 1, a: a};
};
var $author$project$Internal$Compiler$Expression = $elm$core$Basics$identity;
var $author$project$Internal$Compiler$FunctionAppliedToTooManyArgs = {$: 4};
var $stil4m$elm_syntax$Elm$Syntax$Node$value = function (_v0) {
	var v = _v0.b;
	return v;
};
var $author$project$Internal$Compiler$denode = $stil4m$elm_syntax$Elm$Syntax$Node$value;
var $stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$FunctionTypeAnnotation = F2(
	function (a, b) {
		return {$: 6, a: a, b: b};
	});
var $stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Record = function (a) {
	return {$: 4, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Tupled = function (a) {
	return {$: 3, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Typed = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Unit = {$: 2};
var $author$project$Internal$Compiler$getField = F4(
	function (name, val, fields, captured) {
		getField:
		while (true) {
			if (!fields.b) {
				return $elm$core$Result$Err('Could not find ' + name);
			} else {
				var top = fields.a;
				var remain = fields.b;
				var _v1 = $author$project$Internal$Compiler$denode(top);
				var topFieldName = _v1.a;
				var topFieldVal = _v1.b;
				var topName = $author$project$Internal$Compiler$denode(topFieldName);
				var topVal = $author$project$Internal$Compiler$denode(topFieldVal);
				if (_Utils_eq(topName, name)) {
					return $elm$core$Result$Ok(
						_Utils_Tuple2(
							topVal,
							_Utils_ap(captured, remain)));
				} else {
					var $temp$name = name,
						$temp$val = val,
						$temp$fields = remain,
						$temp$captured = A2($elm$core$List$cons, top, captured);
					name = $temp$name;
					val = $temp$val;
					fields = $temp$fields;
					captured = $temp$captured;
					continue getField;
				}
			}
		}
	});
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $stil4m$elm_syntax$Elm$Syntax$Node$Node = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $stil4m$elm_syntax$Elm$Syntax$Range$emptyRange = {
	aW: {bN: 0, bn: 0},
	br: {bN: 0, bn: 0}
};
var $author$project$Internal$Compiler$nodify = function (exp) {
	return A2($stil4m$elm_syntax$Elm$Syntax$Node$Node, $stil4m$elm_syntax$Elm$Syntax$Range$emptyRange, exp);
};
var $author$project$Internal$Compiler$nodifyAll = $elm$core$List$map($author$project$Internal$Compiler$nodify);
var $author$project$Internal$Compiler$unifiableFields = F4(
	function (vars, one, two, unified) {
		unifiableFields:
		while (true) {
			var _v27 = _Utils_Tuple2(one, two);
			if (!_v27.a.b) {
				if (!_v27.b.b) {
					return _Utils_Tuple2(
						vars,
						$elm$core$Result$Ok(
							$author$project$Internal$Compiler$nodifyAll(
								$elm$core$List$reverse(unified))));
				} else {
					return _Utils_Tuple2(
						vars,
						$elm$core$Result$Err('Mismatched numbers of type variables'));
				}
			} else {
				var _v28 = _v27.a;
				var oneX = _v28.a;
				var oneRemain = _v28.b;
				var twoFields = _v27.b;
				var _v29 = $author$project$Internal$Compiler$denode(oneX);
				var oneFieldName = _v29.a;
				var oneFieldVal = _v29.b;
				var oneName = $author$project$Internal$Compiler$denode(oneFieldName);
				var oneVal = $author$project$Internal$Compiler$denode(oneFieldVal);
				var _v30 = A4($author$project$Internal$Compiler$getField, oneName, oneVal, twoFields, _List_Nil);
				if (!_v30.$) {
					var _v31 = _v30.a;
					var matchingFieldVal = _v31.a;
					var remainingTwo = _v31.b;
					var _v32 = A3($author$project$Internal$Compiler$unifiableHelper, vars, oneVal, matchingFieldVal);
					var newVars = _v32.a;
					var unifiedField = _v32.b;
					var $temp$vars = newVars,
						$temp$one = oneRemain,
						$temp$two = remainingTwo,
						$temp$unified = A2($elm$core$List$cons, unifiedField, unified);
					vars = $temp$vars;
					one = $temp$one;
					two = $temp$two;
					unified = $temp$unified;
					continue unifiableFields;
				} else {
					var notFound = _v30.a;
					return _Utils_Tuple2(
						vars,
						$elm$core$Result$Err('Could not find ' + oneName));
				}
			}
		}
	});
var $author$project$Internal$Compiler$unifiableHelper = F3(
	function (vars, one, two) {
		unifiableHelper:
		while (true) {
			switch (one.$) {
				case 0:
					var varName = one.a;
					var _v8 = A2($elm$core$Dict$get, varName, vars);
					if (_v8.$ === 1) {
						return _Utils_Tuple2(
							A3($elm$core$Dict$insert, varName, two, vars),
							$elm$core$Result$Ok(two));
					} else {
						var found = _v8.a;
						if (!two.$) {
							var varNameB = two.a;
							var _v10 = A2($elm$core$Dict$get, varNameB, vars);
							if (_v10.$ === 1) {
								return _Utils_Tuple2(
									A3($elm$core$Dict$insert, varNameB, found, vars),
									$elm$core$Result$Ok(two));
							} else {
								var foundTwo = _v10.a;
								var $temp$vars = vars,
									$temp$one = found,
									$temp$two = foundTwo;
								vars = $temp$vars;
								one = $temp$one;
								two = $temp$two;
								continue unifiableHelper;
							}
						} else {
							var $temp$vars = vars,
								$temp$one = found,
								$temp$two = two;
							vars = $temp$vars;
							one = $temp$one;
							two = $temp$two;
							continue unifiableHelper;
						}
					}
				case 1:
					var oneName = one.a;
					var oneContents = one.b;
					switch (two.$) {
						case 1:
							var twoName = two.a;
							var twoContents = two.b;
							if (_Utils_eq(
								$author$project$Internal$Compiler$denode(oneName),
								$author$project$Internal$Compiler$denode(twoName))) {
								var _v12 = A4($author$project$Internal$Compiler$unifiableLists, vars, oneContents, twoContents, _List_Nil);
								if (!_v12.b.$) {
									var newVars = _v12.a;
									var unifiedContent = _v12.b.a;
									return _Utils_Tuple2(
										newVars,
										$elm$core$Result$Ok(
											A2($stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Typed, twoName, unifiedContent)));
								} else {
									var newVars = _v12.a;
									var err = _v12.b.a;
									return _Utils_Tuple2(
										newVars,
										$elm$core$Result$Err(err));
								}
							} else {
								return _Utils_Tuple2(
									vars,
									$elm$core$Result$Err('Unable to unify container!'));
							}
						case 0:
							var b = two.a;
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Ok(one));
						default:
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Err('Unable to unify container!'));
					}
				case 2:
					switch (two.$) {
						case 0:
							var b = two.a;
							var _v14 = A2($elm$core$Dict$get, b, vars);
							if (_v14.$ === 1) {
								return _Utils_Tuple2(
									A3($elm$core$Dict$insert, b, one, vars),
									$elm$core$Result$Ok(one));
							} else {
								var foundTwo = _v14.a;
								var $temp$vars = vars,
									$temp$one = one,
									$temp$two = foundTwo;
								vars = $temp$vars;
								one = $temp$one;
								two = $temp$two;
								continue unifiableHelper;
							}
						case 2:
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Ok($stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Unit));
						default:
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Err('Unable to unify units!'));
					}
				case 3:
					var valsA = one.a;
					switch (two.$) {
						case 0:
							var b = two.a;
							var _v16 = A2($elm$core$Dict$get, b, vars);
							if (_v16.$ === 1) {
								return _Utils_Tuple2(
									A3($elm$core$Dict$insert, b, one, vars),
									$elm$core$Result$Ok(one));
							} else {
								var foundTwo = _v16.a;
								var $temp$vars = vars,
									$temp$one = one,
									$temp$two = foundTwo;
								vars = $temp$vars;
								one = $temp$one;
								two = $temp$two;
								continue unifiableHelper;
							}
						case 3:
							var valsB = two.a;
							var _v17 = A4($author$project$Internal$Compiler$unifiableLists, vars, valsA, valsB, _List_Nil);
							if (!_v17.b.$) {
								var newVars = _v17.a;
								var unified = _v17.b.a;
								return _Utils_Tuple2(
									newVars,
									$elm$core$Result$Ok(
										$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Tupled(unified)));
							} else {
								var newVars = _v17.a;
								var err = _v17.b.a;
								return _Utils_Tuple2(
									newVars,
									$elm$core$Result$Err(err));
							}
						default:
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Err('Unable to unify tuples!'));
					}
				case 4:
					var fieldsA = one.a;
					switch (two.$) {
						case 0:
							var b = two.a;
							var _v19 = A2($elm$core$Dict$get, b, vars);
							if (_v19.$ === 1) {
								return _Utils_Tuple2(
									A3($elm$core$Dict$insert, b, one, vars),
									$elm$core$Result$Ok(one));
							} else {
								var foundTwo = _v19.a;
								var $temp$vars = vars,
									$temp$one = one,
									$temp$two = foundTwo;
								vars = $temp$vars;
								one = $temp$one;
								two = $temp$two;
								continue unifiableHelper;
							}
						case 4:
							var fieldsB = two.a;
							var _v20 = A4($author$project$Internal$Compiler$unifiableFields, vars, fieldsA, fieldsB, _List_Nil);
							if (!_v20.b.$) {
								var newVars = _v20.a;
								var unifiedFields = _v20.b.a;
								return _Utils_Tuple2(
									newVars,
									$elm$core$Result$Ok(
										$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Record(unifiedFields)));
							} else {
								var newVars = _v20.a;
								var err = _v20.b.a;
								return _Utils_Tuple2(
									newVars,
									$elm$core$Result$Err(err));
							}
						default:
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Err('Unable to unify function with non function type!'));
					}
				case 5:
					var reVarName = one.a;
					var fieldsA = one.b;
					switch (two.$) {
						case 0:
							var b = two.a;
							var _v22 = A2($elm$core$Dict$get, b, vars);
							if (_v22.$ === 1) {
								return _Utils_Tuple2(
									A3($elm$core$Dict$insert, b, one, vars),
									$elm$core$Result$Ok(one));
							} else {
								var foundTwo = _v22.a;
								var $temp$vars = vars,
									$temp$one = one,
									$temp$two = foundTwo;
								vars = $temp$vars;
								one = $temp$one;
								two = $temp$two;
								continue unifiableHelper;
							}
						case 4:
							var fieldsB = two.a;
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Err('Unable to unify function with non function type!'));
						default:
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Err('Unable to unify function with non function type!'));
					}
				default:
					var oneA = one.a;
					var oneB = one.b;
					switch (two.$) {
						case 0:
							var b = two.a;
							var _v24 = A2($elm$core$Dict$get, b, vars);
							if (_v24.$ === 1) {
								return _Utils_Tuple2(
									A3($elm$core$Dict$insert, b, one, vars),
									$elm$core$Result$Ok(one));
							} else {
								var foundTwo = _v24.a;
								var $temp$vars = vars,
									$temp$one = one,
									$temp$two = foundTwo;
								vars = $temp$vars;
								one = $temp$one;
								two = $temp$two;
								continue unifiableHelper;
							}
						case 6:
							var twoA = two.a;
							var twoB = two.b;
							var _v25 = A3(
								$author$project$Internal$Compiler$unifiableHelper,
								vars,
								$author$project$Internal$Compiler$denode(oneA),
								$author$project$Internal$Compiler$denode(twoA));
							if (!_v25.b.$) {
								var aVars = _v25.a;
								var unifiedA = _v25.b.a;
								var _v26 = A3(
									$author$project$Internal$Compiler$unifiableHelper,
									aVars,
									$author$project$Internal$Compiler$denode(oneB),
									$author$project$Internal$Compiler$denode(twoB));
								if (!_v26.b.$) {
									var bVars = _v26.a;
									var unifiedB = _v26.b.a;
									return _Utils_Tuple2(
										bVars,
										$elm$core$Result$Ok(
											A2(
												$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$FunctionTypeAnnotation,
												$author$project$Internal$Compiler$nodify(unifiedA),
												$author$project$Internal$Compiler$nodify(unifiedB))));
								} else {
									var otherwise = _v26;
									return otherwise;
								}
							} else {
								var otherwise = _v25;
								return otherwise;
							}
						default:
							return _Utils_Tuple2(
								vars,
								$elm$core$Result$Err('Unable to unify function with non function type!'));
					}
			}
		}
	});
var $author$project$Internal$Compiler$unifiableLists = F4(
	function (vars, one, two, unified) {
		unifiableLists:
		while (true) {
			var _v0 = _Utils_Tuple2(one, two);
			_v0$3:
			while (true) {
				if (!_v0.a.b) {
					if (!_v0.b.b) {
						return _Utils_Tuple2(
							vars,
							$elm$core$Result$Ok(
								$author$project$Internal$Compiler$nodifyAll(
									$elm$core$List$reverse(unified))));
					} else {
						break _v0$3;
					}
				} else {
					if (_v0.b.b) {
						if ((!_v0.a.b.b) && (!_v0.b.b.b)) {
							var _v1 = _v0.a;
							var oneX = _v1.a;
							var _v2 = _v0.b;
							var twoX = _v2.a;
							var _v3 = A3(
								$author$project$Internal$Compiler$unifiableHelper,
								vars,
								$author$project$Internal$Compiler$denode(oneX),
								$author$project$Internal$Compiler$denode(twoX));
							if (!_v3.b.$) {
								var newVars = _v3.a;
								var un = _v3.b.a;
								return _Utils_Tuple2(
									newVars,
									$elm$core$Result$Ok(
										$author$project$Internal$Compiler$nodifyAll(
											$elm$core$List$reverse(
												A2($elm$core$List$cons, un, unified)))));
							} else {
								var newVars = _v3.a;
								var err = _v3.b.a;
								return _Utils_Tuple2(
									newVars,
									$elm$core$Result$Err(err));
							}
						} else {
							var _v4 = _v0.a;
							var oneX = _v4.a;
							var oneRemain = _v4.b;
							var _v5 = _v0.b;
							var twoX = _v5.a;
							var twoRemain = _v5.b;
							var _v6 = A3(
								$author$project$Internal$Compiler$unifiableHelper,
								vars,
								$author$project$Internal$Compiler$denode(oneX),
								$author$project$Internal$Compiler$denode(twoX));
							if (!_v6.b.$) {
								var newVars = _v6.a;
								var un = _v6.b.a;
								var $temp$vars = newVars,
									$temp$one = oneRemain,
									$temp$two = twoRemain,
									$temp$unified = A2($elm$core$List$cons, un, unified);
								vars = $temp$vars;
								one = $temp$one;
								two = $temp$two;
								unified = $temp$unified;
								continue unifiableLists;
							} else {
								var newVars = _v6.a;
								var err = _v6.b.a;
								return _Utils_Tuple2(
									vars,
									$elm$core$Result$Err(err));
							}
						}
					} else {
						break _v0$3;
					}
				}
			}
			return _Utils_Tuple2(
				vars,
				$elm$core$Result$Err('Mismatched numbers of type variables'));
		}
	});
var $author$project$Internal$Compiler$unifiable = F2(
	function (one, two) {
		var _v0 = A3($author$project$Internal$Compiler$unifiableHelper, $elm$core$Dict$empty, one, two);
		var result = _v0.b;
		var _v1 = function () {
			if (!result.$) {
				return _Utils_Tuple2(one, two);
			} else {
				return _Utils_Tuple2(one, two);
			}
		}();
		return result;
	});
var $author$project$Internal$Compiler$applyTypeHelper = F2(
	function (fn, args) {
		applyTypeHelper:
		while (true) {
			if (fn.$ === 6) {
				var one = fn.a;
				var two = fn.b;
				if (!args.b) {
					return $elm$core$Result$Ok(fn);
				} else {
					var top = args.a;
					var rest = args.b;
					var _v2 = A2(
						$author$project$Internal$Compiler$unifiable,
						$author$project$Internal$Compiler$denode(one),
						top);
					if (!_v2.$) {
						if (!rest.b) {
							return $elm$core$Result$Ok(
								$author$project$Internal$Compiler$denode(two));
						} else {
							var $temp$fn = $author$project$Internal$Compiler$denode(two),
								$temp$args = rest;
							fn = $temp$fn;
							args = $temp$args;
							continue applyTypeHelper;
						}
					} else {
						var err = _v2.a;
						return $elm$core$Result$Err(_List_Nil);
					}
				}
			} else {
				var _final = fn;
				if (!args.b) {
					return $elm$core$Result$Ok(fn);
				} else {
					return $elm$core$Result$Err(
						_List_fromArray(
							[$author$project$Internal$Compiler$FunctionAppliedToTooManyArgs]));
				}
			}
		}
	});
var $author$project$Internal$Compiler$extractListAnnotation = F2(
	function (expressions, annotations) {
		extractListAnnotation:
		while (true) {
			if (!expressions.b) {
				return $elm$core$Result$Ok(
					$elm$core$List$reverse(annotations));
			} else {
				var top = expressions.a;
				var remain = expressions.b;
				var _v1 = top.c;
				if (!_v1.$) {
					var ann = _v1.a;
					var $temp$expressions = remain,
						$temp$annotations = A2($elm$core$List$cons, ann, annotations);
					expressions = $temp$expressions;
					annotations = $temp$annotations;
					continue extractListAnnotation;
				} else {
					var err = _v1.a;
					return $elm$core$Result$Err(err);
				}
			}
		}
	});
var $author$project$Internal$Compiler$applyType = F2(
	function (_v0, args) {
		var exp = _v0;
		var _v1 = exp.c;
		if (_v1.$ === 1) {
			var err = _v1.a;
			return $elm$core$Result$Err(err);
		} else {
			var topAnnotation = _v1.a;
			var _v2 = A2($author$project$Internal$Compiler$extractListAnnotation, args, _List_Nil);
			if (!_v2.$) {
				var types = _v2.a;
				return A2($author$project$Internal$Compiler$applyTypeHelper, topAnnotation, types);
			} else {
				var err = _v2.a;
				return $elm$core$Result$Err(err);
			}
		}
	});
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $elm$core$List$filter = F2(
	function (isGood, list) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, xs) {
					return isGood(x) ? A2($elm$core$List$cons, x, xs) : xs;
				}),
			_List_Nil,
			list);
	});
var $author$project$Elm$getExpression = function (_v0) {
	var exp = _v0;
	return exp.b;
};
var $author$project$Elm$getImports = function (_v0) {
	var exp = _v0;
	return exp.a;
};
var $stil4m$elm_syntax$Elm$Syntax$Expression$ParenthesizedExpression = function (a) {
	return {$: 14, a: a};
};
var $author$project$Elm$parens = function (expr) {
	return $stil4m$elm_syntax$Elm$Syntax$Expression$ParenthesizedExpression(
		$author$project$Internal$Compiler$nodify(expr));
};
var $author$project$Elm$apply = F2(
	function (top, allArgs) {
		var exp = top;
		var args = A2(
			$elm$core$List$filter,
			function (_v0) {
				var arg = _v0;
				return !arg.g;
			},
			allArgs);
		return {
			c: A2($author$project$Internal$Compiler$applyType, top, args),
			b: $stil4m$elm_syntax$Elm$Syntax$Expression$Application(
				$author$project$Internal$Compiler$nodifyAll(
					A2(
						$elm$core$List$cons,
						exp.b,
						A2(
							$elm$core$List$map,
							A2($elm$core$Basics$composeL, $author$project$Elm$parens, $author$project$Elm$getExpression),
							args)))),
			a: _Utils_ap(
				exp.a,
				A2($elm$core$List$concatMap, $author$project$Elm$getImports, args)),
			g: false
		};
	});
var $stil4m$elm_syntax$Elm$Syntax$Expression$Literal = function (a) {
	return {$: 11, a: a};
};
var $author$project$Internal$Compiler$getInnerAnnotation = function (_v0) {
	var details = _v0;
	return details.c;
};
var $author$project$Internal$Compiler$Annotation = $elm$core$Basics$identity;
var $author$project$Internal$Compiler$getAnnotationImports = function (_v0) {
	var details = _v0;
	return details.a;
};
var $author$project$Elm$Annotation$typed = F3(
	function (mod, name, args) {
		return {
			c: A2(
				$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Typed,
				$author$project$Internal$Compiler$nodify(
					_Utils_Tuple2(mod, name)),
				$author$project$Internal$Compiler$nodifyAll(
					A2($elm$core$List$map, $author$project$Internal$Compiler$getInnerAnnotation, args))),
			a: A2($elm$core$List$concatMap, $author$project$Internal$Compiler$getAnnotationImports, args)
		};
	});
var $author$project$Elm$Annotation$string = A3($author$project$Elm$Annotation$typed, _List_Nil, 'String', _List_Nil);
var $author$project$Elm$string = function (literal) {
	return {
		c: $elm$core$Result$Ok(
			$author$project$Internal$Compiler$getInnerAnnotation($author$project$Elm$Annotation$string)),
		b: $stil4m$elm_syntax$Elm$Syntax$Expression$Literal(literal),
		a: _List_Nil,
		g: false
	};
};
var $author$project$Internal$Compiler$Module = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$core$String$length = _String_length;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toUpper = _String_toUpper;
var $author$project$Internal$Compiler$formatType = function (str) {
	return _Utils_ap(
		$elm$core$String$toUpper(
			A2($elm$core$String$left, 1, str)),
		A2($elm$core$String$dropLeft, 1, str));
};
var $author$project$Internal$Compiler$inModule = function (mods) {
	return A2(
		$author$project$Internal$Compiler$Module,
		A2($elm$core$List$map, $author$project$Internal$Compiler$formatType, mods),
		$elm$core$Maybe$Nothing);
};
var $author$project$Elm$moduleName = $author$project$Internal$Compiler$inModule;
var $author$project$Generate$elm = $author$project$Elm$moduleName(
	_List_fromArray(
		['Elm']));
var $author$project$Generate$local = $author$project$Elm$moduleName(_List_Nil);
var $author$project$Internal$Compiler$resolveModuleName = function (_v0) {
	var mod = _v0.a;
	var maybeAlias = _v0.b;
	if (maybeAlias.$ === 1) {
		return mod;
	} else {
		var aliasStr = maybeAlias.a;
		return _List_fromArray(
			[aliasStr]);
	}
};
var $author$project$Elm$Annotation$named = F2(
	function (mod, name) {
		return {
			c: A2(
				$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Typed,
				$author$project$Internal$Compiler$nodify(
					_Utils_Tuple2(
						$author$project$Internal$Compiler$resolveModuleName(mod),
						$author$project$Internal$Compiler$formatType(name))),
				_List_Nil),
			a: _List_fromArray(
				[mod])
		};
	});
var $stil4m$elm_syntax$Elm$Syntax$Expression$FunctionOrValue = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $author$project$Internal$Compiler$resolveModuleNameForValue = function (_v0) {
	var mod = _v0.a;
	var maybeAlias = _v0.b;
	if (maybeAlias.$ === 1) {
		return mod;
	} else {
		var aliasStr = maybeAlias.a;
		return _List_fromArray(
			[aliasStr]);
	}
};
var $author$project$Internal$Compiler$sanitize = function (str) {
	switch (str) {
		case 'in':
			return 'in_';
		case 'type':
			return 'type_';
		case 'case':
			return 'case_';
		case 'let':
			return 'let_';
		case 'module':
			return 'module_';
		case 'exposing':
			return 'exposing_';
		default:
			return str;
	}
};
var $author$project$Elm$valueWith = F3(
	function (mod, name, ann) {
		return {
			c: $elm$core$Result$Ok(
				$author$project$Internal$Compiler$getInnerAnnotation(ann)),
			b: A2(
				$stil4m$elm_syntax$Elm$Syntax$Expression$FunctionOrValue,
				$author$project$Internal$Compiler$resolveModuleNameForValue(mod),
				$author$project$Internal$Compiler$sanitize(name)),
			a: A2(
				$elm$core$List$cons,
				mod,
				$author$project$Internal$Compiler$getAnnotationImports(ann)),
			g: false
		};
	});
var $author$project$Generate$thisModuleName = A3(
	$author$project$Elm$valueWith,
	$author$project$Generate$local,
	'moduleName_',
	A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'));
var $author$project$Internal$Compiler$moduleAs = F2(
	function (mods, modAlias) {
		return A2(
			$author$project$Internal$Compiler$Module,
			A2($elm$core$List$map, $author$project$Internal$Compiler$formatType, mods),
			$elm$core$Maybe$Just(
				$author$project$Internal$Compiler$formatType(modAlias)));
	});
var $author$project$Elm$moduleAs = $author$project$Internal$Compiler$moduleAs;
var $author$project$Generate$elmAnnotation = A2(
	$author$project$Elm$moduleAs,
	_List_fromArray(
		['Elm', 'Annotation']),
	'Type');
var $author$project$Elm$Annotation$function = F2(
	function (anns, _return) {
		return {
			c: A3(
				$elm$core$List$foldr,
				F2(
					function (ann, fn) {
						return A2(
							$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$FunctionTypeAnnotation,
							$author$project$Internal$Compiler$nodify(ann),
							$author$project$Internal$Compiler$nodify(fn));
					}),
				$author$project$Internal$Compiler$getInnerAnnotation(_return),
				A2($elm$core$List$map, $author$project$Internal$Compiler$getInnerAnnotation, anns)),
			a: _Utils_ap(
				$author$project$Internal$Compiler$getAnnotationImports(_return),
				A2($elm$core$List$concatMap, $author$project$Internal$Compiler$getAnnotationImports, anns))
		};
	});
var $author$project$Generate$annotationType = A2($author$project$Elm$Annotation$named, $author$project$Generate$elmAnnotation, 'Annotation');
var $elm$core$List$drop = F2(
	function (n, list) {
		drop:
		while (true) {
			if (n <= 0) {
				return list;
			} else {
				if (!list.b) {
					return list;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs;
					n = $temp$n;
					list = $temp$list;
					continue drop;
				}
			}
		}
	});
var $elm$core$List$head = function (list) {
	if (list.b) {
		var x = list.a;
		var xs = list.b;
		return $elm$core$Maybe$Just(x);
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $stil4m$elm_syntax$Elm$Syntax$Expression$ListExpr = function (a) {
	return {$: 19, a: a};
};
var $elm$core$Result$map = F2(
	function (func, ra) {
		if (!ra.$) {
			var a = ra.a;
			return $elm$core$Result$Ok(
				func(a));
		} else {
			var e = ra.a;
			return $elm$core$Result$Err(e);
		}
	});
var $author$project$Elm$toList = function (_v0) {
	var exp = _v0;
	return $author$project$Internal$Compiler$nodify(exp.b);
};
var $stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$GenericType = function (a) {
	return {$: 0, a: a};
};
var $author$project$Internal$Compiler$MismatchedList = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $author$project$Internal$Compiler$unifyHelper = F2(
	function (exps, existing) {
		unifyHelper:
		while (true) {
			if (!exps.b) {
				return $elm$core$Result$Ok(existing);
			} else {
				var top = exps.a;
				var remain = exps.b;
				var _v1 = top.c;
				if (!_v1.$) {
					var ann = _v1.a;
					var _v2 = A2($author$project$Internal$Compiler$unifiable, ann, existing);
					if (_v2.$ === 1) {
						return $elm$core$Result$Err(
							_List_fromArray(
								[
									A2($author$project$Internal$Compiler$MismatchedList, ann, existing)
								]));
					} else {
						var _new = _v2.a;
						var $temp$exps = remain,
							$temp$existing = _new;
						exps = $temp$exps;
						existing = $temp$existing;
						continue unifyHelper;
					}
				} else {
					var err = _v1.a;
					return $elm$core$Result$Err(err);
				}
			}
		}
	});
var $author$project$Internal$Compiler$unify = function (exps) {
	if (!exps.b) {
		return $elm$core$Result$Ok(
			$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$GenericType('a'));
	} else {
		var top = exps.a;
		var remain = exps.b;
		var _v1 = top.c;
		if (!_v1.$) {
			var ann = _v1.a;
			return A2($author$project$Internal$Compiler$unifyHelper, remain, ann);
		} else {
			var err = _v1.a;
			return $elm$core$Result$Err(err);
		}
	}
};
var $author$project$Elm$list = function (exprs) {
	return {
		c: A2(
			$elm$core$Result$map,
			function (inner) {
				return A2(
					$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Typed,
					$author$project$Internal$Compiler$nodify(
						_Utils_Tuple2(_List_Nil, 'List')),
					_List_fromArray(
						[
							$author$project$Internal$Compiler$nodify(inner)
						]));
			},
			$author$project$Internal$Compiler$unify(exprs)),
		b: $stil4m$elm_syntax$Elm$Syntax$Expression$ListExpr(
			A2($elm$core$List$map, $author$project$Elm$toList, exprs)),
		a: A2($elm$core$List$concatMap, $author$project$Elm$getImports, exprs),
		g: false
	};
};
var $author$project$Elm$Annotation$list = function (inner) {
	return A3(
		$author$project$Elm$Annotation$typed,
		_List_Nil,
		'List',
		_List_fromArray(
			[inner]));
};
var $elm$core$List$takeReverse = F3(
	function (n, list, kept) {
		takeReverse:
		while (true) {
			if (n <= 0) {
				return kept;
			} else {
				if (!list.b) {
					return kept;
				} else {
					var x = list.a;
					var xs = list.b;
					var $temp$n = n - 1,
						$temp$list = xs,
						$temp$kept = A2($elm$core$List$cons, x, kept);
					n = $temp$n;
					list = $temp$list;
					kept = $temp$kept;
					continue takeReverse;
				}
			}
		}
	});
var $elm$core$List$takeTailRec = F2(
	function (n, list) {
		return $elm$core$List$reverse(
			A3($elm$core$List$takeReverse, n, list, _List_Nil));
	});
var $elm$core$List$takeFast = F3(
	function (ctr, n, list) {
		if (n <= 0) {
			return _List_Nil;
		} else {
			var _v0 = _Utils_Tuple2(n, list);
			_v0$1:
			while (true) {
				_v0$5:
				while (true) {
					if (!_v0.b.b) {
						return list;
					} else {
						if (_v0.b.b.b) {
							switch (_v0.a) {
								case 1:
									break _v0$1;
								case 2:
									var _v2 = _v0.b;
									var x = _v2.a;
									var _v3 = _v2.b;
									var y = _v3.a;
									return _List_fromArray(
										[x, y]);
								case 3:
									if (_v0.b.b.b.b) {
										var _v4 = _v0.b;
										var x = _v4.a;
										var _v5 = _v4.b;
										var y = _v5.a;
										var _v6 = _v5.b;
										var z = _v6.a;
										return _List_fromArray(
											[x, y, z]);
									} else {
										break _v0$5;
									}
								default:
									if (_v0.b.b.b.b && _v0.b.b.b.b.b) {
										var _v7 = _v0.b;
										var x = _v7.a;
										var _v8 = _v7.b;
										var y = _v8.a;
										var _v9 = _v8.b;
										var z = _v9.a;
										var _v10 = _v9.b;
										var w = _v10.a;
										var tl = _v10.b;
										return (ctr > 1000) ? A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A2($elm$core$List$takeTailRec, n - 4, tl))))) : A2(
											$elm$core$List$cons,
											x,
											A2(
												$elm$core$List$cons,
												y,
												A2(
													$elm$core$List$cons,
													z,
													A2(
														$elm$core$List$cons,
														w,
														A3($elm$core$List$takeFast, ctr + 1, n - 4, tl)))));
									} else {
										break _v0$5;
									}
							}
						} else {
							if (_v0.a === 1) {
								break _v0$1;
							} else {
								break _v0$5;
							}
						}
					}
				}
				return list;
			}
			var _v1 = _v0.b;
			var x = _v1.a;
			return _List_fromArray(
				[x]);
		}
	});
var $elm$core$List$take = F2(
	function (n, list) {
		return A3($elm$core$List$takeFast, 0, n, list);
	});
var $author$project$Generate$moduleName = function (frags) {
	_v0$6:
	while (true) {
		if ((frags.b && frags.b.b) && (!frags.b.b.b)) {
			switch (frags.a) {
				case 'List':
					if (frags.b.a === 'List') {
						var _v1 = frags.b;
						return A3(
							$author$project$Elm$valueWith,
							$author$project$Generate$elm,
							'local2',
							A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'));
					} else {
						break _v0$6;
					}
				case 'Maybe':
					if (frags.b.a === 'Maybe') {
						var _v2 = frags.b;
						return A3(
							$author$project$Elm$valueWith,
							$author$project$Generate$elm,
							'local',
							A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'));
					} else {
						break _v0$6;
					}
				case 'Basics':
					switch (frags.b.a) {
						case 'Int':
							var _v3 = frags.b;
							return A3(
								$author$project$Elm$valueWith,
								$author$project$Generate$elm,
								'local',
								A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'));
						case 'Float':
							var _v4 = frags.b;
							return A3(
								$author$project$Elm$valueWith,
								$author$project$Generate$elm,
								'local',
								A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'));
						case 'Bool':
							var _v5 = frags.b;
							return A3(
								$author$project$Elm$valueWith,
								$author$project$Generate$elm,
								'local',
								A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'));
						default:
							break _v0$6;
					}
				case 'String':
					if (frags.b.a === 'String') {
						var _v6 = frags.b;
						return A3(
							$author$project$Elm$valueWith,
							$author$project$Generate$elm,
							'local',
							A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'));
					} else {
						break _v0$6;
					}
				default:
					break _v0$6;
			}
		} else {
			break _v0$6;
		}
	}
	var fragsLength = $elm$core$List$length(frags);
	var name = A2(
		$elm$core$List$map,
		$author$project$Elm$string,
		A2($elm$core$List$take, fragsLength - 1, frags));
	return A2(
		$author$project$Elm$apply,
		A3(
			$author$project$Elm$valueWith,
			$author$project$Generate$elm,
			'moduleName',
			A2(
				$author$project$Elm$Annotation$function,
				_List_fromArray(
					[
						$author$project$Elm$Annotation$list($author$project$Elm$Annotation$string)
					]),
				A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'))),
		_List_fromArray(
			[
				$author$project$Elm$list(name)
			]));
};
var $stil4m$elm_syntax$Elm$Syntax$Expression$TupledExpression = function (a) {
	return {$: 13, a: a};
};
var $elm$core$Result$map2 = F3(
	function (func, ra, rb) {
		if (ra.$ === 1) {
			var x = ra.a;
			return $elm$core$Result$Err(x);
		} else {
			var a = ra.a;
			if (rb.$ === 1) {
				var x = rb.a;
				return $elm$core$Result$Err(x);
			} else {
				var b = rb.a;
				return $elm$core$Result$Ok(
					A2(func, a, b));
			}
		}
	});
var $author$project$Internal$Compiler$noImports = function (tipe) {
	return {c: tipe, a: _List_Nil};
};
var $author$project$Elm$Annotation$tuple = F2(
	function (one, two) {
		return {
			c: $stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Tupled(
				$author$project$Internal$Compiler$nodifyAll(
					_List_fromArray(
						[
							$author$project$Internal$Compiler$getInnerAnnotation(one),
							$author$project$Internal$Compiler$getInnerAnnotation(two)
						]))),
			a: _Utils_ap(
				$author$project$Internal$Compiler$getAnnotationImports(one),
				$author$project$Internal$Compiler$getAnnotationImports(two))
		};
	});
var $author$project$Elm$tuple = F2(
	function (_v0, _v1) {
		var one = _v0;
		var two = _v1;
		return {
			c: A3(
				$elm$core$Result$map2,
				F2(
					function (oneA, twoA) {
						return $author$project$Internal$Compiler$getInnerAnnotation(
							A2(
								$author$project$Elm$Annotation$tuple,
								$author$project$Internal$Compiler$noImports(oneA),
								$author$project$Internal$Compiler$noImports(twoA)));
					}),
				one.c,
				two.c),
			b: $stil4m$elm_syntax$Elm$Syntax$Expression$TupledExpression(
				$author$project$Internal$Compiler$nodifyAll(
					_List_fromArray(
						[one.b, two.b]))),
			a: _Utils_ap(one.a, two.a),
			g: false
		};
	});
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Generate$chompLambdas = F2(
	function (exps, tipe) {
		chompLambdas:
		while (true) {
			if (tipe.$ === 1) {
				var one = tipe.a;
				var two = tipe.b;
				var $temp$exps = A2(
					$elm$core$List$cons,
					$author$project$Generate$typeToExpression(one),
					exps),
					$temp$tipe = two;
				exps = $temp$exps;
				tipe = $temp$tipe;
				continue chompLambdas;
			} else {
				return A2(
					$author$project$Elm$apply,
					A3(
						$author$project$Elm$valueWith,
						$author$project$Generate$elmAnnotation,
						'function',
						A2(
							$author$project$Elm$Annotation$function,
							_List_fromArray(
								[
									$author$project$Elm$Annotation$list($author$project$Generate$annotationType),
									$author$project$Generate$annotationType
								]),
							$author$project$Generate$annotationType)),
					_List_fromArray(
						[
							$author$project$Elm$list(
							$elm$core$List$reverse(exps)),
							$author$project$Generate$typeToExpression(tipe)
						]));
			}
		}
	});
var $author$project$Generate$namedWithType = F2(
	function (name, types) {
		var frags = A2($elm$core$String$split, '.', name);
		_v8$6:
		while (true) {
			if ((frags.b && frags.b.b) && (!frags.b.b.b)) {
				switch (frags.a) {
					case 'List':
						if (frags.b.a === 'List') {
							var _v9 = frags.b;
							return A2(
								$author$project$Elm$apply,
								A3(
									$author$project$Elm$valueWith,
									$author$project$Generate$elmAnnotation,
									'list',
									A2(
										$author$project$Elm$Annotation$function,
										_List_fromArray(
											[$author$project$Generate$annotationType]),
										$author$project$Generate$annotationType)),
								A2($elm$core$List$map, $author$project$Generate$typeToExpression, types));
						} else {
							break _v8$6;
						}
					case 'Maybe':
						if (frags.b.a === 'Maybe') {
							var _v10 = frags.b;
							return A2(
								$author$project$Elm$apply,
								A3(
									$author$project$Elm$valueWith,
									$author$project$Generate$elmAnnotation,
									'maybe',
									A2(
										$author$project$Elm$Annotation$function,
										_List_fromArray(
											[$author$project$Generate$annotationType]),
										$author$project$Generate$annotationType)),
								A2($elm$core$List$map, $author$project$Generate$typeToExpression, types));
						} else {
							break _v8$6;
						}
					case 'Basics':
						switch (frags.b.a) {
							case 'Int':
								var _v11 = frags.b;
								return A3($author$project$Elm$valueWith, $author$project$Generate$elmAnnotation, 'int', $author$project$Generate$annotationType);
							case 'Float':
								var _v12 = frags.b;
								return A3($author$project$Elm$valueWith, $author$project$Generate$elmAnnotation, 'float', $author$project$Generate$annotationType);
							case 'Bool':
								var _v13 = frags.b;
								return A3($author$project$Elm$valueWith, $author$project$Generate$elmAnnotation, 'bool', $author$project$Generate$annotationType);
							default:
								break _v8$6;
						}
					case 'String':
						if (frags.b.a === 'String') {
							var _v14 = frags.b;
							return A3($author$project$Elm$valueWith, $author$project$Generate$elmAnnotation, 'string', $author$project$Generate$annotationType);
						} else {
							break _v8$6;
						}
					default:
						break _v8$6;
				}
			} else {
				break _v8$6;
			}
		}
		var fragsLength = $elm$core$List$length(frags);
		var typeName = A2(
			$elm$core$Maybe$withDefault,
			name,
			$elm$core$List$head(
				A2($elm$core$List$drop, fragsLength - 1, frags)));
		return A2(
			$author$project$Elm$apply,
			A3(
				$author$project$Elm$valueWith,
				$author$project$Generate$elmAnnotation,
				'namedWith',
				A2(
					$author$project$Elm$Annotation$function,
					_List_fromArray(
						[
							A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'),
							$author$project$Elm$Annotation$string,
							$author$project$Elm$Annotation$list($author$project$Generate$annotationType)
						]),
					$author$project$Generate$annotationType)),
			_List_fromArray(
				[
					$author$project$Generate$moduleName(frags),
					$author$project$Elm$string(typeName),
					$author$project$Elm$list(
					A2($elm$core$List$map, $author$project$Generate$typeToExpression, types))
				]));
	});
var $author$project$Generate$typeToExpression = function (elmType) {
	switch (elmType.$) {
		case 0:
			var string = elmType.a;
			return A2(
				$author$project$Elm$apply,
				A3(
					$author$project$Elm$valueWith,
					$author$project$Generate$elmAnnotation,
					'var',
					A2(
						$author$project$Elm$Annotation$function,
						_List_fromArray(
							[$author$project$Elm$Annotation$string]),
						$author$project$Generate$annotationType)),
				_List_fromArray(
					[
						$author$project$Elm$string(string)
					]));
		case 1:
			var one = elmType.a;
			var two = elmType.b;
			return A2(
				$author$project$Generate$chompLambdas,
				_List_fromArray(
					[
						$author$project$Generate$typeToExpression(one)
					]),
				two);
		case 2:
			var types = elmType.a;
			_v1$3:
			while (true) {
				if (!types.b) {
					return A3($author$project$Elm$valueWith, $author$project$Generate$elmAnnotation, 'unit', $author$project$Generate$annotationType);
				} else {
					if (types.b.b) {
						if (!types.b.b.b) {
							var one = types.a;
							var _v2 = types.b;
							var two = _v2.a;
							return A2(
								$author$project$Elm$apply,
								A3(
									$author$project$Elm$valueWith,
									$author$project$Generate$elmAnnotation,
									'tuple',
									A2(
										$author$project$Elm$Annotation$function,
										_List_fromArray(
											[$author$project$Generate$annotationType, $author$project$Generate$annotationType]),
										$author$project$Generate$annotationType)),
								_List_fromArray(
									[
										$author$project$Generate$typeToExpression(one),
										$author$project$Generate$typeToExpression(two)
									]));
						} else {
							if (!types.b.b.b.b) {
								var one = types.a;
								var _v3 = types.b;
								var two = _v3.a;
								var _v4 = _v3.b;
								var three = _v4.a;
								return A2(
									$author$project$Elm$apply,
									A3(
										$author$project$Elm$valueWith,
										$author$project$Generate$elmAnnotation,
										'triple',
										A2(
											$author$project$Elm$Annotation$function,
											_List_fromArray(
												[$author$project$Generate$annotationType, $author$project$Generate$annotationType, $author$project$Generate$annotationType]),
											$author$project$Generate$annotationType)),
									_List_fromArray(
										[
											$author$project$Generate$typeToExpression(one),
											$author$project$Generate$typeToExpression(two),
											$author$project$Generate$typeToExpression(three)
										]));
							} else {
								break _v1$3;
							}
						}
					} else {
						break _v1$3;
					}
				}
			}
			return A3($author$project$Elm$valueWith, $author$project$Generate$elmAnnotation, 'unit', $author$project$Generate$annotationType);
		case 3:
			var name = elmType.a;
			var types = elmType.b;
			return A2($author$project$Generate$namedWithType, name, types);
		default:
			var fields = elmType.a;
			var maybeExtensible = elmType.b;
			if (maybeExtensible.$ === 1) {
				return A2(
					$author$project$Elm$apply,
					A3(
						$author$project$Elm$valueWith,
						$author$project$Generate$elmAnnotation,
						'record',
						A2(
							$author$project$Elm$Annotation$function,
							_List_fromArray(
								[
									$author$project$Elm$Annotation$list(
									A2($author$project$Elm$Annotation$tuple, $author$project$Elm$Annotation$string, $author$project$Generate$annotationType))
								]),
							$author$project$Generate$annotationType)),
					_List_fromArray(
						[
							$author$project$Elm$list(
							A2(
								$elm$core$List$map,
								function (_v6) {
									var fieldName = _v6.a;
									var fieldType = _v6.b;
									return A2(
										$author$project$Elm$tuple,
										$author$project$Elm$string(fieldName),
										$author$project$Generate$typeToExpression(fieldType));
								},
								fields))
						]));
			} else {
				var base = maybeExtensible.a;
				return A2(
					$author$project$Elm$apply,
					A3(
						$author$project$Elm$valueWith,
						$author$project$Generate$elmAnnotation,
						'extensible',
						A2(
							$author$project$Elm$Annotation$function,
							_List_fromArray(
								[
									$author$project$Elm$Annotation$string,
									$author$project$Elm$Annotation$list(
									A2($author$project$Elm$Annotation$tuple, $author$project$Elm$Annotation$string, $author$project$Generate$annotationType))
								]),
							$author$project$Generate$annotationType)),
					_List_fromArray(
						[
							$author$project$Elm$string(base),
							$author$project$Elm$list(
							A2(
								$elm$core$List$map,
								function (_v7) {
									var fieldName = _v7.a;
									var fieldType = _v7.b;
									return A2(
										$author$project$Elm$tuple,
										$author$project$Elm$string(fieldName),
										$author$project$Generate$typeToExpression(fieldType));
								},
								fields))
						]));
			}
	}
};
var $author$project$Generate$valueWith = F3(
	function (mod, name, annotation) {
		return A2(
			$author$project$Elm$apply,
			A3(
				$author$project$Elm$valueWith,
				$author$project$Generate$elm,
				'valueWith',
				A2(
					$author$project$Elm$Annotation$function,
					_List_fromArray(
						[
							A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'),
							$author$project$Elm$Annotation$string,
							A2($author$project$Elm$Annotation$named, $author$project$Generate$elmAnnotation, 'Annotation')
						]),
					A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Expression'))),
			_List_fromArray(
				[
					mod,
					name,
					$author$project$Generate$typeToExpression(annotation)
				]));
	});
var $author$project$Generate$blockToIdField = function (block) {
	switch (block.$) {
		case 0:
			var str = block.a;
			return $elm$core$Maybe$Nothing;
		case 1:
			var union = block.a;
			return $elm$core$Maybe$Nothing;
		case 2:
			var alias = block.a;
			return $elm$core$Maybe$Nothing;
		case 3:
			var value = block.a;
			return $elm$core$Maybe$Just(
				_Utils_Tuple2(
					value.i,
					A3(
						$author$project$Generate$valueWith,
						$author$project$Generate$thisModuleName,
						$author$project$Elm$string(value.i),
						value.ak)));
		case 4:
			var binop = block.a;
			return $elm$core$Maybe$Nothing;
		default:
			var str = block.a;
			return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Internal$Compiler$Declaration = F3(
	function (a, b, c) {
		return {$: 0, a: a, b: b, c: c};
	});
var $stil4m$elm_syntax$Elm$Syntax$Declaration$FunctionDeclaration = function (a) {
	return {$: 0, a: a};
};
var $author$project$Internal$Compiler$NotExposed = {$: 0};
var $elm$core$String$toLower = _String_toLower;
var $author$project$Internal$Compiler$formatValue = function (str) {
	var formatted = _Utils_eq(
		$elm$core$String$toUpper(str),
		str) ? $elm$core$String$toLower(str) : _Utils_ap(
		$elm$core$String$toLower(
			A2($elm$core$String$left, 1, str)),
		A2($elm$core$String$dropLeft, 1, str));
	return $author$project$Internal$Compiler$sanitize(formatted);
};
var $elm$core$Maybe$map = F2(
	function (f, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return $elm$core$Maybe$Just(
				f(value));
		} else {
			return $elm$core$Maybe$Nothing;
		}
	});
var $author$project$Internal$Compiler$nodifyMaybe = $elm$core$Maybe$map($author$project$Internal$Compiler$nodify);
var $author$project$Elm$declaration = F2(
	function (name, _v0) {
		var body = _v0;
		return A3(
			$author$project$Internal$Compiler$Declaration,
			$author$project$Internal$Compiler$NotExposed,
			body.a,
			$stil4m$elm_syntax$Elm$Syntax$Declaration$FunctionDeclaration(
				{
					D: $author$project$Internal$Compiler$nodify(
						{
							B: _List_Nil,
							b: $author$project$Internal$Compiler$nodify(body.b),
							i: $author$project$Internal$Compiler$nodify(
								$author$project$Internal$Compiler$formatValue(name))
						}),
					x: $author$project$Internal$Compiler$nodifyMaybe($elm$core$Maybe$Nothing),
					R: function () {
						var _v1 = body.c;
						if (!_v1.$) {
							var sig = _v1.a;
							return $elm$core$Maybe$Just(
								$author$project$Internal$Compiler$nodify(
									{
										i: $author$project$Internal$Compiler$nodify(
											$author$project$Internal$Compiler$formatValue(name)),
										w: $author$project$Internal$Compiler$nodify(sig)
									}));
						} else {
							return $elm$core$Maybe$Nothing;
						}
					}()
				}));
	});
var $author$project$Internal$Compiler$Exposed = function (a) {
	return {$: 1, a: a};
};
var $author$project$Internal$Compiler$expose = function (decl) {
	if (decl.$ === 1) {
		return decl;
	} else {
		var imports = decl.b;
		var body = decl.c;
		return A3(
			$author$project$Internal$Compiler$Declaration,
			$author$project$Internal$Compiler$Exposed(
				{aa: false, ac: $elm$core$Maybe$Nothing}),
			imports,
			body);
	}
};
var $author$project$Elm$expose = $author$project$Internal$Compiler$expose;
var $author$project$Internal$Compiler$fullModName = function (_v0) {
	var name = _v0.a;
	return A2($elm$core$String$join, '.', name);
};
var $elm$core$Set$insert = F2(
	function (key, _v0) {
		var dict = _v0;
		return A3($elm$core$Dict$insert, key, 0, dict);
	});
var $author$project$Elm$addImports = F3(
	function (self, newImports, _v0) {
		addImports:
		while (true) {
			var set = _v0.a;
			var deduped = _v0.b;
			if (!newImports.b) {
				return _Utils_Tuple2(set, deduped);
			} else {
				var _new = newImports.a;
				var remain = newImports.b;
				var full = $author$project$Internal$Compiler$fullModName(_new);
				if (A2($elm$core$Set$member, full, set) || _Utils_eq(
					full,
					$author$project$Internal$Compiler$fullModName(self))) {
					var $temp$self = self,
						$temp$newImports = remain,
						$temp$_v0 = _Utils_Tuple2(set, deduped);
					self = $temp$self;
					newImports = $temp$newImports;
					_v0 = $temp$_v0;
					continue addImports;
				} else {
					var $temp$self = self,
						$temp$newImports = remain,
						$temp$_v0 = _Utils_Tuple2(
						A2($elm$core$Set$insert, full, set),
						A2($elm$core$List$cons, _new, deduped));
					self = $temp$self;
					newImports = $temp$newImports;
					_v0 = $temp$_v0;
					continue addImports;
				}
			}
		}
	});
var $author$project$Elm$reduceDeclarationImports = F3(
	function (self, decs, imports) {
		reduceDeclarationImports:
		while (true) {
			if (!decs.b) {
				return imports;
			} else {
				if (decs.a.$ === 1) {
					var remain = decs.b;
					var $temp$self = self,
						$temp$decs = remain,
						$temp$imports = imports;
					self = $temp$self;
					decs = $temp$decs;
					imports = $temp$imports;
					continue reduceDeclarationImports;
				} else {
					var _v1 = decs.a;
					var newImports = _v1.b;
					var body = _v1.c;
					var remain = decs.b;
					var $temp$self = self,
						$temp$decs = remain,
						$temp$imports = A3($author$project$Elm$addImports, self, newImports, imports);
					self = $temp$self;
					decs = $temp$decs;
					imports = $temp$imports;
					continue reduceDeclarationImports;
				}
			}
		}
	});
var $stil4m$elm_syntax$Elm$Syntax$Exposing$All = function (a) {
	return {$: 0, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$Exposing$Explicit = function (a) {
	return {$: 1, a: a};
};
var $author$project$Internal$Comments$Markdown = function (a) {
	return {$: 0, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$Module$NormalModule = function (a) {
	return {$: 0, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$Module$PortModule = function (a) {
	return {$: 1, a: a};
};
var $author$project$Internal$Comments$Comment = $elm$core$Basics$identity;
var $author$project$Internal$Comments$addPart = F2(
	function (_v0, part) {
		var parts = _v0;
		return A2($elm$core$List$cons, part, parts);
	});
var $author$project$Internal$Comments$emptyComment = _List_Nil;
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (!_v0.$) {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $stil4m$elm_syntax$Elm$Syntax$Exposing$FunctionExpose = function (a) {
	return {$: 1, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$Exposing$TypeExpose = function (a) {
	return {$: 3, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$Exposing$TypeOrAliasExpose = function (a) {
	return {$: 2, a: a};
};
var $author$project$Internal$Compiler$getExposed = function (decls) {
	return A2(
		$elm$core$List$filterMap,
		function (decl) {
			if (decl.$ === 1) {
				return $elm$core$Maybe$Nothing;
			} else {
				var exp = decl.a;
				var decBody = decl.c;
				if (!exp.$) {
					return $elm$core$Maybe$Nothing;
				} else {
					var details = exp.a;
					switch (decBody.$) {
						case 0:
							var fn = decBody.a;
							var fnName = $author$project$Internal$Compiler$denode(
								function ($) {
									return $.i;
								}(
									$author$project$Internal$Compiler$denode(fn.D)));
							return $elm$core$Maybe$Just(
								$stil4m$elm_syntax$Elm$Syntax$Exposing$FunctionExpose(fnName));
						case 1:
							var synonym = decBody.a;
							var aliasName = $author$project$Internal$Compiler$denode(synonym.i);
							return $elm$core$Maybe$Just(
								$stil4m$elm_syntax$Elm$Syntax$Exposing$TypeOrAliasExpose(aliasName));
						case 2:
							var myType = decBody.a;
							var typeName = $author$project$Internal$Compiler$denode(myType.i);
							return details.aa ? $elm$core$Maybe$Just(
								$stil4m$elm_syntax$Elm$Syntax$Exposing$TypeExpose(
									{
										i: typeName,
										b7: $elm$core$Maybe$Just($stil4m$elm_syntax$Elm$Syntax$Range$emptyRange)
									})) : $elm$core$Maybe$Just(
								$stil4m$elm_syntax$Elm$Syntax$Exposing$TypeOrAliasExpose(typeName));
						case 3:
							var myPort = decBody.a;
							var typeName = $author$project$Internal$Compiler$denode(myPort.i);
							return $elm$core$Maybe$Just(
								$stil4m$elm_syntax$Elm$Syntax$Exposing$FunctionExpose(typeName));
						case 4:
							var infix = decBody.a;
							return $elm$core$Maybe$Nothing;
						default:
							return $elm$core$Maybe$Nothing;
					}
				}
			}
		},
		decls);
};
var $author$project$Internal$Compiler$declName = function (decl) {
	if (decl.$ === 1) {
		return $elm$core$Maybe$Nothing;
	} else {
		var exp = decl.a;
		var decBody = decl.c;
		switch (decBody.$) {
			case 0:
				var fn = decBody.a;
				return $elm$core$Maybe$Just(
					$author$project$Internal$Compiler$denode(
						function ($) {
							return $.i;
						}(
							$author$project$Internal$Compiler$denode(fn.D))));
			case 1:
				var synonym = decBody.a;
				return $elm$core$Maybe$Just(
					$author$project$Internal$Compiler$denode(synonym.i));
			case 2:
				var myType = decBody.a;
				return $elm$core$Maybe$Just(
					$author$project$Internal$Compiler$denode(myType.i));
			case 3:
				var myPort = decBody.a;
				return $elm$core$Maybe$Just(
					$author$project$Internal$Compiler$denode(myPort.i));
			case 4:
				var infix = decBody.a;
				return $elm$core$Maybe$Nothing;
			default:
				return $elm$core$Maybe$Nothing;
		}
	}
};
var $author$project$Internal$Compiler$matchName = F2(
	function (one, two) {
		if (one.$ === 1) {
			if (two.$ === 1) {
				return true;
			} else {
				return false;
			}
		} else {
			var oneName = one.a;
			if (two.$ === 1) {
				return false;
			} else {
				var twoName = two.a;
				return _Utils_eq(oneName, twoName);
			}
		}
	});
var $author$project$Internal$Compiler$groupExposing = function (items) {
	return A3(
		$elm$core$List$foldr,
		F2(
			function (_v0, acc) {
				var maybeGroup = _v0.a;
				var name = _v0.b;
				if (!acc.b) {
					return _List_fromArray(
						[
							{
							ac: maybeGroup,
							b2: _List_fromArray(
								[name])
						}
						]);
				} else {
					var top = acc.a;
					var groups = acc.b;
					return A2($author$project$Internal$Compiler$matchName, maybeGroup, top.ac) ? A2(
						$elm$core$List$cons,
						{
							ac: top.ac,
							b2: A2($elm$core$List$cons, name, top.b2)
						},
						groups) : A2(
						$elm$core$List$cons,
						{
							ac: maybeGroup,
							b2: _List_fromArray(
								[name])
						},
						acc);
				}
			}),
		_List_Nil,
		items);
};
var $elm$core$List$sortBy = _List_sortBy;
var $author$project$Internal$Compiler$getExposedGroups = function (decls) {
	return $author$project$Internal$Compiler$groupExposing(
		A2(
			$elm$core$List$sortBy,
			function (_v3) {
				var group = _v3.a;
				if (group.$ === 1) {
					return 'zzzzzzzzz';
				} else {
					var name = group.a;
					return name;
				}
			},
			A2(
				$elm$core$List$filterMap,
				function (decl) {
					if (decl.$ === 1) {
						return $elm$core$Maybe$Nothing;
					} else {
						var exp = decl.a;
						var decBody = decl.c;
						if (!exp.$) {
							return $elm$core$Maybe$Nothing;
						} else {
							var details = exp.a;
							var _v2 = $author$project$Internal$Compiler$declName(decl);
							if (_v2.$ === 1) {
								return $elm$core$Maybe$Nothing;
							} else {
								var name = _v2.a;
								return $elm$core$Maybe$Just(
									_Utils_Tuple2(details.ac, name));
							}
						}
					}
				},
				decls)));
};
var $author$project$Internal$Compiler$getModule = function (_v0) {
	var name = _v0.a;
	return name;
};
var $elm$core$List$any = F2(
	function (isOkay, list) {
		any:
		while (true) {
			if (!list.b) {
				return false;
			} else {
				var x = list.a;
				var xs = list.b;
				if (isOkay(x)) {
					return true;
				} else {
					var $temp$isOkay = isOkay,
						$temp$list = xs;
					isOkay = $temp$isOkay;
					list = $temp$list;
					continue any;
				}
			}
		}
	});
var $author$project$Internal$Compiler$hasPorts = function (decls) {
	return A2(
		$elm$core$List$any,
		function (decl) {
			if (decl.$ === 1) {
				return false;
			} else {
				var exp = decl.a;
				var decBody = decl.c;
				if (!exp.$) {
					return false;
				} else {
					if (decBody.$ === 3) {
						var myPort = decBody.a;
						return true;
					} else {
						return false;
					}
				}
			}
		},
		decls);
};
var $author$project$Internal$Compiler$builtIn = function (name) {
	_v0$4:
	while (true) {
		if (name.b && (!name.b.b)) {
			switch (name.a) {
				case 'List':
					return true;
				case 'Maybe':
					return true;
				case 'String':
					return true;
				case 'Basics':
					return true;
				default:
					break _v0$4;
			}
		} else {
			break _v0$4;
		}
	}
	return false;
};
var $author$project$Internal$Compiler$makeImport = function (_v0) {
	var name = _v0.a;
	var maybeAlias = _v0.b;
	if (!name.b) {
		return $elm$core$Maybe$Nothing;
	} else {
		return ($author$project$Internal$Compiler$builtIn(name) && _Utils_eq(maybeAlias, $elm$core$Maybe$Nothing)) ? $elm$core$Maybe$Nothing : $elm$core$Maybe$Just(
			{
				bW: $elm$core$Maybe$Nothing,
				b3: A2(
					$elm$core$Maybe$map,
					function (al) {
						return $author$project$Internal$Compiler$nodify(
							_List_fromArray(
								[al]));
					},
					maybeAlias),
				b4: $author$project$Internal$Compiler$nodify(name)
			});
	}
};
var $the_sett$elm_pretty_printer$Internals$Concatenate = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $the_sett$elm_pretty_printer$Pretty$append = F2(
	function (doc1, doc2) {
		return A2(
			$the_sett$elm_pretty_printer$Internals$Concatenate,
			function (_v0) {
				return doc1;
			},
			function (_v1) {
				return doc2;
			});
	});
var $elm_community$basics_extra$Basics$Extra$flip = F3(
	function (f, b, a) {
		return A2(f, a, b);
	});
var $the_sett$elm_pretty_printer$Pretty$a = $elm_community$basics_extra$Basics$Extra$flip($the_sett$elm_pretty_printer$Pretty$append);
var $the_sett$elm_pretty_printer$Internals$Line = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $the_sett$elm_pretty_printer$Pretty$line = A2($the_sett$elm_pretty_printer$Internals$Line, ' ', '');
var $the_sett$elm_pretty_printer$Internals$Empty = {$: 0};
var $the_sett$elm_pretty_printer$Pretty$empty = $the_sett$elm_pretty_printer$Internals$Empty;
var $the_sett$elm_pretty_printer$Pretty$join = F2(
	function (sep, docs) {
		join:
		while (true) {
			if (!docs.b) {
				return $the_sett$elm_pretty_printer$Pretty$empty;
			} else {
				if (!docs.a.$) {
					var _v1 = docs.a;
					var ds = docs.b;
					var $temp$sep = sep,
						$temp$docs = ds;
					sep = $temp$sep;
					docs = $temp$docs;
					continue join;
				} else {
					var d = docs.a;
					var ds = docs.b;
					var step = F2(
						function (x, rest) {
							if (!x.$) {
								return rest;
							} else {
								var doc = x;
								return A2(
									$the_sett$elm_pretty_printer$Pretty$append,
									sep,
									A2($the_sett$elm_pretty_printer$Pretty$append, doc, rest));
							}
						});
					var spersed = A3($elm$core$List$foldr, step, $the_sett$elm_pretty_printer$Pretty$empty, ds);
					return A2($the_sett$elm_pretty_printer$Pretty$append, d, spersed);
				}
			}
		}
	});
var $the_sett$elm_pretty_printer$Pretty$lines = $the_sett$elm_pretty_printer$Pretty$join($the_sett$elm_pretty_printer$Pretty$line);
var $author$project$Internal$Compiler$denodeMaybe = $elm$core$Maybe$map($author$project$Internal$Compiler$denode);
var $author$project$Internal$Compiler$denodeAll = $elm$core$List$map($author$project$Internal$Compiler$denode);
var $the_sett$elm_pretty_printer$Internals$Text = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$core$String$cons = _String_cons;
var $elm$core$String$fromChar = function (_char) {
	return A2($elm$core$String$cons, _char, '');
};
var $the_sett$elm_pretty_printer$Pretty$char = function (c) {
	return A2(
		$the_sett$elm_pretty_printer$Internals$Text,
		$elm$core$String$fromChar(c),
		$elm$core$Maybe$Nothing);
};
var $the_sett$elm_pretty_printer$Pretty$surround = F3(
	function (left, right, doc) {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$append,
			A2($the_sett$elm_pretty_printer$Pretty$append, left, doc),
			right);
	});
var $the_sett$elm_pretty_printer$Pretty$parens = function (doc) {
	return A3(
		$the_sett$elm_pretty_printer$Pretty$surround,
		$the_sett$elm_pretty_printer$Pretty$char('('),
		$the_sett$elm_pretty_printer$Pretty$char(')'),
		doc);
};
var $the_sett$elm_pretty_printer$Pretty$string = function (val) {
	return A2($the_sett$elm_pretty_printer$Internals$Text, val, $elm$core$Maybe$Nothing);
};
var $author$project$Internal$Write$prettyTopLevelExpose = function (tlExpose) {
	switch (tlExpose.$) {
		case 0:
			var val = tlExpose.a;
			return $the_sett$elm_pretty_printer$Pretty$parens(
				$the_sett$elm_pretty_printer$Pretty$string(val));
		case 1:
			var val = tlExpose.a;
			return $the_sett$elm_pretty_printer$Pretty$string(val);
		case 2:
			var val = tlExpose.a;
			return $the_sett$elm_pretty_printer$Pretty$string(val);
		default:
			var exposedType = tlExpose.a;
			var _v1 = exposedType.b7;
			if (_v1.$ === 1) {
				return $the_sett$elm_pretty_printer$Pretty$string(exposedType.i);
			} else {
				return A2(
					$the_sett$elm_pretty_printer$Pretty$a,
					$the_sett$elm_pretty_printer$Pretty$string('(..)'),
					$the_sett$elm_pretty_printer$Pretty$string(exposedType.i));
			}
	}
};
var $author$project$Internal$Write$prettyTopLevelExposes = function (exposes) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$join,
		$the_sett$elm_pretty_printer$Pretty$string(', '),
		A2($elm$core$List$map, $author$project$Internal$Write$prettyTopLevelExpose, exposes));
};
var $stil4m$elm_syntax$Elm$Syntax$Exposing$InfixExpose = function (a) {
	return {$: 0, a: a};
};
var $author$project$Internal$ImportsAndExposing$combineTopLevelExposes = function (exposes) {
	if (!exposes.b) {
		return $stil4m$elm_syntax$Elm$Syntax$Exposing$InfixExpose('');
	} else {
		var hd = exposes.a;
		var tl = exposes.b;
		return A3(
			$elm$core$List$foldl,
			F2(
				function (exp, result) {
					var _v1 = _Utils_Tuple2(exp, result);
					if (_v1.a.$ === 3) {
						var typeExpose = _v1.a.a;
						var _v2 = typeExpose.b7;
						if (!_v2.$) {
							return exp;
						} else {
							return result;
						}
					} else {
						if (_v1.b.$ === 3) {
							var typeExpose = _v1.b.a;
							var _v3 = typeExpose.b7;
							if (!_v3.$) {
								return result;
							} else {
								return exp;
							}
						} else {
							return result;
						}
					}
				}),
			hd,
			tl);
	}
};
var $author$project$Internal$ImportsAndExposing$topLevelExposeName = function (tle) {
	switch (tle.$) {
		case 0:
			var val = tle.a;
			return val;
		case 1:
			var val = tle.a;
			return val;
		case 2:
			var val = tle.a;
			return val;
		default:
			var exposedType = tle.a;
			return exposedType.i;
	}
};
var $author$project$Internal$ImportsAndExposing$groupByExposingName = function (innerImports) {
	var _v0 = function () {
		if (!innerImports.b) {
			return _Utils_Tuple3(
				'',
				_List_Nil,
				_List_fromArray(
					[_List_Nil]));
		} else {
			var hd = innerImports.a;
			return A3(
				$elm$core$List$foldl,
				F2(
					function (exp, _v2) {
						var currName = _v2.a;
						var currAccum = _v2.b;
						var accum = _v2.c;
						var nextName = $author$project$Internal$ImportsAndExposing$topLevelExposeName(exp);
						return _Utils_eq(nextName, currName) ? _Utils_Tuple3(
							currName,
							A2($elm$core$List$cons, exp, currAccum),
							accum) : _Utils_Tuple3(
							nextName,
							_List_fromArray(
								[exp]),
							A2($elm$core$List$cons, currAccum, accum));
					}),
				_Utils_Tuple3(
					$author$project$Internal$ImportsAndExposing$topLevelExposeName(hd),
					_List_Nil,
					_List_Nil),
				innerImports);
		}
	}();
	var hdGroup = _v0.b;
	var remGroups = _v0.c;
	return $elm$core$List$reverse(
		A2($elm$core$List$cons, hdGroup, remGroups));
};
var $elm$core$List$sortWith = _List_sortWith;
var $author$project$Internal$ImportsAndExposing$topLevelExposeOrder = F2(
	function (tlel, tler) {
		var _v0 = _Utils_Tuple2(tlel, tler);
		if (!_v0.a.$) {
			if (!_v0.b.$) {
				return A2(
					$elm$core$Basics$compare,
					$author$project$Internal$ImportsAndExposing$topLevelExposeName(tlel),
					$author$project$Internal$ImportsAndExposing$topLevelExposeName(tler));
			} else {
				return 0;
			}
		} else {
			if (!_v0.b.$) {
				return 2;
			} else {
				return A2(
					$elm$core$Basics$compare,
					$author$project$Internal$ImportsAndExposing$topLevelExposeName(tlel),
					$author$project$Internal$ImportsAndExposing$topLevelExposeName(tler));
			}
		}
	});
var $author$project$Internal$ImportsAndExposing$sortAndDedupExposings = function (tlExposings) {
	return A2(
		$elm$core$List$map,
		$author$project$Internal$ImportsAndExposing$combineTopLevelExposes,
		$author$project$Internal$ImportsAndExposing$groupByExposingName(
			A2($elm$core$List$sortWith, $author$project$Internal$ImportsAndExposing$topLevelExposeOrder, tlExposings)));
};
var $the_sett$elm_pretty_printer$Pretty$space = $the_sett$elm_pretty_printer$Pretty$char(' ');
var $author$project$Internal$Write$prettyExposing = function (exposing_) {
	var exposings = function () {
		if (!exposing_.$) {
			return $the_sett$elm_pretty_printer$Pretty$parens(
				$the_sett$elm_pretty_printer$Pretty$string('..'));
		} else {
			var tll = exposing_.a;
			return $the_sett$elm_pretty_printer$Pretty$parens(
				$author$project$Internal$Write$prettyTopLevelExposes(
					$author$project$Internal$ImportsAndExposing$sortAndDedupExposings(
						$author$project$Internal$Compiler$denodeAll(tll))));
		}
	}();
	return A2(
		$the_sett$elm_pretty_printer$Pretty$a,
		exposings,
		A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$space,
			$the_sett$elm_pretty_printer$Pretty$string('exposing')));
};
var $author$project$Internal$Write$prettyMaybe = F2(
	function (prettyFn, maybeVal) {
		return A2(
			$elm$core$Maybe$withDefault,
			$the_sett$elm_pretty_printer$Pretty$empty,
			A2($elm$core$Maybe$map, prettyFn, maybeVal));
	});
var $author$project$Internal$Write$dot = $the_sett$elm_pretty_printer$Pretty$string('.');
var $author$project$Internal$Write$prettyModuleName = function (name) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$join,
		$author$project$Internal$Write$dot,
		A2($elm$core$List$map, $the_sett$elm_pretty_printer$Pretty$string, name));
};
var $author$project$Internal$Write$prettyModuleNameAlias = function (name) {
	if (!name.b) {
		return $the_sett$elm_pretty_printer$Pretty$empty;
	} else {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			A2(
				$the_sett$elm_pretty_printer$Pretty$join,
				$author$project$Internal$Write$dot,
				A2($elm$core$List$map, $the_sett$elm_pretty_printer$Pretty$string, name)),
			$the_sett$elm_pretty_printer$Pretty$string('as '));
	}
};
var $author$project$Internal$Write$prettyImport = function (import_) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$join,
		$the_sett$elm_pretty_printer$Pretty$space,
		_List_fromArray(
			[
				$the_sett$elm_pretty_printer$Pretty$string('import'),
				$author$project$Internal$Write$prettyModuleName(
				$author$project$Internal$Compiler$denode(import_.b4)),
				A2(
				$author$project$Internal$Write$prettyMaybe,
				$author$project$Internal$Write$prettyModuleNameAlias,
				$author$project$Internal$Compiler$denodeMaybe(import_.b3)),
				A2(
				$author$project$Internal$Write$prettyMaybe,
				$author$project$Internal$Write$prettyExposing,
				$author$project$Internal$Compiler$denodeMaybe(import_.bW))
			]));
};
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $author$project$Internal$ImportsAndExposing$denode = $stil4m$elm_syntax$Elm$Syntax$Node$value;
var $author$project$Internal$ImportsAndExposing$denodeMaybe = $elm$core$Maybe$map($author$project$Internal$ImportsAndExposing$denode);
var $author$project$Internal$ImportsAndExposing$denodeAll = $elm$core$List$map($author$project$Internal$ImportsAndExposing$denode);
var $author$project$Internal$ImportsAndExposing$nodify = function (exp) {
	return A2($stil4m$elm_syntax$Elm$Syntax$Node$Node, $stil4m$elm_syntax$Elm$Syntax$Range$emptyRange, exp);
};
var $author$project$Internal$ImportsAndExposing$nodifyAll = $elm$core$List$map($author$project$Internal$ImportsAndExposing$nodify);
var $author$project$Internal$ImportsAndExposing$joinExposings = F2(
	function (left, right) {
		var _v0 = _Utils_Tuple2(left, right);
		if (!_v0.a.$) {
			var range = _v0.a.a;
			return $stil4m$elm_syntax$Elm$Syntax$Exposing$All(range);
		} else {
			if (!_v0.b.$) {
				var range = _v0.b.a;
				return $stil4m$elm_syntax$Elm$Syntax$Exposing$All(range);
			} else {
				var leftNodes = _v0.a.a;
				var rightNodes = _v0.b.a;
				return $stil4m$elm_syntax$Elm$Syntax$Exposing$Explicit(
					$author$project$Internal$ImportsAndExposing$nodifyAll(
						A2(
							$elm$core$List$append,
							$author$project$Internal$ImportsAndExposing$denodeAll(leftNodes),
							$author$project$Internal$ImportsAndExposing$denodeAll(rightNodes))));
			}
		}
	});
var $author$project$Internal$ImportsAndExposing$joinMaybeExposings = F2(
	function (maybeLeft, maybeRight) {
		var _v0 = _Utils_Tuple2(maybeLeft, maybeRight);
		if (_v0.a.$ === 1) {
			if (_v0.b.$ === 1) {
				var _v1 = _v0.a;
				var _v2 = _v0.b;
				return $elm$core$Maybe$Nothing;
			} else {
				var _v4 = _v0.a;
				var right = _v0.b.a;
				return $elm$core$Maybe$Just(right);
			}
		} else {
			if (_v0.b.$ === 1) {
				var left = _v0.a.a;
				var _v3 = _v0.b;
				return $elm$core$Maybe$Just(left);
			} else {
				var left = _v0.a.a;
				var right = _v0.b.a;
				return $elm$core$Maybe$Just(
					A2($author$project$Internal$ImportsAndExposing$joinExposings, left, right));
			}
		}
	});
var $author$project$Internal$ImportsAndExposing$nodifyMaybe = $elm$core$Maybe$map($author$project$Internal$ImportsAndExposing$nodify);
var $elm_community$maybe_extra$Maybe$Extra$or = F2(
	function (ma, mb) {
		if (ma.$ === 1) {
			return mb;
		} else {
			return ma;
		}
	});
var $author$project$Internal$ImportsAndExposing$sortAndDedupExposing = function (exp) {
	if (!exp.$) {
		var range = exp.a;
		return $stil4m$elm_syntax$Elm$Syntax$Exposing$All(range);
	} else {
		var nodes = exp.a;
		return $stil4m$elm_syntax$Elm$Syntax$Exposing$Explicit(
			$author$project$Internal$ImportsAndExposing$nodifyAll(
				$author$project$Internal$ImportsAndExposing$sortAndDedupExposings(
					$author$project$Internal$ImportsAndExposing$denodeAll(nodes))));
	}
};
var $author$project$Internal$ImportsAndExposing$combineImports = function (innerImports) {
	if (!innerImports.b) {
		return {
			bW: $elm$core$Maybe$Nothing,
			b3: $elm$core$Maybe$Nothing,
			b4: $author$project$Internal$ImportsAndExposing$nodify(_List_Nil)
		};
	} else {
		var hd = innerImports.a;
		var tl = innerImports.b;
		var combinedImports = A3(
			$elm$core$List$foldl,
			F2(
				function (imp, result) {
					return {
						bW: $author$project$Internal$ImportsAndExposing$nodifyMaybe(
							A2(
								$author$project$Internal$ImportsAndExposing$joinMaybeExposings,
								$author$project$Internal$ImportsAndExposing$denodeMaybe(imp.bW),
								$author$project$Internal$ImportsAndExposing$denodeMaybe(result.bW))),
						b3: A2($elm_community$maybe_extra$Maybe$Extra$or, imp.b3, result.b3),
						b4: imp.b4
					};
				}),
			hd,
			tl);
		return _Utils_update(
			combinedImports,
			{
				bW: A2(
					$elm$core$Maybe$map,
					A2(
						$elm$core$Basics$composeR,
						$author$project$Internal$ImportsAndExposing$denode,
						A2($elm$core$Basics$composeR, $author$project$Internal$ImportsAndExposing$sortAndDedupExposing, $author$project$Internal$ImportsAndExposing$nodify)),
					combinedImports.bW)
			});
	}
};
var $author$project$Internal$ImportsAndExposing$groupByModuleName = function (innerImports) {
	var _v0 = function () {
		if (!innerImports.b) {
			return _Utils_Tuple3(
				_List_Nil,
				_List_Nil,
				_List_fromArray(
					[_List_Nil]));
		} else {
			var hd = innerImports.a;
			return A3(
				$elm$core$List$foldl,
				F2(
					function (imp, _v2) {
						var currName = _v2.a;
						var currAccum = _v2.b;
						var accum = _v2.c;
						var nextName = $author$project$Internal$ImportsAndExposing$denode(imp.b4);
						return _Utils_eq(nextName, currName) ? _Utils_Tuple3(
							currName,
							A2($elm$core$List$cons, imp, currAccum),
							accum) : _Utils_Tuple3(
							nextName,
							_List_fromArray(
								[imp]),
							A2($elm$core$List$cons, currAccum, accum));
					}),
				_Utils_Tuple3(
					$author$project$Internal$ImportsAndExposing$denode(hd.b4),
					_List_Nil,
					_List_Nil),
				innerImports);
		}
	}();
	var hdGroup = _v0.b;
	var remGroups = _v0.c;
	return $elm$core$List$reverse(
		A2($elm$core$List$cons, hdGroup, remGroups));
};
var $author$project$Internal$ImportsAndExposing$sortAndDedupImports = function (imports) {
	var impName = function (imp) {
		return $author$project$Internal$ImportsAndExposing$denode(imp.b4);
	};
	return A2(
		$elm$core$List$map,
		$author$project$Internal$ImportsAndExposing$combineImports,
		$author$project$Internal$ImportsAndExposing$groupByModuleName(
			A2($elm$core$List$sortBy, impName, imports)));
};
var $author$project$Internal$Write$prettyImports = function (imports) {
	return $the_sett$elm_pretty_printer$Pretty$lines(
		A2(
			$elm$core$List$map,
			$author$project$Internal$Write$prettyImport,
			$author$project$Internal$ImportsAndExposing$sortAndDedupImports(imports)));
};
var $author$project$Internal$Write$importsPretty = function (imports) {
	if (!imports.b) {
		return $the_sett$elm_pretty_printer$Pretty$line;
	} else {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$line,
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				$the_sett$elm_pretty_printer$Pretty$line,
				A2(
					$the_sett$elm_pretty_printer$Pretty$a,
					$the_sett$elm_pretty_printer$Pretty$line,
					$author$project$Internal$Write$prettyImports(imports))));
	}
};
var $author$project$Internal$Write$prettyComments = function (comments) {
	if (!comments.b) {
		return $the_sett$elm_pretty_printer$Pretty$empty;
	} else {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$line,
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				$the_sett$elm_pretty_printer$Pretty$line,
				$the_sett$elm_pretty_printer$Pretty$lines(
					A2($elm$core$List$map, $the_sett$elm_pretty_printer$Pretty$string, comments))));
	}
};
var $the_sett$elm_pretty_printer$Internals$Nest = F2(
	function (a, b) {
		return {$: 2, a: a, b: b};
	});
var $the_sett$elm_pretty_printer$Pretty$nest = F2(
	function (depth, doc) {
		return A2(
			$the_sett$elm_pretty_printer$Internals$Nest,
			depth,
			function (_v0) {
				return doc;
			});
	});
var $author$project$Internal$Write$prettyDocumentation = function (docs) {
	return $the_sett$elm_pretty_printer$Pretty$string(docs);
};
var $the_sett$elm_pretty_printer$Internals$Union = F2(
	function (a, b) {
		return {$: 5, a: a, b: b};
	});
var $the_sett$elm_pretty_printer$Internals$flatten = function (doc) {
	flatten:
	while (true) {
		switch (doc.$) {
			case 1:
				var doc1 = doc.a;
				var doc2 = doc.b;
				return A2(
					$the_sett$elm_pretty_printer$Internals$Concatenate,
					function (_v1) {
						return $the_sett$elm_pretty_printer$Internals$flatten(
							doc1(0));
					},
					function (_v2) {
						return $the_sett$elm_pretty_printer$Internals$flatten(
							doc2(0));
					});
			case 2:
				var i = doc.a;
				var doc1 = doc.b;
				return A2(
					$the_sett$elm_pretty_printer$Internals$Nest,
					i,
					function (_v3) {
						return $the_sett$elm_pretty_printer$Internals$flatten(
							doc1(0));
					});
			case 5:
				var doc1 = doc.a;
				var doc2 = doc.b;
				var $temp$doc = doc1;
				doc = $temp$doc;
				continue flatten;
			case 4:
				var hsep = doc.a;
				return A2($the_sett$elm_pretty_printer$Internals$Text, hsep, $elm$core$Maybe$Nothing);
			case 6:
				var fn = doc.a;
				var $temp$doc = fn(0);
				doc = $temp$doc;
				continue flatten;
			case 7:
				var fn = doc.a;
				var $temp$doc = fn(0);
				doc = $temp$doc;
				continue flatten;
			default:
				var x = doc;
				return x;
		}
	}
};
var $the_sett$elm_pretty_printer$Pretty$group = function (doc) {
	return A2(
		$the_sett$elm_pretty_printer$Internals$Union,
		$the_sett$elm_pretty_printer$Internals$flatten(doc),
		doc);
};
var $author$project$Internal$Write$isNakedCompound = function (typeAnn) {
	switch (typeAnn.$) {
		case 1:
			if (!typeAnn.b.b) {
				return false;
			} else {
				var args = typeAnn.b;
				return true;
			}
		case 6:
			return true;
		default:
			return false;
	}
};
var $elm$core$Tuple$mapBoth = F3(
	function (funcA, funcB, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			funcA(x),
			funcB(y));
	});
var $author$project$Internal$Write$prettyModuleNameDot = function (name) {
	if (!name.b) {
		return $the_sett$elm_pretty_printer$Pretty$empty;
	} else {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$author$project$Internal$Write$dot,
			A2(
				$the_sett$elm_pretty_printer$Pretty$join,
				$author$project$Internal$Write$dot,
				A2($elm$core$List$map, $the_sett$elm_pretty_printer$Pretty$string, name)));
	}
};
var $the_sett$elm_pretty_printer$Pretty$separators = function (sep) {
	return $the_sett$elm_pretty_printer$Pretty$join(
		A2($the_sett$elm_pretty_printer$Internals$Line, sep, sep));
};
var $the_sett$elm_pretty_printer$Pretty$words = $the_sett$elm_pretty_printer$Pretty$join($the_sett$elm_pretty_printer$Pretty$space);
var $author$project$Internal$Write$prettyFieldTypeAnn = function (_v8) {
	var name = _v8.a;
	var ann = _v8.b;
	return $the_sett$elm_pretty_printer$Pretty$group(
		A2(
			$the_sett$elm_pretty_printer$Pretty$nest,
			4,
			$the_sett$elm_pretty_printer$Pretty$lines(
				_List_fromArray(
					[
						$the_sett$elm_pretty_printer$Pretty$words(
						_List_fromArray(
							[
								$the_sett$elm_pretty_printer$Pretty$string(name),
								$the_sett$elm_pretty_printer$Pretty$string(':')
							])),
						$author$project$Internal$Write$prettyTypeAnnotation(ann)
					]))));
};
var $author$project$Internal$Write$prettyFunctionTypeAnnotation = F2(
	function (left, right) {
		var expandLeft = function (ann) {
			if (ann.$ === 6) {
				return $author$project$Internal$Write$prettyTypeAnnotationParens(ann);
			} else {
				return $author$project$Internal$Write$prettyTypeAnnotation(ann);
			}
		};
		var innerFnTypeAnn = F2(
			function (innerLeft, innerRight) {
				var rightSide = expandRight(
					$author$project$Internal$Compiler$denode(innerRight));
				if (rightSide.b) {
					var hd = rightSide.a;
					var tl = rightSide.b;
					return A2(
						$elm$core$List$cons,
						expandLeft(
							$author$project$Internal$Compiler$denode(innerLeft)),
						A2(
							$elm$core$List$cons,
							$the_sett$elm_pretty_printer$Pretty$words(
								_List_fromArray(
									[
										$the_sett$elm_pretty_printer$Pretty$string('->'),
										hd
									])),
							tl));
				} else {
					return _List_Nil;
				}
			});
		var expandRight = function (ann) {
			if (ann.$ === 6) {
				var innerLeft = ann.a;
				var innerRight = ann.b;
				return A2(innerFnTypeAnn, innerLeft, innerRight);
			} else {
				return _List_fromArray(
					[
						$author$project$Internal$Write$prettyTypeAnnotation(ann)
					]);
			}
		};
		return $the_sett$elm_pretty_printer$Pretty$group(
			$the_sett$elm_pretty_printer$Pretty$lines(
				A2(innerFnTypeAnn, left, right)));
	});
var $author$project$Internal$Write$prettyGenericRecord = F2(
	function (paramName, fields) {
		var open = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$line,
			$the_sett$elm_pretty_printer$Pretty$words(
				_List_fromArray(
					[
						$the_sett$elm_pretty_printer$Pretty$string('{'),
						$the_sett$elm_pretty_printer$Pretty$string(paramName)
					])));
		var close = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$string('}'),
			$the_sett$elm_pretty_printer$Pretty$line);
		var addBarToFirst = function (exprs) {
			if (!exprs.b) {
				return _List_Nil;
			} else {
				var hd = exprs.a;
				var tl = exprs.b;
				return A2(
					$elm$core$List$cons,
					A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						hd,
						$the_sett$elm_pretty_printer$Pretty$string('| ')),
					tl);
			}
		};
		if (!fields.b) {
			return $the_sett$elm_pretty_printer$Pretty$string('{}');
		} else {
			return $the_sett$elm_pretty_printer$Pretty$group(
				A3(
					$the_sett$elm_pretty_printer$Pretty$surround,
					$the_sett$elm_pretty_printer$Pretty$empty,
					close,
					A2(
						$the_sett$elm_pretty_printer$Pretty$nest,
						4,
						A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							A2(
								$the_sett$elm_pretty_printer$Pretty$separators,
								', ',
								addBarToFirst(
									A2(
										$elm$core$List$map,
										$author$project$Internal$Write$prettyFieldTypeAnn,
										A2(
											$elm$core$List$map,
											A2($elm$core$Tuple$mapBoth, $author$project$Internal$Compiler$denode, $author$project$Internal$Compiler$denode),
											fields)))),
							open))));
		}
	});
var $author$project$Internal$Write$prettyRecord = function (fields) {
	var open = A2(
		$the_sett$elm_pretty_printer$Pretty$a,
		$the_sett$elm_pretty_printer$Pretty$space,
		$the_sett$elm_pretty_printer$Pretty$string('{'));
	var close = A2(
		$the_sett$elm_pretty_printer$Pretty$a,
		$the_sett$elm_pretty_printer$Pretty$string('}'),
		$the_sett$elm_pretty_printer$Pretty$line);
	if (!fields.b) {
		return $the_sett$elm_pretty_printer$Pretty$string('{}');
	} else {
		return $the_sett$elm_pretty_printer$Pretty$group(
			A3(
				$the_sett$elm_pretty_printer$Pretty$surround,
				open,
				close,
				A2(
					$the_sett$elm_pretty_printer$Pretty$separators,
					', ',
					A2(
						$elm$core$List$map,
						$author$project$Internal$Write$prettyFieldTypeAnn,
						A2(
							$elm$core$List$map,
							A2($elm$core$Tuple$mapBoth, $author$project$Internal$Compiler$denode, $author$project$Internal$Compiler$denode),
							fields)))));
	}
};
var $author$project$Internal$Write$prettyTupled = function (anns) {
	return $the_sett$elm_pretty_printer$Pretty$parens(
		A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$space,
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				A2(
					$the_sett$elm_pretty_printer$Pretty$join,
					$the_sett$elm_pretty_printer$Pretty$string(', '),
					A2(
						$elm$core$List$map,
						$author$project$Internal$Write$prettyTypeAnnotation,
						$author$project$Internal$Compiler$denodeAll(anns))),
				$the_sett$elm_pretty_printer$Pretty$space)));
};
var $author$project$Internal$Write$prettyTypeAnnotation = function (typeAnn) {
	switch (typeAnn.$) {
		case 0:
			var val = typeAnn.a;
			return $the_sett$elm_pretty_printer$Pretty$string(val);
		case 1:
			var fqName = typeAnn.a;
			var anns = typeAnn.b;
			return A2($author$project$Internal$Write$prettyTyped, fqName, anns);
		case 2:
			return $the_sett$elm_pretty_printer$Pretty$string('()');
		case 3:
			var anns = typeAnn.a;
			return $author$project$Internal$Write$prettyTupled(anns);
		case 4:
			var recordDef = typeAnn.a;
			return $author$project$Internal$Write$prettyRecord(
				$author$project$Internal$Compiler$denodeAll(recordDef));
		case 5:
			var paramName = typeAnn.a;
			var recordDef = typeAnn.b;
			return A2(
				$author$project$Internal$Write$prettyGenericRecord,
				$author$project$Internal$Compiler$denode(paramName),
				$author$project$Internal$Compiler$denodeAll(
					$author$project$Internal$Compiler$denode(recordDef)));
		default:
			var fromAnn = typeAnn.a;
			var toAnn = typeAnn.b;
			return A2($author$project$Internal$Write$prettyFunctionTypeAnnotation, fromAnn, toAnn);
	}
};
var $author$project$Internal$Write$prettyTypeAnnotationParens = function (typeAnn) {
	return $author$project$Internal$Write$isNakedCompound(typeAnn) ? $the_sett$elm_pretty_printer$Pretty$parens(
		$author$project$Internal$Write$prettyTypeAnnotation(typeAnn)) : $author$project$Internal$Write$prettyTypeAnnotation(typeAnn);
};
var $author$project$Internal$Write$prettyTyped = F2(
	function (fqName, anns) {
		var argsDoc = $the_sett$elm_pretty_printer$Pretty$words(
			A2(
				$elm$core$List$map,
				$author$project$Internal$Write$prettyTypeAnnotationParens,
				$author$project$Internal$Compiler$denodeAll(anns)));
		var _v0 = $author$project$Internal$Compiler$denode(fqName);
		var moduleName = _v0.a;
		var typeName = _v0.b;
		var typeDoc = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$string(typeName),
			$author$project$Internal$Write$prettyModuleNameDot(moduleName));
		return $the_sett$elm_pretty_printer$Pretty$words(
			_List_fromArray(
				[typeDoc, argsDoc]));
	});
var $author$project$Internal$Write$prettyValueConstructor = function (cons) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$nest,
		4,
		$the_sett$elm_pretty_printer$Pretty$group(
			$the_sett$elm_pretty_printer$Pretty$lines(
				_List_fromArray(
					[
						$the_sett$elm_pretty_printer$Pretty$string(
						$author$project$Internal$Compiler$denode(cons.i)),
						$the_sett$elm_pretty_printer$Pretty$lines(
						A2(
							$elm$core$List$map,
							$author$project$Internal$Write$prettyTypeAnnotationParens,
							$author$project$Internal$Compiler$denodeAll(cons.B)))
					]))));
};
var $author$project$Internal$Write$prettyValueConstructors = function (constructors) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$join,
		A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$string('| '),
			$the_sett$elm_pretty_printer$Pretty$line),
		A2($elm$core$List$map, $author$project$Internal$Write$prettyValueConstructor, constructors));
};
var $author$project$Internal$Write$prettyCustomType = function (type_) {
	var customTypePretty = A2(
		$the_sett$elm_pretty_printer$Pretty$nest,
		4,
		A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$author$project$Internal$Write$prettyValueConstructors(
				$author$project$Internal$Compiler$denodeAll(type_.bP)),
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				$the_sett$elm_pretty_printer$Pretty$string('= '),
				A2(
					$the_sett$elm_pretty_printer$Pretty$a,
					$the_sett$elm_pretty_printer$Pretty$line,
					$the_sett$elm_pretty_printer$Pretty$words(
						_List_fromArray(
							[
								$the_sett$elm_pretty_printer$Pretty$string('type'),
								$the_sett$elm_pretty_printer$Pretty$string(
								$author$project$Internal$Compiler$denode(type_.i)),
								$the_sett$elm_pretty_printer$Pretty$words(
								A2(
									$elm$core$List$map,
									$the_sett$elm_pretty_printer$Pretty$string,
									$author$project$Internal$Compiler$denodeAll(type_.a0)))
							]))))));
	return $the_sett$elm_pretty_printer$Pretty$lines(
		_List_fromArray(
			[
				A2(
				$author$project$Internal$Write$prettyMaybe,
				$author$project$Internal$Write$prettyDocumentation,
				$author$project$Internal$Compiler$denodeMaybe(type_.x)),
				customTypePretty
			]));
};
var $author$project$Internal$Write$adjustExpressionParentheses = F2(
	function (context, expression) {
		var shouldRemove = function (expr) {
			var _v3 = _Utils_Tuple3(context.N, context.M, expr);
			_v3$1:
			while (true) {
				if (_v3.a) {
					return true;
				} else {
					switch (_v3.c.$) {
						case 1:
							if (_v3.b) {
								break _v3$1;
							} else {
								return (context.P < 11) ? true : false;
							}
						case 3:
							if (_v3.b) {
								break _v3$1;
							} else {
								var _v4 = _v3.c;
								return true;
							}
						case 7:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 8:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 9:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 10:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 11:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 12:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 13:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 18:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 19:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 20:
							if (_v3.b) {
								break _v3$1;
							} else {
								var _v5 = _v3.c;
								return true;
							}
						case 21:
							if (_v3.b) {
								break _v3$1;
							} else {
								return true;
							}
						case 22:
							if (_v3.b) {
								break _v3$1;
							} else {
								var _v6 = _v3.c;
								return true;
							}
						default:
							if (_v3.b) {
								break _v3$1;
							} else {
								return false;
							}
					}
				}
			}
			return true;
		};
		var removeParens = function (expr) {
			if (expr.$ === 14) {
				var innerExpr = expr.a;
				return shouldRemove(
					$author$project$Internal$Compiler$denode(innerExpr)) ? removeParens(
					$author$project$Internal$Compiler$denode(innerExpr)) : expr;
			} else {
				return expr;
			}
		};
		var addParens = function (expr) {
			var _v1 = _Utils_Tuple3(context.N, context.M, expr);
			_v1$4:
			while (true) {
				if ((!_v1.a) && (!_v1.b)) {
					switch (_v1.c.$) {
						case 15:
							return $stil4m$elm_syntax$Elm$Syntax$Expression$ParenthesizedExpression(
								$author$project$Internal$Compiler$nodify(expr));
						case 16:
							return $stil4m$elm_syntax$Elm$Syntax$Expression$ParenthesizedExpression(
								$author$project$Internal$Compiler$nodify(expr));
						case 17:
							return $stil4m$elm_syntax$Elm$Syntax$Expression$ParenthesizedExpression(
								$author$project$Internal$Compiler$nodify(expr));
						case 4:
							var _v2 = _v1.c;
							return $stil4m$elm_syntax$Elm$Syntax$Expression$ParenthesizedExpression(
								$author$project$Internal$Compiler$nodify(expr));
						default:
							break _v1$4;
					}
				} else {
					break _v1$4;
				}
			}
			return expr;
		};
		return addParens(
			removeParens(expression));
	});
var $the_sett$elm_pretty_printer$Internals$Column = function (a) {
	return {$: 7, a: a};
};
var $the_sett$elm_pretty_printer$Pretty$column = $the_sett$elm_pretty_printer$Internals$Column;
var $the_sett$elm_pretty_printer$Internals$Nesting = function (a) {
	return {$: 6, a: a};
};
var $the_sett$elm_pretty_printer$Pretty$nesting = $the_sett$elm_pretty_printer$Internals$Nesting;
var $the_sett$elm_pretty_printer$Pretty$align = function (doc) {
	return $the_sett$elm_pretty_printer$Pretty$column(
		function (currentColumn) {
			return $the_sett$elm_pretty_printer$Pretty$nesting(
				function (indentLvl) {
					return A2($the_sett$elm_pretty_printer$Pretty$nest, currentColumn - indentLvl, doc);
				});
		});
};
var $Chadtech$elm_bool_extra$Bool$Extra$any = $elm$core$List$any($elm$core$Basics$identity);
var $elm$core$Basics$modBy = _Basics_modBy;
var $author$project$Internal$Write$decrementIndent = F2(
	function (currentIndent, spaces) {
		var modded = A2($elm$core$Basics$modBy, 4, currentIndent - spaces);
		return (!modded) ? 4 : modded;
	});
var $author$project$Internal$Write$doubleLines = $the_sett$elm_pretty_printer$Pretty$join(
	A2($the_sett$elm_pretty_printer$Pretty$a, $the_sett$elm_pretty_printer$Pretty$line, $the_sett$elm_pretty_printer$Pretty$line));
var $author$project$Internal$Write$escapeChar = function (val) {
	switch (val) {
		case '\\':
			return '\\\\';
		case '\'':
			return '\\\'';
		case '\t':
			return '\\t';
		case '\n':
			return '\\n';
		default:
			var c = val;
			return $elm$core$String$fromChar(c);
	}
};
var $elm$core$String$fromFloat = _String_fromNumber;
var $the_sett$elm_pretty_printer$Internals$copy = F2(
	function (i, s) {
		return (!i) ? '' : _Utils_ap(
			s,
			A2($the_sett$elm_pretty_printer$Internals$copy, i - 1, s));
	});
var $the_sett$elm_pretty_printer$Pretty$hang = F2(
	function (spaces, doc) {
		return $the_sett$elm_pretty_printer$Pretty$align(
			A2($the_sett$elm_pretty_printer$Pretty$nest, spaces, doc));
	});
var $the_sett$elm_pretty_printer$Pretty$indent = F2(
	function (spaces, doc) {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$hang,
			spaces,
			A2(
				$the_sett$elm_pretty_printer$Pretty$append,
				$the_sett$elm_pretty_printer$Pretty$string(
					A2($the_sett$elm_pretty_printer$Internals$copy, spaces, ' ')),
				doc));
	});
var $elm$core$Tuple$mapSecond = F2(
	function (func, _v0) {
		var x = _v0.a;
		var y = _v0.b;
		return _Utils_Tuple2(
			x,
			func(y));
	});
var $author$project$Internal$Write$optionalGroup = F2(
	function (flag, doc) {
		return flag ? doc : $the_sett$elm_pretty_printer$Pretty$group(doc);
	});
var $author$project$Internal$Write$precedence = function (symbol) {
	switch (symbol) {
		case '>>':
			return 9;
		case '<<':
			return 9;
		case '^':
			return 8;
		case '*':
			return 7;
		case '/':
			return 7;
		case '//':
			return 7;
		case '%':
			return 7;
		case 'rem':
			return 7;
		case '+':
			return 6;
		case '-':
			return 6;
		case '++':
			return 5;
		case '::':
			return 5;
		case '==':
			return 4;
		case '/=':
			return 4;
		case '<':
			return 4;
		case '>':
			return 4;
		case '<=':
			return 4;
		case '>=':
			return 4;
		case '&&':
			return 3;
		case '||':
			return 2;
		case '|>':
			return 0;
		case '<|':
			return 0;
		default:
			return 0;
	}
};
var $stil4m$elm_syntax$Elm$Syntax$Pattern$ParenthesizedPattern = function (a) {
	return {$: 14, a: a};
};
var $author$project$Internal$Write$adjustPatternParentheses = F2(
	function (isTop, pattern) {
		var shouldRemove = function (pat) {
			var _v5 = _Utils_Tuple2(isTop, pat);
			_v5$2:
			while (true) {
				switch (_v5.b.$) {
					case 12:
						if (!_v5.a) {
							var _v6 = _v5.b;
							return false;
						} else {
							break _v5$2;
						}
					case 13:
						var _v7 = _v5.b;
						return false;
					default:
						break _v5$2;
				}
			}
			return isTop;
		};
		var removeParens = function (pat) {
			if (pat.$ === 14) {
				var innerPat = pat.a;
				return shouldRemove(
					$author$project$Internal$Compiler$denode(innerPat)) ? removeParens(
					$author$project$Internal$Compiler$denode(innerPat)) : pat;
			} else {
				return pat;
			}
		};
		var addParens = function (pat) {
			var _v1 = _Utils_Tuple2(isTop, pat);
			_v1$2:
			while (true) {
				if (!_v1.a) {
					switch (_v1.b.$) {
						case 12:
							if (_v1.b.b.b) {
								var _v2 = _v1.b;
								var _v3 = _v2.b;
								return $stil4m$elm_syntax$Elm$Syntax$Pattern$ParenthesizedPattern(
									$author$project$Internal$Compiler$nodify(pat));
							} else {
								break _v1$2;
							}
						case 13:
							var _v4 = _v1.b;
							return $stil4m$elm_syntax$Elm$Syntax$Pattern$ParenthesizedPattern(
								$author$project$Internal$Compiler$nodify(pat));
						default:
							break _v1$2;
					}
				} else {
					break _v1$2;
				}
			}
			return pat;
		};
		return addParens(
			removeParens(pattern));
	});
var $the_sett$elm_pretty_printer$Pretty$braces = function (doc) {
	return A3(
		$the_sett$elm_pretty_printer$Pretty$surround,
		$the_sett$elm_pretty_printer$Pretty$char('{'),
		$the_sett$elm_pretty_printer$Pretty$char('}'),
		doc);
};
var $author$project$Internal$Write$quotes = function (doc) {
	return A3(
		$the_sett$elm_pretty_printer$Pretty$surround,
		$the_sett$elm_pretty_printer$Pretty$char('\"'),
		$the_sett$elm_pretty_printer$Pretty$char('\"'),
		doc);
};
var $author$project$Internal$Write$singleQuotes = function (doc) {
	return A3(
		$the_sett$elm_pretty_printer$Pretty$surround,
		$the_sett$elm_pretty_printer$Pretty$char('\''),
		$the_sett$elm_pretty_printer$Pretty$char('\''),
		doc);
};
var $elm$core$String$fromList = _String_fromList;
var $rtfeldman$elm_hex$Hex$unsafeToDigit = function (num) {
	unsafeToDigit:
	while (true) {
		switch (num) {
			case 0:
				return '0';
			case 1:
				return '1';
			case 2:
				return '2';
			case 3:
				return '3';
			case 4:
				return '4';
			case 5:
				return '5';
			case 6:
				return '6';
			case 7:
				return '7';
			case 8:
				return '8';
			case 9:
				return '9';
			case 10:
				return 'a';
			case 11:
				return 'b';
			case 12:
				return 'c';
			case 13:
				return 'd';
			case 14:
				return 'e';
			case 15:
				return 'f';
			default:
				var $temp$num = num;
				num = $temp$num;
				continue unsafeToDigit;
		}
	}
};
var $rtfeldman$elm_hex$Hex$unsafePositiveToDigits = F2(
	function (digits, num) {
		unsafePositiveToDigits:
		while (true) {
			if (num < 16) {
				return A2(
					$elm$core$List$cons,
					$rtfeldman$elm_hex$Hex$unsafeToDigit(num),
					digits);
			} else {
				var $temp$digits = A2(
					$elm$core$List$cons,
					$rtfeldman$elm_hex$Hex$unsafeToDigit(
						A2($elm$core$Basics$modBy, 16, num)),
					digits),
					$temp$num = (num / 16) | 0;
				digits = $temp$digits;
				num = $temp$num;
				continue unsafePositiveToDigits;
			}
		}
	});
var $rtfeldman$elm_hex$Hex$toString = function (num) {
	return $elm$core$String$fromList(
		(num < 0) ? A2(
			$elm$core$List$cons,
			'-',
			A2($rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, -num)) : A2($rtfeldman$elm_hex$Hex$unsafePositiveToDigits, _List_Nil, num));
};
var $author$project$Internal$Write$prettyPatternInner = F2(
	function (isTop, pattern) {
		var _v0 = A2($author$project$Internal$Write$adjustPatternParentheses, isTop, pattern);
		switch (_v0.$) {
			case 0:
				return $the_sett$elm_pretty_printer$Pretty$string('_');
			case 1:
				return $the_sett$elm_pretty_printer$Pretty$string('()');
			case 2:
				var val = _v0.a;
				return $author$project$Internal$Write$singleQuotes(
					$the_sett$elm_pretty_printer$Pretty$string(
						$author$project$Internal$Write$escapeChar(val)));
			case 3:
				var val = _v0.a;
				return $author$project$Internal$Write$quotes(
					$the_sett$elm_pretty_printer$Pretty$string(val));
			case 4:
				var val = _v0.a;
				return $the_sett$elm_pretty_printer$Pretty$string(
					$elm$core$String$fromInt(val));
			case 5:
				var val = _v0.a;
				return $the_sett$elm_pretty_printer$Pretty$string(
					$rtfeldman$elm_hex$Hex$toString(val));
			case 6:
				var val = _v0.a;
				return $the_sett$elm_pretty_printer$Pretty$string(
					$elm$core$String$fromFloat(val));
			case 7:
				var vals = _v0.a;
				return $the_sett$elm_pretty_printer$Pretty$parens(
					A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$space,
						A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							A2(
								$the_sett$elm_pretty_printer$Pretty$join,
								$the_sett$elm_pretty_printer$Pretty$string(', '),
								A2(
									$elm$core$List$map,
									$author$project$Internal$Write$prettyPatternInner(true),
									$author$project$Internal$Compiler$denodeAll(vals))),
							$the_sett$elm_pretty_printer$Pretty$space)));
			case 8:
				var fields = _v0.a;
				return $the_sett$elm_pretty_printer$Pretty$braces(
					A3(
						$the_sett$elm_pretty_printer$Pretty$surround,
						$the_sett$elm_pretty_printer$Pretty$space,
						$the_sett$elm_pretty_printer$Pretty$space,
						A2(
							$the_sett$elm_pretty_printer$Pretty$join,
							$the_sett$elm_pretty_printer$Pretty$string(', '),
							A2(
								$elm$core$List$map,
								$the_sett$elm_pretty_printer$Pretty$string,
								$author$project$Internal$Compiler$denodeAll(fields)))));
			case 9:
				var hdPat = _v0.a;
				var tlPat = _v0.b;
				return $the_sett$elm_pretty_printer$Pretty$words(
					_List_fromArray(
						[
							A2(
							$author$project$Internal$Write$prettyPatternInner,
							false,
							$author$project$Internal$Compiler$denode(hdPat)),
							$the_sett$elm_pretty_printer$Pretty$string('::'),
							A2(
							$author$project$Internal$Write$prettyPatternInner,
							false,
							$author$project$Internal$Compiler$denode(tlPat))
						]));
			case 10:
				var listPats = _v0.a;
				if (!listPats.b) {
					return $the_sett$elm_pretty_printer$Pretty$string('[]');
				} else {
					var open = A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$space,
						$the_sett$elm_pretty_printer$Pretty$string('['));
					var close = A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$string(']'),
						$the_sett$elm_pretty_printer$Pretty$space);
					return A3(
						$the_sett$elm_pretty_printer$Pretty$surround,
						open,
						close,
						A2(
							$the_sett$elm_pretty_printer$Pretty$join,
							$the_sett$elm_pretty_printer$Pretty$string(', '),
							A2(
								$elm$core$List$map,
								$author$project$Internal$Write$prettyPatternInner(false),
								$author$project$Internal$Compiler$denodeAll(listPats))));
				}
			case 11:
				var _var = _v0.a;
				return $the_sett$elm_pretty_printer$Pretty$string(_var);
			case 12:
				var qnRef = _v0.a;
				var listPats = _v0.b;
				return $the_sett$elm_pretty_printer$Pretty$words(
					A2(
						$elm$core$List$cons,
						A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							$the_sett$elm_pretty_printer$Pretty$string(qnRef.i),
							$author$project$Internal$Write$prettyModuleNameDot(qnRef.b4)),
						A2(
							$elm$core$List$map,
							$author$project$Internal$Write$prettyPatternInner(false),
							$author$project$Internal$Compiler$denodeAll(listPats))));
			case 13:
				var pat = _v0.a;
				var name = _v0.b;
				return $the_sett$elm_pretty_printer$Pretty$words(
					_List_fromArray(
						[
							A2(
							$author$project$Internal$Write$prettyPatternInner,
							false,
							$author$project$Internal$Compiler$denode(pat)),
							$the_sett$elm_pretty_printer$Pretty$string('as'),
							$the_sett$elm_pretty_printer$Pretty$string(
							$author$project$Internal$Compiler$denode(name))
						]));
			default:
				var pat = _v0.a;
				return $the_sett$elm_pretty_printer$Pretty$parens(
					A2(
						$author$project$Internal$Write$prettyPatternInner,
						true,
						$author$project$Internal$Compiler$denode(pat)));
		}
	});
var $author$project$Internal$Write$prettyArgs = function (args) {
	return $the_sett$elm_pretty_printer$Pretty$words(
		A2(
			$elm$core$List$map,
			$author$project$Internal$Write$prettyPatternInner(false),
			args));
};
var $elm$core$String$replace = F3(
	function (before, after, string) {
		return A2(
			$elm$core$String$join,
			after,
			A2($elm$core$String$split, before, string));
	});
var $author$project$Internal$Write$escape = function (val) {
	return A3(
		$elm$core$String$replace,
		'\t',
		'\\t',
		A3(
			$elm$core$String$replace,
			'\n',
			'\\n',
			A3(
				$elm$core$String$replace,
				'\"',
				'\\\"',
				A3($elm$core$String$replace, '\\', '\\\\', val))));
};
var $author$project$Internal$Write$prettyLiteral = function (val) {
	return $author$project$Internal$Write$quotes(
		$the_sett$elm_pretty_printer$Pretty$string(
			$author$project$Internal$Write$escape(val)));
};
var $author$project$Internal$Write$prettyPattern = function (pattern) {
	return A2($author$project$Internal$Write$prettyPatternInner, true, pattern);
};
var $author$project$Internal$Write$prettySignature = function (sig) {
	return $the_sett$elm_pretty_printer$Pretty$group(
		A2(
			$the_sett$elm_pretty_printer$Pretty$nest,
			4,
			$the_sett$elm_pretty_printer$Pretty$lines(
				_List_fromArray(
					[
						$the_sett$elm_pretty_printer$Pretty$words(
						_List_fromArray(
							[
								$the_sett$elm_pretty_printer$Pretty$string(
								$author$project$Internal$Compiler$denode(sig.i)),
								$the_sett$elm_pretty_printer$Pretty$string(':')
							])),
						$author$project$Internal$Write$prettyTypeAnnotation(
						$author$project$Internal$Compiler$denode(sig.w))
					]))));
};
var $the_sett$elm_pretty_printer$Pretty$tightline = A2($the_sett$elm_pretty_printer$Internals$Line, '', '');
var $elm$core$Bitwise$and = _Bitwise_and;
var $elm$core$Bitwise$shiftRightBy = _Bitwise_shiftRightBy;
var $elm$core$String$repeatHelp = F3(
	function (n, chunk, result) {
		return (n <= 0) ? result : A3(
			$elm$core$String$repeatHelp,
			n >> 1,
			_Utils_ap(chunk, chunk),
			(!(n & 1)) ? result : _Utils_ap(result, chunk));
	});
var $elm$core$String$repeat = F2(
	function (n, chunk) {
		return A3($elm$core$String$repeatHelp, n, chunk, '');
	});
var $elm$core$String$padLeft = F3(
	function (n, _char, string) {
		return _Utils_ap(
			A2(
				$elm$core$String$repeat,
				n - $elm$core$String$length(string),
				$elm$core$String$fromChar(_char)),
			string);
	});
var $author$project$Internal$Write$toHexString = function (val) {
	var padWithZeros = function (str) {
		var length = $elm$core$String$length(str);
		return (length < 2) ? A3($elm$core$String$padLeft, 2, '0', str) : (((length > 2) && (length < 4)) ? A3($elm$core$String$padLeft, 4, '0', str) : (((length > 4) && (length < 8)) ? A3($elm$core$String$padLeft, 8, '0', str) : str));
	};
	return '0x' + padWithZeros(
		$elm$core$String$toUpper(
			$rtfeldman$elm_hex$Hex$toString(val)));
};
var $author$project$Internal$Write$topContext = {M: false, N: true, P: 11};
var $elm$core$List$unzip = function (pairs) {
	var step = F2(
		function (_v0, _v1) {
			var x = _v0.a;
			var y = _v0.b;
			var xs = _v1.a;
			var ys = _v1.b;
			return _Utils_Tuple2(
				A2($elm$core$List$cons, x, xs),
				A2($elm$core$List$cons, y, ys));
		});
	return A3(
		$elm$core$List$foldr,
		step,
		_Utils_Tuple2(_List_Nil, _List_Nil),
		pairs);
};
var $author$project$Internal$Write$prettyApplication = F2(
	function (indent, exprs) {
		var _v30 = A2(
			$elm$core$Tuple$mapSecond,
			$Chadtech$elm_bool_extra$Bool$Extra$any,
			$elm$core$List$unzip(
				A2(
					$elm$core$List$map,
					A2(
						$author$project$Internal$Write$prettyExpressionInner,
						{M: false, N: false, P: 11},
						4),
					$author$project$Internal$Compiler$denodeAll(exprs))));
		var prettyExpressions = _v30.a;
		var alwaysBreak = _v30.b;
		return _Utils_Tuple2(
			A2(
				$author$project$Internal$Write$optionalGroup,
				alwaysBreak,
				$the_sett$elm_pretty_printer$Pretty$align(
					A2(
						$the_sett$elm_pretty_printer$Pretty$nest,
						indent,
						$the_sett$elm_pretty_printer$Pretty$lines(prettyExpressions)))),
			alwaysBreak);
	});
var $author$project$Internal$Write$prettyCaseBlock = F2(
	function (indent, caseBlock) {
		var prettyCase = function (_v29) {
			var pattern = _v29.a;
			var expr = _v29.b;
			return A2(
				$the_sett$elm_pretty_printer$Pretty$indent,
				indent,
				A2(
					$the_sett$elm_pretty_printer$Pretty$a,
					A2(
						$the_sett$elm_pretty_printer$Pretty$indent,
						4,
						A3(
							$author$project$Internal$Write$prettyExpressionInner,
							$author$project$Internal$Write$topContext,
							4,
							$author$project$Internal$Compiler$denode(expr)).a),
					A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$line,
						A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							$the_sett$elm_pretty_printer$Pretty$string(' ->'),
							$author$project$Internal$Write$prettyPattern(
								$author$project$Internal$Compiler$denode(pattern))))));
		};
		var patternsPart = $author$project$Internal$Write$doubleLines(
			A2($elm$core$List$map, prettyCase, caseBlock._));
		var casePart = function () {
			var _v28 = A3(
				$author$project$Internal$Write$prettyExpressionInner,
				$author$project$Internal$Write$topContext,
				4,
				$author$project$Internal$Compiler$denode(caseBlock.b));
			var caseExpression = _v28.a;
			var alwaysBreak = _v28.b;
			return A2(
				$author$project$Internal$Write$optionalGroup,
				alwaysBreak,
				$the_sett$elm_pretty_printer$Pretty$lines(
					_List_fromArray(
						[
							A2(
							$the_sett$elm_pretty_printer$Pretty$nest,
							indent,
							A2(
								$author$project$Internal$Write$optionalGroup,
								alwaysBreak,
								$the_sett$elm_pretty_printer$Pretty$lines(
									_List_fromArray(
										[
											$the_sett$elm_pretty_printer$Pretty$string('case'),
											caseExpression
										])))),
							$the_sett$elm_pretty_printer$Pretty$string('of')
						])));
		}();
		return _Utils_Tuple2(
			$the_sett$elm_pretty_printer$Pretty$align(
				$the_sett$elm_pretty_printer$Pretty$lines(
					_List_fromArray(
						[casePart, patternsPart]))),
			true);
	});
var $author$project$Internal$Write$prettyExpression = function (expression) {
	return A3($author$project$Internal$Write$prettyExpressionInner, $author$project$Internal$Write$topContext, 4, expression).a;
};
var $author$project$Internal$Write$prettyExpressionInner = F3(
	function (context, indent, expression) {
		var _v26 = A2($author$project$Internal$Write$adjustExpressionParentheses, context, expression);
		switch (_v26.$) {
			case 0:
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$string('()'),
					false);
			case 1:
				var exprs = _v26.a;
				return A2($author$project$Internal$Write$prettyApplication, indent, exprs);
			case 2:
				var symbol = _v26.a;
				var dir = _v26.b;
				var exprl = _v26.c;
				var exprr = _v26.d;
				return A5($author$project$Internal$Write$prettyOperatorApplication, indent, symbol, dir, exprl, exprr);
			case 3:
				var modl = _v26.a;
				var val = _v26.b;
				return _Utils_Tuple2(
					A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$string(val),
						$author$project$Internal$Write$prettyModuleNameDot(modl)),
					false);
			case 4:
				var exprBool = _v26.a;
				var exprTrue = _v26.b;
				var exprFalse = _v26.c;
				return A4($author$project$Internal$Write$prettyIfBlock, indent, exprBool, exprTrue, exprFalse);
			case 5:
				var symbol = _v26.a;
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$parens(
						$the_sett$elm_pretty_printer$Pretty$string(symbol)),
					false);
			case 6:
				var symbol = _v26.a;
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$string(symbol),
					false);
			case 7:
				var val = _v26.a;
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$string(
						$elm$core$String$fromInt(val)),
					false);
			case 8:
				var val = _v26.a;
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$string(
						$author$project$Internal$Write$toHexString(val)),
					false);
			case 9:
				var val = _v26.a;
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$string(
						$elm$core$String$fromFloat(val)),
					false);
			case 10:
				var expr = _v26.a;
				var _v27 = A3(
					$author$project$Internal$Write$prettyExpressionInner,
					$author$project$Internal$Write$topContext,
					4,
					$author$project$Internal$Compiler$denode(expr));
				var prettyExpr = _v27.a;
				var alwaysBreak = _v27.b;
				return _Utils_Tuple2(
					A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						prettyExpr,
						$the_sett$elm_pretty_printer$Pretty$string('-')),
					alwaysBreak);
			case 11:
				var val = _v26.a;
				return _Utils_Tuple2(
					$author$project$Internal$Write$prettyLiteral(val),
					false);
			case 12:
				var val = _v26.a;
				return _Utils_Tuple2(
					$author$project$Internal$Write$singleQuotes(
						$the_sett$elm_pretty_printer$Pretty$string(
							$author$project$Internal$Write$escapeChar(val))),
					false);
			case 13:
				var exprs = _v26.a;
				return A2($author$project$Internal$Write$prettyTupledExpression, indent, exprs);
			case 14:
				var expr = _v26.a;
				return A2($author$project$Internal$Write$prettyParenthesizedExpression, indent, expr);
			case 15:
				var letBlock = _v26.a;
				return A2($author$project$Internal$Write$prettyLetBlock, indent, letBlock);
			case 16:
				var caseBlock = _v26.a;
				return A2($author$project$Internal$Write$prettyCaseBlock, indent, caseBlock);
			case 17:
				var lambda = _v26.a;
				return A2($author$project$Internal$Write$prettyLambdaExpression, indent, lambda);
			case 18:
				var setters = _v26.a;
				return $author$project$Internal$Write$prettyRecordExpr(setters);
			case 19:
				var exprs = _v26.a;
				return A2($author$project$Internal$Write$prettyList, indent, exprs);
			case 20:
				var expr = _v26.a;
				var field = _v26.b;
				return A2($author$project$Internal$Write$prettyRecordAccess, expr, field);
			case 21:
				var field = _v26.a;
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$string(field),
					false);
			case 22:
				var _var = _v26.a;
				var setters = _v26.b;
				return A3($author$project$Internal$Write$prettyRecordUpdateExpression, indent, _var, setters);
			default:
				var val = _v26.a;
				return _Utils_Tuple2(
					$the_sett$elm_pretty_printer$Pretty$string('glsl'),
					true);
		}
	});
var $author$project$Internal$Write$prettyFun = function (fn) {
	return $the_sett$elm_pretty_printer$Pretty$lines(
		_List_fromArray(
			[
				A2(
				$author$project$Internal$Write$prettyMaybe,
				$author$project$Internal$Write$prettyDocumentation,
				$author$project$Internal$Compiler$denodeMaybe(fn.x)),
				A2(
				$author$project$Internal$Write$prettyMaybe,
				$author$project$Internal$Write$prettySignature,
				$author$project$Internal$Compiler$denodeMaybe(fn.R)),
				$author$project$Internal$Write$prettyFunctionImplementation(
				$author$project$Internal$Compiler$denode(fn.D))
			]));
};
var $author$project$Internal$Write$prettyFunctionImplementation = function (impl) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$nest,
		4,
		A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$author$project$Internal$Write$prettyExpression(
				$author$project$Internal$Compiler$denode(impl.b)),
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				$the_sett$elm_pretty_printer$Pretty$line,
				$the_sett$elm_pretty_printer$Pretty$words(
					_List_fromArray(
						[
							$the_sett$elm_pretty_printer$Pretty$string(
							$author$project$Internal$Compiler$denode(impl.i)),
							$author$project$Internal$Write$prettyArgs(
							$author$project$Internal$Compiler$denodeAll(impl.B)),
							$the_sett$elm_pretty_printer$Pretty$string('=')
						])))));
};
var $author$project$Internal$Write$prettyIfBlock = F4(
	function (indent, exprBool, exprTrue, exprFalse) {
		var innerIfBlock = F3(
			function (innerExprBool, innerExprTrue, innerExprFalse) {
				var truePart = A2(
					$the_sett$elm_pretty_printer$Pretty$indent,
					indent,
					A3(
						$author$project$Internal$Write$prettyExpressionInner,
						$author$project$Internal$Write$topContext,
						4,
						$author$project$Internal$Compiler$denode(innerExprTrue)).a);
				var ifPart = function () {
					var _v25 = A3(
						$author$project$Internal$Write$prettyExpressionInner,
						$author$project$Internal$Write$topContext,
						4,
						$author$project$Internal$Compiler$denode(innerExprBool));
					var prettyBoolExpr = _v25.a;
					var alwaysBreak = _v25.b;
					return A2(
						$author$project$Internal$Write$optionalGroup,
						alwaysBreak,
						$the_sett$elm_pretty_printer$Pretty$lines(
							_List_fromArray(
								[
									A2(
									$the_sett$elm_pretty_printer$Pretty$nest,
									indent,
									A2(
										$author$project$Internal$Write$optionalGroup,
										alwaysBreak,
										$the_sett$elm_pretty_printer$Pretty$lines(
											_List_fromArray(
												[
													$the_sett$elm_pretty_printer$Pretty$string('if'),
													A3(
													$author$project$Internal$Write$prettyExpressionInner,
													$author$project$Internal$Write$topContext,
													4,
													$author$project$Internal$Compiler$denode(innerExprBool)).a
												])))),
									$the_sett$elm_pretty_printer$Pretty$string('then')
								])));
				}();
				var falsePart = function () {
					var _v24 = $author$project$Internal$Compiler$denode(innerExprFalse);
					if (_v24.$ === 4) {
						var nestedExprBool = _v24.a;
						var nestedExprTrue = _v24.b;
						var nestedExprFalse = _v24.c;
						return A3(innerIfBlock, nestedExprBool, nestedExprTrue, nestedExprFalse);
					} else {
						return _List_fromArray(
							[
								A2(
								$the_sett$elm_pretty_printer$Pretty$indent,
								indent,
								A3(
									$author$project$Internal$Write$prettyExpressionInner,
									$author$project$Internal$Write$topContext,
									4,
									$author$project$Internal$Compiler$denode(innerExprFalse)).a)
							]);
					}
				}();
				var elsePart = A2(
					$the_sett$elm_pretty_printer$Pretty$a,
					$the_sett$elm_pretty_printer$Pretty$string('else'),
					$the_sett$elm_pretty_printer$Pretty$line);
				var context = $author$project$Internal$Write$topContext;
				if (!falsePart.b) {
					return _List_Nil;
				} else {
					if (!falsePart.b.b) {
						var falseExpr = falsePart.a;
						return _List_fromArray(
							[ifPart, truePart, elsePart, falseExpr]);
					} else {
						var hd = falsePart.a;
						var tl = falsePart.b;
						return A2(
							$elm$core$List$append,
							_List_fromArray(
								[
									ifPart,
									truePart,
									$the_sett$elm_pretty_printer$Pretty$words(
									_List_fromArray(
										[elsePart, hd]))
								]),
							tl);
					}
				}
			});
		var prettyExpressions = A3(innerIfBlock, exprBool, exprTrue, exprFalse);
		return _Utils_Tuple2(
			$the_sett$elm_pretty_printer$Pretty$align(
				$the_sett$elm_pretty_printer$Pretty$lines(prettyExpressions)),
			true);
	});
var $author$project$Internal$Write$prettyLambdaExpression = F2(
	function (indent, lambda) {
		var _v22 = A3(
			$author$project$Internal$Write$prettyExpressionInner,
			$author$project$Internal$Write$topContext,
			4,
			$author$project$Internal$Compiler$denode(lambda.b));
		var prettyExpr = _v22.a;
		var alwaysBreak = _v22.b;
		return _Utils_Tuple2(
			A2(
				$author$project$Internal$Write$optionalGroup,
				alwaysBreak,
				$the_sett$elm_pretty_printer$Pretty$align(
					A2(
						$the_sett$elm_pretty_printer$Pretty$nest,
						indent,
						$the_sett$elm_pretty_printer$Pretty$lines(
							_List_fromArray(
								[
									A2(
									$the_sett$elm_pretty_printer$Pretty$a,
									$the_sett$elm_pretty_printer$Pretty$string(' ->'),
									A2(
										$the_sett$elm_pretty_printer$Pretty$a,
										$the_sett$elm_pretty_printer$Pretty$words(
											A2(
												$elm$core$List$map,
												$author$project$Internal$Write$prettyPatternInner(false),
												$author$project$Internal$Compiler$denodeAll(lambda.T))),
										$the_sett$elm_pretty_printer$Pretty$string('\\'))),
									prettyExpr
								]))))),
			alwaysBreak);
	});
var $author$project$Internal$Write$prettyLetBlock = F2(
	function (indent, letBlock) {
		return _Utils_Tuple2(
			$the_sett$elm_pretty_printer$Pretty$align(
				$the_sett$elm_pretty_printer$Pretty$lines(
					_List_fromArray(
						[
							$the_sett$elm_pretty_printer$Pretty$string('let'),
							A2(
							$the_sett$elm_pretty_printer$Pretty$indent,
							indent,
							$author$project$Internal$Write$doubleLines(
								A2(
									$elm$core$List$map,
									$author$project$Internal$Write$prettyLetDeclaration(indent),
									$author$project$Internal$Compiler$denodeAll(letBlock.E)))),
							$the_sett$elm_pretty_printer$Pretty$string('in'),
							A3(
							$author$project$Internal$Write$prettyExpressionInner,
							$author$project$Internal$Write$topContext,
							4,
							$author$project$Internal$Compiler$denode(letBlock.b)).a
						]))),
			true);
	});
var $author$project$Internal$Write$prettyLetDeclaration = F2(
	function (indent, letDecl) {
		if (!letDecl.$) {
			var fn = letDecl.a;
			return $author$project$Internal$Write$prettyFun(fn);
		} else {
			var pattern = letDecl.a;
			var expr = letDecl.b;
			return A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				A2(
					$the_sett$elm_pretty_printer$Pretty$indent,
					indent,
					A3(
						$author$project$Internal$Write$prettyExpressionInner,
						$author$project$Internal$Write$topContext,
						4,
						$author$project$Internal$Compiler$denode(expr)).a),
				A2(
					$the_sett$elm_pretty_printer$Pretty$a,
					$the_sett$elm_pretty_printer$Pretty$line,
					$the_sett$elm_pretty_printer$Pretty$words(
						_List_fromArray(
							[
								A2(
								$author$project$Internal$Write$prettyPatternInner,
								false,
								$author$project$Internal$Compiler$denode(pattern)),
								$the_sett$elm_pretty_printer$Pretty$string('=')
							]))));
		}
	});
var $author$project$Internal$Write$prettyList = F2(
	function (indent, exprs) {
		var open = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$space,
			$the_sett$elm_pretty_printer$Pretty$string('['));
		var close = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$string(']'),
			$the_sett$elm_pretty_printer$Pretty$line);
		if (!exprs.b) {
			return _Utils_Tuple2(
				$the_sett$elm_pretty_printer$Pretty$string('[]'),
				false);
		} else {
			var _v20 = A2(
				$elm$core$Tuple$mapSecond,
				$Chadtech$elm_bool_extra$Bool$Extra$any,
				$elm$core$List$unzip(
					A2(
						$elm$core$List$map,
						A2(
							$author$project$Internal$Write$prettyExpressionInner,
							$author$project$Internal$Write$topContext,
							A2($author$project$Internal$Write$decrementIndent, indent, 2)),
						$author$project$Internal$Compiler$denodeAll(exprs))));
			var prettyExpressions = _v20.a;
			var alwaysBreak = _v20.b;
			return _Utils_Tuple2(
				A2(
					$author$project$Internal$Write$optionalGroup,
					alwaysBreak,
					$the_sett$elm_pretty_printer$Pretty$align(
						A3(
							$the_sett$elm_pretty_printer$Pretty$surround,
							open,
							close,
							A2($the_sett$elm_pretty_printer$Pretty$separators, ', ', prettyExpressions)))),
				alwaysBreak);
		}
	});
var $author$project$Internal$Write$prettyOperatorApplication = F5(
	function (indent, symbol, dir, exprl, exprr) {
		return (symbol === '<|') ? A5($author$project$Internal$Write$prettyOperatorApplicationLeft, indent, symbol, dir, exprl, exprr) : A5($author$project$Internal$Write$prettyOperatorApplicationRight, indent, symbol, dir, exprl, exprr);
	});
var $author$project$Internal$Write$prettyOperatorApplicationLeft = F5(
	function (indent, symbol, _v16, exprl, exprr) {
		var context = {
			M: true,
			N: false,
			P: $author$project$Internal$Write$precedence(symbol)
		};
		var _v17 = A3(
			$author$project$Internal$Write$prettyExpressionInner,
			context,
			4,
			$author$project$Internal$Compiler$denode(exprr));
		var prettyExpressionRight = _v17.a;
		var alwaysBreakRight = _v17.b;
		var _v18 = A3(
			$author$project$Internal$Write$prettyExpressionInner,
			context,
			4,
			$author$project$Internal$Compiler$denode(exprl));
		var prettyExpressionLeft = _v18.a;
		var alwaysBreakLeft = _v18.b;
		var alwaysBreak = alwaysBreakLeft || alwaysBreakRight;
		return _Utils_Tuple2(
			A2(
				$the_sett$elm_pretty_printer$Pretty$nest,
				4,
				A2(
					$author$project$Internal$Write$optionalGroup,
					alwaysBreak,
					$the_sett$elm_pretty_printer$Pretty$lines(
						_List_fromArray(
							[
								$the_sett$elm_pretty_printer$Pretty$words(
								_List_fromArray(
									[
										prettyExpressionLeft,
										$the_sett$elm_pretty_printer$Pretty$string(symbol)
									])),
								prettyExpressionRight
							])))),
			alwaysBreak);
	});
var $author$project$Internal$Write$prettyOperatorApplicationRight = F5(
	function (indent, symbol, _v11, exprl, exprr) {
		var expandExpr = F3(
			function (innerIndent, context, expr) {
				if (expr.$ === 2) {
					var sym = expr.a;
					var left = expr.c;
					var right = expr.d;
					return A4(innerOpApply, false, sym, left, right);
				} else {
					return _List_fromArray(
						[
							A3($author$project$Internal$Write$prettyExpressionInner, context, innerIndent, expr)
						]);
				}
			});
		var innerOpApply = F4(
			function (isTop, sym, left, right) {
				var innerIndent = A2(
					$author$project$Internal$Write$decrementIndent,
					4,
					$elm$core$String$length(symbol) + 1);
				var leftIndent = isTop ? indent : innerIndent;
				var context = {
					M: '<|' === sym,
					N: false,
					P: $author$project$Internal$Write$precedence(sym)
				};
				var rightSide = A3(
					expandExpr,
					innerIndent,
					context,
					$author$project$Internal$Compiler$denode(right));
				if (rightSide.b) {
					var _v14 = rightSide.a;
					var hdExpr = _v14.a;
					var hdBreak = _v14.b;
					var tl = rightSide.b;
					return A2(
						$elm$core$List$append,
						A3(
							expandExpr,
							leftIndent,
							context,
							$author$project$Internal$Compiler$denode(left)),
						A2(
							$elm$core$List$cons,
							_Utils_Tuple2(
								A2(
									$the_sett$elm_pretty_printer$Pretty$a,
									hdExpr,
									A2(
										$the_sett$elm_pretty_printer$Pretty$a,
										$the_sett$elm_pretty_printer$Pretty$space,
										$the_sett$elm_pretty_printer$Pretty$string(sym))),
								hdBreak),
							tl));
				} else {
					return _List_Nil;
				}
			});
		var _v12 = A2(
			$elm$core$Tuple$mapSecond,
			$Chadtech$elm_bool_extra$Bool$Extra$any,
			$elm$core$List$unzip(
				A4(innerOpApply, true, symbol, exprl, exprr)));
		var prettyExpressions = _v12.a;
		var alwaysBreak = _v12.b;
		return _Utils_Tuple2(
			A2(
				$author$project$Internal$Write$optionalGroup,
				alwaysBreak,
				$the_sett$elm_pretty_printer$Pretty$align(
					A2(
						$the_sett$elm_pretty_printer$Pretty$join,
						A2($the_sett$elm_pretty_printer$Pretty$nest, indent, $the_sett$elm_pretty_printer$Pretty$line),
						prettyExpressions))),
			alwaysBreak);
	});
var $author$project$Internal$Write$prettyParenthesizedExpression = F2(
	function (indent, expr) {
		var open = $the_sett$elm_pretty_printer$Pretty$string('(');
		var close = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$string(')'),
			$the_sett$elm_pretty_printer$Pretty$tightline);
		var _v10 = A3(
			$author$project$Internal$Write$prettyExpressionInner,
			$author$project$Internal$Write$topContext,
			A2($author$project$Internal$Write$decrementIndent, indent, 1),
			$author$project$Internal$Compiler$denode(expr));
		var prettyExpr = _v10.a;
		var alwaysBreak = _v10.b;
		return _Utils_Tuple2(
			A2(
				$author$project$Internal$Write$optionalGroup,
				alwaysBreak,
				$the_sett$elm_pretty_printer$Pretty$align(
					A3(
						$the_sett$elm_pretty_printer$Pretty$surround,
						open,
						close,
						A2($the_sett$elm_pretty_printer$Pretty$nest, 1, prettyExpr)))),
			alwaysBreak);
	});
var $author$project$Internal$Write$prettyRecordAccess = F2(
	function (expr, field) {
		var _v9 = A3(
			$author$project$Internal$Write$prettyExpressionInner,
			$author$project$Internal$Write$topContext,
			4,
			$author$project$Internal$Compiler$denode(expr));
		var prettyExpr = _v9.a;
		var alwaysBreak = _v9.b;
		return _Utils_Tuple2(
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				$the_sett$elm_pretty_printer$Pretty$string(
					$author$project$Internal$Compiler$denode(field)),
				A2($the_sett$elm_pretty_printer$Pretty$a, $author$project$Internal$Write$dot, prettyExpr)),
			alwaysBreak);
	});
var $author$project$Internal$Write$prettyRecordExpr = function (setters) {
	var open = A2(
		$the_sett$elm_pretty_printer$Pretty$a,
		$the_sett$elm_pretty_printer$Pretty$space,
		$the_sett$elm_pretty_printer$Pretty$string('{'));
	var close = A2(
		$the_sett$elm_pretty_printer$Pretty$a,
		$the_sett$elm_pretty_printer$Pretty$string('}'),
		$the_sett$elm_pretty_printer$Pretty$line);
	if (!setters.b) {
		return _Utils_Tuple2(
			$the_sett$elm_pretty_printer$Pretty$string('{}'),
			false);
	} else {
		var _v8 = A2(
			$elm$core$Tuple$mapSecond,
			$Chadtech$elm_bool_extra$Bool$Extra$any,
			$elm$core$List$unzip(
				A2(
					$elm$core$List$map,
					$author$project$Internal$Write$prettySetter,
					$author$project$Internal$Compiler$denodeAll(setters))));
		var prettyExpressions = _v8.a;
		var alwaysBreak = _v8.b;
		return _Utils_Tuple2(
			A2(
				$author$project$Internal$Write$optionalGroup,
				alwaysBreak,
				$the_sett$elm_pretty_printer$Pretty$align(
					A3(
						$the_sett$elm_pretty_printer$Pretty$surround,
						open,
						close,
						A2($the_sett$elm_pretty_printer$Pretty$separators, ', ', prettyExpressions)))),
			alwaysBreak);
	}
};
var $author$project$Internal$Write$prettyRecordUpdateExpression = F3(
	function (indent, _var, setters) {
		var open = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$line,
			$the_sett$elm_pretty_printer$Pretty$words(
				_List_fromArray(
					[
						$the_sett$elm_pretty_printer$Pretty$string('{'),
						$the_sett$elm_pretty_printer$Pretty$string(
						$author$project$Internal$Compiler$denode(_var))
					])));
		var close = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$string('}'),
			$the_sett$elm_pretty_printer$Pretty$line);
		var addBarToFirst = function (exprs) {
			if (!exprs.b) {
				return _List_Nil;
			} else {
				var hd = exprs.a;
				var tl = exprs.b;
				return A2(
					$elm$core$List$cons,
					A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						hd,
						$the_sett$elm_pretty_printer$Pretty$string('| ')),
					tl);
			}
		};
		if (!setters.b) {
			return _Utils_Tuple2(
				$the_sett$elm_pretty_printer$Pretty$string('{}'),
				false);
		} else {
			var _v5 = A2(
				$elm$core$Tuple$mapSecond,
				$Chadtech$elm_bool_extra$Bool$Extra$any,
				$elm$core$List$unzip(
					A2(
						$elm$core$List$map,
						$author$project$Internal$Write$prettySetter,
						$author$project$Internal$Compiler$denodeAll(setters))));
			var prettyExpressions = _v5.a;
			var alwaysBreak = _v5.b;
			return _Utils_Tuple2(
				A2(
					$author$project$Internal$Write$optionalGroup,
					alwaysBreak,
					$the_sett$elm_pretty_printer$Pretty$align(
						A3(
							$the_sett$elm_pretty_printer$Pretty$surround,
							$the_sett$elm_pretty_printer$Pretty$empty,
							close,
							A2(
								$the_sett$elm_pretty_printer$Pretty$nest,
								indent,
								A2(
									$the_sett$elm_pretty_printer$Pretty$a,
									A2(
										$the_sett$elm_pretty_printer$Pretty$separators,
										', ',
										addBarToFirst(prettyExpressions)),
									open))))),
				alwaysBreak);
		}
	});
var $author$project$Internal$Write$prettySetter = function (_v2) {
	var fld = _v2.a;
	var val = _v2.b;
	var _v3 = A3(
		$author$project$Internal$Write$prettyExpressionInner,
		$author$project$Internal$Write$topContext,
		4,
		$author$project$Internal$Compiler$denode(val));
	var prettyExpr = _v3.a;
	var alwaysBreak = _v3.b;
	return _Utils_Tuple2(
		A2(
			$the_sett$elm_pretty_printer$Pretty$nest,
			4,
			A2(
				$author$project$Internal$Write$optionalGroup,
				alwaysBreak,
				$the_sett$elm_pretty_printer$Pretty$lines(
					_List_fromArray(
						[
							$the_sett$elm_pretty_printer$Pretty$words(
							_List_fromArray(
								[
									$the_sett$elm_pretty_printer$Pretty$string(
									$author$project$Internal$Compiler$denode(fld)),
									$the_sett$elm_pretty_printer$Pretty$string('=')
								])),
							prettyExpr
						])))),
		alwaysBreak);
};
var $author$project$Internal$Write$prettyTupledExpression = F2(
	function (indent, exprs) {
		var open = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$space,
			$the_sett$elm_pretty_printer$Pretty$string('('));
		var close = A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$string(')'),
			$the_sett$elm_pretty_printer$Pretty$line);
		if (!exprs.b) {
			return _Utils_Tuple2(
				$the_sett$elm_pretty_printer$Pretty$string('()'),
				false);
		} else {
			var _v1 = A2(
				$elm$core$Tuple$mapSecond,
				$Chadtech$elm_bool_extra$Bool$Extra$any,
				$elm$core$List$unzip(
					A2(
						$elm$core$List$map,
						A2(
							$author$project$Internal$Write$prettyExpressionInner,
							$author$project$Internal$Write$topContext,
							A2($author$project$Internal$Write$decrementIndent, indent, 2)),
						$author$project$Internal$Compiler$denodeAll(exprs))));
			var prettyExpressions = _v1.a;
			var alwaysBreak = _v1.b;
			return _Utils_Tuple2(
				A2(
					$author$project$Internal$Write$optionalGroup,
					alwaysBreak,
					$the_sett$elm_pretty_printer$Pretty$align(
						A3(
							$the_sett$elm_pretty_printer$Pretty$surround,
							open,
							close,
							A2($the_sett$elm_pretty_printer$Pretty$separators, ', ', prettyExpressions)))),
				alwaysBreak);
		}
	});
var $author$project$Internal$Write$prettyDestructuring = F2(
	function (pattern, expr) {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$nest,
			4,
			$the_sett$elm_pretty_printer$Pretty$lines(
				_List_fromArray(
					[
						$the_sett$elm_pretty_printer$Pretty$words(
						_List_fromArray(
							[
								$author$project$Internal$Write$prettyPattern(pattern),
								$the_sett$elm_pretty_printer$Pretty$string('=')
							])),
						$author$project$Internal$Write$prettyExpression(expr)
					])));
	});
var $author$project$Internal$Write$prettyInfix = function (infix_) {
	var dirToString = function (direction) {
		switch (direction) {
			case 0:
				return 'left';
			case 1:
				return 'right';
			default:
				return 'non';
		}
	};
	return $the_sett$elm_pretty_printer$Pretty$words(
		_List_fromArray(
			[
				$the_sett$elm_pretty_printer$Pretty$string('infix'),
				$the_sett$elm_pretty_printer$Pretty$string(
				dirToString(
					$author$project$Internal$Compiler$denode(infix_.bS))),
				$the_sett$elm_pretty_printer$Pretty$string(
				$elm$core$String$fromInt(
					$author$project$Internal$Compiler$denode(infix_.P))),
				$the_sett$elm_pretty_printer$Pretty$parens(
				$the_sett$elm_pretty_printer$Pretty$string(
					$author$project$Internal$Compiler$denode(infix_.b8))),
				$the_sett$elm_pretty_printer$Pretty$string('='),
				$the_sett$elm_pretty_printer$Pretty$string(
				$author$project$Internal$Compiler$denode(infix_.bX))
			]));
};
var $author$project$Internal$Write$prettyPortDeclaration = function (sig) {
	return $the_sett$elm_pretty_printer$Pretty$words(
		_List_fromArray(
			[
				$the_sett$elm_pretty_printer$Pretty$string('port'),
				$author$project$Internal$Write$prettySignature(sig)
			]));
};
var $author$project$Internal$Write$prettyTypeAlias = function (tAlias) {
	var typeAliasPretty = A2(
		$the_sett$elm_pretty_printer$Pretty$nest,
		4,
		A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$author$project$Internal$Write$prettyTypeAnnotation(
				$author$project$Internal$Compiler$denode(tAlias.w)),
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				$the_sett$elm_pretty_printer$Pretty$line,
				$the_sett$elm_pretty_printer$Pretty$words(
					_List_fromArray(
						[
							$the_sett$elm_pretty_printer$Pretty$string('type alias'),
							$the_sett$elm_pretty_printer$Pretty$string(
							$author$project$Internal$Compiler$denode(tAlias.i)),
							$the_sett$elm_pretty_printer$Pretty$words(
							A2(
								$elm$core$List$map,
								$the_sett$elm_pretty_printer$Pretty$string,
								$author$project$Internal$Compiler$denodeAll(tAlias.a0))),
							$the_sett$elm_pretty_printer$Pretty$string('=')
						])))));
	return $the_sett$elm_pretty_printer$Pretty$lines(
		_List_fromArray(
			[
				A2(
				$author$project$Internal$Write$prettyMaybe,
				$author$project$Internal$Write$prettyDocumentation,
				$author$project$Internal$Compiler$denodeMaybe(tAlias.x)),
				typeAliasPretty
			]));
};
var $author$project$Internal$Write$prettyElmSyntaxDeclaration = function (decl) {
	switch (decl.$) {
		case 0:
			var fn = decl.a;
			return $author$project$Internal$Write$prettyFun(fn);
		case 1:
			var tAlias = decl.a;
			return $author$project$Internal$Write$prettyTypeAlias(tAlias);
		case 2:
			var type_ = decl.a;
			return $author$project$Internal$Write$prettyCustomType(type_);
		case 3:
			var sig = decl.a;
			return $author$project$Internal$Write$prettyPortDeclaration(sig);
		case 4:
			var infix_ = decl.a;
			return $author$project$Internal$Write$prettyInfix(infix_);
		default:
			var pattern = decl.a;
			var expr = decl.b;
			return A2(
				$author$project$Internal$Write$prettyDestructuring,
				$author$project$Internal$Compiler$denode(pattern),
				$author$project$Internal$Compiler$denode(expr));
	}
};
var $author$project$Internal$Write$prettyDeclarations = function (decls) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (decl, doc) {
				if (decl.$ === 1) {
					var content = decl.a;
					return A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$line,
						A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							$the_sett$elm_pretty_printer$Pretty$string(content + '\n\n'),
							doc));
				} else {
					var innerDecl = decl.c;
					return A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$line,
						A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							$the_sett$elm_pretty_printer$Pretty$line,
							A2(
								$the_sett$elm_pretty_printer$Pretty$a,
								$the_sett$elm_pretty_printer$Pretty$line,
								A2(
									$the_sett$elm_pretty_printer$Pretty$a,
									$author$project$Internal$Write$prettyElmSyntaxDeclaration(innerDecl),
									doc))));
				}
			}),
		$the_sett$elm_pretty_printer$Pretty$empty,
		decls);
};
var $author$project$Internal$Comments$delimeters = function (doc) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$a,
		$the_sett$elm_pretty_printer$Pretty$string('-}'),
		A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$the_sett$elm_pretty_printer$Pretty$line,
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				doc,
				$the_sett$elm_pretty_printer$Pretty$string('{-| '))));
};
var $author$project$Internal$Comments$getParts = function (_v0) {
	var parts = _v0;
	return $elm$core$List$reverse(parts);
};
var $author$project$Internal$Comments$DocTags = function (a) {
	return {$: 2, a: a};
};
var $author$project$Internal$Comments$fitAndSplit = F2(
	function (width, tags) {
		if (!tags.b) {
			return _List_Nil;
		} else {
			var t = tags.a;
			var ts = tags.b;
			var _v1 = A3(
				$elm$core$List$foldl,
				F2(
					function (tag, _v2) {
						var allSplits = _v2.a;
						var curSplit = _v2.b;
						var remaining = _v2.c;
						return (_Utils_cmp(
							$elm$core$String$length(tag),
							remaining) < 1) ? _Utils_Tuple3(
							allSplits,
							A2($elm$core$List$cons, tag, curSplit),
							remaining - $elm$core$String$length(tag)) : _Utils_Tuple3(
							_Utils_ap(
								allSplits,
								_List_fromArray(
									[
										$elm$core$List$reverse(curSplit)
									])),
							_List_fromArray(
								[tag]),
							width - $elm$core$String$length(tag));
					}),
				_Utils_Tuple3(
					_List_Nil,
					_List_fromArray(
						[t]),
					width - $elm$core$String$length(t)),
				ts);
			var splitsExceptLast = _v1.a;
			var lastSplit = _v1.b;
			return _Utils_ap(
				splitsExceptLast,
				_List_fromArray(
					[
						$elm$core$List$reverse(lastSplit)
					]));
		}
	});
var $elm$core$List$sort = function (xs) {
	return A2($elm$core$List$sortBy, $elm$core$Basics$identity, xs);
};
var $author$project$Internal$Comments$mergeDocTags = function (innerParts) {
	var _v0 = A3(
		$elm$core$List$foldr,
		F2(
			function (part, _v1) {
				var accum = _v1.a;
				var context = _v1.b;
				if (context.$ === 1) {
					if (part.$ === 2) {
						var tags = part.a;
						return _Utils_Tuple2(
							accum,
							$elm$core$Maybe$Just(tags));
					} else {
						var otherPart = part;
						return _Utils_Tuple2(
							A2($elm$core$List$cons, otherPart, accum),
							$elm$core$Maybe$Nothing);
					}
				} else {
					var contextTags = context.a;
					if (part.$ === 2) {
						var tags = part.a;
						return _Utils_Tuple2(
							accum,
							$elm$core$Maybe$Just(
								_Utils_ap(contextTags, tags)));
					} else {
						var otherPart = part;
						return _Utils_Tuple2(
							A2(
								$elm$core$List$cons,
								otherPart,
								A2(
									$elm$core$List$cons,
									$author$project$Internal$Comments$DocTags(
										$elm$core$List$sort(contextTags)),
									accum)),
							$elm$core$Maybe$Nothing);
					}
				}
			}),
		_Utils_Tuple2(_List_Nil, $elm$core$Maybe$Nothing),
		innerParts);
	var partsExceptMaybeFirst = _v0.a;
	var maybeFirstPart = _v0.b;
	if (maybeFirstPart.$ === 1) {
		return partsExceptMaybeFirst;
	} else {
		var tags = maybeFirstPart.a;
		return A2(
			$elm$core$List$cons,
			$author$project$Internal$Comments$DocTags(
				$elm$core$List$sort(tags)),
			partsExceptMaybeFirst);
	}
};
var $author$project$Internal$Comments$layoutTags = F2(
	function (width, parts) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (part, _v0) {
					var accumParts = _v0.a;
					var accumDocTags = _v0.b;
					if (part.$ === 2) {
						var tags = part.a;
						var splits = A2($author$project$Internal$Comments$fitAndSplit, width, tags);
						return _Utils_Tuple2(
							_Utils_ap(
								A2($elm$core$List$map, $author$project$Internal$Comments$DocTags, splits),
								accumParts),
							_Utils_ap(accumDocTags, splits));
					} else {
						var otherPart = part;
						return _Utils_Tuple2(
							A2($elm$core$List$cons, otherPart, accumParts),
							accumDocTags);
					}
				}),
			_Utils_Tuple2(_List_Nil, _List_Nil),
			$author$project$Internal$Comments$mergeDocTags(parts));
	});
var $the_sett$elm_pretty_printer$Internals$NLine = F3(
	function (a, b, c) {
		return {$: 2, a: a, b: b, c: c};
	});
var $the_sett$elm_pretty_printer$Internals$NNil = {$: 0};
var $the_sett$elm_pretty_printer$Internals$NText = F3(
	function (a, b, c) {
		return {$: 1, a: a, b: b, c: c};
	});
var $the_sett$elm_pretty_printer$Internals$fits = F2(
	function (w, normal) {
		fits:
		while (true) {
			if (w < 0) {
				return false;
			} else {
				switch (normal.$) {
					case 0:
						return true;
					case 1:
						var text = normal.a;
						var innerNormal = normal.b;
						var $temp$w = w - $elm$core$String$length(text),
							$temp$normal = innerNormal(0);
						w = $temp$w;
						normal = $temp$normal;
						continue fits;
					default:
						return true;
				}
			}
		}
	});
var $the_sett$elm_pretty_printer$Internals$better = F4(
	function (w, k, doc, doc2Fn) {
		return A2($the_sett$elm_pretty_printer$Internals$fits, w - k, doc) ? doc : doc2Fn(0);
	});
var $the_sett$elm_pretty_printer$Internals$best = F3(
	function (width, startCol, x) {
		var be = F3(
			function (w, k, docs) {
				be:
				while (true) {
					if (!docs.b) {
						return $the_sett$elm_pretty_printer$Internals$NNil;
					} else {
						switch (docs.a.b.$) {
							case 0:
								var _v1 = docs.a;
								var i = _v1.a;
								var _v2 = _v1.b;
								var ds = docs.b;
								var $temp$w = w,
									$temp$k = k,
									$temp$docs = ds;
								w = $temp$w;
								k = $temp$k;
								docs = $temp$docs;
								continue be;
							case 1:
								var _v3 = docs.a;
								var i = _v3.a;
								var _v4 = _v3.b;
								var doc = _v4.a;
								var doc2 = _v4.b;
								var ds = docs.b;
								var $temp$w = w,
									$temp$k = k,
									$temp$docs = A2(
									$elm$core$List$cons,
									_Utils_Tuple2(
										i,
										doc(0)),
									A2(
										$elm$core$List$cons,
										_Utils_Tuple2(
											i,
											doc2(0)),
										ds));
								w = $temp$w;
								k = $temp$k;
								docs = $temp$docs;
								continue be;
							case 2:
								var _v5 = docs.a;
								var i = _v5.a;
								var _v6 = _v5.b;
								var j = _v6.a;
								var doc = _v6.b;
								var ds = docs.b;
								var $temp$w = w,
									$temp$k = k,
									$temp$docs = A2(
									$elm$core$List$cons,
									_Utils_Tuple2(
										i + j,
										doc(0)),
									ds);
								w = $temp$w;
								k = $temp$k;
								docs = $temp$docs;
								continue be;
							case 3:
								var _v7 = docs.a;
								var i = _v7.a;
								var _v8 = _v7.b;
								var text = _v8.a;
								var maybeTag = _v8.b;
								var ds = docs.b;
								return A3(
									$the_sett$elm_pretty_printer$Internals$NText,
									text,
									function (_v9) {
										return A3(
											be,
											w,
											k + $elm$core$String$length(text),
											ds);
									},
									maybeTag);
							case 4:
								var _v10 = docs.a;
								var i = _v10.a;
								var _v11 = _v10.b;
								var vsep = _v11.b;
								var ds = docs.b;
								return A3(
									$the_sett$elm_pretty_printer$Internals$NLine,
									i,
									vsep,
									function (_v12) {
										return A3(
											be,
											w,
											i + $elm$core$String$length(vsep),
											ds);
									});
							case 5:
								var _v13 = docs.a;
								var i = _v13.a;
								var _v14 = _v13.b;
								var doc = _v14.a;
								var doc2 = _v14.b;
								var ds = docs.b;
								return A4(
									$the_sett$elm_pretty_printer$Internals$better,
									w,
									k,
									A3(
										be,
										w,
										k,
										A2(
											$elm$core$List$cons,
											_Utils_Tuple2(i, doc),
											ds)),
									function (_v15) {
										return A3(
											be,
											w,
											k,
											A2(
												$elm$core$List$cons,
												_Utils_Tuple2(i, doc2),
												ds));
									});
							case 6:
								var _v16 = docs.a;
								var i = _v16.a;
								var fn = _v16.b.a;
								var ds = docs.b;
								var $temp$w = w,
									$temp$k = k,
									$temp$docs = A2(
									$elm$core$List$cons,
									_Utils_Tuple2(
										i,
										fn(i)),
									ds);
								w = $temp$w;
								k = $temp$k;
								docs = $temp$docs;
								continue be;
							default:
								var _v17 = docs.a;
								var i = _v17.a;
								var fn = _v17.b.a;
								var ds = docs.b;
								var $temp$w = w,
									$temp$k = k,
									$temp$docs = A2(
									$elm$core$List$cons,
									_Utils_Tuple2(
										i,
										fn(k)),
									ds);
								w = $temp$w;
								k = $temp$k;
								docs = $temp$docs;
								continue be;
						}
					}
				}
			});
		return A3(
			be,
			width,
			startCol,
			_List_fromArray(
				[
					_Utils_Tuple2(0, x)
				]));
	});
var $elm$core$String$concat = function (strings) {
	return A2($elm$core$String$join, '', strings);
};
var $the_sett$elm_pretty_printer$Internals$layout = function (normal) {
	var layoutInner = F2(
		function (normal2, acc) {
			layoutInner:
			while (true) {
				switch (normal2.$) {
					case 0:
						return acc;
					case 1:
						var text = normal2.a;
						var innerNormal = normal2.b;
						var maybeTag = normal2.c;
						var $temp$normal2 = innerNormal(0),
							$temp$acc = A2($elm$core$List$cons, text, acc);
						normal2 = $temp$normal2;
						acc = $temp$acc;
						continue layoutInner;
					default:
						var i = normal2.a;
						var sep = normal2.b;
						var innerNormal = normal2.c;
						var norm = innerNormal(0);
						if (norm.$ === 2) {
							var $temp$normal2 = innerNormal(0),
								$temp$acc = A2($elm$core$List$cons, '\n' + sep, acc);
							normal2 = $temp$normal2;
							acc = $temp$acc;
							continue layoutInner;
						} else {
							var $temp$normal2 = innerNormal(0),
								$temp$acc = A2(
								$elm$core$List$cons,
								'\n' + (A2($the_sett$elm_pretty_printer$Internals$copy, i, ' ') + sep),
								acc);
							normal2 = $temp$normal2;
							acc = $temp$acc;
							continue layoutInner;
						}
				}
			}
		});
	return $elm$core$String$concat(
		$elm$core$List$reverse(
			A2(layoutInner, normal, _List_Nil)));
};
var $the_sett$elm_pretty_printer$Pretty$pretty = F2(
	function (w, doc) {
		return $the_sett$elm_pretty_printer$Internals$layout(
			A3($the_sett$elm_pretty_printer$Internals$best, w, 0, doc));
	});
var $author$project$Internal$Comments$prettyCode = function (val) {
	return A2(
		$the_sett$elm_pretty_printer$Pretty$indent,
		4,
		$the_sett$elm_pretty_printer$Pretty$string(val));
};
var $author$project$Internal$Comments$prettyMarkdown = function (val) {
	return $the_sett$elm_pretty_printer$Pretty$string(val);
};
var $author$project$Internal$Comments$prettyTags = function (tags) {
	return $the_sett$elm_pretty_printer$Pretty$words(
		_List_fromArray(
			[
				$the_sett$elm_pretty_printer$Pretty$string('@docs'),
				A2(
				$the_sett$elm_pretty_printer$Pretty$join,
				$the_sett$elm_pretty_printer$Pretty$string(', '),
				A2($elm$core$List$map, $the_sett$elm_pretty_printer$Pretty$string, tags))
			]));
};
var $author$project$Internal$Comments$prettyCommentPart = function (part) {
	switch (part.$) {
		case 0:
			var val = part.a;
			return $author$project$Internal$Comments$prettyMarkdown(val);
		case 1:
			var val = part.a;
			return $author$project$Internal$Comments$prettyCode(val);
		default:
			var tags = part.a;
			return $author$project$Internal$Comments$prettyTags(tags);
	}
};
var $author$project$Internal$Comments$prettyFileComment = F2(
	function (width, comment) {
		var _v0 = A2(
			$author$project$Internal$Comments$layoutTags,
			width,
			$author$project$Internal$Comments$getParts(comment));
		var parts = _v0.a;
		var splits = _v0.b;
		return _Utils_Tuple2(
			A2(
				$the_sett$elm_pretty_printer$Pretty$pretty,
				width,
				$author$project$Internal$Comments$delimeters(
					$the_sett$elm_pretty_printer$Pretty$lines(
						A2($elm$core$List$map, $author$project$Internal$Comments$prettyCommentPart, parts)))),
			splits);
	});
var $author$project$Internal$Write$prettyDefaultModuleData = function (moduleData) {
	return $the_sett$elm_pretty_printer$Pretty$words(
		_List_fromArray(
			[
				$the_sett$elm_pretty_printer$Pretty$string('module'),
				$author$project$Internal$Write$prettyModuleName(
				$author$project$Internal$Compiler$denode(moduleData.b4)),
				$author$project$Internal$Write$prettyExposing(
				$author$project$Internal$Compiler$denode(moduleData.bW))
			]));
};
var $author$project$Internal$Write$prettyEffectModuleData = function (moduleData) {
	var prettyCmdAndSub = F2(
		function (maybeCmd, maybeSub) {
			var _v0 = _Utils_Tuple2(maybeCmd, maybeSub);
			if (!_v0.a.$) {
				if (!_v0.b.$) {
					var cmdName = _v0.a.a;
					var subName = _v0.b.a;
					return $elm$core$Maybe$Just(
						$the_sett$elm_pretty_printer$Pretty$words(
							_List_fromArray(
								[
									$the_sett$elm_pretty_printer$Pretty$string('where { command ='),
									$the_sett$elm_pretty_printer$Pretty$string(cmdName),
									$the_sett$elm_pretty_printer$Pretty$string(','),
									$the_sett$elm_pretty_printer$Pretty$string('subscription ='),
									$the_sett$elm_pretty_printer$Pretty$string(subName),
									$the_sett$elm_pretty_printer$Pretty$string('}')
								])));
				} else {
					var cmdName = _v0.a.a;
					var _v3 = _v0.b;
					return $elm$core$Maybe$Just(
						$the_sett$elm_pretty_printer$Pretty$words(
							_List_fromArray(
								[
									$the_sett$elm_pretty_printer$Pretty$string('where { command ='),
									$the_sett$elm_pretty_printer$Pretty$string(cmdName),
									$the_sett$elm_pretty_printer$Pretty$string('}')
								])));
				}
			} else {
				if (_v0.b.$ === 1) {
					var _v1 = _v0.a;
					var _v2 = _v0.b;
					return $elm$core$Maybe$Nothing;
				} else {
					var _v4 = _v0.a;
					var subName = _v0.b.a;
					return $elm$core$Maybe$Just(
						$the_sett$elm_pretty_printer$Pretty$words(
							_List_fromArray(
								[
									$the_sett$elm_pretty_printer$Pretty$string('where { subscription ='),
									$the_sett$elm_pretty_printer$Pretty$string(subName),
									$the_sett$elm_pretty_printer$Pretty$string('}')
								])));
				}
			}
		});
	return $the_sett$elm_pretty_printer$Pretty$words(
		_List_fromArray(
			[
				$the_sett$elm_pretty_printer$Pretty$string('effect module'),
				$author$project$Internal$Write$prettyModuleName(
				$author$project$Internal$Compiler$denode(moduleData.b4)),
				A2(
				$author$project$Internal$Write$prettyMaybe,
				$elm$core$Basics$identity,
				A2(
					prettyCmdAndSub,
					$author$project$Internal$Compiler$denodeMaybe(moduleData.bO),
					$author$project$Internal$Compiler$denodeMaybe(moduleData.cd))),
				$author$project$Internal$Write$prettyExposing(
				$author$project$Internal$Compiler$denode(moduleData.bW))
			]));
};
var $author$project$Internal$Write$prettyPortModuleData = function (moduleData) {
	return $the_sett$elm_pretty_printer$Pretty$words(
		_List_fromArray(
			[
				$the_sett$elm_pretty_printer$Pretty$string('port module'),
				$author$project$Internal$Write$prettyModuleName(
				$author$project$Internal$Compiler$denode(moduleData.b4)),
				$author$project$Internal$Write$prettyExposing(
				$author$project$Internal$Compiler$denode(moduleData.bW))
			]));
};
var $author$project$Internal$Write$prettyModule = function (mod) {
	switch (mod.$) {
		case 0:
			var defaultModuleData = mod.a;
			return $author$project$Internal$Write$prettyDefaultModuleData(defaultModuleData);
		case 1:
			var defaultModuleData = mod.a;
			return $author$project$Internal$Write$prettyPortModuleData(defaultModuleData);
		default:
			var effectModuleData = mod.a;
			return $author$project$Internal$Write$prettyEffectModuleData(effectModuleData);
	}
};
var $author$project$Internal$Write$prepareLayout = F2(
	function (width, file) {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$a,
			$author$project$Internal$Write$prettyDeclarations(file.E),
			A2(
				$the_sett$elm_pretty_printer$Pretty$a,
				$author$project$Internal$Write$importsPretty(file.a),
				function (doc) {
					var _v0 = file.aP;
					if (_v0.$ === 1) {
						return doc;
					} else {
						var fileComment = _v0.a;
						var _v1 = A2($author$project$Internal$Comments$prettyFileComment, width, fileComment);
						var fileCommentStr = _v1.a;
						var innerTags = _v1.b;
						return A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							$the_sett$elm_pretty_printer$Pretty$line,
							A2(
								$the_sett$elm_pretty_printer$Pretty$a,
								$author$project$Internal$Write$prettyComments(
									_List_fromArray(
										[fileCommentStr])),
								doc));
					}
				}(
					A2(
						$the_sett$elm_pretty_printer$Pretty$a,
						$the_sett$elm_pretty_printer$Pretty$line,
						A2(
							$the_sett$elm_pretty_printer$Pretty$a,
							$the_sett$elm_pretty_printer$Pretty$line,
							$author$project$Internal$Write$prettyModule(file.V))))));
	});
var $author$project$Internal$Write$pretty = F2(
	function (width, file) {
		return A2(
			$the_sett$elm_pretty_printer$Pretty$pretty,
			width,
			A2($author$project$Internal$Write$prepareLayout, width, file));
	});
var $author$project$Internal$Write$write = $author$project$Internal$Write$pretty(80);
var $author$project$Elm$render = F2(
	function (toDocComment, fileDetails) {
		var mod = $author$project$Internal$Compiler$getModule(fileDetails.V);
		var exposedGroups = $author$project$Internal$Compiler$getExposedGroups(fileDetails.I);
		var exposed = $author$project$Internal$Compiler$getExposed(fileDetails.I);
		var body = $author$project$Internal$Write$write(
			{
				aP: $elm$core$Maybe$Just(
					A2(
						$author$project$Internal$Comments$addPart,
						$author$project$Internal$Comments$emptyComment,
						$author$project$Internal$Comments$Markdown(
							toDocComment(exposedGroups)))),
				E: fileDetails.I,
				a: A2($elm$core$List$filterMap, $author$project$Internal$Compiler$makeImport, fileDetails.a),
				V: ($author$project$Internal$Compiler$hasPorts(fileDetails.I) ? $stil4m$elm_syntax$Elm$Syntax$Module$PortModule : $stil4m$elm_syntax$Elm$Syntax$Module$NormalModule)(
					{
						bW: function () {
							if (!exposed.b) {
								return $author$project$Internal$Compiler$nodify(
									$stil4m$elm_syntax$Elm$Syntax$Exposing$All($stil4m$elm_syntax$Elm$Syntax$Range$emptyRange));
							} else {
								return $author$project$Internal$Compiler$nodify(
									$stil4m$elm_syntax$Elm$Syntax$Exposing$Explicit(
										$author$project$Internal$Compiler$nodifyAll(exposed)));
							}
						}(),
						b4: $author$project$Internal$Compiler$nodify(mod)
					})
			});
		return {
			aQ: body,
			bc: A2($elm$core$String$join, '/', mod) + '.elm'
		};
	});
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Elm$renderStandardComment = function (groups) {
	return $elm$core$List$isEmpty(groups) ? '' : A3(
		$elm$core$List$foldl,
		F2(
			function (grouped, str) {
				return str + ('@docs ' + (A2($elm$core$String$join, ', ', grouped.b2) + '\n\n'));
			}),
		'\n\n',
		groups);
};
var $elm$core$Tuple$second = function (_v0) {
	var y = _v0.b;
	return y;
};
var $author$project$Elm$file = F2(
	function (pieces, decs) {
		var mod = $author$project$Elm$moduleName(pieces);
		return A2(
			$author$project$Elm$render,
			$author$project$Elm$renderStandardComment,
			{
				I: decs,
				a: A3(
					$author$project$Elm$reduceDeclarationImports,
					mod,
					decs,
					_Utils_Tuple2($elm$core$Set$empty, _List_Nil)).b,
				an: '',
				V: mod
			});
	});
var $stil4m$elm_syntax$Elm$Syntax$Expression$LambdaExpression = function (a) {
	return {$: 17, a: a};
};
var $author$project$Elm$lambdaWith = F2(
	function (args, _v0) {
		var expr = _v0;
		return {
			c: function () {
				var _v1 = expr.c;
				if (_v1.$ === 1) {
					var err = _v1.a;
					return $elm$core$Result$Err(err);
				} else {
					var _return = _v1.a;
					return $elm$core$Result$Ok(
						A3(
							$elm$core$List$foldr,
							F2(
								function (ann, fnbody) {
									return A2(
										$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$FunctionTypeAnnotation,
										$author$project$Internal$Compiler$nodify(ann),
										$author$project$Internal$Compiler$nodify(fnbody));
								}),
							_return,
							A2(
								$elm$core$List$map,
								A2($elm$core$Basics$composeL, $author$project$Internal$Compiler$getInnerAnnotation, $elm$core$Tuple$second),
								args)));
				}
			}(),
			b: $stil4m$elm_syntax$Elm$Syntax$Expression$LambdaExpression(
				{
					T: $author$project$Internal$Compiler$nodifyAll(
						A2($elm$core$List$map, $elm$core$Tuple$first, args)),
					b: $author$project$Internal$Compiler$nodify(expr.b)
				}),
			a: expr.a,
			g: false
		};
	});
var $author$project$Elm$local = $author$project$Internal$Compiler$inModule(_List_Nil);
var $author$project$Elm$valueFrom = F2(
	function (mod, name) {
		return {
			c: $elm$core$Result$Err(_List_Nil),
			b: A2(
				$stil4m$elm_syntax$Elm$Syntax$Expression$FunctionOrValue,
				$author$project$Internal$Compiler$resolveModuleNameForValue(mod),
				$author$project$Internal$Compiler$sanitize(name)),
			a: _List_fromArray(
				[mod]),
			g: false
		};
	});
var $author$project$Elm$value = $author$project$Elm$valueFrom($author$project$Elm$local);
var $stil4m$elm_syntax$Elm$Syntax$Pattern$VarPattern = function (a) {
	return {$: 11, a: a};
};
var $author$project$Elm$Pattern$var = function (name) {
	return $stil4m$elm_syntax$Elm$Syntax$Pattern$VarPattern(name);
};
var $author$project$Generate$annotationNamed = F2(
	function (name, tags) {
		if (!tags.b) {
			return A2(
				$author$project$Elm$apply,
				A3(
					$author$project$Elm$valueWith,
					$author$project$Generate$elmAnnotation,
					'named',
					A2(
						$author$project$Elm$Annotation$function,
						_List_fromArray(
							[
								A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'),
								$author$project$Elm$Annotation$string
							]),
						A2($author$project$Elm$Annotation$named, $author$project$Generate$elmAnnotation, 'Annotation'))),
				_List_fromArray(
					[
						$author$project$Generate$thisModuleName,
						$author$project$Elm$string(name)
					]));
		} else {
			var nonEmpty = tags;
			return A2(
				$author$project$Elm$lambdaWith,
				A2(
					$elm$core$List$indexedMap,
					F2(
						function (i, arg) {
							return _Utils_Tuple2(
								$author$project$Elm$Pattern$var(
									'arg' + $elm$core$String$fromInt(i)),
								A2($author$project$Elm$Annotation$named, $author$project$Generate$elmAnnotation, 'Annotation'));
						}),
					nonEmpty),
				A2(
					$author$project$Elm$apply,
					A3(
						$author$project$Elm$valueWith,
						$author$project$Generate$elmAnnotation,
						'namedWith',
						A2(
							$author$project$Elm$Annotation$function,
							_List_fromArray(
								[
									A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'),
									$author$project$Elm$Annotation$string,
									$author$project$Elm$Annotation$list(
									A2($author$project$Elm$Annotation$named, $author$project$Generate$elmAnnotation, 'Annotation'))
								]),
							A2($author$project$Elm$Annotation$named, $author$project$Generate$elmAnnotation, 'Annotation'))),
					_List_fromArray(
						[
							$author$project$Generate$thisModuleName,
							$author$project$Elm$string(name),
							$author$project$Elm$list(
							A2(
								$elm$core$List$indexedMap,
								F2(
									function (i, arg) {
										return $author$project$Elm$value(
											'arg' + $elm$core$String$fromInt(i));
									}),
								nonEmpty))
						])));
		}
	});
var $author$project$Generate$expressionType = A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Expression');
var $author$project$Generate$apply = F2(
	function (fn, args) {
		return A2(
			$author$project$Elm$apply,
			A3(
				$author$project$Elm$valueWith,
				$author$project$Generate$elm,
				'apply',
				A2(
					$author$project$Elm$Annotation$function,
					_List_fromArray(
						[
							$author$project$Generate$expressionType,
							$author$project$Elm$Annotation$list($author$project$Generate$expressionType)
						]),
					$author$project$Generate$expressionType)),
			_List_fromArray(
				[
					fn,
					$author$project$Elm$list(args)
				]));
	});
var $author$project$Generate$argName = function (index) {
	return 'arg' + $elm$core$String$fromInt(index);
};
var $author$project$Generate$asArgumentTypeHelper = function (tipe) {
	if (tipe.$ === 1) {
		var one = tipe.a;
		var two = tipe.b;
		return A2(
			$author$project$Elm$Annotation$function,
			_List_fromArray(
				[
					$author$project$Generate$asArgumentTypeHelper(one)
				]),
			$author$project$Generate$asArgumentTypeHelper(two));
	} else {
		return $author$project$Generate$expressionType;
	}
};
var $author$project$Generate$asArgument = F2(
	function (index, tipe) {
		if (tipe.$ === 1) {
			var one = tipe.a;
			var two = tipe.b;
			return _Utils_Tuple2(
				$author$project$Generate$asArgumentTypeHelper(tipe),
				$author$project$Elm$Pattern$var(
					$author$project$Generate$argName(index)));
		} else {
			return _Utils_Tuple2(
				$author$project$Generate$expressionType,
				$author$project$Elm$Pattern$var(
					$author$project$Generate$argName(index)));
		}
	});
var $elm$core$List$repeatHelp = F3(
	function (result, n, value) {
		repeatHelp:
		while (true) {
			if (n <= 0) {
				return result;
			} else {
				var $temp$result = A2($elm$core$List$cons, value, result),
					$temp$n = n - 1,
					$temp$value = value;
				result = $temp$result;
				n = $temp$n;
				value = $temp$value;
				continue repeatHelp;
			}
		}
	});
var $elm$core$List$repeat = F2(
	function (n, value) {
		return A3($elm$core$List$repeatHelp, _List_Nil, n, value);
	});
var $author$project$Generate$skip = A3($author$project$Elm$valueWith, $author$project$Generate$elm, 'pass', $author$project$Generate$expressionType);
var $author$project$Generate$asValueHelper = F3(
	function (index, tipe, args) {
		asValueHelper:
		while (true) {
			if (tipe.$ === 1) {
				var one = tipe.a;
				var two = tipe.b;
				var $temp$index = index,
					$temp$tipe = two,
					$temp$args = A2($elm$core$List$cons, $author$project$Generate$skip, args);
				index = $temp$index;
				tipe = $temp$tipe;
				args = $temp$args;
				continue asValueHelper;
			} else {
				if (!args.b) {
					return A3(
						$author$project$Elm$valueWith,
						$author$project$Generate$local,
						$author$project$Generate$argName(index),
						$author$project$Generate$expressionType);
				} else {
					return A2(
						$author$project$Elm$apply,
						A3(
							$author$project$Elm$valueWith,
							$author$project$Generate$local,
							$author$project$Generate$argName(index),
							A2(
								$author$project$Elm$Annotation$function,
								A2(
									$elm$core$List$repeat,
									$elm$core$List$length(args),
									$author$project$Generate$expressionType),
								$author$project$Generate$expressionType)),
						$elm$core$List$reverse(args));
				}
			}
		}
	});
var $author$project$Generate$asValue = F2(
	function (index, tipe) {
		return A3($author$project$Generate$asValueHelper, index, tipe, _List_Nil);
	});
var $author$project$Generate$captureFunction = F2(
	function (tipe, captured) {
		captureFunction:
		while (true) {
			if (tipe.$ === 1) {
				var one = tipe.a;
				var two = tipe.b;
				var $temp$tipe = two,
					$temp$captured = {
					B: A2(
						$elm$core$List$cons,
						A2($author$project$Generate$asArgument, captured.y, one),
						captured.B),
					y: captured.y + 1,
					X: A2(
						$elm$core$List$cons,
						A2($author$project$Generate$asValue, captured.y, one),
						captured.X)
				};
				tipe = $temp$tipe;
				captured = $temp$captured;
				continue captureFunction;
			} else {
				return {
					B: A2(
						$elm$core$List$cons,
						A2($author$project$Generate$asArgument, captured.y, tipe),
						captured.B),
					y: captured.y + 1,
					X: A2(
						$elm$core$List$cons,
						A2($author$project$Generate$asValue, captured.y, tipe),
						captured.X)
				};
			}
		}
	});
var $author$project$Generate$chooseName = F2(
	function (base, tags) {
		chooseName:
		while (true) {
			if (!tags.b) {
				return base;
			} else {
				var _v1 = tags.a;
				var name = _v1.a;
				var rest = tags.b;
				if (_Utils_eq(name, base)) {
					var $temp$base = base + '_',
						$temp$tags = rest;
					base = $temp$base;
					tags = $temp$tags;
					continue chooseName;
				} else {
					var $temp$base = base,
						$temp$tags = rest;
					base = $temp$base;
					tags = $temp$tags;
					continue chooseName;
				}
			}
		}
	});
var $author$project$Elm$functionWith = F3(
	function (name, args, _v0) {
		var body = _v0;
		return A3(
			$author$project$Internal$Compiler$Declaration,
			$author$project$Internal$Compiler$NotExposed,
			_Utils_ap(
				A2(
					$elm$core$List$concatMap,
					A2($elm$core$Basics$composeR, $elm$core$Tuple$first, $author$project$Internal$Compiler$getAnnotationImports),
					args),
				body.a),
			$stil4m$elm_syntax$Elm$Syntax$Declaration$FunctionDeclaration(
				{
					D: $author$project$Internal$Compiler$nodify(
						{
							B: $author$project$Internal$Compiler$nodifyAll(
								A2($elm$core$List$map, $elm$core$Tuple$second, args)),
							b: $author$project$Internal$Compiler$nodify(body.b),
							i: $author$project$Internal$Compiler$nodify(
								$author$project$Internal$Compiler$formatValue(name))
						}),
					x: $author$project$Internal$Compiler$nodifyMaybe($elm$core$Maybe$Nothing),
					R: function () {
						var _v1 = body.c;
						if (!_v1.$) {
							var _return = _v1.a;
							return $elm$core$Maybe$Just(
								$author$project$Internal$Compiler$nodify(
									{
										i: $author$project$Internal$Compiler$nodify(
											$author$project$Internal$Compiler$formatValue(name)),
										w: $author$project$Internal$Compiler$nodify(
											$author$project$Internal$Compiler$getInnerAnnotation(
												A2(
													$author$project$Elm$Annotation$function,
													A2($elm$core$List$map, $elm$core$Tuple$first, args),
													$author$project$Internal$Compiler$noImports(_return))))
									}));
						} else {
							return $elm$core$Maybe$Nothing;
						}
					}()
				}));
	});
var $author$project$Internal$Compiler$DuplicateFieldInRecord = function (a) {
	return {$: 5, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$Expression$RecordExpr = function (a) {
	return {$: 18, a: a};
};
var $author$project$Internal$Compiler$SomeOtherIssue = {$: 1};
var $author$project$Elm$record = function (fields) {
	var unified = A3(
		$elm$core$List$foldl,
		F2(
			function (_v2, found) {
				var unformattedFieldName = _v2.a;
				var exp = _v2.b;
				var fieldName = $author$project$Internal$Compiler$formatValue(unformattedFieldName);
				return {
					J: function () {
						if (A2($elm$core$Set$member, fieldName, found.aj)) {
							return A2(
								$elm$core$List$cons,
								$author$project$Internal$Compiler$DuplicateFieldInRecord(fieldName),
								found.J);
						} else {
							var _v3 = exp.c;
							if (_v3.$ === 1) {
								if (!_v3.a.b) {
									return A2($elm$core$List$cons, $author$project$Internal$Compiler$SomeOtherIssue, found.J);
								} else {
									var errs = _v3.a;
									return _Utils_ap(errs, found.J);
								}
							} else {
								var ann = _v3.a;
								return found.J;
							}
						}
					}(),
					ab: function () {
						var _v4 = exp.c;
						if (_v4.$ === 1) {
							var err = _v4.a;
							return found.ab;
						} else {
							var ann = _v4.a;
							return A2(
								$elm$core$List$cons,
								_Utils_Tuple2(
									$author$project$Internal$Compiler$formatValue(fieldName),
									ann),
								found.ab);
						}
					}(),
					ah: A2(
						$elm$core$List$cons,
						_Utils_Tuple2(
							$author$project$Internal$Compiler$nodify(fieldName),
							$author$project$Internal$Compiler$nodify(exp.b)),
						found.ah),
					a: _Utils_ap(exp.a, found.a),
					aj: A2($elm$core$Set$insert, fieldName, found.aj)
				};
			}),
		{J: _List_Nil, ab: _List_Nil, ah: _List_Nil, a: _List_Nil, aj: $elm$core$Set$empty},
		fields);
	return {
		c: function () {
			var _v0 = unified.J;
			if (!_v0.b) {
				return $elm$core$Result$Ok(
					$stil4m$elm_syntax$Elm$Syntax$TypeAnnotation$Record(
						$author$project$Internal$Compiler$nodifyAll(
							A2(
								$elm$core$List$map,
								function (_v1) {
									var name = _v1.a;
									var ann = _v1.b;
									return _Utils_Tuple2(
										$author$project$Internal$Compiler$nodify(name),
										$author$project$Internal$Compiler$nodify(ann));
								},
								$elm$core$List$reverse(unified.ab)))));
			} else {
				var errs = _v0;
				return $elm$core$Result$Err(errs);
			}
		}(),
		b: $stil4m$elm_syntax$Elm$Syntax$Expression$RecordExpr(
			$author$project$Internal$Compiler$nodifyAll(
				$elm$core$List$reverse(unified.ah))),
		a: unified.a,
		g: false
	};
};
var $stil4m$elm_syntax$Elm$Syntax$Declaration$AliasDeclaration = function (a) {
	return {$: 1, a: a};
};
var $stil4m$elm_syntax$Elm$Syntax$Declaration$CustomTypeDeclaration = function (a) {
	return {$: 2, a: a};
};
var $author$project$Internal$Compiler$documentation = F2(
	function (doc, decl) {
		if (decl.$ === 1) {
			return decl;
		} else {
			var exp = decl.a;
			var imports = decl.b;
			var body = decl.c;
			var str = '{-|' + (doc + '-}');
			switch (body.$) {
				case 0:
					var func = body.a;
					return A3(
						$author$project$Internal$Compiler$Declaration,
						exp,
						imports,
						$stil4m$elm_syntax$Elm$Syntax$Declaration$FunctionDeclaration(
							_Utils_update(
								func,
								{
									x: $elm$core$Maybe$Just(
										$author$project$Internal$Compiler$nodify(str))
								})));
				case 1:
					var typealias = body.a;
					return A3(
						$author$project$Internal$Compiler$Declaration,
						exp,
						imports,
						$stil4m$elm_syntax$Elm$Syntax$Declaration$AliasDeclaration(
							_Utils_update(
								typealias,
								{
									x: $elm$core$Maybe$Just(
										$author$project$Internal$Compiler$nodify(str))
								})));
				case 2:
					var typeDecl = body.a;
					return A3(
						$author$project$Internal$Compiler$Declaration,
						exp,
						imports,
						$stil4m$elm_syntax$Elm$Syntax$Declaration$CustomTypeDeclaration(
							_Utils_update(
								typeDecl,
								{
									x: $elm$core$Maybe$Just(
										$author$project$Internal$Compiler$nodify(str))
								})));
				case 3:
					var sig = body.a;
					return decl;
				case 4:
					return decl;
				default:
					return decl;
			}
		}
	});
var $author$project$Elm$withDocumentation = $author$project$Internal$Compiler$documentation;
var $author$project$Elm$withType = F2(
	function (ann, _v0) {
		var exp = _v0;
		return _Utils_update(
			exp,
			{
				c: $elm$core$Result$Ok(
					$author$project$Internal$Compiler$getInnerAnnotation(ann)),
				a: _Utils_ap(
					exp.a,
					$author$project$Internal$Compiler$getAnnotationImports(ann))
			});
	});
var $author$project$Generate$generateBlocks = function (block) {
	switch (block.$) {
		case 0:
			var str = block.a;
			return _List_Nil;
		case 1:
			var union = block.a;
			return _List_fromArray(
				[
					$author$project$Elm$expose(
					A2(
						$author$project$Elm$withDocumentation,
						union.ag,
						A2(
							$author$project$Elm$declaration,
							'type' + union.i,
							$author$project$Elm$record(
								A2(
									$elm$core$List$cons,
									_Utils_Tuple2(
										A2($author$project$Generate$chooseName, 'annotation', union.bw),
										A2($author$project$Generate$annotationNamed, union.i, union.T)),
									A2(
										$elm$core$List$map,
										function (_v1) {
											var name = _v1.a;
											var tags = _v1.b;
											if (!tags.b) {
												return _Utils_Tuple2(
													name,
													A3(
														$author$project$Generate$valueWith,
														$author$project$Generate$thisModuleName,
														$author$project$Elm$string(name),
														A2(
															$elm$project_metadata_utils$Elm$Type$Type,
															union.i,
															A2($elm$core$List$map, $elm$project_metadata_utils$Elm$Type$Var, union.T))));
											} else {
												return _Utils_Tuple2(
													name,
													A2(
														$author$project$Elm$lambdaWith,
														A2(
															$elm$core$List$indexedMap,
															F2(
																function (i, tag) {
																	return _Utils_Tuple2(
																		$author$project$Elm$Pattern$var(
																			'ar' + $elm$core$String$fromInt(i)),
																		A2($author$project$Elm$Annotation$named, $author$project$Generate$elmAnnotation, 'Annotation'));
																}),
															tags),
														A2(
															$author$project$Generate$apply,
															A3(
																$author$project$Generate$valueWith,
																$author$project$Generate$thisModuleName,
																$author$project$Elm$string(name),
																A2(
																	$elm$project_metadata_utils$Elm$Type$Type,
																	union.i,
																	A2($elm$core$List$map, $elm$project_metadata_utils$Elm$Type$Var, union.T))),
															A2(
																$elm$core$List$indexedMap,
																F2(
																	function (i, tag) {
																		return $author$project$Elm$value(
																			'ar' + $elm$core$String$fromInt(i));
																	}),
																tags))));
											}
										},
										union.bw))))))
				]);
		case 2:
			var alias = block.a;
			return _List_fromArray(
				[
					$author$project$Elm$expose(
					A2(
						$author$project$Elm$withDocumentation,
						alias.ag,
						A2(
							$author$project$Elm$declaration,
							'alias' + alias.i,
							$author$project$Elm$record(
								_List_fromArray(
									[
										_Utils_Tuple2(
										'annotation',
										A2($author$project$Generate$annotationNamed, alias.i, alias.T))
									])))))
				]);
		case 3:
			var value = block.a;
			var _v3 = value.ak;
			if (_v3.$ === 1) {
				var one = _v3.a;
				var two = _v3.b;
				var captured = A2(
					$author$project$Generate$captureFunction,
					two,
					{
						B: _List_fromArray(
							[
								A2($author$project$Generate$asArgument, 1, one)
							]),
						y: 2,
						X: _List_fromArray(
							[
								A2($author$project$Generate$asValue, 1, one)
							])
					});
				return _List_fromArray(
					[
						$author$project$Elm$expose(
						A2(
							$author$project$Elm$withDocumentation,
							value.ag,
							A3(
								$author$project$Elm$functionWith,
								value.i,
								$elm$core$List$reverse(
									A2($elm$core$List$drop, 1, captured.B)),
								A2(
									$author$project$Generate$apply,
									A3(
										$author$project$Generate$valueWith,
										$author$project$Generate$thisModuleName,
										$author$project$Elm$string(value.i),
										value.ak),
									$elm$core$List$reverse(
										A2($elm$core$List$drop, 1, captured.X))))))
					]);
			} else {
				return _List_fromArray(
					[
						$author$project$Elm$expose(
						A2(
							$author$project$Elm$withDocumentation,
							value.ag,
							A2(
								$author$project$Elm$declaration,
								value.i,
								A2(
									$author$project$Elm$withType,
									$author$project$Generate$expressionType,
									A3(
										$author$project$Generate$valueWith,
										$author$project$Generate$thisModuleName,
										$author$project$Elm$string(value.i),
										value.ak)))))
					]);
			}
		case 4:
			var binop = block.a;
			return _List_Nil;
		default:
			var str = block.a;
			return _List_Nil;
	}
};
var $elm$project_metadata_utils$Elm$Docs$MarkdownBlock = function (a) {
	return {$: 0, a: a};
};
var $elm$project_metadata_utils$Elm$Docs$AliasBlock = function (a) {
	return {$: 2, a: a};
};
var $elm$project_metadata_utils$Elm$Docs$BinopBlock = function (a) {
	return {$: 4, a: a};
};
var $elm$project_metadata_utils$Elm$Docs$UnionBlock = function (a) {
	return {$: 1, a: a};
};
var $elm$project_metadata_utils$Elm$Docs$UnknownBlock = function (a) {
	return {$: 5, a: a};
};
var $elm$project_metadata_utils$Elm$Docs$ValueBlock = function (a) {
	return {$: 3, a: a};
};
var $elm$core$String$dropRight = F2(
	function (n, string) {
		return (n < 1) ? string : A3($elm$core$String$slice, 0, -n, string);
	});
var $elm$project_metadata_utils$Elm$Docs$find = F4(
	function (toBlock, name, entries, fallback) {
		find:
		while (true) {
			if (!entries.b) {
				return fallback;
			} else {
				var entry = entries.a;
				var rest = entries.b;
				if (_Utils_eq(entry.i, name)) {
					return toBlock(entry);
				} else {
					var $temp$toBlock = toBlock,
						$temp$name = name,
						$temp$entries = rest,
						$temp$fallback = fallback;
					toBlock = $temp$toBlock;
					name = $temp$name;
					entries = $temp$entries;
					fallback = $temp$fallback;
					continue find;
				}
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$project_metadata_utils$Elm$Docs$nameToBlock = F2(
	function (docs, docsName) {
		var name = A2($elm$core$String$startsWith, '(', docsName) ? A2(
			$elm$core$String$dropLeft,
			1,
			A2($elm$core$String$dropRight, 1, docsName)) : docsName;
		return A4(
			$elm$project_metadata_utils$Elm$Docs$find,
			$elm$project_metadata_utils$Elm$Docs$ValueBlock,
			name,
			docs.X,
			A4(
				$elm$project_metadata_utils$Elm$Docs$find,
				$elm$project_metadata_utils$Elm$Docs$BinopBlock,
				name,
				docs.aM,
				A4(
					$elm$project_metadata_utils$Elm$Docs$find,
					$elm$project_metadata_utils$Elm$Docs$UnionBlock,
					name,
					docs.af,
					A4(
						$elm$project_metadata_utils$Elm$Docs$find,
						$elm$project_metadata_utils$Elm$Docs$AliasBlock,
						name,
						docs.Z,
						$elm$project_metadata_utils$Elm$Docs$UnknownBlock(name)))));
	});
var $elm$core$String$trim = _String_trim;
var $elm$core$String$trimLeft = _String_trimLeft;
var $elm$core$String$words = _String_words;
var $elm$project_metadata_utils$Elm$Docs$partsToBlocks = F2(
	function (docs, parts) {
		if (!parts.b) {
			return _List_Nil;
		} else {
			var part = parts.a;
			var otherParts = parts.b;
			var _v1 = $elm$core$String$words(
				$elm$core$String$trim(part));
			if (!_v1.b) {
				return _List_fromArray(
					[
						$elm$project_metadata_utils$Elm$Docs$MarkdownBlock(
						A2($elm$core$String$join, ',', parts))
					]);
			} else {
				if (!_v1.b.b) {
					var name = _v1.a;
					return A2(
						$elm$core$List$cons,
						A2($elm$project_metadata_utils$Elm$Docs$nameToBlock, docs, name),
						A2($elm$project_metadata_utils$Elm$Docs$partsToBlocks, docs, otherParts));
				} else {
					var name = _v1.a;
					return _List_fromArray(
						[
							A2($elm$project_metadata_utils$Elm$Docs$nameToBlock, docs, name),
							$elm$project_metadata_utils$Elm$Docs$MarkdownBlock(
							A2(
								$elm$core$String$join,
								',',
								A2(
									$elm$core$List$cons,
									A2(
										$elm$core$String$dropLeft,
										$elm$core$String$length(name),
										$elm$core$String$trimLeft(part)),
									otherParts)))
						]);
				}
			}
		}
	});
var $elm$project_metadata_utils$Elm$Docs$chunkToBlocks = F2(
	function (docs, chunk) {
		return A2(
			$elm$project_metadata_utils$Elm$Docs$partsToBlocks,
			docs,
			A2($elm$core$String$split, ',', chunk));
	});
var $elm$project_metadata_utils$Elm$Docs$toBlocks = function (docs) {
	var _v0 = A2($elm$core$String$split, '\n@docs ', docs.ag);
	if (!_v0.b) {
		return _List_Nil;
	} else {
		var firstMarkdown = _v0.a;
		var docsChunks = _v0.b;
		return A2(
			$elm$core$List$cons,
			$elm$project_metadata_utils$Elm$Docs$MarkdownBlock(firstMarkdown),
			A2(
				$elm$core$List$concatMap,
				$elm$project_metadata_utils$Elm$Docs$chunkToBlocks(docs),
				docsChunks));
	}
};
var $author$project$Generate$moduleToFile = function (docs) {
	var sourceModName = A2($elm$core$String$split, '.', docs.i);
	var modNameBlock = $author$project$Elm$expose(
		A2(
			$author$project$Elm$withDocumentation,
			' The name of this module. ',
			A2(
				$author$project$Elm$declaration,
				'moduleName_',
				A2(
					$author$project$Elm$withType,
					A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'),
					A2(
						$author$project$Elm$apply,
						A3(
							$author$project$Elm$valueWith,
							$author$project$Generate$elm,
							'moduleName',
							A2(
								$author$project$Elm$Annotation$function,
								_List_fromArray(
									[
										$author$project$Elm$Annotation$list($author$project$Elm$Annotation$string)
									]),
								A2($author$project$Elm$Annotation$named, $author$project$Generate$elm, 'Module'))),
						_List_fromArray(
							[
								$author$project$Elm$list(
								A2($elm$core$List$map, $author$project$Elm$string, sourceModName))
							]))))));
	var modName = A2(
		$elm$core$List$cons,
		'Elm',
		A2($elm$core$List$cons, 'Gen', sourceModName));
	var blocks = $elm$project_metadata_utils$Elm$Docs$toBlocks(docs);
	var ids = $author$project$Elm$expose(
		A2(
			$author$project$Elm$withDocumentation,
			' Every value/function in this module in case you need to refer to it directly. ',
			A2(
				$author$project$Elm$declaration,
				'id_',
				$author$project$Elm$record(
					A2($elm$core$List$filterMap, $author$project$Generate$blockToIdField, blocks)))));
	return A2(
		$author$project$Elm$file,
		modName,
		A2(
			$elm$core$List$cons,
			modNameBlock,
			_Utils_ap(
				A2($elm$core$List$concatMap, $author$project$Generate$generateBlocks, blocks),
				_List_fromArray(
					[ids]))));
};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $elm$json$Json$Decode$value = _Json_decodeValue;
var $elm$core$Platform$worker = _Platform_worker;
var $author$project$Generate$main = $elm$core$Platform$worker(
	{
		b_: function (json) {
			var _v0 = A2(
				$elm$json$Json$Decode$decodeValue,
				$elm$json$Json$Decode$list($elm$project_metadata_utils$Elm$Docs$decoder),
				json);
			if (_v0.$ === 1) {
				var err = _v0.a;
				return _Utils_Tuple2(
					0,
					$author$project$Elm$Gen$error(
						{
							bR: $elm$json$Json$Decode$errorToString(err),
							cf: 'Issue decoding docs'
						}));
			} else {
				var docs = _v0.a;
				return _Utils_Tuple2(
					0,
					$author$project$Elm$Gen$files(
						A2($elm$core$List$map, $author$project$Generate$moduleToFile, docs)));
			}
		},
		ce: function (_v1) {
			return $elm$core$Platform$Sub$none;
		},
		ch: F2(
			function (msg, model) {
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			})
	});
_Platform_export({'Generate':{'init':$author$project$Generate$main($elm$json$Json$Decode$value)(0)}});}(this));