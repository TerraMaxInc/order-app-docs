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

    local basicBlocks = { pandoc.Header(2, { pandoc.Str("Basic Terms") }, pandoc.Attr("basic-terms", {}, {})) }
    local azureBlocks = { pandoc.Header(2, { pandoc.Str("Azure Terms") }, pandoc.Attr("azure-terms", {}, {})) }
    local hubspotBlocks = { pandoc.Header(2, { pandoc.Str("HubSpot Terms") }, pandoc.Attr("hubspot-terms", {}, {})) }
    local defaultBlocks = { pandoc.Header(2, { pandoc.Str("Other Terms") }, pandoc.Attr("default-terms", {}, {})) }

    for _, entry in pairs(glossary) do
        local term = entry.term or "(unknown)"
        local key = entry.key or term:lower():gsub("%s+", "-")
        local def = entry.definition or "(no definition)"
        local cat = entry.category or "default"

        local blocks = {
            pandoc.Header(3, { pandoc.Str(term) }, pandoc.Attr(key, {}, {})),
            pandoc.Para({ pandoc.Str(def) })
        }

        if cat == "basic" then
            for _, b in ipairs(blocks) do table.insert(basicBlocks, b) end
        elseif cat == "azure" then
            for _, b in ipairs(blocks) do table.insert(azureBlocks, b) end
        elseif cat == "hubspot" then
            for _, b in ipairs(blocks) do table.insert(hubspotBlocks, b) end
        else
            for _, b in ipairs(blocks) do table.insert(defaultBlocks, b) end
        end
    end

    local allBlocks = {}
    for _, b in ipairs(basicBlocks) do table.insert(allBlocks, b) end
    for _, b in ipairs(azureBlocks) do table.insert(allBlocks, b) end
    for _, b in ipairs(hubspotBlocks) do table.insert(allBlocks, b) end
    for _, b in ipairs(defaultBlocks) do table.insert(allBlocks, b) end

    return pandoc.Pandoc(allBlocks, doc.meta)
end
