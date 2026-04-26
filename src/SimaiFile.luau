--!strict

local SimaiFile = {}
SimaiFile.__index = SimaiFile

export type SimaiFile = setmetatable<{
    Content: string,
}, typeof(SimaiFile)>

local function StringConcatTrimmedEnd(s: {string}, separator: string): string
    local final = ""
    for i = 1, #s do
        final ..= s[i]
        if (i ~= #s) then
            final ..= separator
        end
    end
    return final
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
            key = string.sub(kvSplit[1], 2)
            table.insert(value, kvSplit[2] or "")
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

            if (not (string.lower(string.sub(line, 1, #key)) == string.lower(key))) then
                continue
            end

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