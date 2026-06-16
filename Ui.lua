local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local RunService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");
local Lighting = game:GetService("Lighting");
local Camera = workspace.CurrentCamera;
local MAIN_URL = "https://raw.githubusercontent.com/GGG792/KaiHubjiaoben/refs/heads/main/zhengw.lua";
local THEME = {Background=Color3.fromRGB(30, 30, 46),Sidebar=Color3.fromRGB(24, 24, 37),Accent=Color3.fromRGB(119, 221, 255),Text=Color3.fromRGB(255, 255, 255),TextDark=Color3.fromRGB(170, 170, 170),Border=Color3.fromRGB(44, 44, 62),Card=Color3.fromRGB(37, 37, 53),Hover=Color3.fromRGB(45, 45, 65),Success=Color3.fromRGB(46, 213, 115),Error=Color3.fromRGB(255, 71, 87)};
local screenSize = Camera.ViewportSize;
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled;
local scale = (isMobile and 0.7) or 1;
pcall(function()
	if LocalPlayer.PlayerGui:FindFirstChild("KaiHubLoader") then
		LocalPlayer.PlayerGui.KaiHubLoader:Destroy();
	end
	if LocalPlayer.PlayerGui:FindFirstChild("KaiHub") then
		game:GetService("StarterGui"):SetCore("SendNotification", {Title="提示",Text="启动界面已存在，请勿重复点击",Duration=3});
		return;
	end
end);
local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "KaiHubLoader";
ScreenGui.Parent = LocalPlayer.PlayerGui;
ScreenGui.ResetOnSpawn = false;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
ScreenGui.IgnoreGuiInset = true;
local blurEffect = Instance.new("BlurEffect");
blurEffect.Name = "FLoaderBlur";
blurEffect.Size = 0;
blurEffect.Parent = Lighting;
local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=12});
blurTween:Play();
local MainFrame = Instance.new("Frame");
MainFrame.Name = "MainFrame";
MainFrame.Size = UDim2.new(1, 0, 1, 0);
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
MainFrame.BackgroundTransparency = 1;
MainFrame.BorderSizePixel = 0;
MainFrame.ClipsDescendants = true;
MainFrame.Parent = ScreenGui;
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency=0.4}):Play();
local GlowAmbient = Instance.new("Frame");
GlowAmbient.Name = "GlowAmbient";
GlowAmbient.Size = UDim2.new(1.5, 0, 1.5, 0);
GlowAmbient.Position = UDim2.new(0.5, 0, 0.5, 0);
GlowAmbient.AnchorPoint = Vector2.new(0.5, 0.5);
GlowAmbient.BackgroundTransparency = 1;
GlowAmbient.BorderSizePixel = 0;
GlowAmbient.ZIndex = 25;
GlowAmbient.Parent = MainFrame;
local GlowColor = Instance.new("Frame");
GlowColor.Size = UDim2.new(1, 0, 1, 0);
GlowColor.BackgroundColor3 = THEME.Accent;
GlowColor.BackgroundTransparency = 0.95;
GlowColor.BorderSizePixel = 0;
GlowColor.ZIndex = 25;
GlowColor.Parent = GlowAmbient;
local contentWidth = (isMobile and 280) or 400;
local contentHeight = (isMobile and 45) or 60;
local ContentGroup = Instance.new("Frame");
ContentGroup.Name = "ContentGroup";
ContentGroup.Size = UDim2.new(0, contentWidth, 0, contentHeight);
ContentGroup.Position = UDim2.new(0.5, -contentWidth / 2, 0.5, -contentHeight / 2);
ContentGroup.BackgroundTransparency = 1;
ContentGroup.BorderSizePixel = 0;
ContentGroup.Parent = MainFrame;
local dotContainerSize = (isMobile and 45) or 60;
local DotContainer = Instance.new("Frame");
DotContainer.Name = "DotContainer";
DotContainer.Size = UDim2.new(0, dotContainerSize, 0, dotContainerSize);
DotContainer.Position = UDim2.new(0.5, -dotContainerSize / 2, 0.5, -dotContainerSize / 2);
DotContainer.BackgroundTransparency = 1;
DotContainer.BorderSizePixel = 0;
DotContainer.Parent = ContentGroup;
local dotSize = (isMobile and 14) or 20;
local dotHalf = dotSize / 2;
local Dot1 = Instance.new("Frame");
Dot1.Name = "Dot1";
Dot1.Size = UDim2.new(0, dotSize, 0, dotSize);
Dot1.Position = UDim2.new(0.5, -dotHalf, 0.5, -dotHalf);
Dot1.BackgroundColor3 = Color3.fromRGB(240, 243, 250);
Dot1.BackgroundTransparency = 1;
Dot1.BorderSizePixel = 0;
Dot1.ZIndex = 31;
Dot1.Parent = DotContainer;
local Dot1Corner = Instance.new("UICorner");
Dot1Corner.CornerRadius = UDim.new(1, 0);
Dot1Corner.Parent = Dot1;
local Dot2 = Instance.new("Frame");
Dot2.Name = "Dot2";
Dot2.Size = UDim2.new(0, dotSize, 0, dotSize);
Dot2.Position = UDim2.new(0.5, -dotHalf, 0.5, -dotHalf);
Dot2.BackgroundColor3 = Color3.fromRGB(240, 243, 250);
Dot2.BackgroundTransparency = 1;
Dot2.BorderSizePixel = 0;
Dot2.ZIndex = 30;
Dot2.Parent = DotContainer;
local Dot2Corner = Instance.new("UICorner");
Dot2Corner.CornerRadius = UDim.new(1, 0);
Dot2Corner.Parent = Dot2;
local Dot3 = Instance.new("Frame");
Dot3.Name = "Dot3";
Dot3.Size = UDim2.new(0, dotSize, 0, dotSize);
Dot3.Position = UDim2.new(0.5, -dotHalf, 0.5, -dotHalf);
Dot3.BackgroundColor3 = Color3.fromRGB(240, 243, 250);
Dot3.BackgroundTransparency = 1;
Dot3.BorderSizePixel = 0;
Dot3.ZIndex = 29;
Dot3.Parent = DotContainer;
local Dot3Corner = Instance.new("UICorner");
Dot3Corner.CornerRadius = UDim.new(1, 0);
Dot3Corner.Parent = Dot3;
local titleFontSize = (isMobile and 28) or 42;
local titleWidth = (isMobile and 220) or 300;
local titleOffset = (isMobile and 80) or 70;
local BrandTitle = Instance.new("TextLabel");
BrandTitle.Name = "BrandTitle";
BrandTitle.Size = UDim2.new(0, titleWidth, 0, 50 * scale);
BrandTitle.Position = UDim2.new(0, titleOffset * scale, 0.5, -25 * scale);
BrandTitle.BackgroundTransparency = 1;
BrandTitle.Text = "KaiHub";
BrandTitle.TextColor3 = THEME.Text;
BrandTitle.Font = Enum.Font.GothamBold;
BrandTitle.TextSize = titleFontSize;
BrandTitle.TextTransparency = 1;
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left;
BrandTitle.Parent = ContentGroup;
local VersionText = Instance.new("TextLabel");
VersionText.Size = UDim2.new(0, 100, 0, 20);
VersionText.Position = UDim2.new(0, titleOffset * scale, 0.5, 15 * scale);
VersionText.BackgroundTransparency = 1;
VersionText.Text = "v6.0";
VersionText.TextColor3 = THEME.Accent;
VersionText.Font = Enum.Font.GothamMedium;
VersionText.TextSize = (isMobile and 12) or 14;
VersionText.TextTransparency = 1;
VersionText.TextXAlignment = Enum.TextXAlignment.Left;
VersionText.Parent = ContentGroup;
local footerWidth = (isMobile and 200) or 260;
local footerYOffset = (isMobile and -80) or -120;
local LoadingFooter = Instance.new("Frame");
LoadingFooter.Name = "LoadingFooter";
LoadingFooter.Size = UDim2.new(0, footerWidth, 0, 60 * scale);
LoadingFooter.Position = UDim2.new(0.5, -footerWidth / 2, 1, footerYOffset * scale);
LoadingFooter.BackgroundTransparency = 1;
LoadingFooter.BorderSizePixel = 0;
LoadingFooter.ZIndex = 35;
LoadingFooter.Parent = MainFrame;
local LoadingText = Instance.new("TextLabel");
LoadingText.Name = "LoadingText";
LoadingText.Size = UDim2.new(1, 0, 0, 24 * scale);
LoadingText.Position = UDim2.new(0, 0, 0, 0);
LoadingText.BackgroundTransparency = 1;
LoadingText.Text = "加载中 · LOADING";
LoadingText.TextColor3 = Color3.fromRGB(176, 199, 233);
LoadingText.Font = Enum.Font.GothamMedium;
LoadingText.TextSize = (isMobile and 13) or 16;
LoadingText.TextTransparency = 1;
LoadingText.Parent = LoadingFooter;
local ProgressContainer = Instance.new("Frame");
ProgressContainer.Name = "ProgressContainer";
ProgressContainer.Size = UDim2.new(1, 0, 0, 3 * scale);
ProgressContainer.Position = UDim2.new(0, 0, 0, 36 * scale);
ProgressContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
ProgressContainer.BackgroundTransparency = 0.92;
ProgressContainer.BorderSizePixel = 0;
ProgressContainer.Parent = LoadingFooter;
local ProgressCorner = Instance.new("UICorner");
ProgressCorner.CornerRadius = UDim.new(0, 20 * scale);
ProgressCorner.Parent = ProgressContainer;
local ProgressFill = Instance.new("Frame");
ProgressFill.Name = "ProgressFill";
ProgressFill.Size = UDim2.new(0, 0, 1, 0);
ProgressFill.BackgroundColor3 = THEME.Accent;
ProgressFill.BorderSizePixel = 0;
ProgressFill.Parent = ProgressContainer;
local FillCorner = Instance.new("UICorner");
FillCorner.CornerRadius = UDim.new(0, 20 * scale);
FillCorner.Parent = ProgressFill;
local readyFontSize = (isMobile and 20) or 28;
local CompleteText = Instance.new("TextLabel");
CompleteText.Name = "CompleteText";
CompleteText.Size = UDim2.new(1, 0, 0, 40 * scale);
CompleteText.Position = UDim2.new(0.5, 0, 0.5, -20 * scale);
CompleteText.AnchorPoint = Vector2.new(0.5, 0.5);
CompleteText.BackgroundTransparency = 1;
CompleteText.Text = "R E A D Y";
CompleteText.TextColor3 = THEME.Accent;
CompleteText.Font = Enum.Font.GothamBold;
CompleteText.TextSize = readyFontSize;
CompleteText.TextTransparency = 1;
CompleteText.ZIndex = 45;
CompleteText.Visible = false;
CompleteText.Parent = MainFrame;
local decoFontSize = (isMobile and 8) or 10;
local CornerDeco1 = Instance.new("TextLabel");
CornerDeco1.Name = "CornerDeco1";
CornerDeco1.Size = UDim2.new(0, 100, 0, 20 * scale);
CornerDeco1.Position = UDim2.new(0, 16 * scale, 0, 12 * scale);
CornerDeco1.BackgroundTransparency = 1;
CornerDeco1.Text = "KAI HUB";
CornerDeco1.TextColor3 = Color3.fromRGB(62, 80, 107);
CornerDeco1.TextTransparency = 1;
CornerDeco1.Font = Enum.Font.GothamMedium;
CornerDeco1.TextSize = decoFontSize;
CornerDeco1.TextXAlignment = Enum.TextXAlignment.Left;
CornerDeco1.ZIndex = 40;
CornerDeco1.Parent = MainFrame;
local CornerDeco2 = Instance.new("TextLabel");
CornerDeco2.Name = "CornerDeco2";
CornerDeco2.Size = UDim2.new(0, 60, 0, 20 * scale);
CornerDeco2.Position = UDim2.new(1, -76 * scale, 0, 12 * scale);
CornerDeco2.BackgroundTransparency = 1;
CornerDeco2.Text = "v6.0";
CornerDeco2.TextColor3 = Color3.fromRGB(62, 80, 107);
CornerDeco2.TextTransparency = 1;
CornerDeco2.Font = Enum.Font.GothamMedium;
CornerDeco2.TextSize = decoFontSize;
CornerDeco2.TextXAlignment = Enum.TextXAlignment.Right;
CornerDeco2.ZIndex = 40;
CornerDeco2.Parent = MainFrame;
local btnW = (isMobile and 160) or 200;
local btnH = (isMobile and 38) or 46;

