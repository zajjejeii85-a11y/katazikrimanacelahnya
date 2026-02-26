-- [[ ZONHUB - AUTO CLEANER MODULE (INJECTED) ]] --
local TargetPage = ...
if not TargetPage then warn("Module harus di-load dari ZonIndex!") return end

getgenv().ScriptVersion = "AutoCleaner v1.0" 

-- ========================================== --
-- [[ SETTING DEFAULT ]]
getgenv().CleanBreakDelay = 0.05 
getgenv().CleanStepDelay = 0.1   
getgenv().GridSize = 4.5 
-- ========================================== --

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser") 

local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

LP.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

-- [[ VARIABEL GLOBAL ]] --
getgenv().EnableCleaner = false
getgenv().CleanStartX = 0
getgenv().CleanEndX = 100
getgenv().CleanYPos = 37 -- Y Level block yang akan dihancurkan
getgenv().CleanHitCount = 10 -- 6 untuk Dirt, 10 untuk Batu

-- [[ FUNGSI BERJALAN ]] --
local function WalkToGrid(tX, tY)
    local HitboxFolder = workspace:FindFirstChild("Hitbox")
    local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
    if not MyHitbox then return end

    local startZ = MyHitbox.Position.Z
    local currentX = math.floor(MyHitbox.Position.X / getgenv().GridSize + 0.5)
    local currentY = math.floor(MyHitbox.Position.Y / getgenv().GridSize + 0.5)

    while (currentX ~= tX or currentY ~= tY) do
        if not getgenv().EnableCleaner then break end
        if currentX ~= tX then currentX = currentX + (tX > currentX and 1 or -1)
        elseif currentY ~= tY then currentY = currentY + (tY > currentY and 1 or -1) end
        
        local newWorldPos = Vector3.new(currentX * getgenv().GridSize, currentY * getgenv().GridSize, startZ)
        MyHitbox.CFrame = CFrame.new(newWorldPos)
        if PlayerMovement then pcall(function() PlayerMovement.Position = newWorldPos end) end
        task.wait(getgenv().CleanStepDelay)
    end
end

-- [[ UI SETUP ]] --
local Theme = { Item = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255), Purple = Color3.fromRGB(140, 80, 255) }

