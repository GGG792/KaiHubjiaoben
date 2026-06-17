local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local TweenService = game:GetService("TweenService");
local Lighting = game:GetService("Lighting");
local MAIN_URL = "https://raw.githubusercontent.com/GGG792/KaiHubjiaoben/refs/heads/main/zhengw.lua";
local VIP_OWNERS = {"noobnewfggg", "sbcnm229"};
local isOwner = false;
for _, name in ipairs(VIP_OWNERS) do
	if LocalPlayer.Name == name then
		isOwner = true;
		break;
	end;
end;

pcall(function()
	if LocalPlayer.PlayerGui:FindFirstChild("KaiHubLoader") then
		LocalPlayer.PlayerGui.KaiHubLoader:Destroy();
	end;
end);

local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "KaiHubLoader";
ScreenGui.Parent = LocalPlayer.PlayerGui;
ScreenGui.ResetOnSpawn = false;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
ScreenGui.IgnoreGuiInset = true;

-- 模糊背景
local blurEffect = Instance.new("BlurEffect");
blurEffect.Name = "FLoaderBlur";
blurEffect.Size = 0;
blurEffect.Parent = Lighting;
TweenService:Create(blurEffect, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size=24}):Play();

-- 主框架
local MainFrame = Instance.new("Frame");
MainFrame.Name = "MainFrame";
MainFrame.Size = UDim2.new(1, 0, 1, 0);
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
MainFrame.BackgroundTransparency = 1;
MainFrame.BorderSizePixel = 0;
MainFrame.Parent = ScreenGui;
TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {BackgroundTransparency=(isOwner and 0.3) or 0.5}):Play();

-- 如果是作者，背景变金色
if isOwner then
	local goldBg = Instance.new("Frame");
	goldBg.Size = UDim2.new(1, 0, 1, 0);
	goldBg.BackgroundColor3 = Color3.fromRGB(255, 215, 0);
	goldBg.BackgroundTransparency = 0.85;
	goldBg.BorderSizePixel = 0;
	goldBg.ZIndex = 0;
	goldBg.Parent = MainFrame;
end;

-- 中心容器
local CenterFrame = Instance.new("Frame");
CenterFrame.Name = "CenterFrame";
CenterFrame.Size = UDim2.new(0, 400, 0, 300);
CenterFrame.Position = UDim2.new(0.5, -200, 0.5, -150);
CenterFrame.BackgroundTransparency = 1;
CenterFrame.BorderSizePixel = 0;
CenterFrame.Parent = MainFrame;

-- 杨志卡文字
local YangZhiKa = Instance.new("TextLabel");
YangZhiKa.Name = "YangZhiKa";
YangZhiKa.Size = UDim2.new(0, 400, 0, 60);
YangZhiKa.Position = UDim2.new(0.5, -200, 0.5, -30);
YangZhiKa.AnchorPoint = Vector2.new(0.5, 0.5);
YangZhiKa.BackgroundTransparency = 1;
YangZhiKa.Text = "杨志卡";
YangZhiKa.Font = Enum.Font.GothamBlack;
YangZhiKa.TextSize = 48;
YangZhiKa.TextTransparency = 1;
YangZhiKa.TextXAlignment = Enum.TextXAlignment.Center;
YangZhiKa.Parent = CenterFrame;

-- 渐变色
local gradient1 = Instance.new("UIGradient");
gradient1.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(128, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 128, 255))
});
gradient1.Parent = YangZhiKa;

-- (作者)
local AuthorTag1 = Instance.new("TextLabel");
AuthorTag1.Name = "AuthorTag1";
AuthorTag1.Size = UDim2.new(0, 100, 0, 24);
AuthorTag1.Position = UDim2.new(0.5, 50, 0.5, 5);
AuthorTag1.AnchorPoint = Vector2.new(0.5, 0.5);
AuthorTag1.BackgroundTransparency = 1;
AuthorTag1.Text = "(作者)";
AuthorTag1.Font = Enum.Font.GothamBold;
AuthorTag1.TextSize = 18;
AuthorTag1.TextColor3 = Color3.fromRGB(255, 255, 255);
AuthorTag1.TextTransparency = 1;
AuthorTag1.TextXAlignment = Enum.TextXAlignment.Left;
AuthorTag1.Parent = CenterFrame;

