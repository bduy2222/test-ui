-- [[ THƯ VIỆN UI CHUYÊN NGHIỆP - FIXED DROPDOWN CORES ]]
-- Tác giả: .matjias

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Fluent = {
    Options = {},
    Themes = {
        Darker = {
            Background = Color3.fromRGB(15, 15, 18),
            Topbar = Color3.fromRGB(22, 22, 26),
            Sidebar = Color3.fromRGB(18, 18, 22),
            Accent = Color3.fromRGB(0, 140, 255),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(160, 160, 165),
            Element = Color3.fromRGB(25, 25, 30),
            ToggleOn = Color3.fromRGB(45, 210, 90),
            ToggleOff = Color3.fromRGB(60, 60, 65)
        }
    },
    ActiveNotifications = {},
    ConfigData = {}
}

-- Hệ thống quản lý File Config
local function writefile_safe(folder, file, data)
    if writefile and makefolder then
        pcall(function()
            makefolder(folder)
            writefile(folder .. "/" .. file .. ".json", HttpService:JSONEncode(data))
        end)
    end
end

local function readfile_safe(folder, file)
    if readfile then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(folder .. "/" .. file .. ".json"))
        end)
        if success then return result end
    end
    return nil
end

-- Hiệu ứng sóng Gradient chuyển động thời gian thực
local function ApplyGradientWave(uiObject)
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 140, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 50, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 255))
    })
    UIGradient.Parent = uiObject
    
    task.spawn(function()
        local offset = 0
        while RunService.RenderStepped:Wait() do
            offset = offset + 0.015
            if offset > 1 then offset = 0 end
            UIGradient.Offset = Vector2.new(offset, 0)
        end
    end)
end

-- Hệ thống Notification xếp chồng thông minh
function Fluent:Notify(cfg)
    local TitleText = cfg.Title or "Notification"
    local ContentText = cfg.Content or ""
    local SubContentText = cfg.SubContent or ""
    local Duration = cfg.Duration or nil
    
    local CoreGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local TargetGui = CoreGui:FindFirstChild("FluentUIFrame")
    if not TargetGui then return end
    
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Size = UDim2.new(0, 260, 0, 75)
    NotifyFrame.Position = UDim2.new(1, 300, 0.85, 0)
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = TargetGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = NotifyFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 50)
    Stroke.Thickness = 1
    Stroke.Parent = NotifyFrame
    
    local nTitle = Instance.new("TextLabel")
    nTitle.Size = UDim2.new(1, -20, 0, 25)
    nTitle.Position = UDim2.new(0, 12, 0, 4)
    nTitle.Font = Enum.Font.SourceSansBold
    nTitle.Text = TitleText
    nTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    nTitle.TextSize = 14
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.BackgroundTransparency = 1
    nTitle.Parent = NotifyFrame
    
    local nContent = Instance.new("TextLabel")
    nContent.Size = UDim2.new(1, -20, 0, 20)
    nContent.Position = UDim2.new(0, 12, 0, 26)
    nContent.Font = Enum.Font.SourceSans
    nContent.Text = ContentText
    nContent.TextColor3 = Color3.fromRGB(200, 200, 205)
    nContent.TextSize = 13
    nContent.TextXAlignment = Enum.TextXAlignment.Left
    nContent.BackgroundTransparency = 1
    nContent.Parent = NotifyFrame

    if SubContentText ~= "" then
        local nSub = Instance.new("TextLabel")
        nSub.Size = UDim2.new(1, -20, 0, 15)
        nSub.Position = UDim2.new(0, 12, 0, 48)
        nSub.Font = Enum.Font.SourceSansItalic
        nSub.Text = SubContentText
        nSub.TextColor3 = Color3.fromRGB(140, 140, 145)
        nSub.TextSize = 11
        nSub.TextXAlignment = Enum.TextXAlignment.Left
        nSub.BackgroundTransparency = 1
        nSub.Parent = NotifyFrame
    end

    for _, activeNotify in pairs(Fluent.ActiveNotifications) do
        if activeNotify and activeNotify.Parent then
            local currentPos = activeNotify.Position
            TweenService:Create(activeNotify, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset - 85)
            }):Play()
        end
    end
    
    table.insert(Fluent.ActiveNotifications, NotifyFrame)
    
    TweenService:Create(NotifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -280, 0.85, 0)
    }):Play()
    
    if Duration then
        task.delay(Duration, function()
            if NotifyFrame and NotifyFrame.Parent then
                TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(1, 300, NotifyFrame.Position.Y.Scale, NotifyFrame.Position.Y.Offset),
                    BackgroundTransparency = 1
                }):Play()
                task.wait(0.3)
                local idx = table.find(Fluent.ActiveNotifications, NotifyFrame)
                if idx then table.remove(Fluent.ActiveNotifications, idx) end
                NotifyFrame:Destroy()
            end
        end)
    end
