local JDX2 = SMODS.current_mod


JDX2.ui_config = {
 colour = G.C.L_BLACK, -- Colour of the mod menu
 author_colour = G.C.BLUE, -- Colour of the text displaying the mod authors
 bg_colour = { G.C.GREY[1], G.C.GREY[2], G.C.GREY[3], 0.5 }, -- Colour of the area behind the mod menu.
 back_colour = G.C.ORANGE, -- Colour of the "Back" button
 tab_button_colour = G.C.BOOSTER, -- Colour of the tab buttons
 collection_colour = G.C.L_BLACK, -- Colour of the collections menu. Defaults to `colour` if not provided.
 collection_bg_colour = { G.C.GREY[1], G.C.GREY[2], G.C.GREY[3], 0.5 }, -- Colour of the area behind the collections menu. Defaults to `bg_colour` if not provided.
 collection_back_colour = G.C.ORANGE, -- Colour of the "Back" button in the collections menu. Defaults to `back_colour` if not provided.
 collection_option_cycle_colour = G.C.RED -- Colour of the option cycle in the collection
}

JDX2.config_tab = function()
    return { n = G.UIT.ROOT, config = {   align = "cm", r = 0.1, minw = 5, padding = 0.2, colour = HEX("00000000") }, nodes = {
        create_toggle({
            label = "Enable ^2 Display",
            ref_table = JDX2.config,
            ref_value = "enable",
            callback = function() SMODS.save_mod_config(JDX2) end,
        })
    } }
end


local text_format_ref = JokerDisplay.text_format
function JokerDisplay.text_format(text, node)
    if not JDX2.config.enable then return text_format_ref(text, node) end
    local retrigger_type = node.config.retrigger_type
    if retrigger_type == "exp" or retrigger_type == "exponentiate" or retrigger_type == "^" then
        local card = node.UIBox.parent
        text = JokerDisplay.retrigger_format(text, node, card)
        text = number_format_x2(text, nil, nil, node.config.signed)
    else 
        text = text_format_ref(text, node)
    end
    return text
end

---Formats number. Modified from JokerDisplay.number_format
---@see number_format
---@param num any Number to format. Accepts Talisman's bignum/omeganum.
---@param e_switch_point number? Number from where to switch to scientic notation. Defaults to 1000000.
---@param places number? Maximum decimal places. Defaults to 2.
---@param signed boolean|string|table?
---@return any # The formatted string or `num` if it's not a number.
function number_format_x2(num, e_switch_point, places, signed)
    local mynum = num -- Avoid modifyoing the original in case we default to using JokerDisplay.number_format
    if not mynum then return mynum or '' end
    if type(mynum) == "function" then mynum = mynum() end
    if (type(mynum) ~= 'number' and type(mynum) ~= 'table' and type(mynum) ~= 'cdata') then return mynum or '' end
    -- Amulet compat. Copied from Talisman with some changes :)
    local plus = ""
    local minus = "-"

    -- Just get a regular number  (copied from JokerDisplay)
    if type(mynum) == 'table' or type(mynum) == "cdata" then
        mynum = mynum:to_number()
    end

    if math.abs(mynum) >= 2 then  -- If it's smaller than 2x, just let it be
        -- Figure out signs (copied from JokerDisplay)
        if signed then
            local typesigned = type(signed)
            if typesigned == "table" then
                plus = signed.plus or plus
                minus = signed.minus or minus
            elseif typesigned == "string" then
                plus = signed == "$" and "+" .. localize('$') or signed
                minus = signed == "$" and "-" .. localize('$') or (signed .. minus)
            else
                plus = "+"
            end
        end
        local sign = (mynum >= 0 and plus) or minus
        if mynum == math.huge then
            return sign .. "naneinf"
        end

        -- Get the log and make decimal part only 0.25, 0.5 ,0.75
        mynum = math.abs(mynum)
        local numTwos = math.log(mynum, 2)
        local numTwosFinal = math.floor(numTwos)
        local fractionPart = numTwos - numTwosFinal
        if fractionPart >= 0.75 then
            numTwosFinal = numTwosFinal + 0.75
        elseif fractionPart >= 0.50 then
            numTwosFinal = numTwosFinal + 0.5
        elseif fractionPart >= 0.25 then
            numTwosFinal = numTwosFinal + 0.25
        end
        return "2^" .. numTwosFinal
    else
        return JokerDisplay.number_format(num, e_switch_point, places, signed)
    end
end