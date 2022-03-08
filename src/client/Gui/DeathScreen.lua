local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween

local motivationalMessages = {
    "Don't let your dreams be dreams",
    "Good job, you need it",
    "h"
}

local function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

local friendPages = Players:GetFriendsAsync(Players.LocalPlayer.UserId)

local usernames = {}
for item, pageNo in iterPageItems(friendPages) do
	table.insert(usernames, item.Username)
end

local function DeathScreen(props)
    local visible = Fusion.Value(false)
    local text = Fusion.Value("")
    local gui = New "ScreenGui" {
        IgnoreGuiInset = true,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        [Children] = {
            New "Frame" {
                ZIndex = 0,
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Visible = Computed(function()
                    return visible:get()
                end),
                [Children] = {
                    New "TextLabel" {
                        AnchorPoint = Vector2.new(1, 1),
                        Position = UDim2.fromScale(1, 1),
                        Size = UDim2.fromScale(0.4, 0.1),
                        Text = Computed(function()
                            return text:get()
                        end),
                        Font = Enum.Font.Gotham,
                        TextSize = 20,
                        TextColor3 = Color3.fromRGB(0, 0, 0)
                    }
                }
            }
        }
    }

    props.EventOpen:Connect(function()
        local randomMotivationalMessage = motivationalMessages[math.random(#motivationalMessages)]
        local randomFriendUsername = #usernames == 0 and "QuantixDev" or usernames[math.random(#usernames)]
        print(randomMotivationalMessage)

        local concatString = '"'.. randomMotivationalMessage .. '" -' .. randomFriendUsername

        text:set(concatString)
        visible:set(true)
    end)

    props.EventClose:Connect(function()
        visible:set(false)
    end)

    return gui
end

return DeathScreen