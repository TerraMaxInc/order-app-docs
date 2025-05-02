-- quarto render architecture/azure/azure-overview.qmd

local json = require("lunajson.lunajson")
local glossary = {}
local glossary_loaded = false

local function load_glossary(doc)
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
    glossary = json.decode(contents)
    glossary_loaded = true
end

local function tooltipify_cites(inlines)
    local new_block = inlines:walk {
        Cite = function(cite)
            local id = cite.citations[1].id:lower()
            io.stderr:write("id: " .. tostring(id) .. "\n")

            local entry = nil
            for _, item in ipairs(glossary) do
                if item.key == id then
                    entry = item
                    break
                end
            end
            if not entry then return nil end

            -- Replace @key with the actual term as a limk with tooltip
            local content = { pandoc.Str(entry.term) }
            local target = "/reference/glossary.qmd#" .. id
            local title = entry.definition
            local attr = pandoc.Attr("", { "glossary-term" }, { { "title", title } })

            local link = pandoc.Link(content, target, title, attr)

            return link
        end
    }

    return new_block
end

function tooltipify_cite(cite)
    local id = cite.citations[1].id:lower()
    io.stderr:write("id: " .. tostring(id) .. "\n")

    local entry = nil

    for _, item in ipairs(glossary) do
        if item.key == id then
            entry = item
            break
        end
    end
    if not entry then return nil end

    local content = { pandoc.Str(entry.term) }
    local target = "/reference/glossary.qmd#" .. id
    local title = entry.definition
    local attr = pandoc.Attr("", { "glossary-term" }, { { "title", title } })

    local link = pandoc.Link(content, target, title, attr)
    return link
end

function Pandoc(doc)
    if glossary_loaded == false then
        load_glossary(doc)
    end

    return doc:walk {
        Cite = tooltipify_cite
    }

    -- local new_blocks = {}

    -- for _, block in ipairs(doc.blocks) do
    --     if block.t == "Para" or block.t == "Plain" then
    --         table.insert(new_blocks, pandoc.Plain(tooltipify_cites(block.content)))
    --     else
    --         table.insert(new_blocks, block)
    --     end
    -- end

    -- return pandoc.Pandoc(new_blocks, doc.meta)
end
