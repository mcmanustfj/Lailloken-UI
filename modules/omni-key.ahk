﻿Omnikey:
clipboard := ""
ThisHotkey_copy := StrReplace(A_ThisHotkey, "~")
ThisHotkey_copy := StrReplace(ThisHotkey_copy, "*")
If (alt_modifier != "")
	SendInput {%alt_modifier% down}^{c}{%alt_modifier% up}
Else SendInput !^{c}
ClipWait, 0.05
If (clipboard != "")
{
	start := A_TickCount
	If WinExist("ahk_id " hwnd_itemchecker) && !InStr(Clipboard, "item class: maps") && !InStr(Clipboard, "orb of horizon") && !InStr(Clipboard, "rarity: gem")
	{
		LLK_ItemCheck()
		Return
	}
	While GetKeyState(ThisHotkey_copy, "P") && !InStr(Clipboard, "item class: maps") && !InStr(Clipboard, "orb of horizon") && !InStr(Clipboard, "rarity: gem")
	{
		If (A_TickCount >= start + 200)
		{
			LLK_ItemCheck()
			KeyWait, % ThisHotkey_copy
			Return
		}
	}
	If WinExist("ahk_id " hwnd_gem_notes) && InStr(Clipboard, "rarity: gem")
	{
		If !LLK_LevelGuideGemNote()
			LLK_ToolTip("no notes")
		Return
	}
	While enable_leveling_guide && GetKeyState(ThisHotkey_copy, "P") && InStr(Clipboard, "rarity: gem")
	{
		If (A_TickCount >= start + 200)
		{
			If !LLK_LevelGuideGemNote()
				LLK_ToolTip("no notes")
			KeyWait, % ThisHotkey_copy
			Return
		}
	}
	If WinExist("ahk_id " hwnd_gear_tracker)
	{
		If !InStr(clipboard, "requirements:`r`nlevel:")
		{
			LLK_ToolTip("no lvl requirement")
			Return
		}
		If InStr(clipboard, "unidentified")
		{
			LLK_ToolTip("not identified")
			Return
		}
		Loop, Parse, clipboard, `n, `r
		{
			If InStr(A_Loopfield, "class")
			{
				class := StrReplace(A_Loopfield, "item class: ")
				class := (!InStr(class, "boots") && !InStr(class, "gloves")) ? SubStr(class, InStr(class, " ",,, LLK_InStrCount(class, " ")) +1, -1) : SubStr(class, InStr(class, " ",,, LLK_InStrCount(class, " ")) +1)
			}
			If (A_Index = 3)
			{
				name := StrReplace(A_Loopfield, "`r")
				break
			}
		}
		IniRead, gear_tracker_items, ini\leveling tracker.ini, gear,, % A_Space
		If InStr(gear_tracker_items, name)
		{
			LLK_ToolTip("already added")
			Return
		}
		required_level := SubStr(clipboard, InStr(clipboard, "requirements:`r`nlevel:"))
		required_level := StrReplace(required_level, "requirements:`r`nlevel: ")
		required_level := StrReplace(required_level, " (unmet)")
		required_level := SubStr(required_level, 1, InStr(required_level, "`r`n") - 1)
		required_level := (StrLen(required_level) = 1) ? 0 required_level : required_level
		If (required_level <= gear_tracker_characters[gear_tracker_char])
		{
			LLK_ToolTip("already equippable")
			Return
		}
		update_gear_tracker := 1
		IniWrite, % (InStr(clipboard, "rarity: rare") || InStr(clipboard, "rarity: magic")) ? "(" required_level ") " class ": " name : "(" required_level ") " name, ini\leveling tracker.ini, gear
		GoSub, Leveling_guide_gear
		Return
	}
	
	Loop, Parse, clipboard, `n, `n
	{
		If InStr(A_LoopField, "item class:")
		{
			item_class := StrReplace(A_LoopField, "item class:")
			item_class := StrReplace(item_class, "`r")
			break
		}
	}
	start := A_TickCount
	If InStr(clipboard, "recombinator") || InStr(clipboard, "power core")
	{
		recomb_item1 := "sample item`nclass x:`n`n`n`n`n`n`n`n"
		recomb_item2 := "sample item`nclass x:`n`n`n`n`n`n`n`n"
		GoSub, Recombinators_add2
		Return
	}
	If InStr(clipboard, "limited to: 1 historic") && WinExist("ahk_id " hwnd_legion_window)
	{
		GoSub, Legion_seeds_parse
		Return
	}
	If WinExist("ahk_id " hwnd_recombinator_window)
	{
		GoSub, Recombinators_add
		Return
	}
	If !InStr(clipboard, "Rarity: Currency") && !InStr(clipboard, "Item Class: Map") && !InStr(clipboard, "Heist") && !InStr(clipboard, "Item Class: Expedition") && !InStr(clipboard, "Item Class: Stackable Currency") || InStr(clipboard, "to the goddess") || InStr(clipboard, "other oils")
	{
		GoSub, Omnikey_context_menu
		Return
	}
	If InStr(clipboard, "Orb of Horizons")
	{
		While GetKeyState(ThisHotkey_copy, "P")
		{
			If (A_TickCount >= start + 200)
			{
				horizon_toggle := 1
				LLK_Omnikey_ToolTip(maps_a)
				KeyWait, %ThisHotkey_copy%
				horizon_toggle := 0
				LLK_Omnikey_ToolTip()
				Return
			}
		}
	}
	If InStr(clipboard, "Item Class: Map") && !InStr(clipboard, "Fragment")
	{
		start := A_TickCount
		While GetKeyState(ThisHotkey_copy, "P")
		{
			If (A_TickCount >= start + 200)
			{
				Loop, Parse, Clipboard, `r`n, `r`n
				{
					If InStr(A_Loopfield, "Map Tier: ")
					{
						parse_tier := StrReplace(A_Loopfield, "Map Tier: ")
						Break
					}
				}
				If InStr(clipboard, "maze of the minotaur") || InStr(clipboard, "forge of the phoenix") || InStr(clipboard, "lair of the hydra") || InStr(clipboard, "pit of the chimera")
					LLK_Omnikey_ToolTip("horizons:maze of the minotaur`nforge of the phoenix`nlair of the hydra`npit of the chimera" )
				Else LLK_Omnikey_ToolTip("horizons:" maps_tier%parse_tier%)
				KeyWait, %ThisHotkey_copy%
				LLK_Omnikey_ToolTip()
				Return
			}
		}
		If InStr(clipboard, "Unidentified") || InStr(clipboard, "Rarity: Normal") || InStr(clipboard, "Rarity: Unique")
		{
			LLK_ToolTip("not supported:`nnormal, unique, un-ID")
			Return
		}
		If (pixel_gamescreen_color1 = "ERROR") || (pixel_gamescreen_color1 = "")
		{
			LLK_ToolTip("pixel-check setup required")
			Return
		}
		If !LLK_itemInfoCheck()
			Return
		Gui, map_info_menu: Destroy
		hwnd_map_info_menu := ""
		GoSub, Map_info
		Return
	}
}
Else GoSub, Omnikey2
Return

