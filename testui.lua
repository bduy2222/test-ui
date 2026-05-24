-- [[ FYNIX HUB PREMIUM UI LIBRARY ]]
-- CHÚ Ý: Chạy mượt mà trên tất cả Executor hỗ trợ writefile/readfile/json

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local Players = game:GetService("Players")

-- 1. XÓA UI CŨ TRƯỚC KHI CHẠY (Chống trùng lặp bộ nhớ)
if game:GetService("CoreGui"):FindFirstChild("FynixUIFrame") then
    game:GetService("CoreGui").FynixUIFrame:Destroy()
elseif Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("FynixUIFrame") then
    Players.LocalPlayer.PlayerGui.FynixUIFrame:Destroy()
end

local Fynix = {
    ActiveNotifs = {},
    Options = {},
    Themes = {
        Darker = {
            Bg = Color3.fromRGB(11, 11, 14),
            Top = Color3.fromRGB(16, 16, 22),
            Comp = Color3.fromRGB(20, 20, 26),
            Txt = Color3.fromRGB(245, 245, 250),
            Sub = Color3.fromRGB(140, 140, 150),
            G1 = Color3.fromRGB(0, 215, 255), -- Cyan Wave
            G2 = Color3.fromRGB(160, 40, 255)  -- Purple Wave
        }
    },
    CfgFolder = "Fynix_Configs",
    CfgFile = "default.json"
}
_G.Options = Fynix.Options

-- [[ AUTO SAVE & LOAD CONFIG LOGIC ]]
local function SaveConfig()
    if not Fynix.CfgFolder or not Fynix.CfgFile then return end
    local data = {}
    for k, v in pairs(Fynix.Options) do
        data[k] = v.Value
    end
    pcall(function()
        if not isfolder(Fynix.CfgFolder) then makefolder(Fynix.CfgFolder) end
        writefile(Fynix.CfgFolder .. "/" .. Fynix.CfgFile, HS:JSONEncode(data))
    end)
end

local function LoadConfig()
    pcall(function()
        local path = Fynix.CfgFolder .. "/" .. Fynix.CfgFile
        if isfile(path) then
            local data = HS:JSONDecode(readfile(path))
            for k, v in pairs(data) do
                if Fynix.Options[k] then
                    Fynix.Options[k]:SetValue(v)
                end
            end
        end
    end)
end

-- [[ UTILS: TẠO GRADIENT WAVE ]]
local function ApplyWave(parent)
    local UIGrad = Instance.new("UIGradient")
    UIGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Fynix.Themes.Darker.G1),
        ColorSequenceKeypoint.new(1, Fynix.Themes.Darker.G2)
    })
    UIGrad.Parent = parent
    
    -- Hiệu ứng sóng cuộn động
    coroutine.wrap(function()
        while parent and parent.Parent do
            TS:Create(UIGrad, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            task.wait(3)
            UIGrad.Rotation = 0
        end
    end)()
    return UIGrad
end

-- [[ HỆ THỐNG NOTIFICATION CHUẨN XẾP CHỒNG ]]
function Fynix:Notify(cfg)
    local Target = ScreenGui or Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("FynixUIFrame")
    if not Target then return end

    local Box = Instance.new("Frame")
    Box.Size = UDim2.fromOffset(280, 70)
    Box.Position = UDim2.new(1, 300, 0.85, 0)
    Box.BackgroundColor3 = Fynix.Themes.Darker.Comp
    Box.ClipsDescendants = true
    Box.Parent = Target

    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 8) bc.Parent = Box
    local bs = Instance.new("UIStroke") bs.Thickness = 1.2 bs.Parent = Box ApplyWave(bs)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -20, 0, 22) tl.Position = UDim2.fromOffset(12, 6)
    tl.Text = cfg.Title or "Notification" tl.TextColor3 = Fynix.Themes.Darker.Txt
    tl.Font = Enum.Font.SourceSansBold tl.TextSize = 14 tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.BackgroundTransparency = 1 tl.Parent = Box

    local cl = Instance.new("TextLabel")
    cl.Size = UDim2.new(1, -20, 0, 18) cl.Position = UDim2.fromOffset(12, 26)
    cl.Text = cfg.Content or "" cl.TextColor3 = Fynix.Themes.Darker.Sub
    cl.Font = Enum.Font.SourceSans tl.TextSize = 13 cl.TextXAlignment = Enum.TextXAlignment.Left
    cl.BackgroundTransparency = 1 cl.Parent = Box

    if cfg.SubContent then
        local sl = Instance.new("TextLabel")
        sl.Size = UDim2.new(1, -20, 0, 15) sl.Position = UDim2.fromOffset(12, 45)
        sl.Text = cfg.SubContent sl.TextColor3 = Fynix.Themes.Darker.Sub
        sl.Font = Enum.Font.SourceSansItalic tl.TextSize = 11 tl.TextXAlignment = Enum.TextXAlignment.Left
        sl.BackgroundTransparency = 1 sl.Parent = Box
    end

    local function Rearrange()
        for i, n in ipairs(Fynix.ActiveNotifs) do
            local offset = -(#Fynix.ActiveNotifs - i) * 80
            TS:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -295, 0.85, offset)}):Play()
        end
    end

    table.insert(Fynix.ActiveNotifs, Box)
    Rearrange()

    if cfg.Duration then
        task.delay(cfg.Duration, function()
            local idx = table.find(Fynix.ActiveNotifs, Box)
            if idx then table.remove(Fynix.ActiveNotifs, idx) end
            TS:Create(Box, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 300, 0.85, Box.Position.Y.Offset)}):Play()
            task.wait(0.25) Box:Destroy() Rearrange()
        end)
    end
