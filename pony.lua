VERSION = "0.2.0"

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
  "primitive",
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

  outdented = false

  local line = v.Buf:Line(v.Cursor.Y)
  local ws = GetLeadingWhitespace(line)
  local x = v.Cursor.X

  if
    (string.sub(line, x+1, x+1) == "}") and 
    (string.find(string.sub(line, x+1), "{") == nil) 
  then
    v:InsertNewline(false)
    v:CursorUp(false)
    v:EndOfLine(false)
    v:InsertNewline(false)
    v:InsertTab(false)
    return false
  end

  for _, key in pairs(indent) do
    for word in string.gmatch(string.sub(line, 1, x), "%S+") do
      if word == key then
        v:InsertNewline(false)
        if string.find(string.sub(line, 1, x+1), "end") == nil then   
          v:InsertTab(false)
        end
        return false
      end
    end
  end
end

local unindent = {
  "then",
  "else",
  "do",
  "until",
  "end"
}

outdented = false

function onRune(r, v)
  checkOutdent(v)
end

function onBackspace(v)
  checkOutdent(v)
end

function checkOutdent(v)
  if not GetOption("pony-mode") or not (v.Buf:FileType() == "pony") then
    return
  end

  if outdented == true then
    v:SelectToStartOfLine(false)
    v:IndentSelection(false)
    v:CursorRight(false)
    v:CursorRight(false)
    outdented = false
  end

  local line = v.Buf:Line(v.Cursor.Y)
  
  local trimmed = line:match("^%s*(.+)")
  for _, key in pairs(unindent) do
    if trimmed == key then
      v:OutdentLine(false)
      outdented = true
      return
    end
  end
end
