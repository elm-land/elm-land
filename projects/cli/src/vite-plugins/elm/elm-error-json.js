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
var toColoredHtmlOutput = function (elmError, hasLinks = true, colorMap = {
  "RED": "var(--elmError__red)",
  "GREEN": "var(--elmError__green)",
  "YELLOW": "var(--elmError__yellow)",
  "BLUE": "var(--elmError__blue)",
  "MAGENTA": "var(--elmError__magenta)",
  "CYAN": "var(--elmError__cyan)",
  "BLACK": "var(--elmError__foreground)",
  "WHITE": "var(--elmError__foreground)",
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
            "<span style=\"color:var(--elmError__cyan)\">".concat(header(error, problem, hasLinks), "</span>"),
            render(problem.message)
          ].join(gap.repeat(2));
        }).join(gap.repeat(2))
      });
      return "<div ".concat(attrs, ">").concat(lines.join(gap.repeat(3)), "</div>")
    case 'error':
      return [
        "<span style=\"color:var(--elmError__cyan)\">".concat(header(elmError, elmError, hasLinks), "</span>"),
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
      ? { bold: false, underline: false, color: 'var(--elmError__white)', string: msg }
      : msg;
  });
};
var header = function (error, problem, hasLinks = true) {
  var MAX_WIDTH = 80;
  var SPACER = '-';
  var SPACING_COUNT = 2;
  var PREFIX = '-- ';
  var left = problem.title;
  var url = ''
  var dashCount = (right = '') => MAX_WIDTH - left.length - PREFIX.length - SPACING_COUNT - right.length
  if (hasLinks) {
    try {
      let { region } = problem
      url = `${error.path}:${region.start.line}:${region.start.column}`
    } catch (_) { }
  }
  if (hasLinks && url) {
    let right = 'Jump to problem'
    let link = (label) => `<button data-source="${url}">${label}</button>`
    return PREFIX + left + ' ' + '-'.repeat(dashCount(right) - 2) + '  ' + link(right)
  } else {
    var cwd = process.cwd()
    var absolutePath = error.path
    var relativePath = ''
    if (absolutePath) {
      relativePath = absolutePath.slice(cwd.length + 1)
    }
    return "".concat(PREFIX).concat(left, " ").concat(SPACER.repeat(dashCount(relativePath)), " ").concat(escapeHtml(relativePath))
  }
};
var escapeHtml = function (str) {
  return str
    .split('<').join('&lt;')
    .split('>').join('&gt;');
};
export var toColoredTerminalOutput = function (elmError) {
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

export default { toColoredHtmlOutput }