Omnikey2:
If WinExist("ahk_id " hwnd_delve_grid)
{
	If (delve_enable_recognition = 1)
		GoSub, Delve_scan
	Return
}
Clipboard := ""
ThisHotkey_copy := StrReplace(A_ThisHotkey, "~")
ThisHotkey_copy := StrReplace(ThisHotkey_copy, "*")
If (enable_pixelchecks = 0 || pixelchecks_enabled = "")
	LLK_PixelSearch("gamescreen")

If (clipboard = "") && (gamescreen = 0)
{
	LLK_ImageSearch()
	If (disable_imagecheck_bestiary = 0) && (bestiary = 1)
		GoSub, Bestiary_search
	If (disable_imagecheck_gwennen = 0) && (gwennen = 1)
	{
		stash_search_type := "gwennen"
		GoSub, Stash_search
	}
	If (disable_imagecheck_betrayal = 0) && (betrayal = 1)
		GoSub, Betrayal_search
	If (disable_imagecheck_sanctum = 0) && (sanctum = 1)
		GoSub, Sanctum
	If (disable_imagecheck_stash = 0) && (stash = 1)
	{
		stash_search_type := "stash"
		GoSub, Stash_search
	}
	If (disable_imagecheck_vendor = 0) && (vendor = 1)
	{
		stash_search_type := "vendor"
		GoSub, Stash_search
	}
}
Return

