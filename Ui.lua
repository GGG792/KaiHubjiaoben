local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local TweenService = game:GetService("TweenService");
local Lighting = game:GetService("Lighting");
local RunService = game:GetService("RunService");
local MAIN_URL = "https://raw.githubusercontent.com/GGG792/KaiHubjiaoben/refs/heads/main/zhengw.lua";
local VIP_OWNERS = {"noobnewfggg", "sbcnm229"};
local isOwner = false;
for _, name in ipairs(VIP_OWNERS) do
	if LocalPlayer.Name == name then
		isOwner = true;
		break;
	end;
end;

-- 清理旧界面
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
blurEffect.Name = "KaiLoaderBlur";
blurEffect.Size = 0;
blurEffect.Parent = Lighting;
TweenService:Create(blurEffect, TweenInfo.new(1, Enum.EasingStyle.Quad), {Size=18}):Play();

-- 主背景（磨砂玻璃效果）
local MainFrame = Instance.new("Frame");
MainFrame.Name = "MainFrame";
MainFrame.Size = UDim2.new(1, 0, 1, 0);
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
MainFrame.BackgroundTransparency = 1;
MainFrame.BorderSizePixel = 0;
MainFrame.ClipsDescendants = true;
MainFrame.Parent = ScreenGui;
TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {BackgroundTransparency=0.4}):Play();

-- 光晕效果
local GlowAmbient = Instance.new("Frame");
GlowAmbient.Size = UDim2.new(1.5, 0, 1.5, 0);
GlowAmbient.Position = UDim2.new(0.5, 0, 0.5, 0);
GlowAmbient.AnchorPoint = Vector2.new(0.5, 0.5);
GlowAmbient.BackgroundTransparency = 1;
GlowAmbient.BorderSizePixel = 0;
GlowAmbient.ZIndex = 0;
GlowAmbient.Parent = MainFrame;

local GlowColor = Instance.new("Frame");
GlowColor.Size = UDim2.new(1, 0, 1, 0);
GlowColor.BackgroundColor3 = (isOwner and Color3.fromRGB(255, 200, 0)) or Color3.fromRGB(119, 221, 255);
GlowColor.BackgroundTransparency = 0.95;
GlowColor.BorderSizePixel = 0;
GlowColor.ZIndex = 0;
GlowColor.Parent = GlowAmbient;

-- 如果是作者，加金色呼吸光晕
if isOwner then
	task.spawn(function()
		while ScreenGui.Parent do
			task.wait(0.1);
			pcall(function()
				GlowColor.BackgroundTransparency = 0.92 + math.sin(tick() * 2) * 0.03;
			end);
		end
	end);
end;

-- 辅助函数：创建居中文字
local function makeLabel(props)
	local lbl = Instance.new("TextLabel");
	lbl.AnchorPoint = Vector2.new(0.5, 0.5);
	lbl.BackgroundTransparency = 1;
	lbl.TextXAlignment = Enum.TextXAlignment.Center;
	lbl.TextYAlignment = Enum.TextYAlignment.Center;
	lbl.Font = Enum.Font.GothamBlack;
	lbl.TextTransparency = 1;
	for k, v in pairs(props) do
		lbl[k] = v;
	end;
	return lbl;
end;

-- 辅助函数：渐变文字（用 RichText 模拟）
local function makeGradientText(text, colors)
	-- colors: {Color3, Color3, Color3}
	local result = "";
	local chars = {};
	for i = 1, #text do
		chars[i] = text:sub(i, i);
	end;
	for i, char in ipairs(chars) do
		local t = (i - 1) / math.max(1, #chars - 1);
		local r = colors[1].R * (1-t)*(1-t) + colors[2].R * 2*(1-t)*t + colors[3].R * t*t;
		local g = colors[1].G * (1-t)*(1-t) + colors[2].G * 2*(1-t)*t + colors[3].G * t*t;
		local b = colors[1].B * (1-t)*(1-t) + colors[2].B * 2*(1-t)*t + colors[3].B * t*t;
		local cr = math.floor(r * 255);
		local cg = math.floor(g * 255);
		local cb = math.floor(b * 255);
		result = result .. string.format('<font color="#%02X%02X%02X">%s</font>', cr, cg, cb, char);
	end;
	return result;
end;

-- 中心容器
local Center = Instance.new("Frame");
Center.Size = UDim2.new(1, 0, 1, 0);
Center.BackgroundTransparency = 1;
Center.Parent = MainFrame;

-- 杨志卡
local YangZhiKa = makeLabel({
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 0, 0, 0),
	TextSize = 52,
	RichText = true,
	Visible = true,
	Parent = Center
});
YangZhiKa.Name = "YangZhiKa";

