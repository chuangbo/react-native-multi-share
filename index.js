/**
 * MultiShare high level api. Copy from react-native `Share` and add `images` field.
 * @providesModule react-native-multi-share
 * @flow
 */

import {
  Platform,
  processColor,
  NativeModules,
} from 'react-native';

import invariant from 'fbjs/lib/invariant';

const { MultiShare: MultiShareModule } = NativeModules;

class MultiShare {

  /**
   * Display the iOS share sheet. The `options` object should contain
   * one or both of `message` and `url` and can additionally have
   * a `subject` or `excludedActivityTypes`:
   *
   * - `url` (string) - a URL to share
   * - `message` (string) - a message to share
   * - `subject` (string) - a subject for the message
   * - `images` (string) - the URL of images
   * - `excludedActivityTypes` (array) - the activities to exclude from
   *   the ActionSheet
   * - `tintColor` (color) - tint color of the buttons
   *
   * The 'failureCallback' function takes one parameter, an error object.
   * The only property defined on this object is an optional `stack` property
   * of type `string`.
   *
   * The 'successCallback' function takes two parameters:
   *
   * - a boolean value signifying success or failure
   * - a string that, in the case of success, indicates the method of sharing
   *
   * See http://facebook.github.io/react-native/docs/actionsheetios.html#showshareactionsheetwithoptions
   */
  static showShareActionSheetWithOptions(
    options: Object,
    failureCallback: Function,
    successCallback: Function,
  ) {
    invariant(
      typeof options === 'object' && options !== null,
      'Options must be a valid object',
    );
    invariant(
      typeof failureCallback === 'function',
      'Must provide a valid failureCallback',
    );
    invariant(
      typeof successCallback === 'function',
      'Must provide a valid successCallback',
    );
    MultiShareModule.showShareActionSheetWithOptions(
      {...options, tintColor: processColor(options.tintColor)},
      failureCallback,
      successCallback,
    );
  }

  /**
   * Open a dialog to share text content.
   *
   * In iOS, Returns a Promise which will be invoked an object containing `action`, `activityType`.
   * If the user dismissed the dialog, the Promise will still be resolved with action being `Share.dismissedAction`
   * and all the other keys being undefined.
   *
   * In Android, Returns a Promise which always be resolved with action being `Share.sharedAction`.
   *
   * ### Content
   *
   *  - `message` - a message to share
   *  - `title` - title of the message
   *
   * #### iOS
   *
   *  - `url` - an URL to share
   *  - `images` - URL of images to share
   *
   * At least one of URL and message is required.
   *
   * ### Options
   *
   * #### iOS
   *
   *  - `subject` - a subject to share via email
   *  - `excludedActivityTypes`
   *  - `tintColor`
   *
   * #### Android
   *
   *  - `dialogTitle`
   *
   */
  static share(content: Content, options: Options = {}): Promise<Object> {
    invariant(
      typeof content === 'object' && content !== null,
      'Content to share must be a valid object'
    );
    invariant(
      typeof content.url === 'string'
      || typeof content.message === 'string'
      || Array.isArray(content.images),
      'At least one of URL and message and images is required'
    );
    invariant(
      typeof options === 'object' && options !== null,
      'Options must be a valid object'
    );

    if (Platform.OS === 'android') {
      invariant(
        !content.title || typeof content.title === 'string' || Array.isArray(content.images),
        'At least one of title and images is required.'
      );
      return MultiShareModule.share(content, options.dialogTitle);
    } else if (Platform.OS === 'ios') {
      return new Promise((resolve, reject) => {
        this.showShareActionSheetWithOptions(
          {...content, ...options, tintColor: processColor(options.tintColor)},
          (error) => reject(error),
          (success, activityType) => {
            if (success) {
              resolve({
                'action': 'sharedAction',
                'activityType': activityType
              });
            } else {
              resolve({
                'action': 'dismissedAction'
              });
            }
          }
        );
      });
    } else {
      return Promise.reject(new Error('Unsupported platform'));
    }
  }

  /**
   * The content was successfully shared.
   */
  static get sharedAction(): string { return 'sharedAction'; }

  /**
   * The dialog has been dismissed.
   * @platform ios
   */
  static get dismissedAction(): string { return 'dismissedAction'; }

}

module.exports = MultiShare;
