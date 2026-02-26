-- [[ ZONHUB - AUTO CLEANER MODULE V3 (ANTI-STUCK & DEEP SWEEP) ]] --
local TargetPage = ...
if not TargetPage then warn("Module harus di-load dari ZonIndex!") return end

getgenv().ScriptVersion = "AutoCleaner v3.0-AntiStuck" 

-- ========================================== --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser") 

local PlayerMovement
pcall(function() PlayerMovement = require(LP.PlayerScripts:WaitForChild("PlayerMovement")) end)

LP.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

-- [[ SETTING AUTO CLEANER ]] --
getgenv().EnableCleaner = false
getgenv().CleanHitCount = 15     -- 15 Pukulan jaminan hancur sampai ke background
getgenv().HoverHeight = 1.2      -- Tinggi melayang absolut
getgenv().BreakDelay = 0.05      -- Jeda antar pukulan yang aman untuk server
getgenv().GridSize = 4.5 
-- ========================================== --

-- [[ UI SETUP ]] --
local Theme = { Item = Color3.fromRGB(45, 45, 45), Text = Color3.fromRGB(255, 255, 255), Purple = Color3.fromRGB(140, 80, 255), Green = Color3.fromRGB(80, 255, 140) }

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

-- [[ INJECT MENU ]] --
local InfoLabel = Instance.new("TextLabel", TargetPage)
InfoLabel.Size = UDim2.new(1, 0, 0, 35)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "ℹ️ Berdirilah di atas block pertama, lalu nyalakan."
InfoLabel.TextColor3 = Theme.Green
InfoLabel.Font = Enum.Font.GothamSemibold
InfoLabel.TextSize = 11

CreateTextBox(TargetPage, "Jumlah Hit (Default 15)", getgenv().CleanHitCount, "CleanHitCount")
CreateToggle(TargetPage, "🚀 START AUTO GLIDE (Anti-Stuck)", "EnableCleaner")

-- [[ LOGIKA AUTO CLEANER & SWEEPER ]] --
local RemoteBreak = RS:WaitForChild("Remotes"):WaitForChild("PlayerFist")

task.spawn(function()
    while true do
        if getgenv().EnableCleaner then
            local HitboxFolder = workspace:FindFirstChild("Hitbox")
            local MyHitbox = HitboxFolder and HitboxFolder:FindFirstChild(LP.Name)
            
            if MyHitbox then
                -- KUNCI FISIKA SECARA ABSOLUT: Karakter tidak akan jatuh sama sekali
                MyHitbox.Anchored = true
                MyHitbox.CanCollide = false
                
                local startX = math.floor(MyHitbox.Position.X / getgenv().GridSize + 0.5)
                local targetY = math.floor(MyHitbox.Position.Y / getgenv().GridSize + 0.5) - 1 
                local targetZ = MyHitbox.Position.Z
                
                local worldLimitLeft = -200 

                for x = startX, worldLimitLeft, -1 do
                    if not getgenv().EnableCleaner then break end
                    
                    -- 1. GLIDE CEPAT & MULUS KE TARGET X
                    local targetPos = Vector3.new(x * getgenv().GridSize, (targetY + getgenv().HoverHeight) * getgenv().GridSize, targetZ)
                    local distance = (MyHitbox.Position - targetPos).Magnitude
                    
                    if distance > 0.1 then
                        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                        local tween = TS:Create(MyHitbox, tweenInfo, {CFrame = CFrame.new(targetPos)})
                        
                        tween:Play()
                        
                        -- Update Visual Kamera
                        if PlayerMovement then
                            task.spawn(function()
                                while tween.PlaybackState == Enum.PlaybackState.Playing and getgenv().EnableCleaner do
                                    pcall(function() PlayerMovement.Position = MyHitbox.Position end)
                                    task.wait(0.03)
                                end
                            end)
                        end
                        tween.Completed:Wait()
                    end
                    
                    -- 2. DIAM MENGAMBANG & HANCURKAN BLOCK SAMPAI BERSIH
                    local TargetGrid = Vector2.new(x, targetY)
                    for hit = 1, getgenv().CleanHitCount do
                        if not getgenv().EnableCleaner then break end
                        RemoteBreak:FireServer(TargetGrid)
                        task.wait(getgenv().BreakDelay) 
                    end
                    
                    -- Jeda kecil memastikan konfirmasi server
                    task.wait(0.1) 
                end
                
                -- KEMBALIKAN FISIKA JIKA SELESAI / DIMATIKAN
                getgenv().EnableCleaner = false
                if MyHitbox then
                    MyHitbox.Anchored = false
                    MyHitbox.CanCollide = true
                end
            end
        end
        task.wait(0.5)
    end
end)
