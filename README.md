Update Comments
==================

An AppleScript application (with a ridiculously unimaginative name) for managing Spotlight comments.

Drag it to your Finder toolbar to quickly add, edit, replace and remove Spotlight comments. It's got a few odd bugs, mostly related to listing comments for removal or editing, but nothing that prevents using it.

## Setup
### Run it as you would any other AppleScript
The easiest way to do this is to drop the script file into your _~/Library/Scripts_ folder and run it from the Script menu in the menu bar. To enable the Script menu, open AppleScript Editor (/Applications/Utilities/AppleScript Editor.app) and  enable the option for "Show Script menu in menu bar" in the AppleScript Editor's preferences window.

### Save it as an application
Open the script in AppleScript Editor and select "Application" from the _Save As_ menu. From there, there are a couple extra steps.

1. **Add the icon file to the Resources folder**  
Right-click your application file and select "Show Package Contents". Open the _Contents/Resources_ folder and drag the included .icns file (or your own, whatever) into this folder. Go ahead and copy the filename to the clipboard.
3. **Alter the icon file key in the plist to enable the icon file.**  
In the _Contents_ folder is your Info.plist file. Open this file in your editor of choice and find the ````CFBundleIconFile```` key. Change the associated ````<string>```` entry (directly after ````<key>CFBundleIconFile</key>````) to reflect the name of your icon file (without the file extension). If you've used the included icon file, your plist file should read:  
````  
<key>CFBundleIconFile</key>
<string>update-comments</string>  
````  
Keep that plist file open, dawg...
2. **Add a key to the plist file so the dock icon will remain hidden.**   
In order to keep New File from showing a dock icon (which, IMHO is dumb and pointless for this type of application), you need to _add_ the following to the plist file:  
````
<key>LSUIElement</key>
<string>1</string>
````

### IAQ (Infrequently asked questions)
### Why are you doing this?
I wanted a quick way to add and edit a file's Spotlight comments. When saved as an application from AppleScript Editor, and with a few trivial extra steps, Update Comments can be dragged to the Finder toolbar for easy access.

### Okay, so why not just create a Service?
I do what I want.