local StartBtn = Instance.new("TextButton");
StartBtn.Name = "StartBtn";
StartBtn.Size = UDim2.new(0, btnW, 0, btnH);
StartBtn.Position = UDim2.new(0.5, -btnW / 2, 1, -180 * scale);
StartBtn.BackgroundColor3 = THEME.Accent;
StartBtn.Text = "启 动 脚 本";
StartBtn.TextColor3 = Color3.fromRGB(0, 0, 0);
StartBtn.TextSize = (isMobile and 14) or 16;
StartBtn.Font = Enum.Font.GothamBlack;
StartBtn.BorderSizePixel = 0;
StartBtn.AutoButtonColor = false;
StartBtn.Visible = false;
StartBtn.ZIndex = 50;
StartBtn.Parent = MainFrame;
local BtnCorner = Instance.new("UICorner");
BtnCorner.CornerRadius = UDim.new(0, 8);
BtnCorner.Parent = StartBtn;
local BtnStroke = Instance.new("UIStroke");
BtnStroke.Thickness = 2;
BtnStroke.Transparency = 0.3;
BtnStroke.Color = THEME.Accent;
BtnStroke.Parent = StartBtn;
TweenService:Create(BrandTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency=0}):Play();
TweenService:Create(VersionText, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {TextTransparency=0}):Play();
TweenService:Create(CornerDeco1, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {TextTransparency=0}):Play();
TweenService:Create(CornerDeco2, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {TextTransparency=0}):Play();
local function playPulseAnimation()
	TweenService:Create(Dot1, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency=0}):Play();
	task.delay(0.15, function()
		TweenService:Create(Dot2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency=0.3}):Play();
		TweenService:Create(Dot2, TweenInfo.new(1, Enum.EasingStyle.Quad), {Size=UDim2.new(0, dotSize * 2.5, 0, dotSize * 2.5),Position=UDim2.new(0.5, -dotSize * 1.25, 0.5, -dotSize * 1.25),BackgroundTransparency=1}):Play();
	end);
	task.delay(0.3, function()
		TweenService:Create(Dot3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency=0.2}):Play();
		TweenService:Create(Dot3, TweenInfo.new(1, Enum.EasingStyle.Quad), {Size=UDim2.new(0, dotSize * 3.5, 0, dotSize * 3.5),Position=UDim2.new(0.5, -dotSize * 1.75, 0.5, -dotSize * 1.75),BackgroundTransparency=1}):Play();
	end);
	task.delay(1.2, function()
		Dot2.Size = UDim2.new(0, dotSize, 0, dotSize);
		Dot2.Position = UDim2.new(0.5, -dotHalf, 0.5, -dotHalf);
		Dot3.Size = UDim2.new(0, dotSize, 0, dotSize);
		Dot3.Position = UDim2.new(0.5, -dotHalf, 0.5, -dotHalf);
	end);