local YangAuthor = makeLabel({
	Position = UDim2.new(0.5, 0, 0.5, 35),
	Size = UDim2.new(0, 120, 0, 24),
	TextSize = 18,
	Font = Enum.Font.GothamBold,
	Text = "(作者)",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Parent = Center
});
YangAuthor.Name = "YangAuthor";

-- 杯子狗
local BeiZiGou = makeLabel({
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 0, 0, 0),
	TextSize = 52,
	RichText = true,
	Visible = false,
	Parent = Center
});
BeiZiGou.Name = "BeiZiGou";

local BeiAuthor = makeLabel({
	Position = UDim2.new(0.5, 0, 0.5, 35),
	Size = UDim2.new(0, 120, 0, 24),
	TextSize = 18,
	Font = Enum.Font.GothamBold,
	Text = "(作者)",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Visible = false,
	Parent = Center
});
BeiAuthor.Name = "BeiAuthor";

-- 加载文字
local LoadingText = makeLabel({
	Position = UDim2.new(0.5, 0, 0.72, 0),
	Size = UDim2.new(0, 300, 0, 28),
	TextSize = 16,
	Font = Enum.Font.GothamMedium,
	Text = "正在加载中...",
	TextColor3 = (isOwner and Color3.fromRGB(255, 215, 0)) or Color3.fromRGB(180, 180, 200),
	Parent = Center
});
LoadingText.Name = "LoadingText";

-- 进度条
local ProgressBg = Instance.new("Frame");
ProgressBg.Size = UDim2.new(0, 280, 0, 4);
ProgressBg.Position = UDim2.new(0.5, -140, 0.76, 0);
ProgressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60);
ProgressBg.BackgroundTransparency = 1;
ProgressBg.BorderSizePixel = 0;
ProgressBg.Parent = Center;
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(0, 2);

local ProgressFill = Instance.new("Frame");
ProgressFill.Size = UDim2.new(0, 0, 1, 0);
ProgressFill.BackgroundColor3 = (isOwner and Color3.fromRGB(255, 200, 0)) or Color3.fromRGB(100, 180, 255);
ProgressFill.BorderSizePixel = 0;
ProgressFill.Parent = ProgressBg;
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(0, 2);

-- 动态模糊辅助
local function dynamicBlur(duration, maxBlur, callback)
	local extraBlur = Instance.new("BlurEffect");
	extraBlur.Size = 0;
	extraBlur.Parent = Lighting;
	TweenService:Create(extraBlur, TweenInfo.new(duration * 0.4, Enum.EasingStyle.Quad), {Size=maxBlur}):Play();
	task.delay(duration * 0.5, function()
		TweenService:Create(extraBlur, TweenInfo.new(duration * 0.6, Enum.EasingStyle.Quad), {Size=0}):Play();
		task.delay(duration * 0.7, function()
			extraBlur:Destroy();
			if callback then callback() end;
		end);
	end);
end;

-- 淡出所有元素
local function fadeOutAll(callback)
	TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play();
	TweenService:Create(blurEffect, TweenInfo.new(0.6), {Size=0}):Play();
	
	local labels = {YangZhiKa, YangAuthor, BeiZiGou, BeiAuthor, LoadingText, ProgressBg};
	for _, lbl in ipairs(labels) do
		pcall(function()
			TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency=1, BackgroundTransparency=1}):Play();
		end);
	end;
	
	task.delay(0.7, function()
		pcall(function() ScreenGui:Destroy() end);
		pcall(function() blurEffect:Destroy() end);
		if callback then callback() end;
	end);
end;