Omnikey_context_menu:
Gui, context_menu: New, -Caption +LastFound +AlwaysOnTop +ToolWindow +Border HWNDhwnd_context_menu
Gui, context_menu: Margin, 4, 2
Gui, context_menu: Color, Black
WinSet, Transparent, %trans%
Gui, context_menu: Font, s%fSize0% cWhite, Fontin SmallCaps

If InStr(clipboard, "Rarity: Unique") || InStr(clipboard, "Rarity: Gem") || InStr(clipboard, "Class: Quest") || InStr(clipboard, "Rarity: Divination Card")
	Gui, context_menu: Add, Text, vwiki_exact gOmnikey_menu_selection BackgroundTrans Center, wiki (exact item)
Else If InStr(clipboard, "to the goddess")
{
	Gui, context_menu: Add, Text, vwiki_exact gOmnikey_menu_selection BackgroundTrans Center, wiki (exact item)
	Gui, context_menu: Add, Text, vlab_layout gOmnikey_menu_selection BackgroundTrans Center, lab info
}
Else If InStr(clipboard, "other oils")
{
	Gui, context_menu: Add, Text, vOil_wiki gOmnikey_menu_selection BackgroundTrans Center, wiki (item class)
	Gui, context_menu: Add, Text, vOil_table gOmnikey_menu_selection BackgroundTrans Center, anoint table
}
Else If InStr(clipboard, "cluster jewel")
{
	If !LLK_itemInfoCheck()
		Return
	If InStr(clipboard, "small cluster")
		cluster_type := "Small"
	Else cluster_type := InStr(clipboard, "medium cluster") ? "Medium" : "Large"
	StringLower, cluster_type1, cluster_type
	Gui, context_menu: Add, Text, vcrafting_table_all_cluster gOmnikey_menu_selection BackgroundTrans Center, crafting table: all
	Gui, context_menu: Add, Text, vcrafting_table_%cluster_type%_cluster gOmnikey_menu_selection BackgroundTrans Center, crafting table: %cluster_type1%
	Gui, context_menu: Add, Text, vcraft_of_exile gOmnikey_menu_selection BackgroundTrans Center, craft of exile
	Gui, context_menu: Add, Text, vwiki_class gOmnikey_menu_selection BackgroundTrans Center, wiki (item class)
}
Else
{
	If !LLK_itemInfoCheck()
		Return
	Gui, context_menu: Add, Text, vcrafting_table gOmnikey_menu_selection BackgroundTrans Center, crafting table
	If !InStr(Clipboard, "`nUnidentified", 1)
		Gui, context_menu: Add, Text, vcraft_of_exile gOmnikey_menu_selection BackgroundTrans Center, craft of exile
	Gui, context_menu: Add, Text, vwiki_class gOmnikey_menu_selection BackgroundTrans Center, wiki (item class)
}

If InStr(clipboard, "limited to: 1 historic")
{
	If !LLK_itemInfoCheck()
		Return
	Gui, context_menu: Add, Text, vlegion_seed_explore gOmnikey_menu_selection BackgroundTrans Center, explore seed
}

