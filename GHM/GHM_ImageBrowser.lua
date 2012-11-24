local count = 1;
local menuFrame
function GHM_ImageBrowser()
	local miscApi = GHI_MiscAPI().GetAPI();
	local loc = GHI_Loc()
if not (GHM_IMGLIST) then
		GHM_LoadImageList()
	end
if not (GHM_IMGCATLIST) then
		GHM_GetImageCat()
	end
if menuFrame then
	menuFrame:Show()
	return
end
	local imgCat
	local previewFrame, previewImage
	local selectedImage,selectedIndex -- Path of selected image
	local OnOkCallback
	


	local t = {
	  {
		 {
			{
			  type = "Dummy",
			  align = "c",
			  height = 10,
			  width = 600,
			},
		},
		{
		  {
			  type = "Dummy",
			  align = "7",
			  height = 256,
			  width = 192,
			  label = "ListAnchor",
		  },
		  {
			type = "ImageList",
			align = "c",
			height = 256,
			width = 256,
			scaleX = 1.3,
			scaleY = 1.3,
			label = "image",
			xOff = 0,
			OnSelect = function(self, path)
				selectedImage,selectedIndex = menuFrame.GetLabel("image");
				previewImage:SetTexture(menuFrame.GetLabel("image"))

			end,
		  },
		  {
			  type = "Dummy",
			  align = "r",
			  height = 256,
			  width = 256,
			  label = "preview",
		  },
		},
		{
			{
			  type = "Dummy",
			  align = "c",
			  height = 10,
			  width = 600,
			},
		},
		{
			{
				type = "Button",
				text = OKAY,
				align = "r",
				label = "ok",
				compact = false,
				OnClick = function()
						if OnOkCallback then
							OnOkCallback(selectedImage);
						end
						print(selectedImage,selectedIndex)
					menuFrame:Hide()
				end,
			},
			{
				type = "Button",
				text = CANCEL,
				align = "r",
				label = "cancel",
				compact = false,
				OnClick = function(obj)
					menuFrame:Hide()
					local list = menuFrame.GetLabelFrame("image")
					list.Clear()
				end,
			},
		}
	  },
	  
	  background = "Interface\\FrameGeneral\\UI-Background-Rock",
	  title = "Image Browser",
	  name = "GHM_ImagePicker"..count,
	  theme = "BlankTheme",
	  height = 320,
	  width = 800,
	  useWindow = true,
	}
	count = count + 1;
	menuFrame = GHM_NewFrame("ImageBrowser", t);
		
	-- Preview Frame
	local previewBackdrop = {
		bgFile = "Interface\\Tooltips\\ChatBubble-Background",
		edgeFile = "Interface\\Tooltips\\ChatBubble-Backdrop",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = {left = 32, right = 32, top = 32, bottom = 32}
	}
	local previewAnchor = menuFrame.GetLabelFrame("preview")
	local previewFrame = CreateFrame("Frame",menuFrame:GetName().."Preview",menuFrame)
	previewFrame:SetSize(275,275)
	previewFrame:SetPoint("CENTER",previewAnchor,"CENTER")
	previewFrame:SetBackdrop(previewBackdrop)
	previewImage = previewFrame:CreateTexture()
	previewImage:SetParent(previewFrame)
	previewImage:SetPoint("CENTER",previewFrame,"CENTER")
	previewImage:SetSize(256,256)				
	previewImage:SetTexture("")
	
	-- List View
	local scroll = CreateFrame("ScrollFrame","$parentScroll",menuFrame,"GHM_ScrollFrameTemplate")
	scroll:SetSize(128,192)
	scroll:SetAllPoints(menuFrame.GetLabelFrame("ListAnchor"))
		
	local tree = CreateFrame("Frame", scroll:GetName() .. "TreeView", scroll, "GHM_TreeView_Template");
	tree:SetHeight(512)
	tree:SetWidth(192)
	tree:SetAllPoints();
	scroll:SetScrollChild(tree)
	
		-- List View Scripts
	local OnExpand;

	local InsertNode = function(pTree, index, text, nodeValue, tableValue)
		local subTree
		if pTree.Elements and pTree.Elements[index] then
			subTree = pTree.Elements[index];
			subTree.Value = nodeValue;
			subTree.Title.Text:SetText(text);
		else
			subTree = pTree:AddNode(text, nodeValue, pTree:GetWidth() - 15, 15)
			subTree:AddScript("OnExpand", OnExpand);
		end

		subTree:SetMargins(15, 0);
		subTree.tableValue = tableValue;
		if (type(tableValue) == "table") then
			if #(subTree.Elements or {}) == 0 then
				local dummyNode = subTree:AddNode("dummy", "dummy", subTree:GetWidth() - 15, 15);
				dummyNode:AddScript("OnExpand", OnExpand);
			end
		end
		pTree.Elements[index]:Show();
	end

	local function pairsByKeys(t, f)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0 -- iterator variable
		local iter = function() -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
		return iter
	end
	
	local StringContainsKeyword = function(str)
		local keywords = scroll.keywords or {};
		for _, keyword in pairs(keywords) do
			if not (string.find(string.lower(str), string.lower(keyword))) then
				return false;
			end
		end
		return true;
	end
	
	local TableContainsKeyword;
	TableContainsKeyword = function(pTree, index, tableValue)
		if pTree and pTree.Value then
			index = string.join("", unpack(pTree:GetFullPath())) .. index;
		end
		if index and (StringContainsKeyword(index)) then     -- the whole subtable is okay
			return true;
		end

		if tableValue then
			for i, v in pairs(tableValue) do
				if (StringContainsKeyword(index..i)) then
					return true;
				elseif (type(v) == "table") then
					if TableContainsKeyword(nil, index .. i, v) then
						return true;
					end
				end
			end
		end
		return false;
	end


	OnExpand = function(pTree)
		if not (pTree.refreshing == true) and type(pTree.tableValue) == "table" then
			local i = 1;
			for index, value in pairsByKeys(pTree.tableValue) do
				local name = string.gsub(index, "[\\_]", "");
				name = string.gsub(name, ".mp3", "")
				if type(value) == "table" then
					InsertNode(pTree, i, name, index, value);

					if TableContainsKeyword(pTree, index, value) then
						pTree.Elements[i]:Show();
					else
						pTree.Elements[i]:Hide();
					end

					i = i + 1;
			
				end
			end
			for index, value in pairsByKeys(pTree.tableValue) do
				if type(value) == "string" then
				local name = value;
					InsertNode(pTree, i, name, index, value);
				end
					i = i + 1;
			end
			while pTree.Elements[i] do
				pTree.Elements[i]:Hide();
				i = i + 1;
			end

			pTree.refreshing = true;
			if pTree.Collapse and pTree.Expand then

				pTree:Collapse();
				pTree:Expand();
			end
			pTree:SkipAllHidden()
			pTree.refreshing = false;
		end
	end

	tree.tableValue = GHM_IMGCATLIST;
	local loaded = false;
	tree:SetScript("OnShow", function()
		tree:SetWidth(scroll:GetWidth() - 20);
		OnExpand(tree);
	end)

	tree:AddScript("OnSelectionChange", function(node)
		local cata = node.tableValue
		if type(cata) == "table" then
			return
		else
			local list = GHM_IMGLIST[cata]
			menuFrame.GetLabelFrame("image").SetImages(list)
		end
	end);



	-- end list view scripts
	
	
	scroll.treeView = tree;
	menuFrame.treeView = tree;	

	menuFrame.Show()
	
	menuFrame.New = function(_OnOkCallback)
		OnOkCallback = _OnOkCallback;
		menuFrame:Show();
		inUse = true;
	end
		
	menuFrame.IsInUse = function()
		 return inUse;
	end
--menuFrame:Hide();
end