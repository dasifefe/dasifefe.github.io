temporary_file_name = os.tmpname()

local text_from_file = function (file_name)
	local input = nil
	local text = nil
	input = io.open(file_name, "r")
	text = input:read("*all")
	io.close(input)
	return text
end

local array_line_from_file = function (file_name)
	local input = nil
	local line = nil
	local array_line = {}
	input = io.open(file_name, "r")
	line = input:read("*line")
	while line ~= nil do
		array_line[#array_line + 1] = line
		line = input:read("*line")
	end
	io.close(input)
	return array_line
end

local build_target = function (title, target, target_directory, reverse)
	print("Building list of " .. target .. ".")
	index_text = index_text .. "<h1>" .. title .. "</h1>" .. "\n"
	if reverse == true then
		index_text = index_text .. "<ol reversed>\n"
	else
		index_text = index_text .. "<ol>\n"
	end
	list_array_line = array_line_from_file(temporary_file_name)
	for list_line_index, list_line in ipairs(list_array_line) do
		local target_output = nil
		local target_text = nil
		local template_target_array_line = nil
		local date = nil
		print("Building \"" .. list_line .. "\".")
		date = string.match(list_line, target .. "%-(%d%d%d%d%-%d%d%-%d%d)%-.+")
		if date ~= "0000-00-00" then
			template_target_array_line = array_line_from_file("./templates/" .. list_line)
			-- Index.
			index_text = index_text .. "<li>"
			if target == "post" then
				index_text = index_text .. string.match(list_line, "(%d%d%d%d%-%d%d%-%d%d)-.+") .. " "
			end
			index_text = index_text .. "<a href=\"" .. target_directory .. list_line .. "\">"
			index_text = index_text .. string.match(template_target_array_line[1], "<h1>(.+)</h1>") .. "</a></li>\n"
			-- Generate target.
			target_text = text_from_file("./templates/template-top-1.html")
			target_text = target_text .. "<title>Dasifefe - " .. string.match(template_target_array_line[1], "<h1>(.+)</h1>") .. "</title>" .. "\n"
			target_text = target_text .. text_from_file("./templates/template-top-2.html")
			target_text = target_text .. text_from_file("./templates/" .. list_line)
			target_text = target_text .. text_from_file("./templates/template-bottom.html")
			target_output = io.open(target_directory .. list_line, "w")
			target_output:write(target_text)
			io.close(target_output)
		end
	end
	if reverse == true then
		index_text = index_text .. "</ol>\n"
	else
		index_text = index_text .. "</ol>\n"
	end
end

os.execute("rm page-*.html")
os.execute("rm post-*.html")

index_text = text_from_file("./templates/template-top-1.html")
index_text = index_text .. "<title>Dasifefe</title>" .. "\n"
index_text = index_text .. text_from_file("./templates/template-top-2.html")

os.execute("ls ./templates | grep \"^page-*\" > " .. temporary_file_name)
build_target("Pages", "page", "./", false)
os.execute("ls ./templates | grep \"^post-*\" | sort -r > " .. temporary_file_name)
build_target("Posts", "post", "./", true)

index_text = index_text .. text_from_file("./templates/template-bottom.html")
index_output = io.open("./index.html", "w")
index_output:write(index_text)
io.close(index_output)

os.remove(temporary_file_name)
