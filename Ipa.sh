rm build/CrowdFound.ipa
xcodebuild -scheme CrowdFound -workspace CrowdFound.xcworkspace clean archive -archivePath build/CrowdFound
#fasdfas
xcodebuild -exportArchive -exportFormat ipa -archivePath "build/CrowdFound.xcarchive" -exportPath "build/CrowdFound.ipa" -exportProvisioningProfile "Delta"
rm /Users/yk/Dropbox/CrowdFound/CrowdFound.ipa
cp build/CrowdFound.ipa /Users/yk/Dropbox/CrowdFound/CrowdFound.ipa
