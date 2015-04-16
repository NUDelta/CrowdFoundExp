rm build/CrowdFound.ipa
xcodebuild -scheme CrowdFound -workspace CrowdFound.xcworkspace clean archive -archivePath build/CrowdFound
xcodebuild -exportArchive -exportFormat ipa -archivePath "build/CrowdFound.xcarchive" -exportPath "build/CrowdFound.ipa" -exportProvisioningProfile "Delta"