-- 杯子狗文字
local BeiZiGou = Instance.new("TextLabel");
BeiZiGou.Name = "BeiZiGou";
BeiZiGou.Size = UDim2.new(0, 400, 0, 60);
BeiZiGou.Position = UDim2.new(0.5, -200, 0.5, -30);
BeiZiGou.AnchorPoint = Vector2.new(0.5, 0.5);
BeiZiGou.BackgroundTransparency = 1;
BeiZiGou.Text = "杯子狗";
BeiZiGou.Font = Enum.Font.GothamBlack;
BeiZiGou.TextSize = 48;
BeiZiGou.TextTransparency = 1;
BeiZiGou.TextXAlignment = Enum.TextXAlignment.Center;
BeiZiGou.Visible = false;
BeiZiGou.Parent = CenterFrame;

-- 杯子狗渐变色
local gradient2 = Instance.new("UIGradient");
gradient2.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 128)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 128, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 128))
});
gradient2.Parent = BeiZiGou;

-- (作者)
local AuthorTag2 = Instance.new("TextLabel");
AuthorTag2.Name = "AuthorTag2";
AuthorTag2.Size = UDim2.new(0, 100, 0, 24);
AuthorTag2.Position = UDim2.new(0.5, 50, 0.5, 5);
AuthorTag2.AnchorPoint = Vector2.new(0.5, 0.5);
AuthorTag2.BackgroundTransparency = 1;
AuthorTag2.Text = "(作者)";
AuthorTag2.Font = Enum.Font.GothamBold;
AuthorTag2.TextSize = 18;
AuthorTag2.TextColor3 = Color3.fromRGB(255, 255, 255);
AuthorTag2.TextTransparency = 1;
AuthorTag2.TextXAlignment = Enum.TextXAlignment.Left;
AuthorTag2.Visible = false;
AuthorTag2.Parent = CenterFrame;

-- 加载文字
local LoadingText = Instance.new("TextLabel");
LoadingText.Name = "LoadingText";
LoadingText.Size = UDim2.new(0, 400, 0, 30);
LoadingText.Position = UDim2.new(0.5, -200, 0.7, 0);
LoadingText.BackgroundTransparency = 1;
LoadingText.Text = "正在加载中...";
LoadingText.Font = Enum.Font.GothamMedium;
LoadingText.TextSize = 16;
LoadingText.TextColor3 = Color3.fromRGB(200, 200, 200);
LoadingText.TextTransparency = 1;
LoadingText.TextXAlignment = Enum.TextXAlignment.Center;
LoadingText.Parent = CenterFrame;

-- 进度条背景
local ProgressBg = Instance.new("Frame");
ProgressBg.Name = "ProgressBg";
ProgressBg.Size = UDim2.new(0, 300, 0, 4);
ProgressBg.Position = UDim2.new(0.5, -150, 0.75, 0);
ProgressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80);
ProgressBg.BackgroundTransparency = 1;
ProgressBg.BorderSizePixel = 0;
ProgressBg.Parent = CenterFrame;

local ProgressBgCorner = Instance.new("UICorner");
ProgressBgCorner.CornerRadius = UDim.new(0, 2);
ProgressBgCorner.Parent = ProgressBg;

-- 进度条填充
local ProgressFill = Instance.new("Frame");
ProgressFill.Name = "ProgressFill";
ProgressFill.Size = UDim2.new(0, 0, 1, 0);
ProgressFill.BackgroundColor3 = (isOwner and Color3.fromRGB(255, 215, 0)) or Color3.fromRGB(119, 221, 255);
ProgressFill.BorderSizePixel = 0;
ProgressFill.Parent = ProgressBg;

local ProgressFillCorner = Instance.new("UICorner");
ProgressFillCorner.CornerRadius = UDim.new(0, 2);
ProgressFillCorner.Parent = ProgressFill;

