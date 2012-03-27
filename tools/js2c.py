#!/usr/bin/env python2
#
# Copyright 2006-2008 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This is a utility for converting JavaScript source code into C-style
# char arrays. It is used for embedded JavaScript code in the V8
# library.

import os, re, sys, string
import jsmin


def ToCArray(lines):
  result = []
  for chr in lines:
    value = ord(chr)
    assert value < 128
    result.append(str(value))
  result.append("0")
  return ", ".join(result)


def RemoveCommentsAndTrailingWhitespace(lines):
  lines = re.sub(r'//.*\n', '\n', lines) # end-of-line comments
  lines = re.sub(re.compile(r'/\*.*?\*/', re.DOTALL), '', lines) # comments.
  lines = re.sub(r'\s+\n+', '\n', lines) # trailing whitespace
  return lines


def ReadFile(filename):
  file = open(filename, "rt")
  try:
    lines = file.read()
  finally:
    file.close()
  return lines


def ReadLines(filename):
  result = []
  for line in open(filename, "rt"):
    if '#' in line:
      line = line[:line.index('#')]
    line = line.strip()
    if len(line) > 0:
      result.append(line)
  return result


def LoadConfigFrom(name):
  import ConfigParser
  config = ConfigParser.ConfigParser()
  config.read(name)
  return config


def ParseValue(string):
  string = string.strip()
  if string.startswith('[') and string.endswith(']'):
    return string.lstrip('[').rstrip(']').split()
  else:
    return string


EVAL_PATTERN = re.compile(r'\beval\s*\(');
WITH_PATTERN = re.compile(r'\bwith\s*\(');


def Validate(lines, file):
  lines = RemoveCommentsAndTrailingWhitespace(lines)
  # Because of simplified context setup, eval and with is not
  # allowed in the natives files.
  eval_match = EVAL_PATTERN.search(lines)
  if eval_match:
    raise ("Eval disallowed in natives: %s" % file)
  with_match = WITH_PATTERN.search(lines)
  if with_match:
    raise ("With statements disallowed in natives: %s" % file)


def ExpandConstants(lines, constants):
  for key, value in constants:
    lines = key.sub(str(value), lines)
  return lines


def ExpandMacros(lines, macros):
  # We allow macros to depend on the previously declared macros, but
  # we don't allow self-dependecies or recursion.
  for name_pattern, macro in reversed(macros):
    pattern_match = name_pattern.search(lines, 0)
    while pattern_match is not None:
      # Scan over the arguments
      height = 1
      start = pattern_match.start()
      end = pattern_match.end()
      assert lines[end - 1] == '('
      last_match = end
      arg_index = 0
      mapping = { }
      def add_arg(str):
        # Remember to expand recursively in the arguments
        replacement = ExpandMacros(str.strip(), macros)
        mapping[macro.args[arg_index]] = replacement
      while end < len(lines) and height > 0:
        # We don't count commas at higher nesting levels.
        if lines[end] == ',' and height == 1:
          add_arg(lines[last_match:end])
          last_match = end + 1
        elif lines[end] in ['(', '{', '[']:
          height = height + 1
        elif lines[end] in [')', '}', ']']:
          height = height - 1
        end = end + 1
      # Remember to add the last match.
      add_arg(lines[last_match:end-1])
      result = macro.expand(mapping)
      # Replace the occurrence of the macro with the expansion
      lines = lines[:start] + result + lines[end:]
      pattern_match = name_pattern.search(lines, start + len(result))
  return lines

class TextMacro:
  def __init__(self, args, body):
    self.args = args
    self.body = body
  def expand(self, mapping):
    result = self.body
    for key, value in mapping.items():
        result = result.replace(key, value)
    return result

class PythonMacro:
  def __init__(self, args, fun):
    self.args = args
    self.fun = fun
  def expand(self, mapping):
    args = []
    for arg in self.args:
      args.append(mapping[arg])
    return str(self.fun(*args))

CONST_PATTERN = re.compile(r'^const\s+([a-zA-Z0-9_]+)\s*=\s*([^;]*);$')
MACRO_PATTERN = re.compile(r'^macro\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*=\s*([^;]*);$')
PYTHON_MACRO_PATTERN = re.compile(r'^python\s+macro\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*=\s*([^;]*);$')


def ReadMacros(lines):
  constants = []
  macros = []
  for line in lines:
    hash = line.find('#')
    if hash != -1: line = line[:hash]
    line = line.strip()
    if len(line) is 0: continue
    const_match = CONST_PATTERN.match(line)
    if const_match:
      name = const_match.group(1)
      value = const_match.group(2).strip()
      constants.append((re.compile("\\b%s\\b" % name), value))
    else:
      macro_match = MACRO_PATTERN.match(line)
      if macro_match:
        name = macro_match.group(1)
        args = map(string.strip, macro_match.group(2).split(','))
        body = macro_match.group(3).strip()
        macros.append((re.compile("\\b%s\\(" % name), TextMacro(args, body)))
      else:
        python_match = PYTHON_MACRO_PATTERN.match(line)
        if python_match:
          name = python_match.group(1)
          args = map(string.strip, python_match.group(2).split(','))
          body = python_match.group(3).strip()
          fun = eval("lambda " + ",".join(args) + ': ' + body)
          macros.append((re.compile("\\b%s\\(" % name), PythonMacro(args, fun)))
        else:
          raise ("Illegal line: " + line)
  return (constants, macros)