If InStr(clipboard, "Sockets: ") && !InStr(clipboard, "Class: Ring") && !InStr(clipboard, "Class: Amulet") && !InStr(clipboard, "Class: Belt")
	Gui, context_menu: Add, Text, vchrome_calc gOmnikey_menu_selection BackgroundTrans Center, chromatics

Loop, Parse, allowed_recomb_classes, `,, `,
	If InStr(item_class, A_Loopfield) && !InStr(clipboard, "rarity: unique") && !InStr(clipboard, "unidentified")
	{
		If !LLK_itemInfoCheck()
			Return
		Gui, context_menu: Add, Text, gRecombinators_add BackgroundTrans Center, recombinator
		break
	}
MouseGetPos, mouseX, mouseY
Gui, context_menu: Show, % "Hide x"mouseX " y"mouseY
WinGetPos, x_context,, w_context
Gui, context_menu: Show, % "Hide x"mouseX - w_context " y"mouseY
WinGetPos, x_context,, w_context
If (x_context < xScreenOffset)
	Gui, context_menu: Show, x%xScreenOffset% y%mouseY%
Else Gui, context_menu: Show, % "x"mouseX - w_context " y"mouseY
WinWaitActive, ahk_group poe_window
If WinExist("ahk_id " hwnd_context_menu)
	Gui, context_menu: destroy
Return

