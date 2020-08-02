-- Universal Counter Tokens      coded by: MrStump

--Saves the count value into a table (data_to_save) then encodes it into the Tabletop save
function onSave()
    local data_to_save = {saved_count = count}
    saved_data = JSON.encode(data_to_save)
    return saved_data
end

--Loads the saved data then creates the buttons
function onload(saved_data)
    generateButtonParamiters()
    --Checks if there is a saved data. If there is, it gets the saved value for 'count'
    if saved_data ~= '' then
        local loaded_data = JSON.decode(saved_data)
        count = loaded_data.saved_count
    else
        --If there wasn't saved data, the default value is set to 10.
        count = 0
    end

    --Generates the buttons after putting the count value onto the 'display' button
    b_display.label = tostring(count)
    if count >= 100 then
        b_display.font_size = 360
    else
        b_display.font_size = 500
    end
    self.createButton(b_display)
    self.createButton(b_plus)
    self.createButton(b_minus)
end

--Activates when + is hit. Adds 1 to 'count' then updates the display button.
function increase()
    count = count + 1
    updateDisplay()
end

--Activates when - is hit. Subtracts 1 from 'count' then updates the display button.
function decrease()
    --Prevents count from going below 0
    if count > 0 then
        count = count - 1
        updateDisplay()
    end
end

function customSet()
    local description = self.getDescription()
    if description ~= '' and type(tonumber(description)) == 'number' then
        self.setDescription('')
        count = tonumber(description)
        updateDisplay()
    end
end

--function that updates the display. I trigger it whenever I change 'count'
function updateDisplay()
    --If statement to resize font size if it gets too long
    if count >= 100 then
        b_display.font_size = 360
    else
        b_display.font_size = 500
    end
    b_display.label = tostring(count)
    self.editButton(b_display)
end

--This is activated when onload runs. This sets all paramiters for our buttons.
--I do not have to put this all into a function, but I prefer to do it this way.
function generateButtonParamiters()
    b_display = {
        index = 0, click_function = 'customSet', function_owner = self, label = '',
        position = {-1.3,0.1,-0.5}, width = 600, height = 600, font_size = 500
    }
    b_plus = {
        click_function = 'increase', function_owner = self, label =  '+1',
        position = {-0.55,0.1,-0.5}, width = 150, height = 600, font_size = 100
    }
    b_minus = {
        click_function = 'decrease', function_owner = self, label =  '-1',
        position = {-2.05,0.1,-0.5}, width = 150, height = 600, font_size = 100
    }
end