-- ========== 动画序列 ==========
task.delay(0.5, function()
	-- 阶段1: 杨志卡从中间放大出现
	YangZhiKa.Text = makeGradientText("杨志卡", {
		Color3.fromRGB(255, 50, 150),
		Color3.fromRGB(150, 50, 255),
		Color3.fromRGB(50, 150, 255)
	});
	
	TweenService:Create(YangZhiKa, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 350, 0, 60),
		TextTransparency = 0
	}):Play();
	TweenService:Create(YangAuthor, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
		TextTransparency = 0
	}):Play();
	
	task.delay(2, function()
		-- 阶段2: 动态模糊 + 缩小消失
		dynamicBlur(0.6, 35);
		TweenService:Create(YangZhiKa, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 0, 0, 0),
			TextTransparency = 1
		}):Play();
		TweenService:Create(YangAuthor, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			TextTransparency = 1
		}):Play();
		
		task.delay(0.7, function()
			-- 阶段3: 杯子狗从中间放大出现
			BeiZiGou.Visible = true;
			BeiAuthor.Visible = true;
			BeiZiGou.Text = makeGradientText("杯子狗", {
				Color3.fromRGB(50, 255, 150),
				Color3.fromRGB(255, 150, 50),
				Color3.fromRGB(255, 50, 150)
			});
			
			TweenService:Create(BeiZiGou, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
				Size = UDim2.new(0, 350, 0, 60),
				TextTransparency = 0
			}):Play();
			TweenService:Create(BeiAuthor, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
				TextTransparency = 0
			}):Play();
			
			task.delay(2, function()
				-- 阶段4: 动态模糊 + 缩小消失
				dynamicBlur(0.6, 35);
				TweenService:Create(BeiZiGou, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					Size = UDim2.new(0, 0, 0, 0),
					TextTransparency = 1
				}):Play();
				TweenService:Create(BeiAuthor, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
					TextTransparency = 1
				}):Play();
				
				task.delay(0.7, function()
					-- 阶段5: 两个一起出现（杨志卡上，杯子狗下）
					-- 先重置位置
					YangZhiKa.Position = UDim2.new(0.5, 0, 0.42, 0);
					YangAuthor.Position = UDim2.new(0.5, 0, 0.42, 35);
					BeiZiGou.Position = UDim2.new(0.5, 0, 0.58, 0);
					BeiAuthor.Position = UDim2.new(0.5, 0, 0.58, 35);
					
					YangZhiKa.Size = UDim2.new(0, 0, 0, 0);
					YangZhiKa.TextTransparency = 1;
					YangAuthor.TextTransparency = 1;
					BeiZiGou.Size = UDim2.new(0, 0, 0, 0);
					BeiZiGou.TextTransparency = 1;
					BeiAuthor.TextTransparency = 1;
					
					YangZhiKa.Visible = true;
					YangAuthor.Visible = true;
					BeiZiGou.Visible = true;
					BeiAuthor.Visible = true;
					
					-- 动态模糊放大
					dynamicBlur(0.5, 20);
					
					TweenService:Create(YangZhiKa, TweenInfo.new(0.7, Enum.EasingStyle.Back), {
						Size = UDim2.new(0, 300, 0, 50),
						TextTransparency = 0
					}):Play();
					TweenService:Create(YangAuthor, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
						TextTransparency = 0
					}):Play();
					TweenService:Create(BeiZiGou, TweenInfo.new(0.7, Enum.EasingStyle.Back), {
						Size = UDim2.new(0, 300, 0, 50),
						TextTransparency = 0
					}):Play();
					TweenService:Create(BeiAuthor, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
						TextTransparency = 0
					}):Play();
					
					task.delay(1, function()
						-- 阶段6: 显示加载
						TweenService:Create(LoadingText, TweenInfo.new(0.4), {TextTransparency=0}):Play();
						TweenService:Create(ProgressBg, TweenInfo.new(0.4), {BackgroundTransparency=0}):Play();
						
						-- 开始加载进度
						local steps = {
							{p=0.15, d=0.5, t="正在连接服务器..."},
							{p=0.35, d=0.5, t="正在验证版本..."},
							{p=0.55, d=0.6, t="正在下载主脚本..."},
							{p=0.80, d=0.5, t="正在加载模块..."},
							{p=1.0,  d=0.4, t="准备启动..."}
						};
						
						for i, step in ipairs(steps) do
							task.delay(step.d * (i - 1) + (i > 1 and 0.1 or 0), function()
								LoadingText.Text = step.t;
								TweenService:Create(ProgressFill, TweenInfo.new(step.d, Enum.EasingStyle.Quad), {
									Size = UDim2.new(step.p, 0, 1, 0)
								}):Play();
							end);
						end;
						
						-- 加载完成后
						local totalTime = 0;
						for _, s in ipairs(steps) do totalTime = totalTime + s.d end;
						
						task.delay(totalTime + 0.3, function()
							LoadingText.Text = "启动中...";
							
							-- 如果是作者，显示金色提示
							if isOwner then
								local goldBox = Instance.new("Frame");
								goldBox.Size = UDim2.new(0, 380, 0, 90);
								goldBox.Position = UDim2.new(0.5, 0, 0.5, 0);
								goldBox.AnchorPoint = Vector2.new(0.5, 0.5);
								goldBox.BackgroundColor3 = Color3.fromRGB(30, 25, 0);
								goldBox.BackgroundTransparency = 0;
								goldBox.BorderSizePixel = 0;
								goldBox.ZIndex = 100;
								goldBox.Parent = Center;
								Instance.new("UICorner", goldBox).CornerRadius = UDim.new(0, 14);
								
								local goldBorder = Instance.new("UIStroke");
								goldBorder.Thickness = 2;
								goldBorder.Color = Color3.fromRGB(255, 200, 0);
								goldBorder.Transparency = 0;
								goldBorder.Parent = goldBox;
								
								local goldTitle = makeLabel({
									Position = UDim2.new(0.5, 0, 0.35, 0),
									Size = UDim2.new(0.9, 0, 0, 24),
									TextSize = 14,
									Font = Enum.Font.GothamBold,
									Text = "VIP OWNER",
									TextColor3 = Color3.fromRGB(255, 200, 0),
									TextTransparency = 0,
									ZIndex = 101,
									Parent = goldBox
								});
								
								local goldMsg = makeLabel({
									Position = UDim2.new(0.5, 0, 0.65, 0),
									Size = UDim2.new(0.9, 0, 0, 28),
									TextSize = 20,
									Font = Enum.Font.GothamBlack,
									RichText = true,
									Text = makeGradientText("欢迎尊贵的作者使用此脚本", {
										Color3.fromRGB(255, 200, 0),
										Color3.fromRGB(255, 255, 100),
										Color3.fromRGB(255, 200, 0)
									}),
									TextTransparency = 0,
									ZIndex = 101,
									Parent = goldBox
								});
								
								-- 金色闪烁
								task.spawn(function()
									while goldBox.Parent do
										task.wait(0.3);
										pcall(function()
											goldBorder.Color = Color3.fromRGB(255, 200 + math.sin(tick()*3)*55, 0);
										end);
									end;
								end);
								
								task.delay(2.5, function()
									TweenService:Create(goldBox, TweenInfo.new(0.5), {BackgroundTransparency=1}):Play();
									TweenService:Create(goldBorder, TweenInfo.new(0.5), {Transparency=1}):Play();
									TweenService:Create(goldTitle, TweenInfo.new(0.4), {TextTransparency=1}):Play();
									TweenService:Create(goldMsg, TweenInfo.new(0.4), {TextTransparency=1}):Play();
									task.delay(0.6, function()
										goldBox:Destroy();
										doLaunch();
									end);
								end);
							else
								task.delay(0.3, doLaunch);
							end;
						end);
					end);
				end);
			end);
		end);
	end);
end);

-- 执行主脚本
local function doLaunch()
	local success, err = pcall(function()
		local code = game:HttpGet(MAIN_URL);
		if code and #code > 100 then
			loadstring(code)();
		else
			error("获取脚本失败");
		end;
	end);
	
	if not success then
		LoadingText.Text = "启动失败: " .. tostring(err):sub(1, 25);
		LoadingText.TextColor3 = Color3.fromRGB(255, 71, 87);
		task.delay(4, function()
			fadeOutAll();
		end);
	else
		fadeOutAll();
	end;
end;
