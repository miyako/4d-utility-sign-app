# 4d-utility-sign-app
Invoke SignApp.sh from terminal

#### About

to use plugins such as 

* https://github.com/miyako/4d-plugin-ical-v3
* https://github.com/miyako/4d-plugin-address-book
* https://github.com/miyako/4d-plugin-capture-v2
* https://github.com/miyako/4d-plugin-photos-v2
* https://github.com/miyako/4d-plugin-apple-file-promises

you need to codesign the app with entitlements and also edit the `Info.plist` file.

you do **not** need an Apple Developer ID to run locally. 

you do **not** need to notarise the app to run locally.

v18 R4 has a *SignApp.sh* shell script that supports **Ad Hoc codesign**.

this method can be used to quickly sign the app to use the aforementioned plugins.

#### Prerequisites 

* 4D v18 R4 or later (preferably R6)

#### How to

create a method, paste the [code](https://raw.githubusercontent.com/miyako/4d-utility-sign-app/main/sign_app_for_privacy.4dm) and run. 

an alert should pop up in the end.

<img width="480" alt="alert" src="https://user-images.githubusercontent.com/1725068/118119990-29edab80-b42a-11eb-9897-013c08a26f41.png">

accept.

paste the content of the pasteboard in Terminal and enter.

that's it.
