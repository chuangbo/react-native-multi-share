## react-native-multi-share

Drop-in replacement of react-native `Share` module, provides the ability to share multiple images.

### Installation

```
npm i react-native-multi-share --save
```

```
react-native link react-native-multi-share
```

#### Android

* Follow this [guide](https://developer.android.com/training/secure-file-sharing/setup-sharing). For example:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.myapp">
    <application
        ...>
        <provider
            android:name="android.support.v4.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:grantUriPermissions="true"
            android:exported="false"
            tools:replace="android:authorities">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths"
                tools:replace="android:resource" />
        </provider>
        ...
    </application>
</manifest>
```

* Create a `provider_paths ` under this directory: android/app/src/main/res/xml. In this file, add the following contents:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path
        name="external_files"
        path="." />
    <files-path
        name="files-path"
        path="." /> <!-- Used to access into application data files -->
</paths>
```


#### Using CocoaPods

```
# Add to Podfile
pod 'react-native-multi-share', :path => '../node_modules/react-native-multi-share'
```

### Usage

```javascript
import MultiShare from 'react-native-multi-share';

async function onShare() {
  await MultiShare.share({ images: ['file:///.../image1.jpg', ...] });
}
```

### Todos

- [x] Test on react-native
- [x] Test on detached expo.io project
- [x] iOS
- [x] Android
- [ ] ~~Pull request to react-native~~
- [ ] Test using images along with other fields
- [ ] Support more file types
