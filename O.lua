local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/senzxyz2xxx/SUI/refs/heads/main/p.lua"))()

Library:PlaySplash(function()
    Library:Notify("SENZY HUB", "UI Showcase Framework Loaded!", 3.5, "Success")
end)

local Window = Library:CreateWindow({
    Title = "SENZY HUB",
    Subtitle = "Example UI",
    Size = UDim2.fromOffset(1120, 720)
})

local MainTab       = Window:CreateTab("Main")
local ComponentsTab = Window:CreateTab("Components")
local MainSection = MainTab:AddSection("Basic Interactive Elements")

MainSection:AddButton({
    Name = "Test Notification Trigger",
    Callback = function()
        print("[SENZY HUB] Button Clicked!")
        Library:Notify("Button Event", "Triggered notification successfully!", 3, "Success")
    end
})

MainSection:AddToggle({
    Name = "Demo Toggle Switch",
    Description = "Example toggle description text",
    Default = false,
    Flag = "DemoToggleFlag",
    Callback = function(state)
        print("[SENZY HUB] Toggle changed state to:", state)
        Library:Notify("Toggle Event", "State changed to: " .. tostring(state), 2.5, state and "Success" or "Warning")
    end
})

MainSection:AddSlider({
    Name = "Demo Speed Slider",
    Min = 16,
    Max = 250,
    Default = 100,
    Flag = "DemoSliderFlag",
    Callback = function(value)
        print("[SENZY HUB] Slider value set to:", value)
    end
})

local SelectionSection = ComponentsTab:AddSection("Selection Controls")

SelectionSection:AddDropdown({
    Name = "Mode Selection",
    Options = {"Normal Mode", "Fast Mode", "Safe Mode", "Experimental Mode"},
    Default = "Normal Mode",
    Flag = "DemoDropdownFlag",
    Callback = function(selectedOption)
        print("[SENZY HUB] Dropdown selected:", selectedOption)
        Library:Notify("Dropdown Event", "Selected Mode: " .. tostring(selectedOption), 2.5, "Info")
    end
})

SelectionSection:AddMultiDropdown({
    Name = "Feature Multi Selector",
    Options = {"Option Alpha", "Option Beta", "Option Gamma", "Option Delta", "Option Epsilon"},
    Default = {"Option Alpha", "Option Beta"},
    Flag = "DemoMultiDropdownFlag",
    Callback = function(selectedTable)
        print("[SENZY HUB] Multi-Dropdown selected table:", table.concat(selectedTable, ", "))
        Library:Notify("Multi-Dropdown", "Selected " .. tostring(#selectedTable) .. " items", 2.5, "Info")
    end
})

local InputSection = ComponentsTab:AddSection("Text & Information Components")

InputSection:AddLabel("This is a simple informational Label component.")

InputSection:AddParagraph(
    "Information Header",
    "This is a Paragraph component used to explain features, instructions, or documentation in detail without requiring interactivity."
)

InputSection:AddTextbox({
    Name = "Custom Text Buffer",
    Placeholder = "Type something here...",
    Flag = "DemoTextboxFlag",
    Callback = function(textInput, enterPressed)
        print("[SENZY HUB] Textbox input:", textInput, "| Enter Pressed:", enterPressed)
        Library:Notify("Textbox Event", "Input text: " .. tostring(textInput), 3, "Info")
    end
})

InputSection:AddKeybind({
    Name = "UI Toggle Keybind",
    Default = Enum.KeyCode.LeftControl,
    Callback = function(key)
        print("[SENZY HUB] Keybind updated to:", key.Name)
        Library:Notify("Keybind System", "New Keybind: " .. tostring(key.Name), 2.5, "Info")
    end
})
