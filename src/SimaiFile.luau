--!strict

local SimaiFile = {}
SimaiFile.__index = SimaiFile

export type SimaiFile = setmetatable<{
    Content: string,
}, typeof(SimaiFile)>

local function StringTrimEnd(s: string): string
    local ns = string.gsub(s, "%s+$", "")
    return ns
end

local function StringConcatTrimmedEnd(s: {string}, separator: string): string
    return StringTrimEnd(table.concat(s, separator))
end

function SimaiFile.ToKeyValuePairs(self: SimaiFile): {[string]: string}
    local kvPairs = {}  :: {[string]: string}
    local lines   = string.split(string.gsub(self.Content, "\r\n", "\n"), "\n")
    local key     = nil :: string?
    local value   = {}  :: {string}
    for _, line in lines do
        if (string.sub(line, 1, 1) == "&") then
            if (key ~= nil) then
                kvPairs[key] = StringConcatTrimmedEnd(value, "\n")
                table.clear(value)
            end
            
            local kvSplit = string.split(line, "=")
            key = string.sub(table.remove(kvSplit, 1) :: string, 2)
            table.insert(value, table.concat(kvSplit, "="))
        else
            table.insert(value, line)
        end
    end

    if (key ~= nil) then
        kvPairs[key] = StringConcatTrimmedEnd(value, "\n")
    end
    
    return kvPairs
end

function SimaiFile.GetValue(self: SimaiFile, key: string): string?
    key                = `&{key}=`
    local lines        = string.split(string.gsub(self.Content, "\r\n", "\n"), "\n")
    local result       = {} :: {string}
    local readingValue = false
    for _, line in lines do
        if (string.sub(line, 1, 1) == "&") then
            if (readingValue) then
                return StringConcatTrimmedEnd(result, "\n")
            end

            if (string.lower(string.sub(line, 1, #key)) ~= string.lower(key)) then
                continue
            end
            
            local kvSplit = string.split(line, "=")
            table.remove(kvSplit, 1)
            table.insert(result, table.concat(kvSplit, "="))
            readingValue = true
        elseif (readingValue) then
            table.insert(result, line)
        end
    end

    if (readingValue) then
        return StringConcatTrimmedEnd(result, "\n")
    end

    return nil
end

return {
    new = function(content: string): SimaiFile
        return setmetatable({
            Content = content,
        }, SimaiFile)
    end
}