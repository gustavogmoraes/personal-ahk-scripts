#Requires AutoHotkey v2.0

class JsonBool {
    __New(value) {
        this.Value := !!value
    }
}

LayoutConfigPath() {
    return A_AppData "\PersonalAhkScripts\WindowLayoutLauncher\layouts.json"
}

LayoutDefaultsPath() {
    return A_ScriptDir "\..\defaults\layouts.json"
}

LoadLayoutFile(path) {
    if !FileExist(path)
        return {ok: true, missing: true, data: Map()}
    try {
        text := FileRead(path, "UTF-8")
        if (SubStr(text, 1, 1) = Chr(0xFEFF))
            text := SubStr(text, 2)
        data := JsonParse(text)
    } catch as err {
        return {ok: false, missing: false, error: "Could not read layouts.json. The file was kept. " err.Message, data: Map()}
    }
    if !(data is Map) || (data.Has("layouts") && !(data["layouts"] is Array))
        return {ok: false, missing: false, error: "layouts.json has an unexpected shape. The file was kept.", data: Map()}
    return {ok: true, missing: false, data: data}
}

CustomExactLayouts(data) {
    found := []
    if !(data is Map) || !data.Has("layouts") || !(data["layouts"] is Array)
        return found
    for item in data["layouts"] {
        if !(item is Map) || !JsonIsTrue(item.Has("custom") ? item["custom"] : false)
            continue
        if !item.Has("kind") || item["kind"] != "exact"
            continue
        if !item.Has("id") || !item.Has("label") || !(item["label"] is String) || Trim(item["label"]) = ""
            continue
        if !item.Has("width") || !item.Has("height") || !(item["width"] is Integer) || !(item["height"] is Integer)
            continue
        if (item["width"] < 1 || item["height"] < 1)
            continue
        found.Push({id: item["id"], label: item["label"], width: item["width"], height: item["height"]})
    }
    return found
}

SaveCustomExact(path, defaultsPath, label, width, height) {
    if !(width is Integer) || !(height is Integer) || width < 1 || height < 1
        return "The captured window has no size to save."
    label := Trim(label)
    if (label = "")
        return "The size needs a name."
    if !FileExist(path) {
        if !FileExist(defaultsPath)
            return "The default layout file is missing."
        SplitPath path, , &directory
        DirCreate directory
        FileCopy defaultsPath, path, 0
    }
    before := FileRead(path, "UTF-8")
    loaded := LoadLayoutFile(path)
    if !loaded.ok
        return loaded.error
    data := loaded.data
    if !data.Has("schemaVersion")
        data["schemaVersion"] := 1
    if !data.Has("settings")
        data["settings"] := Map("openMenuHotkey", "^#z", "showTrayNotifications", JsonBool(true))
    if !data.Has("layouts")
        data["layouts"] := []
    for item in CustomExactLayouts(data) {
        if (item.label = label)
            return "That name is already used."
    }
    entry := Map()
    entry["id"] := "custom-" A_Now "-" A_TickCount
    entry["label"] := label
    entry["group"] := "Exact sizes"
    entry["kind"] := "exact"
    entry["width"] := width
    entry["height"] := height
    entry["custom"] := JsonBool(true)
    data["layouts"].Push(entry)
    written := WriteLayoutFile(path, data)
    if (written != "") {
        try {
            restored := FileOpen(path, "w", "UTF-8-RAW")
            restored.Write(before)
            restored.Close()
        }
        return written
    }
    return ""
}

DeleteCustomExact(path, id) {
    if !FileExist(path)
        return "There is no custom size file to edit."
    before := FileRead(path, "UTF-8")
    loaded := LoadLayoutFile(path)
    if !loaded.ok
        return loaded.error
    layouts := loaded.data["layouts"]
    removed := false
    index := layouts.Length
    while (index >= 1) {
        item := layouts[index]
        if (item is Map && item.Has("id") && item["id"] = id && JsonIsTrue(item.Has("custom") ? item["custom"] : false)) {
            layouts.RemoveAt(index)
            removed := true
        }
        index--
    }
    if !removed
        return "That custom size is no longer in the file."
    written := WriteLayoutFile(path, loaded.data)
    if (written != "") {
        try {
            restored := FileOpen(path, "w", "UTF-8-RAW")
            restored.Write(before)
            restored.Close()
        }
        return written
    }
    return ""
}

WriteLayoutFile(path, data) {
    temp := path ".tmp"
    try {
        output := FileOpen(temp, "w", "UTF-8-RAW")
        if !output
            throw Error("Could not write a temporary layout file.")
        output.Write(JsonStringify(data) "`n")
        output.Close()
        FileMove temp, path, 1
    } catch as err {
        try FileDelete temp
        return "Could not save layouts.json. The previous file was kept. " err.Message
    }
    return ""
}

JsonIsTrue(value) {
    return value is JsonBool && value.Value
}

JsonParse(text) {
    parser := JsonParser(text)
    return parser.Parse()
}

JsonStringify(value, depth := 0) {
    if value is JsonNull
        return "null"
    if value is JsonBool
        return value.Value ? "true" : "false"
    if value is String
        return JsonQuote(value)
    if value is Integer
        return String(value)
    if value is Float
        return String(value)
    pad := ""
    loop depth
        pad .= "  "
    inner := pad "  "
    if value is Array {
        if (value.Length = 0)
            return "[]"
        lines := []
        for item in value
            lines.Push(inner JsonStringify(item, depth + 1))
        return "[`n" JsonJoin(lines, ",`n") "`n" pad "]"
    }
    if value is Map {
        if (value.Count = 0)
            return "{}"
        lines := []
        for key, item in value
            lines.Push(inner JsonQuote(String(key)) ": " JsonStringify(item, depth + 1))
        return "{`n" JsonJoin(lines, ",`n") "`n" pad "}"
    }
    throw Error("Cannot write an unsupported JSON value.")
}

