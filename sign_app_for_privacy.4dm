ASSERT(Is macOS)
ASSERT(Num(Application version($build))>=1860)  //LTS is not shipped with signApp.sh

$MACRO:=New object
$MACRO.metacharacters:=Split string("\\!\"#$%&'()=~|<>?;*`[] "; "")
$MACRO.backslash:="\\"
$mi:=New collection(\
"<!--#4DCODE"; \
"For each ($metacharacter;This.metacharacters)"; \
"$1->:=Replace string($1->;$metacharacter;This.backslash+$metacharacter;*)"; \
"End for each"; \
"-->").join("\r")
$mo:=""

//an inline function we will use later

$MACRO.escape:=Formula(Formula(PROCESS 4D TAGS($1; $2; $3)).call(This; $mi; $mo; $1))

//these are the keys that enable privacy features
$keys:=New object
$keys.NSRequiresAquaSystemAppearance:="NO"
$keys.NSAppleEventsUsageDescription:=""
$keys.NSCalendarsUsageDescription:=""
$keys.NSContactsUsageDescription:=""
$keys.NSRemindersUsageDescription:=""
$keys.NSCameraUsageDescription:=""
$keys.NSMicrophoneUsageDescription:=""
$keys.NSLocationUsageDescription:=""
$keys.NSPhotoLibraryUsageDescription:=""
$keys.NSSystemAdministrationUsageDescription:=""


//--- real work starts here ---


//step 1. we need to update the info.plist file of 4D

$infoPlistFile:=Folder(Application file; fk platform path).folder("Contents").file("Info.plist")

ASSERT($infoPlistFile.exists)

C_BLOB($stdIn; $stdOut; $stdErr)
C_TEXT($dom; $dict)

$dom:=DOM Parse XML source($infoPlistFile.platformPath)

ASSERT(OK=1)

$dict:=DOM Find XML element($dom; "/plist/dict")  //must start with / for 18 R3 xPath syntax 
ARRAY TEXT($domKeys; 0)
$domKey:=DOM Find XML element($dict; "dict/key"; $domKeys)
For ($i; 1; Size of array($domKeys))
	$domKey:=$domKeys{$i}
	DOM GET XML ELEMENT VALUE($domKey; $keyName)
	If ($keys[$keyName]#Null)
		//remove existing keys first to avoid duplicates
		DOM REMOVE XML ELEMENT(DOM Get next sibling XML element($domKey))
		DOM REMOVE XML ELEMENT($domKey)
	End if 
End for 
//now write keys
For each ($key; $keys)
	Case of 
		: (Value type($keys[$key])=Is text)
			DOM SET XML ELEMENT VALUE(DOM Create XML element($dict; "key"); $key)
			DOM SET XML ELEMENT VALUE(DOM Create XML element($dict; "string"); $keys[$key])
		: (Value type($keys[$key])=Is boolean)
			DOM SET XML ELEMENT VALUE(DOM Create XML element($dict; "key"); $key)
			If (Bool($keys[$key]))
				$value:=DOM Create XML element($dict; "true")
			Else 
				$value:=DOM Create XML element($dict; "false")
			End if 
		Else 
			//don't care for dict, array, etc.
	End case 
End for each 
//DOM EXPORT TO FILE exports CR which is problematic for info.plist
$pl:=""
DOM EXPORT TO VAR($dom; $pl)
$infoPlistFile.setText($pl; "utf-8"; Document with LF)
DOM CLOSE XML($dom)

$sh:=Folder(Application file; fk platform path).folder("Contents").folder("Resources").file("SignApp.sh").path

$arg1:="-"
$arg2:=File(Application file; fk platform path).path
$arg3:=Folder(Application file; fk platform path).folder("Contents").folder("Resources").file("4D.entitlements").path
$arg4:=Folder(Get 4D folder(Logs folder); fk platform path).file(Current method name+".txt").path

$MACRO.escape(->$sh)
$MACRO.escape(->$arg1)
$MACRO.escape(->$arg2)
$MACRO.escape(->$arg3)
$MACRO.escape(->$arg4)

//the application builder escapes the entire string with single quotes, which is not always good; escape it properly
$command:=New collection($sh; $arg1; $arg2; $arg3; $arg4).join(" ")

SET TEXT TO PASTEBOARD($command)

ALERT("Termial will launch; paste the code and run it after 4D quits")

LAUNCH EXTERNAL PROCESS("open -a terminal")

QUIT 4D
