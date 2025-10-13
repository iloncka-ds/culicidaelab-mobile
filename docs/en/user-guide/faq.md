# Frequently Asked Questions (FAQ)

Find answers to the most common questions about CulicidaeLab, its features, and how to use the app effectively.

## General Questions

### What is CulicidaeLab?
CulicidaeLab is a mobile application that uses artificial intelligence to identify mosquito species from photographs. It also provides comprehensive information about mosquito-borne diseases and serves as an educational tool for public health awareness and scientific research.

### Is CulicidaeLab free to use?
Yes, CulicidaeLab is completely free to download and use. There are no in-app purchases, subscriptions, or hidden fees. The app is supported by research grants and is designed to serve the public good.

### What devices are supported?
**Android**: Version 5.0 (API Level 21) or newer with at least 3GB RAM
**iOS**: Version 12.0 or newer with at least 3GB RAM
**Not Supported**: Web browsers, Windows, macOS, or Linux desktop applications

### Do I need internet to use the app?
**For Identification**: No, the AI model runs entirely on your device
**For Gallery and Diseases**: Initial download requires internet, then works offline
**For Map and Observations**: Internet connection required
**For Updates**: Internet needed for app updates and new content

### How accurate is the mosquito identification?
The AI model achieves over 90% accuracy for the most common disease-vector mosquito species. Accuracy depends on photo quality, lighting conditions, and the species being identified. Always verify results using the species gallery and consider geographic distribution.

## Identification and AI Questions

### How does the AI identification work?
CulicidaeLab uses a deep learning neural network (PyTorch Lite) trained on thousands of mosquito images from scientific collections. The model analyzes visual features like body patterns, wing structure, and size proportions to identify species.

### What mosquito species can the app identify?
The app can identify the most epidemiologically significant mosquito species, focusing on those that transmit diseases to humans. This includes species from genera like Aedes, Anopheles, and Culex. The exact number of species varies by app version.

### Why do I get different results for the same mosquito?
Several factors can cause variation:
- **Photo Quality**: Different lighting, angles, or focus
- **Image Processing**: Slight variations in how the AI processes images
- **Mosquito Condition**: Damage, positioning, or life stage
- **Model Uncertainty**: Some species are more difficult to distinguish

### What should I do if the identification seems wrong?
1. **Check Photo Quality**: Ensure clear, well-lit images
2. **Try Multiple Photos**: Take several photos from different angles
3. **Compare with Gallery**: Verify against species images and descriptions
4. **Check Geographic Range**: Ensure the species occurs in your location
5. **Consider Confidence Score**: Lower scores indicate less certainty

### Can the app identify mosquito larvae or eggs?
No, the current version only identifies adult mosquitoes. The AI model is trained specifically on adult mosquito morphology and cannot accurately identify larvae, pupae, or eggs.

## Privacy and Data Questions

### What data does the app collect?
**Automatically Collected**:
- Device type and operating system version
- App usage statistics (anonymous)
- Crash reports and error logs

**User-Provided** (optional):
- Photos you choose to analyze
- Location data for observations (if you submit them)
- Notes and comments for observations

### Is my personal information safe?
Yes, CulicidaeLab is designed with privacy in mind:
- **No Personal Information**: We don't collect names, emails, or personal details
- **Anonymous Usage**: All usage data is anonymized
- **Local Processing**: AI identification happens on your device
- **Optional Sharing**: You choose what observations to submit

### Are my photos stored or shared?
**Local Storage**: Photos are temporarily stored on your device for processing
**Not Uploaded**: Photos are not automatically uploaded to servers
**User Choice**: You can choose to include photos when submitting observations
**Deletion**: You can delete photos from the app at any time

### Can I use the app without sharing any data?
Yes, you can use all core features (identification, gallery, disease info) without sharing any data. Only the map feature and observation submission require data sharing, and both are optional.

## Technical Questions

### Why is the app so large?
The app includes:
- **AI Model**: Neural network files (~50-100MB)
- **Species Database**: Images and information for all species
- **Disease Database**: Comprehensive disease information
- **Multi-language Content**: Text in multiple languages
- **Offline Capability**: All content available without internet

### Why does the app take time to load initially?
On first launch, the app needs to:
- **Load AI Model**: Initialize the neural network
- **Cache Images**: Download species and disease images
- **Set Up Database**: Prepare local data storage
- **Configure Languages**: Set up localization

### Can I use the app on multiple devices?
Yes, you can install CulicidaeLab on multiple devices. However:
- **No Sync**: Data doesn't sync between devices
- **Separate Setup**: Each device needs individual setup
- **Independent Usage**: Each installation works independently

### How often is the app updated?
**Regular Updates**: New versions released every 2-3 months
**Content Updates**: Species and disease information updated regularly
**Model Improvements**: AI model updated as new training data becomes available
**Bug Fixes**: Critical issues addressed in patch releases

