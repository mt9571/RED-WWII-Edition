----------------------------------------------------
-- Mods Menu
----------------------------------------------------

print("-------------------------------------")
print("Loading Mods Menu...")
print("-------------------------------------")

include( "InstanceManager" );


g_InstanceManager = InstanceManager:new( "ModInstance", "Label", Controls.ModsStack );

g_FirstInitialization = true

g_NumBackground = 14 -- number of available background screens to chose from
g_DLL_MinimumVersion = 2 -- DLL minimum version to be used

g_AuthorizedModList = {
	"580c14eb-9799-4d31-8b14-c2a78931de89", -- R.E.D. WWII Edition
	"544d699d-1c84-4606-b22f-a1b009af9471", -- R.E.D. WWII Data Files
	"abb7721a-0201-4297-ae87-0de0100ec98c", -- UI - Summary Clock
	"420f5ed1-b43c-4ba5-a5f0-d463c4cda72e", -- Faster Aircraft Animations
	"57402d0e-06cb-4e71-831c-10ccd40e9572", -- R.E.D. Quick Combat
	"5739c052-e089-4c19-9f3b-73b5363d4f5c", -- Fast Moves
	"a26ba0d5-2926-4fb2-af6e-b865d69475ea", -- R.E.D. Xtrem for WWII
	"142ec258-8dba-4ac8-9101-4c475bf85351", -- LiveTuner - Icon Viewer
	"139c327c-57ec-4c30-afb1-8ca41998492d", -- LiveTuner - Texture Viewer
	"2896c6d4-0273-4527-813b-b9ab58f0b95e", -- R.E.D. DLL
	"1f0a153b-26ae-4496-a2c0-a106d9b43c95", -- UI - Promotion Tree
}

--------------------------------------------------
-- Navigation Routines (Installed,Online,Back)
--------------------------------------------------
function NavigateBack()
	ContextPtr:LookUpControl("/FrontEnd/AtlasLogo"):SetTextureAndResize( "CivilzationVAtlas.dds" ) -- restore civ5 background
	UIManager:SetUICursor( 1 );
	Modding.DeactivateMods();
	UIManager:DequeuePopup( ContextPtr );
	UIManager:SetUICursor( 0 );
end

----------------------------------------------------
-- UI Event Handlers
----------------------------------------------------
function OnSinglePlayerClick()
	--UIManager:QueuePopup( Controls.ScenarioMod, PopupPriority.ScenarioMod ); -- what's wrong here ?
	ContextPtr:LookUpControl("/FrontEnd/MainMenu/ModsEULAScreen/ModsBrowser/ModsMenu/ScenarioMod/"):SetHide(false) -- even if in VFS, the context is ModsMenu ?
	
	Controls.ModsMenuGrid:SetHide(true)
end
Controls.SinglePlayerButton:RegisterCallback(Mouse.eLClick, OnSinglePlayerClick);
----------------------------------------------------
function OnLoadSingleGameButtonClick()
	--UIManager:QueuePopup( Controls.SingleLoadScreen, PopupPriority.SingleLoadScreen );
	ContextPtr:LookUpControl("/FrontEnd/MainMenu/ModsEULAScreen/ModsBrowser/ModsMenu/SingleLoadScreen/"):SetHide(false)
	Controls.ModsMenuGrid:SetHide(true)
end
Controls.LoadSingleGameButton:RegisterCallback(Mouse.eLClick, OnLoadSingleGameButtonClick);
----------------------------------------------------------------------
----------------------------------------------------
function OnLoadHotseatGameButtonClick()
	--UIManager:QueuePopup( Controls.SingleLoadScreen, PopupPriority.SingleLoadScreen );
	ContextPtr:LookUpControl("/FrontEnd/MainMenu/ModsEULAScreen/ModsBrowser/ModsMenu/HotSeatLoadScreen/"):SetHide(false)
	Controls.ModsMenuGrid:SetHide(true)
end
Controls.LoadHotseatGameButton:RegisterCallback(Mouse.eLClick, OnLoadHotseatGameButtonClick);
----------------------------------------------------------------------
----------------------------------------------------
function OnMultiPlayerClick()
	UIManager:QueuePopup( Controls.ModMultiplayerSelectScreen, PopupPriority.ModMultiplayerSelectScreen );