end

-- Hàm khởi tạo Cửa sổ chính
function Fluent:CreateWindow(settings)
    local WindowName = settings.Title or "UI Library"
    local SubTitleText = settings.SubTitle or "by Studio"
    local TabWidth = settings.TabWidth or 160
    local WindowSize = settings.Size or UDim2.fromOffset(580, 460)
    local FolderName = settings.Config and settings.Config.Foulder or "FluentConfig"
    local FileName = settings.Config and settings.Config.File or "default"
    local MinimizeKey = settings.MinimizeKey or Enum.KeyCode.LeftControl
    
    Fluent.ConfigData = readfile_safe(FolderName, FileName) or {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FluentUIFrame"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = WindowSize
    MainFrame.Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2)
    MainFrame.BackgroundColor3 = Fluent.Themes.Darker.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Fluent.Themes.Darker.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = Topbar
    
    local WaveLine = Instance.new("Frame")
    WaveLine.Size = UDim2.new(1, 0, 0, 2)
    WaveLine.Position = UDim2.new(0, 0, 1, -2)
    WaveLine.BorderSizePixel = 0
    WaveLine.Parent = Topbar
    ApplyGradientWave(WaveLine)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(15, 0)
    TitleLabel.Text = WindowName .. " <font color='rgb(150,150,160)'>" .. SubTitleText .. "</font>"
    TitleLabel.TextColor3 = Fluent.Themes.Darker.Text
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 16
    TitleLabel.RichText = true
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Topbar
    
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, TabWidth, 1, -40)
    Sidebar.Position = UDim2.fromOffset(0, 40)
    Sidebar.BackgroundColor3 = Fluent.Themes.Darker.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    
    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 4)
    SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SideLayout.Parent = Sidebar
    
    local SidePadding = Instance.new("UIPadding")
    SidePadding.PaddingTop = UDim.new(0, 10)
    SidePadding.PaddingLeft = UDim.new(0, 8)
    SidePadding.PaddingRight = UDim.new(0, 8)
    SidePadding.Parent = Sidebar
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -TabWidth, 1, -40)
    Container.Position = UDim2.fromOffset(TabWidth, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == MinimizeKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    local WindowObj = { CurrentTab = nil, Tabs = {} }
    
    function WindowObj:AddTab(tabCfg)
        local TabTitle = tabCfg.Title or "Tab"
        local TabIcon = tabCfg.Icon or ""
        
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
        TabPage.Parent = Container
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 12)
        PagePadding.PaddingLeft = UDim.new(0, 12)
        PagePadding.PaddingRight = UDim.new(0, 12)
        PagePadding.Parent = TabPage
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 25)
        end)
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 34)
        TabButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = (TabIcon ~= "" and TabIcon .. "  " or "") .. TabTitle
        TabButton.TextColor3 = Fluent.Themes.Darker.SubText
        TabButton.Font = Enum.Font.SourceSansBold
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = Sidebar
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 5)
        ButtonCorner.Parent = TabButton
        
        local ButtonPadding = Instance.new("UIPadding")
        ButtonPadding.PaddingLeft = UDim.new(0, 12)
        ButtonPadding.Parent = TabButton
        
        local function Select()
            if WindowObj.CurrentTab then
                WindowObj.CurrentTab.Page.Visible = false
                WindowObj.CurrentTab.Button.TextColor3 = Fluent.Themes.Darker.SubText
                TweenService:Create(WindowObj.CurrentTab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
            WindowObj.CurrentTab = { Page = TabPage, Button = TabButton }
            TabPage.Visible = true
            TabButton.TextColor3 = Fluent.Themes.Darker.Text
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, BackgroundColor3 = Fluent.Themes.Darker.Accent}):Play()
        end
        
        TabButton.MouseButton1Click:Connect(Select)
        if WindowObj.CurrentTab == nil then Select() end
        
        local TabObj = {}
        
        -- [[ PARAGRAPH COMPONENT ]]
        function TabObj:AddParagraph(pCfg)
            local PTitle = pCfg.Title or "Paragraph"
            local PContent = pCfg.Content or ""
            
            local PFrame = Instance.new("Frame")
            PFrame.Size = UDim2.new(1, 0, 0, 55)
            PFrame.BackgroundColor3 = Fluent.Themes.Darker.Element
            PFrame.BorderSizePixel = 0
            PFrame.Parent = TabPage
            
            local PCorner = Instance.new("UICorner")
            PCorner.CornerRadius = UDim.new(0, 6)
            PCorner.Parent = PFrame
            
            local LabelTitle = Instance.new("TextLabel")
            LabelTitle.Size = UDim2.new(1, -20, 0, 22)
            LabelTitle.Position = UDim2.fromOffset(12, 4)
            LabelTitle.Text = PTitle
            LabelTitle.TextColor3 = Fluent.Themes.Darker.Text
            LabelTitle.Font = Enum.Font.SourceSansBold
            LabelTitle.TextSize = 14
            LabelTitle.TextXAlignment = Enum.TextXAlignment.Left
            LabelTitle.BackgroundTransparency = 1
            LabelTitle.Parent = PFrame
            
            local LabelDesc = Instance.new("TextLabel")
            LabelDesc.Size = UDim2.new(1, -20, 0, 25)
            LabelDesc.Position = UDim2.fromOffset(12, 24)
            LabelDesc.Text = PContent
            LabelDesc.TextColor3 = Fluent.Themes.Darker.SubText
            LabelDesc.Font = Enum.Font.SourceSans
            LabelDesc.TextSize = 13
            LabelDesc.TextXAlignment = Enum.TextXAlignment.Left
            LabelDesc.BackgroundTransparency = 1
            LabelDesc.Parent = PFrame
            
            local PInteract = {}
            function PInteract:SetDesc(newText)
                LabelTitle.Text = newText
            end
            return PInteract
        end
        
        -- [[ BUTTON COMPONENT ]]
        function TabObj:AddButton(bCfg)
            local BTitle = bCfg.Title or "Button"
            local BDesc = bCfg.Description or ""
            local Callback = bCfg.Callback or function() end
            
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, 0, 0, 42)
            BtnFrame.BackgroundColor3 = Fluent.Themes.Darker.Element
            BtnFrame.BorderSizePixel = 0
            BtnFrame.Parent = TabPage
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 6)
            BCorner.Parent = BtnFrame
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
            TextLabel.Position = UDim2.fromOffset(12, 0)
            TextLabel.Text = BTitle .. (BDesc ~= "" and " <font color='rgb(130,130,135)'>- " .. BDesc .. "</font>" or "")
            TextLabel.TextColor3 = Fluent.Themes.Darker.Text
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.TextSize = 14
            TextLabel.RichText = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.BackgroundTransparency = 1
            TextLabel.Parent = BtnFrame
            
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(0, 80, 0, 26)
            ClickBtn.Position = UDim2.new(1, -92, 0.5, -13)
            ClickBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            ClickBtn.Text = "Click"
            ClickBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
            ClickBtn.Font = Enum.Font.SourceSansBold
            ClickBtn.TextSize = 13
            ClickBtn.Parent = BtnFrame
            
            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(0, 4)
            CCorner.Parent = ClickBtn
            
            ClickBtn.MouseButton1Click:Connect(function()
                TweenService:Create(ClickBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 76, 0, 24), Position = UDim2.new(1, -90, 0.5, -12)}):Play()
                task.wait(0.08)
                TweenService:Create(ClickBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 80, 0, 26), Position = UDim2.new(1, -92, 0.5, -13)}):Play()
                Callback()
            end)
        end
        
        -- [[ TOGGLE COMPONENT (iOS ANIMATION) ]]
        function TabObj:AddToggle(id, tCfg)
            local TTitle = tCfg.Title or "Toggle"
            local Default = Fluent.ConfigData[id] ~= nil and Fluent.ConfigData[id] or (tCfg.Default or false)
            
            local TFrame = Instance.new("Frame")
            TFrame.Size = UDim2.new(1, 0, 0, 42)
            TFrame.BackgroundColor3 = Fluent.Themes.Darker.Element
            TFrame.Parent = TabPage
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 6)
            TCorner.Parent = TFrame
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -100, 1, 0)
            TextLabel.Position = UDim2.fromOffset(12, 0)
            TextLabel.Text = TTitle
            TextLabel.TextColor3 = Fluent.Themes.Darker.Text
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.TextSize = 14
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.BackgroundTransparency = 1
            TextLabel.Parent = TFrame
            
            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 42, 0, 22)
            Switch.Position = UDim2.new(1, -54, 0.5, -11)
            Switch.BackgroundColor3 = Default and Fluent.Themes.Darker.ToggleOn or Fluent.Themes.Darker.ToggleOff
            Switch.Text = ""
            Switch.Parent = TFrame
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch
            
            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = Default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = Switch
            
            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(1, 0)
            CCorner.Parent = Circle
            
            local ToggleObj = { Value = Default, ChangedCallback = function() end }
            Fluent.Options[id] = ToggleObj
            
            local function UpdateVisuals()
                if ToggleObj.Value then
                    TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Fluent.Themes.Darker.ToggleOn}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
                else
                    TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Fluent.Themes.Darker.ToggleOff}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
                end
                Fluent.ConfigData[id] = ToggleObj.Value
                writefile_safe(FolderName, FileName, Fluent.ConfigData)
            end
            
            Switch.MouseButton1Click:Connect(function()
                ToggleObj.Value = not ToggleObj.Value
                UpdateVisuals()
                ToggleObj.ChangedCallback(ToggleObj.Value)
            end)
            
            function ToggleObj:OnChanged(cb)
                ToggleObj.ChangedCallback = cb
                cb(ToggleObj.Value)
            end
            
            return ToggleObj
        end
        
        -- [[ SLIDER COMPONENT ]]
        function TabObj:AddSlider(id, sCfg)
            local STitle = sCfg.Title or "Slider"
            local Min = sCfg.Min or 0
            local Max = sCfg.Max or 100
            local Rounding = sCfg.Rounding or 1
            local Default = Fluent.ConfigData[id] ~= nil and Fluent.ConfigData[id] or (sCfg.Default or Min)
            
            local SFrame = Instance.new("Frame")
            SFrame.Size = UDim2.new(1, 0, 0, 50)
            SFrame.BackgroundColor3 = Fluent.Themes.Darker.Element
            SFrame.Parent = TabPage
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 6)
            SCorner.Parent = SFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 0, 20)
            Label.Position = UDim2.fromOffset(12, 4)
            Label.Text = STitle
            Label.TextColor3 = Fluent.Themes.Darker.Text
            Label.Font = Enum.Font.SourceSansBold
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SFrame
            
            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(0, 45, 0, 20)
            InputBox.Position = UDim2.new(1, -57, 0, 6)
            InputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            InputBox.Text = tostring(Default)
            InputBox.TextColor3 = Fluent.Themes.Darker.Text
            InputBox.Font = Enum.Font.SourceSansBold
            InputBox.TextSize = 13
            InputBox.Parent = SFrame
            
            local IBCorner = Instance.new("UICorner")
            IBCorner.CornerRadius = UDim.new(0, 4)
            IBCorner.Parent = InputBox
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -24, 0, 4)
            Track.Position = UDim2.new(0, 12, 1, -12)
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            Track.BorderSizePixel = 0
            Track.Parent = SFrame
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            Fill.BackgroundColor3 = Fluent.Themes.Darker.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            
            local SliderObj = { Value = Default, ChangedCallback = function() end }
            Fluent.Options[id] = SliderObj
            
            local function UpdateSliderPosition(percent)
                percent = math.clamp(percent, 0, 1)
                local exactValue = Min + (Max - Min) * percent
                local mult = 10 ^ Rounding
                local roundedValue = math.floor(exactValue * mult + 0.5) / mult
                
                SliderObj.Value = roundedValue
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                InputBox.Text = tostring(roundedValue)
                
                Fluent.ConfigData[id] = roundedValue
                writefile_safe(FolderName, FileName, Fluent.ConfigData)
                SliderObj.ChangedCallback(roundedValue)
            end
            
            local IsDragging = false
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    IsDragging = true
                    local mousePos = input.Position.X
                    local percent = (mousePos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
                    UpdateSliderPosition(percent)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local mousePos = input.Position.X
                    local percent = (mousePos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
                    UpdateSliderPosition(percent)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    IsDragging = false
                end
            end)
            
            InputBox.FocusLost:Connect(function()
                local num = tonumber(InputBox.Text)
                if num then
                    num = math.clamp(num, Min, Max)
                    local percent = (num - Min) / (Max - Min)
                    UpdateSliderPosition(percent)
                else
                    InputBox.Text = tostring(SliderObj.Value)
                end
            end)
            
            function SliderObj:OnChanged(cb)
                SliderObj.ChangedCallback = cb
                cb(SliderObj.Value)
            end
            
            return SliderObj
        end
        
        -- [[ DROPDOWN COMPONENT (FIXED CRASH) ]]
        function TabObj:AddDropdown(id, dCfg)
            local DTitle = dCfg.Title or "Dropdown"
            local Values = dCfg.Values or {}
            local Multi = dCfg.Multi or false
            
            local Default = Fluent.ConfigData[id]
            if Default == nil then
                if Multi then
                    Default = {}
                    if typeof(dCfg.Default) == "table" then
                        for _, v in pairs(dCfg.Default) do Default[v] = true end
                    end
                else
                    Default = dCfg.Default or 1
                end
            end
            
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 42)
            DropFrame.BackgroundColor3 = Fluent.Themes.Darker.Element
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage
            
            local DCorner = Instance.new("UICorner")
            DCorner.CornerRadius = UDim.new(0, 6)
            DCorner.Parent = DropFrame
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(0.5, 0, 0, 42)
            TextLabel.Position = UDim2.fromOffset(12, 0)
            TextLabel.Text = DTitle
            TextLabel.TextColor3 = Fluent.Themes.Darker.Text
            TextLabel.Font = Enum.Font.SourceSansBold
            TextLabel.TextSize = 14
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.BackgroundTransparency = 1
            TextLabel.Parent = DropFrame
            
            local SelectionDisplay = Instance.new("TextButton")
            SelectionDisplay.Size = UDim2.new(0, 150, 0, 26)
            SelectionDisplay.Position = UDim2.new(1, -162, 0, 8)
            SelectionDisplay.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            SelectionDisplay.Text = "Chọn..."
            SelectionDisplay.TextColor3 = Fluent.Themes.Darker.SubText
            SelectionDisplay.Font = Enum.Font.SourceSans
            SelectionDisplay.TextSize = 13
            SelectionDisplay.Parent = DropFrame
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 4)
            SCorner.Parent = SelectionDisplay
            
            local OptionContainer = Instance.new("Frame")
            OptionContainer.Size = UDim2.new(1, -24, 0, #Values * 28)
            OptionContainer.Position = UDim2.fromOffset(12, 45)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.Parent = DropFrame
            
            local DropLayout = Instance.new("UIListLayout")
            DropLayout.Padding = UDim.new(0, 2)
            DropLayout.Parent = OptionContainer
            
            local DropdownObj = { Value = Default, ChangedCallback = function() end }
            Fluent.Options[id] = DropdownObj
            
            local Open = false
            
            local function RefreshDisplay()
                if not Multi then
                    local selectedText = Values[DropdownObj.Value] or tostring(DropdownObj.Value)
                    SelectionDisplay.Text = selectedText
                else
                    local selectedList = {}
                    for k, v in pairs(DropdownObj.Value) do
                        if v == true then table.insert(selectedList, k) end
                    end
                    if #selectedList == 0 then
                        SelectionDisplay.Text = "Trống"
                    else
                        SelectionDisplay.Text = table.concat(selectedList, ", ")
                    end
                end
                Fluent.ConfigData[id] = DropdownObj.Value
                writefile_safe(FolderName, FileName, Fluent.ConfigData)
            end
            
            for index, valName in pairs(Values) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 26)
                OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                OptBtn.Text = "  " .. tostring(valName)
                OptBtn.TextColor3 = Fluent.Themes.Darker.SubText
                OptBtn.Font = Enum.Font.SourceSans
                OptBtn.TextSize = 13
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.Parent = OptionContainer
                
                local OCorner = Instance.new("UICorner")
                OCorner.CornerRadius = UDim.new(0, 4)
                OCorner.Parent = OptBtn
                
                if Multi and typeof(DropdownObj.Value) == "table" and DropdownObj.Value[valName] then
                    OptBtn.TextColor3 = Fluent.Themes.Darker.Accent
                elseif not Multi and DropdownObj.Value == index then
                    OptBtn.TextColor3 = Fluent.Themes.Darker.Accent
                end
                
                OptBtn.MouseButton1Click:Connect(function()
                    if not Multi then
                        DropdownObj.Value = index
                        for _, btn in pairs(OptionContainer:GetChildren()) do
                            if btn:IsA("TextButton") then btn.TextColor3 = Fluent.Themes.Darker.SubText end
                        end
                        OptBtn.TextColor3 = Fluent.Themes.Darker.Accent
                        Open = false
                        
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 42)}):Play()
                        RefreshDisplay()
                        DropdownObj.ChangedCallback(DropdownObj.Value)
                    else
                        if typeof(DropdownObj.Value) ~= "table" then DropdownObj.Value = {} end
                        DropdownObj.Value[valName] = not DropdownObj.Value[valName]
                        if DropdownObj.Value[valName] then
                            OptBtn.TextColor3 = Fluent.Themes.Darker.Accent
                        else
                            OptBtn.TextColor3 = Fluent.Themes.Darker.SubText
                        end
                        RefreshDisplay()
                        DropdownObj.ChangedCallback(DropdownObj.Value)
                    end
                end)
            end
            
            -- Ép TabPage phải cập nhật Layout khi Dropdown đang thực hiện hiệu ứng đóng/mở rộng
            local function ToggleDropdown()
                Open = not Open
                local targetSize = Open and UDim2.new(1, 0, 0, 50 + (#Values * 28) + 10) or UDim2.new(1, 0, 0, 42)
                
                local tween = TweenService:Create(DropFrame, TweenInfo.new(0.25, Enum.EasingStyle.QuartOut), {Size = targetSize})
                tween:Play()
                
                local connection
                connection = RunService.Heartbeat:Connect(function()
                    if tween.PlaybackState == Enum.TweenStatus.Playing then
                        -- Buộc UIListLayout cha sắp xếp lại danh sách ngay lập tức
                        PageLayout.Enabled = false
                        PageLayout.Enabled = true
                    else
                        connection:Disconnect()
                    end
                end)
            end
            
            SelectionDisplay.MouseButton1Click:Connect(ToggleDropdown)
            RefreshDisplay()
            
            function DropdownObj:OnChanged(cb)
                DropdownObj.ChangedCallback = cb
                cb(DropdownObj.Value)
            end
            
            return DropdownObj
        end
        
        WindowObj.Tabs[TabTitle] = TabObj
        return TabObj
    end
    
    return WindowObj
end

