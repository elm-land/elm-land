"use strict";
var __assign = (this && this.__assign) || function () {
  __assign = Object.assign || function (t) {
    for (var s, i = 1, n = arguments.length; i < n; i++) {
      s = arguments[i];
      for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
        t[p] = s[p];
    }
    return t;
  };
  return __assign.apply(this, arguments);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
  function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
  return new (P || (P = Promise))(function (resolve, reject) {
    function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
    function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
    function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
    step((generator = generator.apply(thisArg, _arguments || [])).next());
  });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
  var _ = { label: 0, sent: function () { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
  return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function () { return this; }), g;
  function verb(n) { return function (v) { return step([n, v]); }; }
  function step(op) {
    if (f) throw new TypeError("Generator is already executing.");
    while (_) try {
      if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
      if (y = 0, t) op = [op[0] & 2, t.value];
      switch (op[0]) {
        case 0: case 1: t = op; break;
        case 4: _.label++; return { value: op[1], done: false };
        case 5: _.label++; y = op[1]; op = [0]; continue;
        case 7: op = _.ops.pop(); _.trys.pop(); continue;
        default:
          if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
          if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
          if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
          if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
          if (t[2]) _.ops.pop();
          _.trys.pop(); continue;
      }
      op = body.call(thisArg, _);
    } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
    if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
  }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.toColoredTerminalOutput = void 0;
var nodeElmCompiler = require('node-elm-compiler');
var compile = function (path) {
  return __awaiter(void 0, void 0, void 0, function () {
    return __generator(this, function (_a) {
      return [2 /*return*/, toRawJsonString(path).then(parse)];
    });
  });
};
var toRawJsonString = function (path) {
  return __awaiter(void 0, void 0, void 0, function () {
    return __generator(this, function (_a) {
      return [2 /*return*/, nodeElmCompiler
        .compileToString([path], { report: 'json' })
        .catch(function (err) { return err.message.slice('Compilation failed\n'.length); })];
    });
  });
};
var parse = function (rawErrorString) {
  // The error returned from node-elm-compiler's error.message
  // contains this string before the JSON blob:
  var nodeElmCompilerPreamble = "Compilation failed\n";
  var normalizedJsonString = (rawErrorString.indexOf(nodeElmCompilerPreamble) === 0)
    ? rawErrorString.slice(nodeElmCompilerPreamble.length)
    : rawErrorString;
  try {
    // Doing this `as` cast here is dangerous, because 
    // the caller can pass arbitrary JSON:
    var json = JSON.parse(normalizedJsonString);
    // To potentially prevent this cast from leading to
    // unexpected errors, we validate it at least has
    // the expected "type" values
    if (json.type === 'compile-errors' || json.type === 'error') {
      return json;
    }
    else {
      console.error("JSON is valid, but result is not an Elm error", rawErrorString);
      return undefined;
    }
  }
  catch (e) {
    console.error("Failed to decode an Elm error", rawErrorString);
    return undefined;
  }
};
var toColoredHtmlOutput = function (elmError, colorMap = {
  GREEN: 'mediumseagreen',
  RED: 'indianred',
  BLUE: 'dodgerblue',
}) {
  var gap = "<br/>";
  // These can be passed in
  var colors = __assign({ RED: 'red', MAGENTA: 'magenta', YELLOW: 'yellow', GREEN: 'green', CYAN: 'cyan', BLUE: 'blue', BLACK: 'black', WHITE: 'white' }, colorMap);
  var render = function (message) {
    var messages = normalizeErrorMessages(message);
    return messages.map(function (msg) {
      var text = msg.string.split('\n');
      var lines = text.map(function (str) {
        var style = {};
        if (msg.bold) {
          style['font-weight'] = 'bold';
        }
        if (msg.underline) {
          style['text-decoration'] = 'underline';
        }
        if (msg.color) {
          style['color'] = colors[msg.color.toUpperCase()];
        }
        var styleValue = Object.keys(style).map(function (k) { return "".concat(k, ": ").concat(style[k]); }).join('; ');
        return "<span style=\"".concat(styleValue, "\">").concat(escapeHtml(str), "</span>");
      });
      return lines.join(gap);
    }).join('');
  };
  var attrs = "style=\"white-space: pre;\"";
  switch (elmError.type) {
    case 'compile-errors':
      var lines = elmError.errors.map(function (error) {
        return error.problems.map(function (problem) {
          return [
            "<span style=\"color:cyan\">".concat(escapeHtml(header(error, problem)), "</span>"),
            render(problem.message)
          ].join(gap.repeat(2));
        }).join(gap.repeat(2));
      });
      return "<div ".concat(attrs, ">").concat(lines.join(gap.repeat(3)), "</div>");
    case 'error':
      return [
        "<span style=\"color:cyan\">".concat(escapeHtml(header(elmError, elmError)), "</span>"),
        "<div ".concat(attrs, ">").concat(render(elmError.message), "</div>")
      ].join(gap.repeat(2))
  }
};
// INTERNALS
/**
 * Converts strings to styled messages, so we can easily
 * apply formatting using an Array.map in view code
 */
var normalizeErrorMessages = function (messages) {
  return messages.map(function (msg) {
    return typeof msg === 'string'
      ? { bold: false, underline: false, color: 'WHITE', string: msg }
      : msg;
  });
};
var header = function (error, problem, cwd_) {
  var MAX_WIDTH = 80;
  var SPACER = '-';
  var SPACING_COUNT = 2;
  var PREFIX = '-- ';
  var left = problem.title;
  var cwd = cwd_ || process.cwd();

  var absolutePath = error.path;
  var relativePath = ''
  if (absolutePath) {
    relativePath = absolutePath.slice(cwd.length + 1);
  }
  var dashCount = MAX_WIDTH - left.length - PREFIX.length - SPACING_COUNT - relativePath.length;
  return "".concat(PREFIX).concat(left, " ").concat(SPACER.repeat(dashCount), " ").concat(relativePath);
};
var escapeHtml = function (str) {
  return str
    .split('<').join('&lt;')
    .split('>').join('&gt;');
};
var toColoredTerminalOutput = function (elmError) {
  // TERMINAL ASCII CODES
  var code = function (num) { return "\u001b[" + num + "m"; };
  var reset = code(0);
  var bold = code(1);
  var underline = code(4);
  var colors = {
    RED: 31,
    MAGENTA: 35,
    YELLOW: 33,
    GREEN: 32,
    CYAN: 36,
    BLUE: 34,
    BLACK: 30,
    WHITE: 37
  };
  var render = function (message) {
    var messages = normalizeErrorMessages(message);
    return messages.map(function (msg) {
      var str = '';
      if (msg.bold) {
        str += bold;
      }
      if (msg.underline) {
        str += underline;
      }
      if (msg.color) {
        str += code(colors[msg.color.toUpperCase()]);
      }
      str += msg.string;
      str += reset;
      return str;
    }).join('');
  };
  switch (elmError.type) {
    case 'compile-errors':
      var output = elmError.errors.reduce(function (output, error) {
        var problems = error.problems.map(function (problem) {
          return [
            (code(colors.CYAN) + header(error, problem) + reset),
            render(problem.message)
          ].join('\n\n\n');
        });
        return output.concat(problems);
      }, []);
      return output.join('\n\n');
    case 'error':
      return [
        (code(colors.CYAN) + header(elmError, elmError) + reset),
        render(elmError.message)
      ].join('\n\n')
  }
};
exports.toColoredTerminalOutput = toColoredTerminalOutput;
exports.default = {
  compile: compile,
  parse: parse,
  toRawJsonString: toRawJsonString,
  toColoredTerminalOutput: exports.toColoredTerminalOutput,
  toColoredHtmlOutput: toColoredHtmlOutput
};
