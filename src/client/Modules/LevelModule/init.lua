local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local LightOn = ReplicatedStorage:WaitForChild("LightOn")

local ZonePlus = require(Common:WaitForChild("ZonePlus"))
local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Gui = Client:WaitForChild("Gui")

local LevelTransition = require(Gui:WaitForChild("LevelTransition"))

local LevelModules = {
	["Level 1"] = require(script:WaitForChild("Level1")),
	["Level 2"] = require(script:WaitForChild("Level2")),
}

local LevelOrder = {
	"Level 1",
	"Level 2"
}

local LevelModule = {}

function LevelModule:Start()
	self.LevelledUp = Signal.new()
	self.Gui = LevelTransition({
		LevelledUp = self.LevelledUp,
	})
	self.CurrentLevelName = LevelOrder[1]

	local function CharacterAdded(character)
		local currentLevelFolder = self.CurrentLevelFolder
		if currentLevelFolder then
			self:UnloadLevel(currentLevelFolder)
		end

		if not character.PrimaryPart then
			character:GetPropertyChangedSignal("PrimaryPart"):Wait()
		end
		self:LoadLevel(self.CurrentLevelName)
	end

	Player.CharacterAdded:Connect(CharacterAdded)

	local character = Player.Character
	if character then
		CharacterAdded(character)
	end
end

function LevelModule:LoadLevel(levelName)
	local levelModule = LevelModules[levelName]
	if not levelModule then
		return
	end
	self.LevelModule = levelModule

	local clonedLevelFolder = levelModule.Data.Folder:Clone()
	local lightsFolder = clonedLevelFolder:FindFirstChild("lights")

	if lightsFolder then
		local lightsFolderChildren = lightsFolder:GetChildren()
		for _, set in ipairs(lightsFolderChildren) do
			for _, light in ipairs(set:GetDescendants()) do
				if not light:IsA("Light") then
					continue
				end
				light.Enabled = false
			end
		end

		table.sort(lightsFolderChildren, function(a, b)
			return a:GetFullName() < b:GetFullName()
		end)

		task.spawn(function()
			for _, set in ipairs(lightsFolderChildren) do
				task.wait(1)

				local clonedLightOn = LightOn:Clone() :: Sound
				clonedLightOn:Play()
				task.spawn(function()
					clonedLightOn.Ended:Wait()
					clonedLightOn:Destroy()
				end)
				clonedLightOn.Parent = set

				for _, light in ipairs(set:GetDescendants()) do
					if not light:IsA("Light") then
						continue
					end

					light.Enabled = true
				end
			end
		end)
	end

	clonedLevelFolder.Parent = workspace
	self.CurrentLevelFolder = clonedLevelFolder

	Player.Character:SetPrimaryPartCFrame(clonedLevelFolder.spawn.CFrame)

	self.LevelledUp:Fire(levelName)

	levelModule:OnLoaded(clonedLevelFolder)

	local exit = clonedLevelFolder:FindFirstChild("exit")
	if exit then
		local zone = ZonePlus.new(exit)
		local hrp = Player.Character:WaitForChild("HumanoidRootPart")
		zone:onItemEnter(hrp, function()
			local canProceed = levelModule.CanProceed()
			if not canProceed then
				return
			end

			self:UnloadLevel(clonedLevelFolder)
			local currentIndex = table.find(LevelOrder, levelName)
			local nextIndex = currentIndex + 1
			self:LoadLevel(LevelOrder[nextIndex])
		end)
	end
end

function LevelModule:UnloadLevel(map)
	self.LevelModule:OnUnloaded(map)

	map:Destroy()
end

return LevelModule
