# Troubleshooting Guide

This guide helps you resolve common issues you might encounter while using CulicidaeLab. Find solutions to technical problems, performance issues, and feature-specific challenges.

## Quick Solutions

### App Won't Start or Crashes
**Symptoms**: App closes immediately, won't open, or crashes during startup

**Solutions**:
1. **Restart the App**: Close completely and reopen
2. **Restart Device**: Power off and on your phone/tablet
3. **Check Storage**: Ensure at least 500MB free space
4. **Update App**: Install latest version from app store
5. **Clear Cache**: Clear app cache in device settings

**Android Specific**:
- Go to Settings > Apps > CulicidaeLab > Storage > Clear Cache
- If problem persists, try "Clear Data" (will reset app settings)

**iOS Specific**:
- Delete and reinstall the app if other solutions don't work
- Check iOS version compatibility (requires iOS 12.0+)

### Classification Not Working
**Symptoms**: Camera won't open, photos won't analyze, or results don't appear

**Immediate Fixes**:
1. **Check Permissions**: Ensure camera and photo access are enabled
2. **Restart App**: Close and reopen CulicidaeLab
3. **Try Different Image**: Use a clearer, well-lit photo
4. **Check Storage**: Free up device storage space
5. **Wait for Model**: Allow time for AI model to load on first use

### Gallery or Disease Info Won't Load
**Symptoms**: Empty screens, loading indicators that don't finish, or error messages

**Solutions**:
1. **Check Internet**: Ensure stable internet connection for initial data download
2. **Wait for Loading**: Initial data download may take 1-2 minutes
3. **Restart App**: Close and reopen if loading seems stuck
4. **Clear Cache**: Clear app cache to refresh data
5. **Update App**: Ensure you have the latest version

## Camera and Photo Issues

### Camera Won't Open
**Problem**: Camera button doesn't work or shows error

**Check Permissions**:
- **Android**: Settings > Apps > CulicidaeLab > Permissions > Camera (Enable)
- **iOS**: Settings > Privacy & Security > Camera > CulicidaeLab (Enable)

**Other Solutions**:
- Close other apps using the camera
- Restart the device
- Check if camera works in other apps
- Update the app to latest version

### Photos Are Blurry or Poor Quality
**Problem**: Images are unclear, making identification difficult

**Photography Tips**:
- **Lighting**: Use bright, natural light
- **Distance**: Get closer to the mosquito while maintaining focus
- **Stability**: Hold device steady or use a tripod
- **Focus**: Tap on the mosquito to focus before taking photo
- **Background**: Use plain, contrasting background

**Technical Solutions**:
- Clean camera lens
- Check if camera focus is working in other apps
- Try different camera modes if available
- Ensure adequate lighting conditions

### Gallery Photos Won't Select
**Problem**: Can't select existing photos from device gallery

**Permission Check**:
- **Android**: Settings > Apps > CulicidaeLab > Permissions > Storage/Photos
- **iOS**: Settings > Privacy & Security > Photos > CulicidaeLab

**Other Fixes**:
- Restart the app
- Try selecting different photo formats (JPEG works best)
- Check if photos are stored locally (not just in cloud)
- Ensure photos aren't corrupted## AI Model
 and Classification Issues

### Model Won't Load
**Problem**: "Model not loaded" error or classification doesn't start

**Solutions**:
1. **Wait for Loading**: Model loading can take 30-60 seconds on first launch
2. **Check Storage**: Ensure at least 200MB free space for model files
3. **Restart App**: Close completely and reopen
4. **Check Platform**: Ensure you're using Android or iOS (not supported on web/desktop)
5. **Update App**: Install latest version with model improvements

**Memory Issues**:
- Close other apps to free RAM
- Restart device if memory is very low
- Consider device upgrade if consistently problematic

### Classification Results Seem Wrong
**Problem**: AI identifies wrong species or gives low confidence

**Photo Quality Check**:
- Ensure mosquito fills most of the frame
- Check that image is sharp and well-focused
- Verify good lighting without harsh shadows
- Make sure entire mosquito is visible

**Verification Steps**:
1. **Compare with Gallery**: Check species images in gallery
2. **Try Multiple Photos**: Take several photos from different angles
3. **Check Geographic Range**: Verify species occurs in your location
4. **Consider Alternatives**: Look at other high-confidence results

### Slow Classification Performance
**Problem**: Analysis takes very long or appears stuck

**Performance Optimization**:
- **Close Background Apps**: Free up device memory
- **Restart App**: Fresh start can improve performance
- **Reduce Image Size**: Use smaller images if possible
- **Check Device Temperature**: Allow device to cool if overheated
- **Update App**: Newer versions may have performance improvements

**Device Considerations**:
- Older devices may process more slowly
- Ensure device meets minimum requirements
- Consider upgrading device for better performance

