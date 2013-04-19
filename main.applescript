--  Update Comments.app
--  Created by Ryan Domingue 2/13

global commentLog
global allComments

--------------------------------------------------------------
--   Receives a string and separators (to be used as text item delimeters)

--   Converts the string into a list
--   Returns a list created from the string
--------------------------------------------------------------

on toList(theString, separators)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to separators
	set theList to every text item of theString
	return theList
end toList

--------------------------------------------------------------
--   Receives the unsorted list

--   Alphabetizes a given list
--   Returns a sorted list
--------------------------------------------------------------

on sortAlph(ul)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {ASCII character 10} --> always a linefeed
	set listString to (ul as string)
	set newString to do shell script "echo " & quoted form of listString & " | sort -u"
	set ol to (paragraphs of newString)
	set AppleScript's text item delimiters to oldDelims
	return ol
end sortAlph

--------------------------------------------------------------
--   Receives: Finder item

--   Gets the current comments for the passes item
--   Resets the allComments list
--------------------------------------------------------------

on getFinderItemComments(thisItem)
	
	set commentLog to ""
	
	tell application "Finder"
		if the comment of thisItem is not "" then
			set commentLog to the comment of thisItem as text --> get the item's comments as a string
		end if
	end tell
	
	--> explode the string into a list for future processing
	if commentLog is not "" then set commentLog to toList(commentLog, ", ")
	
	--> allComments will be used to house values from commentLog and submittedComments as we filter out duplicates
	set allComments to {}
	
end getFinderItemComments

--------------------------------------------------------------
--   Get selected Finder items and any possible comments to display in the dialog
--------------------------------------------------------------

tell application "Finder"
	
	set sel to selection
	
	--> if none selected, set selection to all items in front window or choosen folder
	if (count sel) is 0 then
		try
			get (target of front Finder window) as alias
		on error
			choose folder with prompt "Set comments of files in this folder:"
		end try
		
		try
			set theFolder to result
			set sel to every file of folder (result) as alias list
		end try
	end if
	
	set n to (count sel) --> count the number of files selected
	
end tell

--------------------------------------------------------------
--   Sets up and handles the displaying of the dialog

--   For one item, we want to only display the Set Comments and Cancel buttons
--   The reasoning is, to edit the comments for one item is as simple as editing the text in the dialog
--   We also change the messaging to make it appropriate for what's going to happen and actually display the item's current comments

--   For more than one item, we display all buttons, display messaging more appropriate for multimple items and the trext field is empty
--------------------------------------------------------------

if n is 1 then
	set defaultAnswer to ""
	
	set preFlight to the first item of sel
	--> get comments to display in the dialog
	tell application "Finder"
		if the comment of preFlight is not "" then set defaultAnswer to the comment of preFlight
	end tell
	
	set msg to "Add/update comments for this item:" --> if 1 item is selected, display a relevant message
	set cmt to (defaultAnswer as text) --> display its comments in the text field
	set myButtons to {"Cancel", "Set Comments"} --> we're also going to hide the "Remove/Replace" button
	set myDefaultButton to 2
else
	set msg to "Add or edit comments for the selected items:" --> if more than 1 item is selected, display a relevant message
	set cmt to "" --> display an empty text field
	set myButtons to {"Cancel", "Remove/Replace", "Set Comments"} --> display the "Remove/Replace" button
	set myDefaultButton to 3
end if

--> request text
try
	--> display the comments and ask for edits/additions
	set request to display dialog msg default answer cmt buttons myButtons default button myDefaultButton with icon note with title "Spotlight Comments"
on error msg number e
	if e is -128 then --> user cancelled
		return
	end if
end try

--> get text from dialog
set submittedComments to (text returned of request)

--> get button from dialog
set buttonResponse to button returned of request

--log "<-- begin explode -->"
set submittedCommentsList to toList(submittedComments, ", ")

--> a set of lists to discard of duplicate items
set allCommentsWithDups to {}
set discardList to {}

--------------------------------------------------------------
--   The user clicked the Set Comments button

--   If text was not entered in the dialog, the comments for all selected items will be cleared
--   If text was entered, the text entered will be added to the item's existing comments (if any) minus duplicates
--   The resulting list will be sorted an added to the item
--------------------------------------------------------------

