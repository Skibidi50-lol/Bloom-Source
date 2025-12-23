local WalkOnWaterModule = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local WalkOnWaterEnabled = false
local waterPlane = nil
local WALK_SIZE = Vector3.new(1000,112,1000)

local function findWaterPlane()
    return workspace.Map:FindFirstChild("WaterBase-Plane")
end

local function applyWater()
    if not WalkOnWaterEnabled then return end
    
    waterPlane = findWaterPlane()
    if not waterPlane then
        warn("[⚠️] Couldn't find WaterBase-Plane.")
        return false
    end
    
    waterPlane.Size = WALK_SIZE
    return true
end

local function removeWater()
    waterPlane = findWaterPlane()
    if waterPlane then
        -- Khôi phục kích thước mặc định (hoặc bạn có thể set lại kích thước gốc nếu biết)
        waterPlane.Size = Vector3.new(1000, 1, 1000) -- Kích thước mặc định thông thường
    end
end

-- API cho WindUI
function WalkOnWaterModule:SetState(state)
    WalkOnWaterEnabled = state

    if state then
        local success = applyWater()
        if success then
            print("[✅] Đã bật đi trên nước")
        else
            print("[❌] Không thể bật đi trên nước - Không tìm thấy WaterBase-Plane")
        end
    else
        removeWater()
        print("[✅] Đã tắt đi trên nước")
    end
end

function WalkOnWaterModule:IsEnabled()
    return WalkOnWaterEnabled
end

player.CharacterAdded:Connect(function()
    if WalkOnWaterEnabled then
        task.wait(0.1)
        applyWater()
    end
end)

-- Tự động tìm lại water plane khi map thay đổi
workspace.DescendantAdded:Connect(function(descendant)
    if WalkOnWaterEnabled and descendant.Name == "WaterBase-Plane" then
        task.wait(0.5)
        applyWater()
    end
end)

return WalkOnWaterModule