end

-- [[ TẠO WINDOW CHÍNH ]]
function Fynix:CreateWindow(cfg)
    Fynix.CfgFolder = cfg.Config and cfg.Config.Foulder or Fynix.CfgFolder
    Fynix.CfgFile = cfg.Config and (cfg.Config.File .. ".json") or Fynix.CfgFile

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FynixUIFrame"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

    local OSize = cfg.Size or UDim2.fromOffset(580, 460)
    local Main = Instance.new("Frame")
    Main.Size = OSize
    Main.Position = UDim2.new(0.5, -OSize.X.Offset/2, 0.5, -OSize.Y.Offset/2)
    Main.BackgroundColor3 = Fynix.Themes.Darker.Bg
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, 10) mc.Parent = Main
    local ms = Instance.new("UIStroke") ms.Thickness = 1.5 ms.Parent = Main ApplyWave(ms)

    -- Nút kích hoạt lại UI nhỏ hình vuông
    local ToggleBindBtn = Instance.new("TextButton")
    ToggleBindBtn.Size = UDim2.fromOffset(45, 45)
    ToggleBindBtn.Position = UDim2.new(0, 15, 0.5, -22)
    ToggleBindBtn.BackgroundColor3 = Fynix.Themes.Darker.Comp
    ToggleBindBtn.Text = "🔥"
    ToggleBindBtn.TextSize = 20
    ToggleBindBtn.Visible = false
    ToggleBindBtn.Parent = ScreenGui
    local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 8) tc.Parent = ToggleBindBtn
    local ts = Instance.new("UIStroke") ts.Thickness = 1.2 ts.Parent = ToggleBindBtn ApplyWave(ts)

    ToggleBindBtn.MouseButton1Click:Connect(function()
        ToggleBindBtn.Visible = false
        Main.Visible = true
        Main:TweenSize(OSize, "Out", "Quart", 0.3, true)
    end)

    -- Topbar (Kéo thả)
    local Top = Instance.new("TextButton")
    Top.Size = UDim2.new(1, 0, 0, 42) Top.BackgroundTransparency = 1 Top.Text = "" Top.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -150, 1, 0) Title.Position = UDim2.fromOffset(15, 0)
    Title.Text = (cfg.Title or "Fynix Hub") .. " <font color='#BCBCFF'>" .. (cfg.SubTitle or "") .. "</font>"
    Title.TextColor3 = Fynix.Themes.Darker.Txt Title.RichText = true
    Title.Font = Enum.Font.SourceSansBold Title.TextSize = 16 Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1 Title.Parent = Top

    -- Nút Đóng (X) & Thu Nhỏ (-)
    local XBtn = Instance.new("TextButton")
    XBtn.Size = UDim2.fromOffset(26, 26) XBtn.Position = UDim2.new(1, -34, 0, 8)
    XBtn.BackgroundTransparency = 1 XBtn.Text = "×" XBtn.TextColor3 = Color3.fromRGB(150,150,155)
    XBtn.TextSize = 22 XBtn.Font = Enum.Font.SourceSans XBtn.Parent = Top
    XBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MBtn = Instance.new("TextButton")
    MBtn.Size = UDim2.fromOffset(26, 26) MBtn.Position = UDim2.new(1, -64, 0, 8)
    MBtn.BackgroundTransparency = 1 MBtn.Text = "─" MBtn.TextColor3 = Color3.fromRGB(150,150,155)
    MBtn.TextSize = 12 MBtn.Font = Enum.Font.SourceSansBold MBtn.Parent = Top
    
    MBtn.MouseButton1Click:Connect(function()
        Main:TweenSize(UDim2.fromOffset(OSize.X.Offset, 0), "In", "Quart", 0.25, true, function()
            Main.Visible = false
            ToggleBindBtn.Visible = true
        end)
    end)

    -- Logic Kéo thả
    local drag, dragInput, start, startPos
    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true start = input.Position startPos = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    Top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    RS.RenderStepped:Connect(function()
        if drag and dragInput then
            local delta = dragInput.Position - start
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Keybind Ẩn/Hiện nhanh UI
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == (cfg.MinimizeKey or Enum.KeyCode.LeftControl) then
            if Main.Visible then
                Main:TweenSize(UDim2.fromOffset(OSize.X.Offset, 0), "In", "Quart", 0.2, true, function() Main.Visible = false ToggleBindBtn.Visible = true end)
            else
                ToggleBindBtn.Visible = false Main.Visible = true Main:TweenSize(OSize, "Out", "Quart", 0.2, true)
            end
        end
    end)

    -- SideBar & Containers
    local SBWidth = cfg.TabWidth or 160
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, SBWidth, 1, -45) Sidebar.Position = UDim2.fromOffset(0, 45)
    Sidebar.BackgroundTransparency = 1 Sidebar.BorderSizePixel = 0 Sidebar.ScrollBarThickness = 0 Sidebar.Parent = Main

    local sbl = Instance.new("UIListLayout") sbl.Padding = UDim.new(0, 4) sbl.HorizontalAlignment = Enum.HorizontalAlignment.Center sbl.Parent = Sidebar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -SBWidth - 10, 1, -45) Container.Position = UDim2.fromOffset(SBWidth + 5, 45)
    Container.BackgroundTransparency = 1 Container.Parent = Main

    local WindowObj = { Tabs = {}, Current = nil }

    function WindowObj:AddTab(tCfg)
        local TabName = tCfg.Title or "Tab"
        local Icon = tCfg.Icon or ""

        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, -16, 0, 34) TBtn.BackgroundColor3 = Fynix.Themes.Darker.Comp TBtn.BackgroundTransparency = 1
        TBtn.Text = (Icon ~= "" and Icon .. "  " or "") .. TabName TBtn.TextColor3 = Fynix.Themes.Darker.Sub
        TBtn.Font = Enum.Font.SourceSansBold TBtn.TextSize = 14 TBtn.Parent = Sidebar
        local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 6) tc.Parent = TBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0) Page.BackgroundTransparency = 1 Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2 Page.ScrollBarImageColor3 = Color3.fromRGB(50,50,55) Page.Visible = false Page.Parent = Container

        local pbl = Instance.new("UIListLayout") pbl.Padding = UDim.new(0, 6) pbl.HorizontalAlignment = Enum.HorizontalAlignment.Center pbl.Parent = Page
        pbl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, pbl.AbsoluteContentSize.Y + 15)
        end)

        local TabObj = { Page = Page, TBtn = TBtn }

        local function Select()
            if WindowObj.Current then
                WindowObj.Current.Page.Visible = false
                WindowObj.Current.TBtn.BackgroundTransparency = 1
                WindowObj.Current.TBtn.TextColor3 = Fynix.Themes.Darker.Sub
            end
            Page.Visible = true TBtn.BackgroundTransparency = 0 TBtn.TextColor3 = Fynix.Themes.Darker.Txt
            WindowObj.Current = TabObj
        end
        TBtn.MouseButton1Click:Connect(Select)

        if #WindowObj.Tabs == 0 then Select() end
        table.insert(WindowObj.Tabs, TabObj)

        -- ==========================================
        -- COMPONENT: PARAGRAPH
        -- ==========================================
        function TabObj:AddParagraph(pCfg)
            local PFrame = Instance.new("Frame")
            PFrame.Size = UDim2.new(1, -10, 0, 50) PFrame.BackgroundColor3 = Fynix.Themes.Darker.Comp PFrame.Parent = Page
            local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 6) cc.Parent = PFrame

            local pt = Instance.new("TextLabel")
            pt.Size = UDim2.new(1, -20, 0, 20) pt.Position = UDim2.fromOffset(10, 5)
            pt.Text = pCfg.Title or "Paragraph" pt.TextColor3 = Fynix.Themes.Darker.Txt
            pt.Font = Enum.Font.SourceSansBold pt.TextSize = 14 pt.TextXAlignment = Enum.TextXAlignment.Left
            pt.BackgroundTransparency = 1 pt.Parent = PFrame

            local pc = Instance.new("TextLabel")
            pc.Size = UDim2.new(1, -20, 0, 20) pc.Position = UDim2.fromOffset(10, 23)
            pc.Text = pCfg.Content or "" pc.TextColor3 = Fynix.Themes.Darker.Sub
            pc.Font = Enum.Font.SourceSans pc.TextSize = 13 pc.TextXAlignment = Enum.TextXAlignment.Left
            pc.BackgroundTransparency = 1 pc.Parent = PFrame

            local ParaObj = {}
            function ParaObj:SetDesc(txt) pt.Text = txt end
            return ParaObj
        end

        -- ==========================================
        -- COMPONENT: BUTTON
        -- ==========================================
        function TabObj:AddButton(bCfg)
            local BFrame = Instance.new("TextButton")
            BFrame.Size = UDim2.new(1, -10, 0, 42) BFrame.BackgroundColor3 = Fynix.Themes.Darker.Comp
            BFrame.Text = "" BFrame.AutoButtonColor = false BFrame.Parent = Page
            local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 6) cc.Parent = BFrame

            local bt = Instance.new("TextLabel")
            bt.Size = UDim2.new(0.6, 0, 1, 0) bt.Position = UDim2.fromOffset(10, 0)
            bt.Text = bCfg.Title or "Button" bt.TextColor3 = Fynix.Themes.Darker.Txt
            bt.Font = Enum.Font.SourceSansBold bt.TextSize = 14 bt.TextXAlignment = Enum.TextXAlignment.Left
            bt.BackgroundTransparency = 1 bt.Parent = BFrame

            local bd = Instance.new("TextLabel")
            bd.Size = UDim2.new(0.4, -15, 1, 0) bd.Position = UDim2.new(0.6, 0, 0, 0)
            bd.Text = bCfg.Description or "" bd.TextColor3 = Fynix.Themes.Darker.Sub
            bd.Font = Enum.Font.SourceSans pc.TextSize = 12 bd.TextXAlignment = Enum.TextXAlignment.Right
            bd.BackgroundTransparency = 1 bd.Parent = BFrame

            BFrame.MouseButton1Click:Connect(function()
                TS:Create(BFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30,30,38)}):Play()
                task.wait(0.1)
                TS:Create(BFrame, TweenInfo.new(0.1), {BackgroundColor3 = Fynix.Themes.Darker.Comp}):Play()
                if bCfg.Callback then bCfg.Callback() end
            end)
        end

        -- ==========================================
        -- COMPONENT: TOGGLE (ANIMATION IOS STYLE)
        -- ==========================================
        function TabObj:AddToggle(id, tCfg)
            local TglObj = { Value = tCfg.Default or false, ChangeCallback = nil }

            local TFrame = Instance.new("TextButton")
            TFrame.Size = UDim2.new(1, -10, 0, 42) TFrame.BackgroundColor3 = Fynix.Themes.Darker.Comp
            TFrame.Text = "" TFrame.AutoButtonColor = false TFrame.Parent = Page
            local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 6) cc.Parent = TFrame

            local tt = Instance.new("TextLabel")
            tt.Size = UDim2.new(1, -60, 1, 0) tt.Position = UDim2.fromOffset(10, 0)
            tt.Text = tCfg.Title or "Toggle" tt.TextColor3 = Fynix.Themes.Darker.Txt
            tt.Font = Enum.Font.SourceSansBold tt.TextSize = 14 tt.TextXAlignment = Enum.TextXAlignment.Left
            tt.BackgroundTransparency = 1 tt.Parent = TFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.fromOffset(36, 20) Switch.Position = UDim2.new(1, -46, 0.5, -10)
            Switch.BackgroundColor3 = Color3.fromRGB(45, 45, 50) Switch.Parent = TFrame
            local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(1, 0) sc.Parent = Switch

            local SliderDot = Instance.new("Frame")
            SliderDot.Size = UDim2.fromOffset(16, 16) SliderDot.Position = UDim2.new(0, 2, 0.5, -8)
            SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255) SliderDot.Parent = Switch
            local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(1, 0) dc.Parent = SliderDot

            local function Update()
                if TglObj.Value then
                    TS:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Fynix.Themes.Darker.G1}):Play()
                    TS:Create(SliderDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                else
                    TS:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
                    TS:Create(SliderDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                end
                SaveConfig()
                if TglObj.ChangeCallback then TglObj.ChangeCallback(TglObj.Value) end
            end

            TFrame.MouseButton1Click:Connect(function()
                TglObj.Value = not TglObj.Value
                Update()
            end)

            function TglObj:OnChanged(cb) TglObj.ChangeCallback = cb cb(TglObj.Value) end
            function TglObj:SetValue(v) TglObj.Value = v Update() end

            Fynix.Options[id] = TglObj
            Update()
            return TglObj
        end

        -- ==========================================
        -- COMPONENT: SLIDER
        -- ==========================================
        function TabObj:AddSlider(id, sCfg)
            local SldObj = { Value = sCfg.Default or sCfg.Min, ChangeCallback = nil }
            local Min, Max = sCfg.Min or 0, sCfg.Max or 100
            local Round = sCfg.Rounding or 1

            local SFrame = Instance.new("Frame")
            SFrame.Size = UDim2.new(1, -10, 0, 52) SFrame.BackgroundColor3 = Fynix.Themes.Darker.Comp SFrame.Parent = Page
            local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 6) cc.Parent = SFrame

            local st = Instance.new("TextLabel")
            st.Size = UDim2.new(0.5, 0, 0, 22) st.Position = UDim2.fromOffset(10, 4)
            st.Text = sCfg.Title or "Slider" st.TextColor3 = Fynix.Themes.Darker.Txt
            st.Font = Enum.Font.SourceSansBold st.TextSize = 14 st.TextXAlignment = Enum.TextXAlignment.Left
            st.BackgroundTransparency = 1 st.Parent = SFrame

            -- Ô nhập kiêm hiển thị giá trị ở cuối thanh tiêu đề
            local ValInput = Instance.new("TextBox")
            ValInput.Size = UDim2.fromOffset(45, 18) ValInput.Position = UDim2.new(1, -55, 0, 6)
            ValInput.BackgroundColor3 = Color3.fromRGB(30,30,35) ValInput.TextColor3 = Fynix.Themes.Darker.Txt
            ValInput.Text = tostring(SldObj.Value) ValInput.Font = Enum.Font.SourceSansBold ValInput.TextSize = 12
            ValInput.BorderSizePixel = 0 ValInput.ClearTextOnFocus = false ValInput.Parent = SFrame
            local ic = Instance.new("UICorner") ic.CornerRadius = UDim.new(0, 4) ic.Parent = ValInput

            local Track = Instance.new("TextButton")
            Track.Size = UDim2.new(1, -20, 0, 6) Track.Position = UDim2.fromOffset(10, 34)
            Track.BackgroundColor3 = Color3.fromRGB(40, 40, 45) Track.Text = "" Track.AutoButtonColor = false Track.Parent = SFrame
            local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(1, 0) tc.Parent = Track

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0) Fill.BackgroundColor3 = Fynix.Themes.Darker.G1 Fill.Parent = Track
            local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(1, 0) fc.Parent = Fill

            local function Update(snap)
                local perc = math.clamp((SldObj.Value - Min) / (Max - Min), 0, 1)
                Fill.Size = UDim2.new(perc, 0, 1, 0)
                ValInput.Text = tostring(math.floor(SldObj.Value * (10^Round) + 0.5) / (10^Round))
                SaveConfig()
                if SldObj.ChangeCallback then SldObj.ChangeCallback(SldObj.Value) end
            end

            local function Slide(input)
                local res = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local rawVal = Min + res * (Max - Min)
                SldObj.Value = math.floor(rawVal * (10^Round) + 0.5) / (10^Round)
                Update()
            end

            local sDrag = false
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sDrag = true Slide(input)
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if sDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Slide(input) end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sDrag = false end
            end)

            ValInput.FocusLost:Connect(function()
                local num = tonumber(ValInput.Text)
                if num then SldObj.Value = math.clamp(num, Min, Max) end
                Update()
            end)

            function SldObj:OnChanged(cb) SldObj.ChangeCallback = cb cb(SldObj.Value) end
            function SldObj:SetValue(v) SldObj.Value = math.clamp(v, Min, Max) Update() end

            Fynix.Options[id] = SldObj
            Update()
            return SldObj
        end

        -- ==========================================
        -- COMPONENT: DROPDOWN & MULTI DROPDOWN
        -- ==========================================
        function TabObj:AddDropdown(id, dCfg)
            local DropObj = { 
                Value = dCfg.Default or (dCfg.Multi and {} or dCfg.Values[1]), 
                Values = dCfg.Values or {}, 
                Multi = dCfg.Multi or false,
                ChangeCallback = nil 
            }

            local DFrame = Instance.new("Frame")
            DFrame.Size = UDim2.new(1, -10, 0, 42) DFrame.BackgroundColor3 = Fynix.Themes.Darker.Comp DFrame.ClipsDescendants = true DFrame.Parent = Page
            local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 6) cc.Parent = DFrame

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 0, 42) ClickBtn.BackgroundTransparency = 1 ClickBtn.Text = "" ClickBtn.Parent = DFrame

            local dt = Instance.new("TextLabel")
            dt.Size = UDim2.new(0.5, 0, 1, 0) dt.Position = UDim2.fromOffset(10, 0)
            dt.Text = dCfg.Title or "Dropdown" dt.TextColor3 = Fynix.Themes.Darker.Txt
            dt.Font = Enum.Font.SourceSansBold dt.TextSize = 14 dt.TextXAlignment = Enum.TextXAlignment.Left
            dt.BackgroundTransparency = 1 dt.Parent = ClickBtn

            local SelectedTxt = Instance.new("TextLabel")
            SelectedTxt.Size = UDim2.new(0.5, -35, 1, 0) SelectedTxt.Position = UDim2.new(0.5, 0, 0, 0)
            SelectedTxt.Text = "..." SelectedTxt.TextColor3 = Fynix.Themes.Darker.Sub
            SelectedTxt.Font = Enum.Font.SourceSans SelectedTxt.TextSize = 13 SelectedTxt.TextXAlignment = Enum.TextXAlignment.Right
            SelectedTxt.BackgroundTransparency = 1 SelectedTxt.Parent = ClickBtn

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.fromOffset(20, 42) Arrow.Position = UDim2.new(1, -25, 0, 0)
            Arrow.Text = "▼" Arrow.TextColor3 = Fynix.Themes.Darker.Sub Arrow.TextSize = 12 Arrow.BackgroundTransparency = 1 Arrow.Parent = ClickBtn

            local OptionList = Instance.new("ScrollingFrame")
            OptionList.Size = UDim2.new(1, -10, 1, -46) OptionList.Position = UDim2.fromOffset(5, 44)
            OptionList.BackgroundTransparency = 1 OptionList.BorderSizePixel = 0 OptionList.ScrollBarThickness = 2 OptionList.Parent = DFrame
            local olayout = Instance.new("UIListLayout") olayout.Padding = UDim.new(0, 3) olayout.Parent = OptionList

            local IsOpen = false
            local function RefreshDisplay()
                if DropObj.Multi then
                    local selected = {}
                    for k, v in pairs(DropObj.Value) do if v then table.insert(selected, k) end end
                    SelectedTxt.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                else
                    SelectedTxt.Text = tostring(DropObj.Value)
                end
                SaveConfig()
                if DropObj.ChangeCallback then DropObj.ChangeCallback(DropObj.Value) end
            end

            local function ToggleOpen()
                IsOpen = not IsOpen
                local targetHeight = IsOpen and math.clamp(#DropObj.Values * 28 + 52, 42, 200) or 42
                TS:Create(DFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, targetHeight)}):Play()
                Arrow.Text = IsOpen and "▲" or "▼"
                OptionList.CanvasSize = UDim2.new(0,0,0, olayout.AbsoluteContentSize.Y + 5)
            end
            ClickBtn.MouseButton1Click:Connect(ToggleOpen)

            function DropObj:BuildOptions()
                for _, item in ipairs(OptionList:GetChildren()) do if item:IsA("TextButton") then item:Destroy() end end
                
                for _, val in ipairs(DropObj.Values) do
                    local OBtn = Instance.new("TextButton")
                    OBtn.Size = UDim2.new(1, 0, 0, 26) OBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                    OBtn.Text = "  " .. val OBtn.TextColor3 = Fynix.Themes.Darker.Sub OBtn.Font = Enum.Font.SourceSans
                    OBtn.TextSize = 13 OBtn.TextXAlignment = Enum.TextXAlignment.Left OBtn.Parent = OptionList
                    local oc = Instance.new("UICorner") oc.CornerRadius = UDim.new(0, 4) oc.Parent = OBtn

                    if DropObj.Multi then
                        if type(DropObj.Value) ~= "table" then DropObj.Value = {} end
                        if DropObj.Value[val] then OBtn.TextColor3 = Fynix.Themes.Darker.G1 end
                    else
                        if DropObj.Value == val then OBtn.TextColor3 = Fynix.Themes.Darker.G1 end
                    end

                    OBtn.MouseButton1Click:Connect(function()
                        if DropObj.Multi then
                            DropObj.Value[val] = not DropObj.Value[val]
                            OBtn.TextColor3 = DropObj.Value[val] and Fynix.Themes.Darker.G1 or Fynix.Themes.Darker.Sub
                        else
                            DropObj.Value = val
                            ToggleOpen()
                            for _, b in ipairs(OptionList:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Fynix.Themes.Darker.Sub end end
                            OBtn.TextColor3 = Fynix.Themes.Darker.G1
                        end
                        RefreshDisplay()
                    end)
                end
            end

            function DropObj:OnChanged(cb) DropObj.ChangeCallback = cb cb(DropObj.Value) end
            function DropObj:SetValue(v)
                if DropObj.Multi and type(v) == "table" then
                    DropObj.Value = v
                elseif DropObj.Multi and type(v) == "string" then
                    DropObj.Value = {[v] = true}
                else
                    DropObj.Value = v
                end
                DropObj:BuildOptions()
                RefreshDisplay()
            end

            -- Thiết lập giá trị Multi dạng table nếu đầu vào mặc định là mảng string
            if dCfg.Multi and type(dCfg.Default) == "table" then
                DropObj.Value = {}
                for _, v in ipairs(dCfg.Default) do DropObj.Value[v] = true end
            end

            DropObj:BuildOptions()
            RefreshDisplay()
            Fynix.Options[id] = DropObj
            return DropObj
        end

        return TabObj
    end

    task.spawn(LoadConfig)
    return WindowObj
end

return Fynix
