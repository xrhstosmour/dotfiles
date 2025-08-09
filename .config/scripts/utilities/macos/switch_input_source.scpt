tell application "System Events"
	tell process "SystemUIServer"
		tell (menu bar item 1 of menu bar 1 whose description contains "text input")
			click
			click menu item 1 of menu 1
		end tell
	end tell
end tell
