VERSION = "1.0.0"

if GetOption("pony-mode") == nil then
  AddOption("pony-mode", true)
end

local indent = {
  "actor", 
  "be", 
  "class",
  "do",
  "else",
  "elseif",
  "for",
  "fun",
  "if",
  "in",
  "interface",
  "match",
  "new",
  "object",
  "recover",
  "ref",
  "repeat",
  "struct",
  "tag",
  "then",
  "trait",
  "try",
  "type",
  "until",
  "while",
  "with",
  "=>"
}

function preInsertNewline(v)
  if not GetOption("pony-mode") or not (v.Buf:FileType() == "pony") then
    return
  end

  local line = v.Buf:Line(v.Cursor.Y)
  local ws = GetLeadingWhitespace(line)
  local x = v.Cursor.X

  for _, key in pairs(indent) do
    for word in string.gmatch(string.sub(line, 1, x), "%S+") do
      if word == key then
        v:InsertNewline(false)
        v:InsertTab(false)

        return false
      end
    end
  end
end

local unindent = {
  "then",
  "else",
  "elseif",
  "do",
  "until",
  "end"
}

function onRune(r, v)
  if not GetOption("pony-mode") or not (v.Buf:FileType() == "pony") then
    return
  end

  local line = v.Buf:Line(v.Cursor.Y)

  if string.match(line, "|") and string.match(line, "=>") then
    v:OutdentLine(false)
    return
  end
  
  local trimmed = line:match("^%s*(.+)")
  for _, key in pairs(unindent) do
    if trimmed == key then
      v:OutdentLine(false)
      return
    end
  end
end
