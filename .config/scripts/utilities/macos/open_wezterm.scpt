set appName to "WezTerm"

if application appName is running then
	do shell script "/Applications/WezTerm.app/Contents/MacOS/wezterm-gui"
else
	tell application appName to activate
end if
