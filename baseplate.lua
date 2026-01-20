-- Find the main baseplate
local baseplate = workspace:FindFirstChild("Baseplate")
if not baseplate then
    warn("Baseplate not found!")
    return
end

-- Delete all other baseplates first
for _, obj in ipairs(workspace:GetChildren()) do
    if obj:IsA("BasePart") and obj.Name == "Baseplate" and obj ~= baseplate then
        obj:Destroy()
    end
end

-- Make sure the main baseplate is anchored
baseplate.Anchored = true

-- Resize and style the main baseplate
baseplate.Size = Vector3.new(1000, 16, 1000)
baseplate.Material = Enum.Material.Snow
baseplate.Color = Color3.fromRGB(255, 255, 255) -- white

-- Get the center position of the main baseplate
local centerPos = baseplate.Position
local size = baseplate.Size

-- Function to duplicate baseplates around the main one
local function duplicateAroundMain(base)
    local offsets = {
        Vector3.new(-size.X, 0, -size.Z),
        Vector3.new(0, 0, -size.Z),
        Vector3.new(size.X, 0, -size.Z),
        Vector3.new(-size.X, 0, 0),
        Vector3.new(size.X, 0, 0),
        Vector3.new(-size.X, 0, size.Z),
        Vector3.new(0, 0, size.Z),
        Vector3.new(size.X, 0, size.Z),
    }

    for _, offset in ipairs(offsets) do
        local clone = base:Clone()
        clone.Parent = workspace
        clone.Anchored = true
        clone.Material = Enum.Material.Snow
        clone.Color = Color3.fromRGB(255, 255, 255) -- white
        clone.Position = centerPos + offset
    end
end

-- Duplicate 8 baseplates around the main one
duplicateAroundMain(baseplate)

-- Delete all objects named "platform" inside workspace.Map.extra_room
local map = workspace:FindFirstChild("map")
if map then
    local extraRoom = map:FindFirstChild("extra_room")
    if extraRoom then
        for _, obj in ipairs(extraRoom:GetChildren()) do
            if obj.Name == "platform" then
                obj:Destroy()
            end
        end
    end
end