-- 动画序列
local function playIntro()
	-- 步骤1: 显示杨志卡
	TweenService:Create(YangZhiKa, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextTransparency=0}):Play();
	TweenService:Create(AuthorTag1, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextTransparency=0}):Play();
	
	task.delay(1.5, function()
		-- 步骤2: 动态模糊缩小
		TweenService:Create(YangZhiKa, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			TextTransparency=1,
			Size=UDim2.new(0, 0, 0, 0)
		}):Play();
		TweenService:Create(AuthorTag1, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency=1}):Play();
		
		-- 添加动态模糊效果
		local blur1 = Instance.new("BlurEffect");
		blur1.Size = 0;
		blur1.Parent = Lighting;
		TweenService:Create(blur1, TweenInfo.new(0.3), {Size=30}):Play();
		
		task.delay(0.3, function()
			TweenService:Create(blur1, TweenInfo.new(0.3), {Size=0}):Play();
			task.delay(0.3, function()
				blur1:Destroy();
			end);
		end);
		
		task.delay(0.5, function()
			-- 步骤3: 显示杯子狗（从中间放大）
			BeiZiGou.Visible = true;
			AuthorTag2.Visible = true;
			BeiZiGou.Size = UDim2.new(0, 0, 0, 0);
			AuthorTag2.TextTransparency = 1;
			
			TweenService:Create(BeiZiGou, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
				Size=UDim2.new(0, 400, 0, 60),
				TextTransparency=0
			}):Play();
			TweenService:Create(AuthorTag2, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextTransparency=0}):Play();
			
			task.delay(1.5, function()
				-- 步骤4: 缩小杯子狗
				TweenService:Create(BeiZiGou, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					TextTransparency=1,
					Size=UDim2.new(0, 0, 0, 0)
				}):Play();
				TweenService:Create(AuthorTag2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency=1}):Play();
				
				-- 动态模糊
				local blur2 = Instance.new("BlurEffect");
				blur2.Size = 0;
				blur2.Parent = Lighting;
				TweenService:Create(blur2, TweenInfo.new(0.3), {Size=30}):Play();
				
				task.delay(0.3, function()
					TweenService:Create(blur2, TweenInfo.new(0.3), {Size=0}):Play();
					task.delay(0.3, function()
						blur2:Destroy();
					end);
				end);
				
				task.delay(0.5, function()
					-- 步骤5: 一起出现（杨志卡在上，杯子狗在下）
					YangZhiKa.Position = UDim2.new(0.5, -200, 0.35, -30);
					YangZhiKa.Size = UDim2.new(0, 400, 0, 50);
					YangZhiKa.TextTransparency = 1;
					YangZhiKa.Visible = true;
					
					BeiZiGou.Position = UDim2.new(0.5, -200, 0.55, -30);
					BeiZiGou.Size = UDim2.new(0, 400, 0, 50);
					BeiZiGou.TextTransparency = 1;
					BeiZiGou.Visible = true;
					
					TweenService:Create(YangZhiKa, TweenInfo.new(0.6, Enum.EasingStyle.Back), {TextTransparency=0}):Play();
					TweenService:Create(BeiZiGou, TweenInfo.new(0.6, Enum.EasingStyle.Back), {TextTransparency=0}):Play();
					
					-- 显示加载
					task.delay(0.8, function()
						TweenService:Create(LoadingText, TweenInfo.new(0.4), {TextTransparency=0}):Play();
						TweenService:Create(ProgressBg, TweenInfo.new(0.4), {BackgroundTransparency=0}):Play();
						
						-- 开始加载进度
						startLoading();
					end);
				end);
			end);
		end);
	end);
end;

-- 加载进度和自动启动
local function startLoading()
	local steps = {
		{progress=0.2, delay=0.4, text="正在连接服务器..."},
		{progress=0.4, delay=0.5, text="正在验证版本..."},
		{progress=0.6, delay=0.5, text="正在下载主脚本..."},
		{progress=0.8, delay=0.4, text="正在加载模块..."},
		{progress=1.0, delay=0.3, text="准备启动..."}
	};
	
	local currentStep = 1;
	local function nextStep()
		if currentStep > #steps then
			-- 加载完成，启动脚本
			launchScript();
			return;
		end;
		
		local step = steps[currentStep];
		LoadingText.Text = step.text;
		TweenService:Create(ProgressFill, TweenInfo.new(step.delay, Enum.EasingStyle.Quad), {
			Size=UDim2.new(step.progress, 0, 1, 0)
		}):Play();
		
		currentStep = currentStep + 1;
		task.delay(step.delay + 0.1, nextStep);
	end;
	
	nextStep();
