## react-native-multi-share

Drop-in replacement of react-native `Share` module, provides the ability to share multiple images.

### Installation

```
npm i react-native-multi-share --save
```

### Usage

```javascript
import MultiShare from 'react-native-multi-share';

async function onShare() {
  await MultiShare.share({ images: ['file:///.../image1.jpg', ...] });
}
```

### Todos

- [ ] Test on react-native
- [x] Test on detached expo.io project
- [x] iOS
- [ ] Android
- [ ] Pull request to react-native
