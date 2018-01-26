## react-native-multi-share

Drop-in replacement of react-native `Share` module, provides the ability to share multiple images.

### Installation

```
npm i react-native-multi-share --save
```

```
react-native link react-native-multi-share
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

### Common Issues

#### Does not work android

The images has to be copy to external storage, other apps cannot read your document folder.

```js
// Copy the files to the external storage
import RNFetchBlob from 'react-native-fetch-blob';

const fs = RNFetchBlob.fs;

// Android Only
async function getExternalCacheDirAsync() {
  const dir = `${fs.dirs.SDCardApplicationDir}/cache`;
  if (!await fs.isDir(dir)) {
    await fs.mkdir(dir);
  }
  return dir;
}

export async function copyToExternalCacheDirAsync(from) {
  const dir = await getExternalCacheDirAsync();
  const filename = from.replace(/^.*[\\/]/, '');
  const to = `${dir}/${filename}`;
  await RNFetchBlob.fs.cp(from, to);
  return to;
}

```

### Todos

- [x] Test on react-native
- [x] Test on detached expo.io project
- [x] iOS
- [x] Android
- [ ] Pull request to react-native
- [ ] Test using images along with other fields