## Network and Connectivity Issues

### Map Won't Load
**Problem**: Mosquito activity map shows errors or won't display

**Network Troubleshooting**:
1. **Check Internet**: Ensure stable Wi-Fi or cellular connection
2. **Try Different Network**: Switch between Wi-Fi and cellular
3. **Restart Router**: Reset Wi-Fi connection
4. **Check Firewall**: Ensure app isn't blocked by network security
5. **Wait and Retry**: Server may be temporarily unavailable

### Observation Submission Fails
**Problem**: Can't submit mosquito observations to research database

**Submission Troubleshooting**:
- **Check Internet**: Stable connection required for submission
- **Verify Location**: Ensure location services are enabled
- **Complete Required Fields**: Fill all mandatory information
- **Try Later**: Server may be busy, try again in a few minutes
- **Check App Version**: Update to latest version

### Language Changes Don't Apply
**Problem**: App doesn't switch to selected language

**Language Fixes**:
1. **Restart App**: Close completely and reopen
2. **Check Device Language**: Ensure device supports selected language
3. **Clear Cache**: Clear app cache and restart
4. **Reinstall App**: Delete and reinstall if problem persists
5. **Update App**: Ensure latest version with language improvements

## Performance and Storage Issues

### App Runs Slowly
**Problem**: Laggy interface, slow responses, or delayed actions

**Performance Solutions**:
- **Free Memory**: Close other running apps
- **Restart Device**: Clear system memory
- **Clear Cache**: Remove temporary files
- **Free Storage**: Delete unnecessary files to free space
- **Update App**: Install performance improvements

**Device Optimization**:
- Keep at least 1GB free storage
- Restart device regularly
- Update device operating system
- Remove unused apps

### Storage Space Warnings
**Problem**: Device shows low storage warnings

**Storage Management**:
1. **Delete Unused Apps**: Remove apps you don't use
2. **Clear Photo/Video Cache**: Remove old media files
3. **Move Files to Cloud**: Use cloud storage for photos/videos
4. **Clear App Caches**: Clear cache for multiple apps
5. **Use Storage Analyzer**: Find and remove large files

**CulicidaeLab Specific**:
- App uses approximately 300MB when fully loaded
- Model files are cached locally for offline use
- Gallery images are cached for better performance

## Platform-Specific Issues

### Android Issues

**App Permissions Reset**:
- Android may reset permissions after updates
- Manually re-enable camera, storage, and location permissions
- Check "Auto-start" permissions for background model loading

**Battery Optimization**:
- Disable battery optimization for CulicidaeLab
- Go to Settings > Battery > Battery Optimization > CulicidaeLab > Don't Optimize

**Storage Access Framework**:
- If gallery access fails, try using "Files" app to select photos
- Clear storage permissions and re-grant them

### iOS Issues

**App Transport Security**:
- Ensure iOS version supports required security protocols
- Update iOS if map or network features don't work

**Background App Refresh**:
- Enable Background App Refresh for CulicidaeLab
- Settings > General > Background App Refresh > CulicidaeLab

**iCloud Photo Library**:
- If photos won't select, ensure they're downloaded locally
- Settings > Photos > Download and Keep Originals

## Advanced Troubleshooting

### Complete App Reset
If multiple issues persist, try a complete reset:

1. **Export Data**: Save any important observations or notes
2. **Clear All Data**: 
   - Android: Settings > Apps > CulicidaeLab > Storage > Clear Data
   - iOS: Delete and reinstall app
3. **Restart Device**: Power cycle your device
4. **Reinstall App**: Download fresh copy from app store
5. **Reconfigure**: Set up permissions and preferences again

### Diagnostic Information
When contacting support, provide:
- Device model and operating system version
- CulicidaeLab app version
- Specific error messages
- Steps to reproduce the problem
- Screenshots of issues (if applicable)

### Factory Reset Considerations
As a last resort for persistent device-wide issues:
- Back up all important data first
- Factory reset may resolve deep system conflicts
- Reinstall apps and restore data carefully
- Consider professional device support

## Getting Additional Help

### In-App Support
- Check for help icons (ℹ️) throughout the app
- Look for tooltips and contextual help
- Review app notifications for guidance

### Community Resources
- User forums and discussion groups
- Social media communities
- Educational institution support

### Professional Support
- Contact app developers through official channels
- Report bugs through app store reviews
- Reach out via official website or email

### Emergency Situations
For medical emergencies related to mosquito-borne diseases:
- Contact local emergency services immediately
- Don't rely solely on app information for urgent medical decisions
- Consult healthcare professionals for medical concerns

Remember: Most issues can be resolved with simple solutions like restarting the app or checking permissions. If problems persist, don't hesitate to seek help from the support resources listed above.

For frequently asked questions, see our [FAQ Guide](faq.md).