-- quarto render reference/glossary.qmd

local json = require("lunajson.lunajson")

function Pandoc(doc)
    local root = doc.meta["project-root"]
    if type(root) == "table" then
        root = pandoc.utils.stringify(root)
    elseif type(root) ~= "string" then
        io.stderr:write("No project-root found in metadata.  Using '.'\n")
        root = "."
    end

    local glossary_path = root .. "/glossary.json"
    local file = io.open(glossary_path, "r")
    if not file then
        io.stderr:write("Glossary file not found: " .. glossary_path .. "\n")
        return doc
    end

    local contents = file:read("*a")
    file:close()
    local glossary = json.decode(contents)

    local blocks = {}

    for _, entry in pairs(glossary) do
        local term = entry.term or "(unknown)"
        local key = entry.key or term:lower():gsub("%s+", "-")
        local def = entry.definition or "(no definition)"

        io.stderr:write("term: " .. term .. ", key: " .. key .. ", def: " .. def)

        table.insert(blocks, pandoc.Header(2, { pandoc.Str(term) }, pandoc.Attr(key, {}, {})))
        table.insert(blocks, pandoc.Para({ pandoc.Str(def) }))
    end

    return pandoc.Pandoc(blocks, doc.meta)
end