## Scientific and Educational Questions

### Is CulicidaeLab scientifically accurate?
Yes, the app is developed with scientific rigor:
- **Expert Review**: Content reviewed by entomologists and public health experts
- **Scientific Sources**: Information based on peer-reviewed research
- **Continuous Updates**: Regular updates based on latest scientific findings
- **Quality Control**: Rigorous testing and validation processes

### Can I use CulicidaeLab for research?
Yes, the app supports research activities:
- **Citizen Science**: Contribute observations to research databases
- **Educational Use**: Suitable for teaching and learning
- **Field Work**: Useful for preliminary species identification
- **Data Collection**: Submit observations with location and metadata

**Important**: For formal research, always verify identifications with expert taxonomists.

### How can I contribute to improving the app?
**Submit Observations**: Share high-quality observations with location data
**Report Issues**: Report bugs, errors, or suggestions for improvement
**Provide Feedback**: Share your experience and suggestions
**Educational Outreach**: Help others learn about mosquito-borne diseases
**Scientific Collaboration**: Researchers can contact the development team

### Can teachers use this app in classrooms?
Absolutely! CulicidaeLab is excellent for education:
- **Biology Classes**: Learn about insect morphology and taxonomy
- **Public Health**: Understand disease vectors and prevention
- **Environmental Science**: Explore human-environment interactions
- **Technology**: Demonstrate AI and machine learning applications

## Troubleshooting Questions

### The app crashes frequently. What should I do?
**Immediate Solutions**:
1. Restart the app completely
2. Restart your device
3. Clear app cache
4. Update to the latest version
5. Free up device storage space

**If Problems Persist**: See our detailed [Troubleshooting Guide](troubleshooting.md)

### Why can't I take photos?
**Check Permissions**: Ensure camera access is enabled in device settings
**Camera Conflicts**: Close other apps that might be using the camera
**Hardware Issues**: Test camera in other apps to verify it's working
**App Updates**: Update to the latest version

### The identification is very slow. How can I speed it up?
**Device Optimization**:
- Close other running apps
- Restart your device
- Ensure adequate free storage
- Use smaller image files
- Allow device to cool if overheated

**Photo Optimization**:
- Use well-lit, clear photos
- Avoid extremely large image files
- Ensure mosquito is clearly visible

### Why don't I see all the species mentioned in documentation?
**Regional Differences**: Species availability may vary by geographic region
**App Version**: Older versions may have fewer species
**Language Settings**: Some species names may vary by language
**Updates**: New species added in app updates

## Support and Contact Questions

### How do I report a bug or problem?
**In-App Reporting**: Use any feedback features within the app
**App Store Reviews**: Leave detailed reviews in Google Play or App Store
**Official Channels**: Contact through official website or email
**Community Forums**: Report issues in user communities

### How do I suggest new features?
**User Feedback**: Use in-app feedback mechanisms
**Community Discussion**: Participate in user forums and discussions
**Direct Contact**: Reach out through official communication channels
**Academic Collaboration**: Researchers can propose collaborative features

### Is there a user manual or guide?
Yes! Comprehensive documentation is available:
- **Getting Started**: [Getting Started Guide](getting-started.md)
- **Identification Help**: [Mosquito Identification Guide](mosquito-identification.md)
- **Gallery Usage**: [Using Gallery Guide](using-gallery.md)
- **Disease Information**: [Disease Information Guide](disease-information.md)
- **Technical Issues**: [Troubleshooting Guide](troubleshooting.md)

### Can I get training on using the app?
**Self-Guided Learning**: Use the comprehensive guides and in-app help
**Educational Resources**: Access teaching materials and presentations
**Community Support**: Join user communities and discussion groups
**Professional Training**: Contact the development team for institutional training

## Medical and Health Questions

### Can I use this app for medical diagnosis?
**No**, CulicidaeLab is for educational and research purposes only. It should never be used for medical diagnosis or treatment decisions. Always consult healthcare professionals for medical concerns.

### What should I do if I think I've been bitten by a disease-carrying mosquito?
1. **Monitor Symptoms**: Watch for fever, headache, or other symptoms
2. **Seek Medical Care**: Consult healthcare professionals if symptoms develop
3. **Provide Information**: Share mosquito identification with healthcare providers
4. **Follow Medical Advice**: Follow professional medical guidance
5. **Report to Authorities**: Consider reporting to local health departments

### Is the disease information medically accurate?
Yes, disease information is based on authoritative sources like WHO and CDC, but it's for educational purposes only. Always consult healthcare professionals for medical advice and current treatment guidelines.

---

**Still have questions?** 

Check our [Troubleshooting Guide](troubleshooting.md) for technical issues, or contact support through the official channels mentioned above. We're here to help you make the most of CulicidaeLab!