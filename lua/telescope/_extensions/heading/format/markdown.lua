local Markdown = {}

function lpad(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

function Markdown.get_headings(filepath, start, total)
    local headings = {}
    local index = start
    local matches = {
        '# ',
        '## ',
        '### ',
        '#### ',
        '##### ',
        '###### ',
    }
    local is_code_block = false
    local is_heading = false
    local wc = 0
    local heading_wordcounts = {}
    while index <= total do
        local line = vim.fn.getline(index)
	is_heading = false;

        -- process markdown code blocks
        if vim.startswith(line, '```') then
            is_code_block = not is_code_block
            goto next
        else
            if is_code_block then
                goto next
            end
        end
        -- match heading
        for _, pattern in pairs(matches) do
            if vim.startswith(line, pattern) then
                table.insert(headings, {
                    heading = vim.trim(line),
                    line = index,
                    path = filepath,
                })
		table.insert(heading_wordcounts, wc)
		is_heading = true
		wc = 0
                break
            end
        end

	if not is_heading and not is_code_block then
		_,n = string.gsub(line, "%S+","")
		wc = wc + n
	end

        ::next::
        index = index + 1
    end

    -- make a fake root heading if there are none
    if #headings == 0 then
    	table.insert(headings, { heading = "Root", line = 0, path = filepath })
	table.insert(heading_wordcounts, 0)
    end

    -- the final wc
    table.insert(heading_wordcounts, wc)

    -- reverse
    rev = {}
    for i=#headings, 1, -1 do
	headings[i].heading = lpad(tostring(heading_wordcounts[i+1]), 6, ' ') .. headings[i].heading
	rev[#rev+1] = headings[i]
    end

    return rev
end

return Markdown

