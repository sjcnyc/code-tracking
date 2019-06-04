###########################################################################
#
# NAME: Play-ChristmasCarol
#
# AUTHOR:  edempsey
#
# COMMENT: Fun with PowerShell for Christmas 2013
#
# VERSION HISTORY:
# 1.0 10/30/2013 - Initial release
#
###########################################################################
Function Play-JingleBells()
{
	#Using a 'For Loop' to play Jingle Bells twice
	for ($i=0; $i -le 1; $i++)
	{
		Write-Host "Jin" -NoNewline
		[System.Console]::Beep(850,250)
		Write-Host "gle " -NoNewline
		[System.Console]::Beep(850,250)
		Write-Host "Bells "
		[System.Console]::Beep(850,500)

		Start-Sleep -Milliseconds 250		
	}	
}

Function Play-JingleAllTheWay()
{
	Write-Host "Jin" -NoNewline
	[System.Console]::Beep(850,250)
	Write-Host "gle " -NoNewline
	[System.Console]::Beep(950,250)
	Write-Host "all " -NoNewline
	[System.Console]::Beep(695,375)
	Write-Host "the " -NoNewline
	[System.Console]::Beep(775,175)
	Write-Host "way "
	[System.Console]::Beep(850,625)
	
	Start-Sleep -Milliseconds 250
}

Function Play-OhWhatFun([int] $Order)
{
	Write-Host "Oh, " -NoNewline
	[System.Console]::Beep(900, 250)
	Write-Host "what " -NoNewline
	[System.Console]::Beep(900, 250)
	Write-Host "fun " -NoNewline
	[System.Console]::Beep(900, 375)
	Write-Host "it " -NoNewline
	[System.Console]::Beep(900, 175)
	Write-Host "is " -NoNewline
	[System.Console]::Beep(900, 250)
	Write-Host "to " -NoNewline
	[System.Console]::Beep(850, 250)
	Write-Host "ride " -NoNewline
	[System.Console]::Beep(850, 250)
	Write-Host "in " -NoNewline
	[System.Console]::Beep(850, 175)
	Write-Host "a " -NoNewline
	[System.Console]::Beep(850, 175)
	
	#Using switch-case statement to evaluate the value of $Order
	#to play the correct version of 'one horse open sleigh'
	switch ($Order)
	{
		1
		{
			Write-Host "one " -NoNewline
			[System.Console]::Beep(850, 250)
			Write-Host "horse " -NoNewline
			[System.Console]::Beep(775, 250)
			Write-Host "o" -NoNewline
			[System.Console]::Beep(775, 250)
			Write-Host "pen " -NoNewline
			[System.Console]::Beep(850, 250)
			Write-Host "sleigh " -NoNewline
			[System.Console]::Beep(775, 500)
			Write-Host "Hey"
			[System.Console]::Beep(950, 500)
			break
		}
		2
		{
			Write-Host "one " -NoNewline
			[System.Console]::Beep(975, 250)
			Write-Host "horse " -NoNewline
			[System.Console]::Beep(975, 250)
			Write-Host "o" -NoNewline
			[System.Console]::Beep(900, 250)
			Write-Host "pen " -NoNewline
			[System.Console]::Beep(800, 250)
			Write-Host "sleigh "
			[System.Console]::Beep(700, 750)
			break
		}
	}	
}

Function Play-Chorus()
{	
	Play-JingleBells
	
	Play-JingleAllTheWay
	
	Play-OhWhatFun -Order 1
	
	Start-Sleep -Milliseconds 200
	
	Play-JingleBells
	
	Play-JingleAllTheWay
	
	Play-OhWhatFun -Order 2
}

Function Main()
{
	#Call the function that plays the song
	Play-Chorus
	
	#Ask the user if they would like to play it again
	#here is the slightly easier way, but it requires you to validate the response which can actually make this way more difficult if you have more than 2 options
	
##----------------------------------------------------------------------------------------------------------------------------
##Short way starts here uncomment out the lines of code in this section to see how this method works
#	$choice = Read-Host "Would you like to hear the song again? (Y or N)"
#	if($choice -eq "Y" -or $choice -eq "N")
#	{
#		#Hey, the user answered correctly, now go execute some cool code
#		switch ($choice)
#		{
#			"Y"{Main; break}
#			"N"{Write-Host "Thanks for listening, Merry Christmas!" -ForegroundColor Green; break}
#		}
#	}
#	else
#	{
#		#Oops, the user entered an option that wasn't in the list, now what?
#		#This is where the method below comes in, the script doesn't move on until proper entry is made
#		#Because I enjoy Jingle Bells so much, poor user selection means they get the song again
#		Main
#	}
##End Short way
##----------------------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------------------
#Preferred way starts here commend out the lines of code in this section to turn off this method
	
	#Here is the preferred method
	#Title or caption for the prompt
	$title = "Play again?"
	
	#The prompt message
	$prompt = "Would you like to play the song again?"
	
	#Option 1 - Yes - The & symbol lets the script no which letter of the word that will be in input for the option, in this case (Y) or (N) below
	#Also note the short and long version of the option, the long version is used when the user enters '?' at the prompt so the long version should be
	#a good description of what that option will do
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes','Plays the song again'
	#Option 2 - No
	$no = New-Object System.Management.Automation.Host.ChoiceDescription '&No','Ends the script'
	
	#Now we add the above options to a new variable.  Keep in mind the order you put them in here is the order they will be displayed
	$options = [System.Management.Automation.Host.ChoiceDescription[]] ($yes, $no)
	
	#Now we create the variable to store the selection made by the user which will execute the prompt at runtime
	#It is important to note that the $choice is returned as an integer starting at 0, which is why remembering order is so important
	#In this example - Yes is returned as 0 and No is returned as 1 which is why those are the values evaluated by the switch statement
	#The ending in the line below is what sets Yes as the default option if the user does not provide any input and just hits enter
	$choice = $Host.UI.PromptForChoice($title, $prompt,$options, 0)
	
	switch ($choice)
	{
		0{Main; break}
		1{Write-Host "Thanks for listening, Merry Christmas!" -ForegroundColor Green; break}
	}
#End preferred method
#----------------------------------------------------------------------------------------------------------------------------
}

Main