HEADER_TEMPLATE = """\
// Copyright 2008 Google Inc. All Rights Reserved.

// This file was generated from .js source files by SCons.  If you
// want to make changes to this file you should either change the
// javascript source files or the SConstruct script.

#include "v8.h"
#include "natives.h"

namespace v8 {
namespace internal {

%(source_lines)s\

  template <>
  int NativesCollection<%(type)s>::GetBuiltinsCount() {
    return %(builtin_count)i;
  }

  template <>
  int NativesCollection<%(type)s>::GetDebuggerCount() {
    return %(debugger_count)i;
  }

  template <>
  int NativesCollection<%(type)s>::GetIndex(const char* name) {
%(get_index_cases)s\
    return -1;
  }

  template <>
  Vector<const char> NativesCollection<%(type)s>::GetScriptSource(int index) {
%(get_script_source_cases)s\
    return Vector<const char>("", 0);
  }

  template <>
  Vector<const char> NativesCollection<%(type)s>::GetScriptName(int index) {
%(get_script_name_cases)s\
    return Vector<const char>("", 0);
  }

}  // internal
}  // v8
"""


SOURCE_DECLARATION = """\
  static const char %(id)s[] = { %(data)s };
"""


GET_DEBUGGER_INDEX_CASE = """\
    if (strcmp(name, "%(id)s") == 0) return %(i)i;
"""


GET_DEBUGGER_SCRIPT_SOURCE_CASE = """\
    if (index == %(i)i) return Vector<const char>(%(id)s, %(length)i);
"""


GET_DEBUGGER_SCRIPT_NAME_CASE = """\
    if (index == %(i)i) return Vector<const char>("%(name)s", %(length)i);
"""

def JS2C(source, target, env):
  ids = []
  debugger_ids = []
  modules = []
  # Locate the macros file name.
  consts = []
  macros = []
  for s in source:
    if 'macros.py' == (os.path.split(str(s))[1]):
      (consts, macros) = ReadMacros(ReadLines(str(s)))
    else:
      modules.append(s)

  # Build source code lines
  source_lines = [ ]

  minifier = jsmin.JavaScriptMinifier()

  source_lines_empty = []
  for module in modules:
    filename = str(module)
    debugger = filename.endswith('-debugger.js')
    lines = ReadFile(filename)
    lines = ExpandConstants(lines, consts)
    lines = ExpandMacros(lines, macros)
    Validate(lines, filename)
    lines = minifier.JSMinify(lines)
    data = ToCArray(lines)
    id = (os.path.split(filename)[1])[:-3]
    if debugger: id = id[:-9]
    if debugger:
      debugger_ids.append((id, len(lines)))
    else:
      ids.append((id, len(lines)))
    source_lines.append(SOURCE_DECLARATION % { 'id': id, 'data': data })
    source_lines_empty.append(SOURCE_DECLARATION % { 'id': id, 'data': data })

  # Build debugger support functions
  get_index_cases = [ ]
  get_script_source_cases = [ ]
  get_script_name_cases = [ ]

  i = 0
  for (id, length) in debugger_ids:
    native_name = "native %s.js" % id
    get_index_cases.append(GET_DEBUGGER_INDEX_CASE % { 'id': id, 'i': i })
    get_script_source_cases.append(GET_DEBUGGER_SCRIPT_SOURCE_CASE % {
      'id': id,
      'length': length,
      'i': i
    })
    get_script_name_cases.append(GET_DEBUGGER_SCRIPT_NAME_CASE % {
      'name': native_name,
      'length': len(native_name),
      'i': i
    });
    i = i + 1

  for (id, length) in ids:
    native_name = "native %s.js" % id
    get_index_cases.append(GET_DEBUGGER_INDEX_CASE % { 'id': id, 'i': i })
    get_script_source_cases.append(GET_DEBUGGER_SCRIPT_SOURCE_CASE % {
      'id': id,
      'length': length,
      'i': i
    })
    get_script_name_cases.append(GET_DEBUGGER_SCRIPT_NAME_CASE % {
      'name': native_name,
      'length': len(native_name),
      'i': i
    });
    i = i + 1

  # Emit result
  output = open(str(target[0]), "w")
  output.write(HEADER_TEMPLATE % {
    'builtin_count': len(ids) + len(debugger_ids),
    'debugger_count': len(debugger_ids),
    'source_lines': "\n".join(source_lines),
    'get_index_cases': "".join(get_index_cases),
    'get_script_source_cases': "".join(get_script_source_cases),
    'get_script_name_cases': "".join(get_script_name_cases),
    'type': env['TYPE']
  })
  output.close()

  if len(target) > 1:
    output = open(str(target[1]), "w")
    output.write(HEADER_TEMPLATE % {
      'builtin_count': len(ids) + len(debugger_ids),
      'debugger_count': len(debugger_ids),
      'source_lines': "\n".join(source_lines_empty),
      'get_index_cases': "".join(get_index_cases),
      'get_script_source_cases': "".join(get_script_source_cases),
      'get_script_name_cases': "".join(get_script_name_cases),
      'type': env['TYPE']
    })
    output.close()

def main():
  natives = sys.argv[1]
  natives_empty = sys.argv[2]
  type = sys.argv[3]
  source_files = sys.argv[4:]
  JS2C(source_files, [natives, natives_empty], { 'TYPE': type })

if __name__ == "__main__":
  main()