local function CreateToggle(Parent, Text, Var) 
    local Btn = Instance.new("TextButton", Parent); Btn.BackgroundColor3 = Theme.Item; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = ""; local C = Instance.new("UICorner", Btn); C.CornerRadius = UDim.new(0, 6)
    local T = Instance.new("TextLabel", Btn); T.Text = Text; T.TextColor3 = Theme.Text; T.Font = Enum.Font.GothamSemibold; T.TextSize = 12; T.Size = UDim2.new(1, -40, 1, 0); T.Position = UDim2.new(0, 10, 0, 0); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left
    local IndBg = Instance.new("Frame", Btn); IndBg.Size = UDim2.new(0, 36, 0, 18); IndBg.Position = UDim2.new(1, -45, 0.5, -9); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30); local IC = Instance.new("UICorner", IndBg); IC.CornerRadius = UDim.new(1,0)
    local Dot = Instance.new("Frame", IndBg); Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); local DC = Instance.new("UICorner", Dot); DC.CornerRadius = UDim.new(1,0)
    Btn.MouseButton1Click:Connect(function() 
        getgenv()[Var] = not getgenv()[Var]
        if getgenv()[Var] then 
            Dot:TweenPosition(UDim2.new(1, -16, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.new(1,1,1); IndBg.BackgroundColor3 = Theme.Purple 
        else 
            Dot:TweenPosition(UDim2.new(0, 2, 0.5, -7), "Out", "Quad", 0.2, true); Dot.BackgroundColor3 = Color3.fromRGB(100,100,100); IndBg.BackgroundColor3 = Color3.fromRGB(30,30,30) 
        end 
    end) 
end

local function CreateTextBox(Parent, Text, Default, Var) 
    local Frame = Instance.new("Frame", Parent); Frame.BackgroundColor3 = Theme.Item; Frame.Size = UDim2.new(1, -10, 0, 35); local C = Instance.new("UICorner", Frame); C.CornerRadius = UDim.new(0, 6)
    local Label = Instance.new("TextLabel", Frame); Label.Text = Text; Label.TextColor3 = Theme.Text; Label.BackgroundTransparency = 1; Label.Size = UDim2.new(0.5, 0, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
    local InputBox = Instance.new("TextBox", Frame); InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); InputBox.Position = UDim2.new(0.6, 0, 0.15, 0); InputBox.Size = UDim2.new(0.35, 0, 0.7, 0); InputBox.Font = Enum.Font.GothamSemibold; InputBox.TextSize = 12; InputBox.TextColor3 = Theme.Text; InputBox.Text = tostring(Default); local IC = Instance.new("UICorner", InputBox); IC.CornerRadius = UDim.new(0, 4)
    InputBox.FocusLost:Connect(function() local val = tonumber(InputBox.Text); if val then getgenv()[Var] = val else InputBox.Text = tostring(getgenv()[Var]) end end)
    return InputBox 
end

local function CreateButton(Parent, Text, Callback) 
    local Btn = Instance.new("TextButton", Parent); Btn.BackgroundColor3 = Theme.Purple; Btn.Size = UDim2.new(1, -10, 0, 35); Btn.Text = Text; Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; local C = Instance.new("UICorner", Btn); C.CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(Callback) 
end

-- [[ INJECT MENU KE TARGET PAGE ]] --
CreateButton(TargetPage, "📍 Set Posisi Saat Ini (Start X & Y)", function() 
    local H = workspace.Hitbox:FindFirstChild(LP.Name) 
    if H then 
        getgenv().CleanStartX = math.floor(H.Position.X/getgenv().GridSize+0.5)
        -- Set YPos ke bawah kaki (Y - 1)
        getgenv().CleanYPos = math.floor(H.Position.Y/getgenv().GridSize+0.5) - 1
    end 
end)

CreateTextBox(TargetPage, "Mulai Dari X (Kiri)", getgenv().CleanStartX, "CleanStartX")
CreateTextBox(TargetPage, "Berakhir Di X (Kanan)", getgenv().CleanEndX, "CleanEndX")
CreateTextBox(TargetPage, "Target Y (Posisi Block)", getgenv().CleanYPos, "CleanYPos")
CreateTextBox(TargetPage, "Jumlah Pukulan (6=Dirt, 10=Batu)", getgenv().CleanHitCount, "CleanHitCount")
CreateToggle(TargetPage, "▶ MULAI AUTO CLEANER", "EnableCleaner")

-- [[ LOGIKA AUTO CLEANER ]] --
local RemoteBreak = RS:WaitForChild("Remotes"):WaitForChild("PlayerFist")

task.spawn(function()
    while true do
        if getgenv().EnableCleaner then
            local targetY = getgenv().CleanYPos
            local playerY = targetY + 1 -- Posisi karakter melayang/tegak di atas block target
            
            -- Menentukan arah (Apakah bergerak maju ke kanan atau mundur ke kiri)
            local step = (getgenv().CleanStartX <= getgenv().CleanEndX) and 1 or -1
            
            -- Pindah ke posisi awal terlebih dahulu
            WalkToGrid(getgenv().CleanStartX, playerY)
            task.wait(0.5)

            for x = getgenv().CleanStartX, getgenv().CleanEndX, step do
                if not getgenv().EnableCleaner then break end
                
                -- Bergerak ke atas block yang ingin dihancurkan
                WalkToGrid(x, playerY)
                task.wait(0.1) 
                
                -- Menghancurkan block di bawah kaki
                local TargetGrid = Vector2.new(x, targetY)
                for hit = 1, getgenv().CleanHitCount do
                    if not getgenv().EnableCleaner then break end
                    RemoteBreak:FireServer(TargetGrid)
                    task.wait(getgenv().CleanBreakDelay)
                end
                
                -- Jeda sebentar memastikan tersapu bersih sebelum maju
                task.wait(0.1) 
            end
            
            -- Otomatis mati saat mencapai titik akhir
            getgenv().EnableCleaner = false
        end
        task.wait(1)
    end
end)
