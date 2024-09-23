--[[
abstract-section – move an "abstract" section into document metadata

Copyright: © 2024 Pierre-Amiel Giraud
License:   GNU GPL v3 – see LICENSE file for details
]]

--[[if FORMAT ~= "revealjs" then
  print("This filter only works with RevealJS. Sorry.")
  return
end]]

local separator = " - "
local captionClasses = {
"footer",
"ffgLegend"
}
--local caption = true
--local withCaptionClass = "caption"
--local withoutCaptionClass = "nocaption"

--For the Blocks function. Finds figures (with or without captions) in a frame with the fullframegraphic class
local function is_figure_in_fullframegraphic_frame(frame, figure)
  if frame and frame.t == 'Header'
    and figure and (figure.t == 'Figure' or figure.t == 'Para')
    and frame.classes[1] == "fullframegraphic" then
    return figure.t
  end
end

local function parameters(meta)
  if meta.fullframegraphics ~= nil then
    if meta.fullframegraphics.captionClasses ~= nil then
      captionClasses = {}
      for i,class in pairs(meta.fullframegraphics.captionClasses) do table.insert(captionClasses, pandoc.utils.stringify(class)) end
    end
    if meta.fullframegraphics.separator ~= nil then
      separator = pandoc.utils.stringify(meta.fullframegraphics.separator)
    end
    --[[
    if meta.fullframegraphics.caption ~= nil then
      caption = pandoc.utils.stringify(meta.fullframegraphics.caption)
    end
    if meta.fullframegraphics.withCaptionClass ~= nil then
      withCaptionClass = pandoc.utils.stringify(meta.fullframegraphics.withCaptionClass)
    end
    if meta.fullframegraphics.withoutCaptionClass ~= nil then
      withoutCaptionClass = pandoc.utils.stringify(meta.fullframegraphics.withoutCaptionClass)
    end]]
  end
  return meta
end

--[[
local cap = true

local function isCaption(isItCaptionClass)
  print(isItCaptionClass)
  if caption == true then
    if isItCaptionClass and isItCaptionClass == withoutCaptionClass then
      cap = false
    end
  end
  if caption == false then
    if isItCaptionClass and isItCaptionClass ~= withCaptionClass then
      cap = false
    end
  end
  print("With Caption Class :"..withCaptionClass)
  print("Without Caption Class :"..withoutCaptionClass)
  print("cap : ")
  print(cap)
  return cap
end
]]

local function bblocks (blocks)
  local figuretype
  -- Go from end to start to avoid problems with shifting indices.
  for i = #blocks-1, 1, -1 do
    local newClasses = {}
    local originalClasses = {}
    figuretype = is_figure_in_fullframegraphic_frame(blocks[i], blocks[i+1])
    if figuretype == "Figure" then
      blocks[i].attributes['background-image'] = blocks[i+1].content[1].content[1].src
      originalClasses = blocks[i+1].content[1].content[1].classes
      blocks[i+1] = pandoc.Div(pandoc.Para(pandoc.utils.stringify(blocks[i].content)..separator..pandoc.utils.stringify(blocks[i+1].content[1].content[1].caption)))
      for k,v in pairs(captionClasses) do table.insert(newClasses, v) end
      for k,v in pairs(originalClasses) do table.insert(newClasses, v) end
      blocks[i+1].classes = newClasses
      print("Figure")
      for k,v in pairs(newClasses) do print(v) end
      blocks[i].content = ""
    elseif figuretype == "Para" then
      blocks[i].attributes['background-image'] = blocks[i+1].content[1].src
      originalClasses = blocks[i+1].content[1].classes
      blocks[i+1] = pandoc.Div(pandoc.Para(pandoc.utils.stringify(blocks[i].content)))
      for k,v in pairs(captionClasses) do table.insert(newClasses, v) end
      for k,v in pairs(originalClasses) do table.insert(newClasses, v) end
      blocks[i+1].classes = newClasses
      print("Para")
      for k,v in pairs(blocks[i+1].classes) do print(v) end
      blocks[i].content = ""
    end
  end
  return blocks
end

return {{Meta = parameters}, {Blocks = bblocks}}