end
local pulseConnection;
local pulseRunning = true;
pulseConnection = task.spawn(function()
	while pulseRunning do
		playPulseAnimation();
		task.wait(1.5);
	end
end);
local loadSteps = {{text="连接服务器...",progress=0.15,delay=0.3},{text="验证版本...",progress=0.35,delay=0.4},{text="下载主脚本...",progress=0.6,delay=0.5},{text="加载模块...",progress=0.85,delay=0.4},{text="初始化完成",progress=1,delay=0.3}};
local currentStep = 1;
local function updateLoadingStep()
	if (currentStep > #loadSteps) then
		return;
	end
	local step = loadSteps[currentStep];
	LoadingText.Text = step.text;
	TweenService:Create(LoadingText, TweenInfo.new(0.3), {TextTransparency=0}):Play();
	local targetW = ProgressContainer.Size.X.Offset * step.progress;
	TweenService:Create(ProgressFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size=UDim2.new(0, targetW, 1, 0)}):Play();
	currentStep = currentStep + 1;
	if (currentStep <= #loadSteps) then
		task.delay(step.delay, updateLoadingStep);
	end
end
task.delay(0.5, function()
	TweenService:Create(LoadingText, TweenInfo.new(0.4), {TextTransparency=0}):Play();
	TweenService:Create(ProgressContainer, TweenInfo.new(0.4), {BackgroundTransparency=0.92}):Play();
	updateLoadingStep();
end);
local function showStartButton()
	pulseRunning = false;
	TweenService:Create(LoadingText, TweenInfo.new(0.3), {TextTransparency=1}):Play();
	TweenService:Create(ProgressContainer, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play();
	TweenService:Create(ProgressFill, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play();
	CompleteText.Visible = true;
	TweenService:Create(CompleteText, TweenInfo.new(0.4, Enum.EasingStyle.Back), {TextTransparency=0}):Play();
	task.delay(0.8, function()
		TweenService:Create(CompleteText, TweenInfo.new(0.3), {TextTransparency=1}):Play();
		StartBtn.Visible = true;
		StartBtn.TextTransparency = 1;
		TweenService:Create(StartBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {TextTransparency=0}):Play();

	end);
end
task.delay(2.5, showStartButton);
StartBtn.MouseEnter:Connect(function()
	TweenService:Create(StartBtn, TweenInfo.new(0.2), {Size=UDim2.new(0, btnW + 10, 0, btnH + 4),BackgroundColor3=Color3.fromRGB(140, 230, 255)}):Play();
	BtnStroke.Transparency = 0.1;
end);
StartBtn.MouseLeave:Connect(function()
	TweenService:Create(StartBtn, TweenInfo.new(0.2), {Size=UDim2.new(0, btnW, 0, btnH),BackgroundColor3=THEME.Accent}):Play();
	BtnStroke.Transparency = 0.3;
end);
StartBtn.MouseButton1Down:Connect(function()
	TweenService:Create(StartBtn, TweenInfo.new(0.1), {Size=UDim2.new(0, btnW - 6, 0, btnH - 3),BackgroundColor3=Color3.fromRGB(90, 200, 240)}):Play();
end);
StartBtn.MouseButton1Up:Connect(function()
	TweenService:Create(StartBtn, TweenInfo.new(0.15), {Size=UDim2.new(0, btnW + 10, 0, btnH + 4),BackgroundColor3=Color3.fromRGB(140, 230, 255)}):Play();
end);
StartBtn.MouseButton1Click:Connect(function()
	StartBtn.Text = "执 行 中 . . .";
	StartBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90);
	BtnStroke.Color = Color3.fromRGB(150, 150, 150);
	local success, err = pcall(function()
		local code = game:HttpGet(MAIN_URL);
		if (code and (#code > 100)) then
			loadstring(code)();
		else
			error("获取脚本失败，返回内容过短");
		end
	end);
	if not success then
		StartBtn.Text = "启 动 失 败";
		StartBtn.BackgroundColor3 = THEME.Error;
		BtnStroke.Color = THEME.Error;
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", {Title="启动失败",Text=(tostring(err):sub(1, 50) or "请检查网络连接"),Duration=5});
		end);
		task.delay(3, function()
			StartBtn.Text = "启 动 脚 本";
			StartBtn.BackgroundColor3 = THEME.Accent;
			BtnStroke.Color = THEME.Accent;
		end);
	else
		TweenService:Create(blurEffect, TweenInfo.new(0.4), {Size=0}):Play();
		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play();
		TweenService:Create(StartBtn, TweenInfo.new(0.3), {TextTransparency=1}):Play();
		TweenService:Create(BrandTitle, TweenInfo.new(0.3), {TextTransparency=1}):Play();
		TweenService:Create(VersionText, TweenInfo.new(0.3), {TextTransparency=1}):Play();
		task.delay(0.5, function()
			ScreenGui:Destroy();
			if (blurEffect and blurEffect.Parent) then
				blurEffect:Destroy();
			end
		end);
	end
end);
pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {Title="KaiHub",Text="v6.0 ChronixHub风格启动器已加载",Duration=3});
end);