JsonJoin(lines, separator) {
    text := ""
    for index, line in lines
        text .= (index = 1 ? "" : separator) line
    return text
}

JsonQuote(value) {
    out := '"'
    loop parse value {
        char := A_LoopField
        code := Ord(char)
        if (char = '"')
            out .= '\"'
        else if (char = "\")
            out .= "\\"
        else if (char = "`b")
            out .= "\b"
        else if (char = "`f")
            out .= "\f"
        else if (char = "`n")
            out .= "\n"
        else if (char = "`r")
            out .= "\r"
        else if (char = "`t")
            out .= "\t"
        else if (code < 32)
            out .= Format("\u{:04X}", code)
        else
            out .= char
    }
    return out '"'
}

class JsonParser {
    __New(text) {
        this.text := text
        this.pos := 1
        this.len := StrLen(text)
    }

    Parse() {
        this.Skip()
        value := this.ReadValue()
        this.Skip()
        if (this.pos <= this.len)
            throw Error("Unexpected text after the JSON value.")
        return value
    }

    ReadValue() {
        if (this.pos > this.len)
            throw Error("Unexpected end of JSON.")
        char := this.Peek()
        if (char = "{")
            return this.ReadObject()
        if (char = "[")
            return this.ReadArray()
        if (char = '"')
            return this.ReadString()
        if (char = "t")
            return this.ReadLiteral("true", JsonBool(true))
        if (char = "f")
            return this.ReadLiteral("false", JsonBool(false))
        if (char = "n")
            return this.ReadLiteral("null", JsonNull())
        if (char = "-" || (Ord(char) >= 48 && Ord(char) <= 57))
            return this.ReadNumber()
        throw Error("Unexpected JSON at position " this.pos ".")
    }

    ReadObject() {
        this.Expect("{")
        obj := Map()
        this.Skip()
        if (this.Peek() = "}") {
            this.pos++
            return obj
        }
        loop {
            this.Skip()
            if (this.Peek() != '"')
                throw Error("JSON object key must be a string.")
            key := this.ReadString()
            this.Skip()
            this.Expect(":")
            this.Skip()
            obj[key] := this.ReadValue()
            this.Skip()
            if (this.Peek() = ",") {
                this.pos++
                continue
            }
            this.Expect("}")
            break
        }
        return obj
    }

    ReadArray() {
        this.Expect("[")
        arr := []
        this.Skip()
        if (this.Peek() = "]") {
            this.pos++
            return arr
        }
        loop {
            this.Skip()
            arr.Push(this.ReadValue())
            this.Skip()
            if (this.Peek() = ",") {
                this.pos++
                continue
            }
            this.Expect("]")
            break
        }
        return arr
    }

    ReadString() {
        this.Expect('"')
        out := ""
        while (this.pos <= this.len) {
            char := this.Peek()
            this.pos++
            if (char = '"')
                return out
            if (char != "\") {
                out .= char
                continue
            }
            if (this.pos > this.len)
                throw Error("Unfinished JSON string escape.")
            esc := this.Peek()
            this.pos++
            if (esc = '"')
                out .= '"'
            else if (esc = "\")
                out .= "\"
            else if (esc = "/")
                out .= "/"
            else if (esc = "b")
                out .= "`b"
            else if (esc = "f")
                out .= "`f"
            else if (esc = "n")
                out .= "`n"
            else if (esc = "r")
                out .= "`r"
            else if (esc = "t")
                out .= "`t"
            else if (esc = "u") {
                hex := SubStr(this.text, this.pos, 4)
                if (StrLen(hex) != 4 || !RegExMatch(hex, "^[0-9A-Fa-f]{4}$"))
                    throw Error("Invalid JSON unicode escape.")
                out .= Chr(Number("0x" hex))
                this.pos += 4
            } else
                throw Error("Invalid JSON string escape.")
        }
        throw Error("Unfinished JSON string.")
    }

    ReadNumber() {
        start := this.pos
        if (this.Peek() = "-")
            this.pos++
        this.ReadDigits()
        dotted := false
        if (this.pos <= this.len && this.Peek() = ".") {
            dotted := true
            this.pos++
            this.ReadDigits()
        }
        if (this.pos <= this.len && (this.Peek() = "e" || this.Peek() = "E")) {
            dotted := true
            this.pos++
            if (this.pos <= this.len && (this.Peek() = "+" || this.Peek() = "-"))
                this.pos++
            this.ReadDigits()
        }
        token := SubStr(this.text, start, this.pos - start)
        return Number(token)
    }

    ReadDigits() {
        start := this.pos
        while (this.pos <= this.len) {
            char := this.Peek()
            code := Ord(char)
            if (code < 48 || code > 57)
                break
            this.pos++
        }
        if (this.pos = start)
            throw Error("Expected a number.")
    }

    ReadLiteral(word, value) {
        if (SubStr(this.text, this.pos, StrLen(word)) != word)
            throw Error("Invalid JSON value.")
        this.pos += StrLen(word)
        return value
    }

    Expect(char) {
        if (this.pos > this.len || this.Peek() != char)
            throw Error("Expected " char " at position " this.pos ".")
        this.pos++
    }

    Peek() {
        return SubStr(this.text, this.pos, 1)
    }

    Skip() {
        while (this.pos <= this.len) {
            char := this.Peek()
            if (char != " " && char != "`t" && char != "`n" && char != "`r")
                break
            this.pos++
        }
    }
}

class JsonNull {
}