end
Controls.MultiPlayerButton:RegisterCallback(Mouse.eLClick, OnMultiPlayerClick);
----------------------------------------------------------------------
Controls.BackButton:RegisterCallback(Mouse.eLClick, NavigateBack);


--------------------------------------------------
-- Show/Hide Handler
--------------------------------------------------
ContextPtr:SetShowHideHandler(function(isHiding)
	if(not isHiding) then

		Initialize()

		local supportsSinglePlayer = Modding.AllEnabledModsContainPropertyValue("SupportsSinglePlayer", 1);
		local supportsMultiplayer = Modding.AllEnabledModsContainPropertyValue("SupportsMultiplayer", 1);
		
		--Controls.SinglePlayerButton:SetDisabled(not supportsSinglePlayer);
		--Controls.MultiPlayerButton:SetDisabled(not supportsMultiplayer);
		
		--if(supportsSinglePlayer and not supportsMultiplayer) then
			--OnSinglePlayerClick();
		--elseif(supportsMultiplayer and not supportsSinglePlayer) then
			--OnMultiPlayerClick();
		--end
		
		g_InstanceManager:ResetInstances();
		
		local mods = Modding.GetEnabledModsByActivationOrder();
		
		if(#mods == 0) then
			Controls.ModsInUseLabel:SetHide(true);
		else
			Controls.ModsInUseLabel:SetHide(false);
			for i,v in ipairs(mods) do
				local displayName = Modding.GetModProperty(v.ModID, v.Version, "Name");
				local displayNameVersion = string.format("[ICON_BULLET] %s (v. %i)", displayName, v.Version);			
				local listing = g_InstanceManager:GetInstance();
				listing.Label:SetText(displayNameVersion);
				listing.Label:SetToolTipString(displayNameVersion);
			end
		end
	end
end);

--------------------------------------------------
-- Input Handler
--------------------------------------------------
ContextPtr:SetInputHandler( function(uiMsg, wParam, lParam)

	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_ESCAPE then
			NavigateBack();
		end
	end

	return true;
end);

Controls.MultiPlayerButton:SetHide(true);


function Initialize()

	local bNeedUpdate = false
	
	--print("- Set Quick Combat Option to false...")
	--PreGame.SetGameOption("GAMEOPTION_QUICK_COMBAT", false)
	
	print("- Initializing WWII background...")

	local randNum = math.random(1, g_NumBackground)
	local background = "Background_" .. tostring(randNum) .. ".dds"
	
	print("- Set texture to " .. background)

	ContextPtr:LookUpControl("/FrontEnd/AtlasLogo"):SetTextureAndResize( background )
	ContextPtr:LookUpControl("/FrontEnd/MainMenu/Civ5Logo"):SetTextureAndResize( "RED_WWII_Logo.dds" )
	ContextPtr:LookUpControl("/FrontEnd/MainMenu/ModsEULAScreen/ModsBrowser/ModsMenu/Civ5Logo"):SetTextureAndResize( "RED_WWII_Logo.dds" )
	--ContextPtr:LookUpControl("/FrontEnd/MainMenu/ModsEULAScreen/ModsBrowser/ModsMenu/ModdingSinglePlayer/Civ5Logo"):SetTextureAndResize( "RED_WWII_Logo.dds" )
	
	--Controls.SinglePlayerButton:SetText("START R.E.D. WWII")

	print("-------------------------------------")
	print("Check DLC compatibility list...")
	print("-------------------------------------")

	local ExpansionID = "0E3751A1-F840-4e1b-9706-519BF484E59D" -- G&K ID
	local MongolDlcID = "293C1EE3-1176-44f6-AC1F-59663826DE74" -- Mongol DLC ID

	local bExpansionActive = ContentManager.IsActive(ExpansionID, ContentType.GAMEPLAY)
	local bMongolDlcActive = ContentManager.IsActive(MongolDlcID, ContentType.GAMEPLAY)
	local bUnauthorizedModActive = false

	local packages = {}

	--[[
	if bExpansionActive then
		print ("- G&K Expansion active, marked for deactivation...")
		table.insert(packages, {ExpansionID, ContentType.GAMEPLAY, false})
	else
		print ("- G&K Expansion not active...")		
	end
	
	if not bMongolDlcActive then
		print ("- Mongol DLC inactive, marked for activation...")
		table.insert(packages, {MongolDlcID, ContentType.GAMEPLAY, true})
	else
		print ("- Mongol DLC is active...")		
	end
	--]]
	
	print("-------------------------------------")
	print("Check Mods compatibility list...")
	print("-------------------------------------")	

	-- list mods
	print("Active mods :")
	local unsortedInstalledMods = Modding.GetInstalledMods()
	for key, modInfo in pairs(unsortedInstalledMods) do
		if modInfo.Enabled then
			if (modInfo.Name) then
				-- Don't allow another mod to be activated, let's help clean debugging
				if not IsModAuthorized ( modInfo.ID ) then 				
					print (" - " .. modInfo.Name .. " (v." .. modInfo.Version ..") : Not authorised, marked for deactivation...")
					Modding.DisableMod(modInfo.ID, modInfo.Version)
					bUnauthorizedModActive = true
				else				
					print (" - " .. modInfo.Name .. " (v." .. modInfo.Version ..")")
				end
			end
		end
	end
	if g_FirstInitialization then
		print("")
		print("Deactivated mods :")
		local unsortedInstalledMods = Modding.GetInstalledMods()
		for key, modInfo in pairs(unsortedInstalledMods) do
			if not (modInfo.Enabled) then
				if (modInfo.Name) then
					print (" - " .. modInfo.Name .. " (v." .. modInfo.Version ..")")
				end
			end
		end			
	end

	bNeedUpdate = bExpansionActive or (not bMongolDlcActive) or bUnauthorizedModActive

	if bNeedUpdate then
		
		print("-------------------------------------")
		print("Update of Mods/DLC state is needed")
		print("-------------------------------------")
		UIManager:SetUICursor(1)
		--print("- Activate/Deactivate DLC...")
		--ContentManager.SetActive(packages)
		print("- Activate/Deactivate MODs...")
		Modding.ActivateEnabledMods()
		--[[
		print("- Deactivate/Activate R.E.D.WWII for DLL...")
		local REDversion = Modding.GetActivatedModVersion("580c14eb-9799-4d31-8b14-c2a78931de89")
		Modding.DisableMod("580c14eb-9799-4d31-8b14-c2a78931de89", REDversion)
		Modding.ActivateEnabledMods()
		Modding.EnableMod("580c14eb-9799-4d31-8b14-c2a78931de89", REDversion)
		Modding.ActivateEnabledMods()
		--]]
		UIManager:SetUICursor(0)	

	end

	if not GameDefines.DLL_RED_VANILLA then
		print("ERROR: Custom DLL not found !")
		local title = "[COLOR_RED]Error: R.E.D. DLL is not active ![ENDCOLOR][NEWLINE]Launch buttons have been disabled.[NEWLINE]Please see installation instructions."
		Controls.WarningTitle:SetText(title)
		Controls.WarningGrid:SetHide(false)
		--UI.AddPopup(popupInfo)
		Controls.LoadSingleGameButton:SetDisabled(true)
		Controls.LoadHotseatGameButton:SetDisabled(true)
		Controls.SinglePlayerButton:SetDisabled(true)
	else
		if GameDefines.DLL_RED_VANILLA < g_DLL_MinimumVersion then
			print("ERROR: RED DLL deprecated !")
			local title = "[COLOR_RED]Error: obsolete R.E.D. DLL ![ENDCOLOR][NEWLINE]Launch buttons have been disabled.[NEWLINE]Please install the latest version."
			Controls.WarningTitle:SetText(title)
			Controls.WarningGrid:SetHide(false)
			--UI.AddPopup(popupInfo)
			Controls.LoadSingleGameButton:SetDisabled(true)
			Controls.LoadHotseatGameButton:SetDisabled(true)
			Controls.SinglePlayerButton:SetDisabled(true)
		else
			Controls.WarningGrid:SetHide(true)
		end
	end

	print("-------------------------------------")
	g_FirstInitialization = false
end

function IsModAuthorized (id)
	local bCheck = false
	for i, modID in pairs(g_AuthorizedModList) do
		if id == modID then
			bCheck = true
		end
	end
	return bCheck
end