if buttonResponse is equal to "Set Comments" then --> Set Comments button was clicked
	
	--> if no text entered, clear selected items' comments
	if submittedComments is "" then
		
		repeat with i from 1 to count of items in sel
			set thisItem to item i of sel
			tell application "Finder" to set the comment of thisItem to "" --> set the comments to "", effectively clearing them
		end repeat
		
	else
		--> if text is entered, loop through and get, sort and set the comments		
		if n is greater than 1 then
			
			repeat with i from 1 to (count of sel)
				
				set thisItem to item i of sel
				
				my getFinderItemComments(thisItem)
				
				--> loop through the commentLog and add to the new list
				repeat with c from 1 to (count of commentLog)
					set theTerm to item c of commentLog
					if theTerm is not "" and theTerm is not in allComments then set the end of allComments to theTerm
				end repeat
				
				--> loop through the submittedCommentsList and add to the new list
				repeat with s from 1 to (count of submittedCommentsList)
					set theTerm to item s of submittedCommentsList
					if theTerm is not in allComments then set the end of allComments to theTerm
				end repeat
				
				--> sort the resulting list
				set sortedComments to sortAlph(allComments)
				
				-- add comments
				tell application "Finder" to set the comment of thisItem to sortedComments as text --> update the item's comments with the sorted string
				
			end repeat
			
		else
			
			--> n is 1
			repeat with i from 1 to count of items in sel
				set thisItem to item i of sel
				--> sort the resulting list
				set sortedComments to sortAlph(submittedCommentsList)
				--> update the item's comments with the sorted string
				tell application "Finder" to set the comment of thisItem to sortedComments as text
			end repeat
			
		end if
		
	end if
	
end if

if buttonResponse is equal to "Remove/Replace" then --> Remove/Replace button was clicked
	
	--> loop through and get the comments
	repeat with i from 1 to (count of sel)
		
		set thisItem to item i of sel
		
		my getFinderItemComments(thisItem)
		
		--> loop through the commentLog and add to the new list, including duplicates
		repeat with c from 1 to (count of commentLog)
			set theTerm to item c of commentLog
			if theTerm is not "" then set the end of allCommentsWithDups to theTerm
		end repeat
		
	end repeat
	
	--> filter out duplicates
	if allCommentsWithDups is not {} then
		repeat with d from 1 to (count of allCommentsWithDups)
			set theTerm to item d of allCommentsWithDups
			if theTerm is not in discardList then
				set the end of discardList to theTerm
			else if theTerm is in allComments then
				set the end of discardList to theTerm
			else
				set the end of allComments to theTerm
			end if
		end repeat
	end if
	
	--> if the selected items have no comments in common, quit
	if allComments is {} then
		try
			display dialog "The selected items have no shared comments." buttons "End"
			if button returned of result is "End" then return
		on error msg number e
			if e is -128 then --> user cancelled
				return
			end if
		end try
	end if
	
	--> sort the resulting list
	set sortedComments to sortAlph(allComments)
	
	try
		-- display a list of shared comments
		set selectedComments to choose from list sortedComments with title "Remove/Replace" with prompt "Choose one or more items:" with multiple selections allowed
	on error msg number e
		if e is -128 then --> user cancelled
			return
		end if
	end try
	
	--> loop through and get the comments
	repeat with i from 1 to (count of sel)
		
		set thisItem to item i of sel
		
		my getFinderItemComments(thisItem)
		
		set replace to false
		
		--> loop through the commentLog and remove the specified terms, avoiding duplicates
		repeat with c from 1 to (count of commentLog)
			set theTerm to item c of commentLog
			if theTerm is not "" and theTerm is not in selectedComments and theTerm is not in allComments then set the end of allComments to theTerm
			if theTerm is not "" and theTerm is in selectedComments then set replace to true
		end repeat
		
		if replace then
			if submittedComments is not "" and submittedComments is not in allComments then copy submittedComments to the end of allComments
		end if
		
		--> sort the resulting list
		set sortedComments to sortAlph(allComments)
		
		-- add comments
		tell application "Finder" to set the comment of thisItem to sortedComments as text --> update the item's comments with the sorted string
		
	end repeat
	
end if