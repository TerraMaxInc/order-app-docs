local glossary_defs = nil --{}
local cached_doc = nil

-- Utility: Load glossary definitions from a markdown file
local function load_glossary(doc)
    if glossary_defs then return glossary_defs end -- already loaded

    glossary_defs = {}

    -- Get project root if available: new way
    -- local root = "."
    -- if PANDOC_STATE.metadata and PANDOC_STATE.metadata["project-root"] then
    --     io.stderr:write("PANDOC_STATE.metadata found... \n")
    --     root = pandoc.utils.stringify(PANDOC_STATE.metadata["project-root"])
    --     io.stderr:write("root: " .. root "\n")
    -- end

    -- old way:
    local root = doc.meta["project-root"]
    if type(root) == "table" then
        root = pandoc.utils.stringify(root)
    elseif type(root) ~= "string" then
        io.stderr:write("No project-root found in metadata.  Using '.'\n")
        root = "."
    end

    local glossary_path = root .. "/reference/glossary.qmd"
    io.stderr:write("Attempting to load glossary from: " .. glossary_path .. "\n")

    -- prevent recursion, supposedly
    if PANDOC_STATE.input_files and PANDOC_STATE.input_files[1] == glossary_path then
        io.stderr:write("Skipping glossary.qmd to avoid recursion.\n")
        return
    end

    local file = io.open(glossary_path, "r")
    if not file then
        io.stderr:write("Glossary file not found: " .. glossary_path .. "\n")
        return
    end

    local current_term = nil
    local buffer = {}

    for line in file:lines() do
        local header = line:match("^##%s+(.+)")
        if header then
            if current_term and #buffer > 0 then
                glossary_defs[current_term:lower()] = table.concat(buffer, " ")
            end
            current_term = header
            buffer = {}
        elseif current_term then
            table.insert(buffer, line)
        end
    end

    if current_term and #buffer > 0 then
        glossary_defs[current_term:lower()] = table.concat(buffer, " ")
    end

    file:close()

    -- Print what was loaded for checking
    io.stderr:write("Loaded gloassry terms:\n")
    for term, def in pairs(glossary_defs) do
        io.stderr:write("   - " .. term .. ": " .. def:sub(1, 40) .. "...\n")
    end

    return glossary_defs
end

function Inlines(inlines)
    --io.stderr:write("[glossary] Inlines filter called.\n")
    local glossary = glossary_defs or load_glossary(cached_doc)
    local result = {}

    for i = 1, #inlines do
        local item = inlines[i]

        if item.t == "Str" and item.text:sub(1, 1) == "@" then
            local raw_text = item.text
            local term = item.text:sub(2):lower()
            local def = glossary[term] --glossary_defs[term]

            io.stderr:write(string.format("*****[glossary] Found glossary tag: '%s'\n", raw_text))

            if def then
                local tooltip = string.gsub(def, '"', '&quot;') -- escape quotes for HTML attribute
                local raw_html = string.format('<span title="%s">%s</span>', tooltip, item.text:sub(2))

                io.stderr:write(string.format("*****[glossary] Injecting tooltip for '%s': %s\n", term,
                    tooltip:sub(1, 60)))
                table.insert(result, pandoc.RawInline("html", raw_html))
            else
                -- Fallback: leave it alone or flag somehow
                io.stderr:write(string.format("*****[glossary] No definition found for '%s'.\n", term))
                table.insert(result, item)
            end
        else
            table.insert(result, item)
        end
    end
    return pandoc.Inlines(result)
end

--Pandoc filter: called once per document
function Pandoc(doc)
    cached_doc = doc
    load_glossary(doc)
    return doc
end
