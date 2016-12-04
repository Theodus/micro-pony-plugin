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

  if 
    (string.sub(line, x+1, x+1) == "}") and 
    (string.find(string.sub(line, x+1), "{") == nil) 
  then
    v:InsertNewline(false)
    v:OutdentLine(false)
    v:CursorLeft(false)
    v:InsertNewline(false)
    v:InsertTab(false)
    return false
  end

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
  
  local trimmed = line:match("^%s*(.+)")
  for _, key in pairs(unindent) do
    if trimmed == key then
      v:OutdentLine(false)
      return
    end
  end
end