Omnikey_craft_chrome:
attribute0 := ""
attribute := ""
strength := ""
dexterity := ""
intelligence := ""
wiki_level := ""
If (A_GuiControl = "craft_of_exile")
{
	Run, https://www.craftofexile.com/
	Return
}
Loop, Parse, clipboard, `r`n, `r`n
{
	If (A_Index=1)
	{
		wiki_term := StrReplace(A_LoopField, "Item Class: ")
		class := wiki_term
		wiki_term := StrReplace(wiki_term, A_Space, "_")
		If InStr(clipboard, "runic") && InStr(clipboard, "ward:")
		{
			If (class = "gloves")
				wiki_term := "Runic_Gauntlets"
			Else wiki_term := (class = "helmets") ? "Runic_Crown" : "Runic_Sabatons"
		}
	}
	If InStr(A_LoopField, "Str: ")
	{
		strength := StrReplace(A_LoopField, "Str: ")
		strength := StrReplace(strength, " (augmented)")
		strength := StrReplace(strength, " (unmet)")
	}
	Else If InStr(A_LoopField, "Strength: ")
	{
		strength := StrReplace(A_LoopField, "Strength: ")
		strength := StrReplace(strength, " (augmented)")
		strength := StrReplace(strength, " (unmet)")
	}
	Else strength := (strength="") ? 0 : strength
	If InStr(A_LoopField, "Dex: ")
	{
		dexterity := StrReplace(A_LoopField, "Dex: ")
		dexterity := StrReplace(dexterity, " (augmented)")
		dexterity := StrReplace(dexterity, " (unmet)")
	}
	Else If InStr(A_LoopField, "Dexterity: ")
	{
		dexterity := StrReplace(A_LoopField, "Dexterity: ")
		dexterity := StrReplace(dexterity, " (augmented)")
		dexterity := StrReplace(dexterity, " (unmet)")
	}
	Else dexterity := (dexterity="") ? 0 : dexterity
	If InStr(A_LoopField, "Int: ")
	{
		intelligence := StrReplace(A_LoopField, "Int: ")
		intelligence := StrReplace(intelligence, " (augmented)")
		intelligence := StrReplace(intelligence, " (unmet)")
	}
	If InStr(A_LoopField, "Intelligence: ")
	{
		intelligence := StrReplace(A_LoopField, "Intelligence: ")
		intelligence := StrReplace(intelligence, " (augmented)")
		intelligence := StrReplace(intelligence, " (unmet)")
	}
	Else	intelligence := (intelligence="") ? 0 : intelligence
	If InStr(A_LoopField, "Item Level: ")
	{
		wiki_level := SubStr(A_LoopField, InStr(A_LoopField, ":")+1)
		wiki_level := StrReplace(wiki_level, " ")
	}
	If InStr(A_LoopField, "Added Small Passive Skills grant: ")
	{
		wiki_cluster := SubStr(A_LoopField, 35)
		wiki_cluster := StrReplace(wiki_cluster, "+")
	}
}
If (class="Gloves") || (class="Boots") || (class="Body Armours") || (class="Helmets") || (class="Shields")
{
	If InStr(clipboard, "Armour: ")
		attribute := "_str"
	If InStr(clipboard, "Evasion Rating: ")
		attribute := (attribute="") ? "_dex" : attribute "_dex"
	If InStr(clipboard, "Energy Shield: ")
		attribute := (attribute="") ? "_int" : attribute "_int"
}
If InStr(A_GuiControl, "crafting_table")
{
	If InStr(clipboard, "unset ring")
		wiki_term := "Unset_Ring"
	If InStr(clipboard, "iron flask")
		wiki_term := "Iron_Flask"
	If InStr(clipboard, "convoking wand")
		wiki_term := "Convoking_Wand"
	If InStr(clipboard, "silver flask")
		wiki_term := "Silver_Flask"
	If InStr(clipboard, "crimson jewel")
		wiki_term := "Crimson_Jewel"
	If InStr(clipboard, "viridian jewel")
		wiki_term := "Viridian_Jewel"
	If InStr(clipboard, "cobalt jewel")
		wiki_term := "Cobalt_Jewel"
	If InStr(wiki_term, "abyss_jewel")
	{
		wiki_index := InStr(clipboard, "rarity: normal") ? 3 : 4
		Loop, Parse, clipboard, `n, `n
		{
			If (A_Index = wiki_index)
				wiki_term := StrReplace(A_Loopfield, " ", "_")
			If InStr(A_Loopfield, "item level: ")
			{
				clipboard := StrReplace(A_Loopfield, "item level: ")
				break
			}
		}
		Run, https://poedb.tw/us/%wiki_term%
		Return
	}
	If InStr(clipboard, "Cluster Jewel")
	{
		If (A_GuiControl = "crafting_table_all_cluster")
			Run, https://poedb.tw/us/Cluster_Jewel#EnchantmentModifiers
		Else Run, https://poedb.tw/us/%cluster_type%_Cluster_Jewel#%cluster_type%ClusterJewelEnchantmentModifiers
		wiki_cluster := SubStr(wiki_cluster, 1, InStr(wiki_cluster, "(")-2)
		If (enable_browser_features = 1) && (A_GuiControl = "crafting_table_all_cluster")
		{
			ToolTip, % "Press F3 to highlight the jewel's enchant/type", % xScreenOffset + poe_width//2, yScreenOffset + poe_height//2, 15
			SetTimer, Timeout_cluster_jewels
		}
	}
	Else If (InStr(clipboard, "runic") && InStr(Clipboard, "ward:"))
		Run, https://poedb.tw/us/%wiki_term%#ModifiersCalc
	Else Run, https://poedb.tw/us/%wiki_term%%attribute%#ModifiersCalc
	clipboard := wiki_level
}
If (A_GuiControl = "chrome_calc")
{
	Run, https://siveran.github.io/calc.html
	If (enable_browser_features = 1)
	{
		ToolTip, Click into the str field and press`nCTRL-V to paste stat requirements, % xScreenOffset + poe_width//2, yScreenOffset + poe_height//2, 15
		clipboard := ""
		SetTimer, Timeout_chromatics
	}
}
Return

Omnikey_menu_selection:
If (A_GuiControl = "chrome_calc") || InStr(A_GuiControl, "crafting_table") || InStr(A_GuiControl, "craft_of_exile")
	GoSub, Omnikey_craft_chrome
Else If (A_GuiControl = "oil_wiki")
	Run, https://www.poewiki.net/wiki/Oil
Else If (A_GuiControl = "oil_table")
	Run, https://blight.raelys.com/
Else If InStr(A_GuiControl, "wiki")
	GoSub, Omnikey_wiki
Else If InStr(A_GuiControl, "layout")
	GoSub, Lab_info
Else If (A_GuiControl = "legion_seed_explore")
	GoSub, Legion_seeds_parse
KeyWait, LButton
Gui, context_menu: destroy
Return

Omnikey_wiki:
If (A_GuiControl = "wiki_exact")
	wiki_index := 3
If (A_GuiControl = "wiki_class")
	wiki_index := 1
Loop, Parse, clipboard, `n, `n 
{
	If (A_Index=wiki_index)
	{
		wiki_term := StrReplace(A_LoopField, "Item Class: ")
		wiki_term := (InStr(wiki_term, "Body")) ? "Body armour" : wiki_term
		wiki_term := StrReplace(wiki_term, A_Space, "_")
		wiki_term := StrReplace(wiki_term, "'", "%27")
		wiki_term := InStr(wiki_term, "abyss_jewel") ? "abyss_jewel" : wiki_term
		break
	}
}
If InStr(clipboard, "Cluster Jewel")
	wiki_term := "Cluster_Jewel"
If (InStr(clipboard, "runic") && InStr(clipboard, "ward:"))
	Run, https://www.poewiki.net/wiki/Runic_base_type#%wiki_term%
Else Run, https://poewiki.net/wiki/%wiki_term%
Return

Init_omnikey:
IniRead, omnikey_hotkey, ini\config.ini, Settings, omni-hotkey, % A_Space
IniRead, omnikey_hotkey2, ini\config.ini, Settings, omni-hotkey2, % A_Space
IniRead, alt_modifier, ini\config.ini, Settings, highlight-key, % A_Space

Hotkey, IfWinActive, ahk_group poe_ahk_window
If (omnikey_hotkey2 = "")
	Hotkey, % (omnikey_hotkey != "") ? "*~" omnikey_hotkey : "*~MButton", Omnikey, On
Else
{
	Hotkey, *~%omnikey_hotkey2%, Omnikey, On
	Hotkey, % (omnikey_hotkey != "") ? "*~" omnikey_hotkey : "*~MButton", Omnikey2, On
}
Return

LLK_Omnikey_ToolTip(text:=0)
{
	global
	If (text = 0)
	{
		Gui, omnikey_tooltip: Destroy
		Return
	}
	If (text = "")
	{
		LLK_ToolTip("no maps with " A_ThisHotkey)
		Return
	}
	Gui, omnikey_tooltip: New, -DPIScale +E0x20 +LastFound +AlwaysOnTop +ToolWindow -Caption +Border HWNDhwnd_omnikey_tooltip,
	Gui, omnikey_tooltip: Color, Black
	Gui, omnikey_tooltip: Margin, 12, 4
	WinSet, Transparent, %trans%
	Gui, omnikey_tooltip: Font, s%fSize0% cWhite, Fontin SmallCaps
	If InStr(text, "horizons:")
	{
		text := StrReplace(text, "horizons:")
		Gui, omnikey_tooltip: Font, underline
		Gui, omnikey_tooltip: Add, Text, Section BackgroundTrans, % "horizons:"
		Gui, omnikey_tooltip: Font, norm
		Gui, omnikey_tooltip: Add, Text, xs BackgroundTrans, % text
	}
	Else Gui, omnikey_tooltip: Add, Text, BackgroundTrans, % text
	Gui, omnikey_tooltip: Show, Hide AutoSize
	MouseGetPos, mouseXpos, mouseYpos
	WinGetPos, winX, winY, winW, winH
	tooltip_posX := (mouseXpos - winW < xScreenOffSet) ? xScreenOffSet : mouseXpos - winW
	tooltip_posy := (mouseYpos - winH < yScreenOffSet) ? yScreenOffSet : mouseYpos - winH
	Gui, omnikey_tooltip: Show, % "NA AutoSize x"tooltip_posX " y"tooltip_posy
}