end;

-- 启动脚本
local function launchScript()
	-- 如果是作者，显示金色提示
	if isOwner then
		local goldNotify = Instance.new("Frame");
		goldNotify.Size = UDim2.new(0, 350, 0, 80);
		goldNotify.Position = UDim2.new(0.5, -175, 0.5, -40);
		goldNotify.AnchorPoint = Vector2.new(0.5, 0.5);
		goldNotify.BackgroundColor3 = Color3.fromRGB(255, 215, 0);
		goldNotify.BackgroundTransparency = 0.2;
		goldNotify.BorderSizePixel = 0;
		goldNotify.ZIndex = 100;
		goldNotify.Parent = MainFrame;
		
		local goldCorner = Instance.new("UICorner");
		goldCorner.CornerRadius = UDim.new(0, 12);
		goldCorner.Parent = goldNotify;
		
		local goldStroke = Instance.new("UIStroke");
		goldStroke.Thickness = 2;
		goldStroke.Color = Color3.fromRGB(255, 255, 0);
		goldStroke.Parent = goldNotify;
		
		local goldText = Instance.new("TextLabel");
		goldText.Size = UDim2.new(1, 0, 1, 0);
		goldText.BackgroundTransparency = 1;
		goldText.Text = "欢迎尊贵的作者使用此脚本";
		goldText.Font = Enum.Font.GothamBlack;
		goldText.TextSize = 22;
		goldText.TextColor3 = Color3.fromRGB(0, 0, 0);
		goldText.ZIndex = 101;
		goldText.Parent = goldNotify;
		
		-- 闪烁效果
		local flash = Instance.new("Frame");
		flash.Size = UDim2.new(1, 0, 1, 0);
		flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		flash.BackgroundTransparency = 1;
		flash.ZIndex = 102;
		flash.Parent = goldNotify;
		
		TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency=0.5}):Play();
		task.delay(0.3, function()
			TweenService:Create(flash, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play();
		end);
		
		task.delay(2, function()
			TweenService:Create(goldNotify, TweenInfo.new(0.5), {BackgroundTransparency=1}):Play();
			TweenService:Create(goldText, TweenInfo.new(0.5), {TextTransparency=1}):Play();
			TweenService:Create(goldStroke, TweenInfo.new(0.5), {Transparency=1}):Play();
			task.delay(0.6, function()
				goldNotify:Destroy();
				executeScript();
			end);
		end);
	else
		task.delay(0.5, executeScript);
	end;
end;

-- 执行脚本
local function executeScript()
	local success, err = pcall(function()
		local code = game:HttpGet(MAIN_URL);
		if (code and (#code > 100)) then
			loadstring(code)();
		else
			error("获取脚本失败，返回内容过短");
		end;
	end);
	
	if not success then
		LoadingText.Text = "启动失败: " .. tostring(err):sub(1, 30);
		LoadingText.TextColor3 = Color3.fromRGB(255, 71, 87);
		task.delay(3, function()
			ScreenGui:Destroy();
			blurEffect:Destroy();
		end);
	else
		-- 成功启动，淡出界面
		TweenService:Create(blurEffect, TweenInfo.new(0.6), {Size=0}):Play();
		TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play();
		TweenService:Create(CenterFrame, TweenInfo.new(0.4), {BackgroundTransparency=1}):Play();
		
		for _, child in ipairs(CenterFrame:GetDescendants()) do
			if child:IsA("TextLabel") or child:IsA("Frame") then
				TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency=1, TextTransparency=1}):Play();
			end;
		end;
		
		task.delay(0.7, function()
			ScreenGui:Destroy();
			if blurEffect and blurEffect.Parent then
				blurEffect:Destroy();
			end;
		end);
	end;
end;

-- 开始动画
task.delay(0.3, playIntro);
