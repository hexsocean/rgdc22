local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Modules = Client:WaitForChild("Modules")

local Spider = require(Modules:WaitForChild("Spider"))

local Door = require(script.Parent.Door)
local LaserColourUtils = require(script.Parent.LaserColourUtils)
local Fusion = require(ReplicatedStorage:WaitForChild("Common").fusion)

local Dialogue = require(script.Parent.Parent.Parent.Gui.Dialogue)
local BossTransition = require(script.Parent.Parent.Parent.Gui.BossTransition)
local Boss = require(script.Parent.Parent.Boss)

local Data = {
	Folder = Levels:WaitForChild("Level8"),
}

local swishTween = TweenInfo.new(1)

local function OnLoaded(self, map)
	shared.physenabled:set(false)
	task.wait(2)
	Dialogue.enabled:set(true)
	Dialogue.event:Fire("Space Invader", {
		"Well, well, well, behold who is't t is.",
		"Thee bethink of yourself as a gallant reveng'r f'r those the 8-bit hast did cause fallen.",
		"Thou art but a measly cosmonaut.",
		"Unw'rthy of the attention of the 8-bit."
	})
	local character = Player.Character
	character.HumanoidRootPart.Anchored = true
	TweenService:Create(workspace.CurrentCamera, swishTween, {
		CFrame = CFrame.lookAt(character:WaitForChild("Head").Position, map:WaitForChild("invader").Position)
	}):Play()
	Dialogue.completed:Wait()
	task.spawn(function()
		BossTransition:set(true)
		task.wait(1)
		BossTransition:set(false)
	end)
	task.wait(1)
	Boss.Begin()
end

local function OnUnloaded(self, map)
end

local function CanProceed()
	return true
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
	OnUnloaded = OnUnloaded,
	CanProceed = CanProceed,
}
