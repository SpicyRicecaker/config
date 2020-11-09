
# First create new language list
$List = New-WinUserLanguageList 'en-US'
# Then add international keyboard
$List[0].InputMethodTips.add('0409:00020409')
# Then set current to the input method tips
Set-WinUserLanguageList -LanguageList $List
# We're done!