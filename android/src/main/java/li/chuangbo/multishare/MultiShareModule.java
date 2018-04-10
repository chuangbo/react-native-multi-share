/*
 * Copy from react-native `ShareModule.java` and add `images` field.
 */

package li.chuangbo.multishare;

import java.util.ArrayList;
import java.io.File;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.v4.content.FileProvider;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

/**
 * Intent module. Launch other activities or open URLs.
 */
public class MultiShareModule extends ReactContextBaseJavaModule {

  /* package */ static final String ACTION_SHARED = "sharedAction";
  /* package */ static final String ERROR_INVALID_CONTENT = "E_INVALID_CONTENT";
  /* package */ static final String ERROR_UNABLE_TO_OPEN_DIALOG = "E_UNABLE_TO_OPEN_DIALOG";

  public MultiShareModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "MultiShare";
  }

  /**
   * Open a chooser dialog to send text content to other apps.
   *
   * Refer http://developer.android.com/intl/ko/training/sharing/send.html
   *
   * @param content the data to send
   * @param dialogTitle the title of the chooser dialog
   */
  @ReactMethod
  public void share(ReadableMap content, String dialogTitle, Promise promise) {
    if (content == null) {
      promise.reject(ERROR_INVALID_CONTENT, "Content cannot be null");
      return;
    }

    try {
      Intent intent = new Intent(Intent.ACTION_SEND);
      intent.setTypeAndNormalize("text/plain");

      if (content.hasKey("title")) {
        intent.putExtra(Intent.EXTRA_SUBJECT, content.getString("title"));
      }

      if (content.hasKey("message")) {
        intent.putExtra(Intent.EXTRA_TEXT, content.getString("message"));
      }

      if (content.hasKey("images")) {
        ReadableArray images = content.getArray("images");
        if (images.size() > 0 ) {
          this.addImagesToIntent(intent, images);
          intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
      }

      Intent chooser = Intent.createChooser(intent, dialogTitle);
      chooser.addCategory(Intent.CATEGORY_DEFAULT);

      Activity currentActivity = getCurrentActivity();
      if (currentActivity != null) {
        currentActivity.startActivity(chooser);
      } else {
        getReactApplicationContext().startActivity(chooser);
      }
      WritableMap result = Arguments.createMap();
      result.putString("action", ACTION_SHARED);
      promise.resolve(result);
    } catch (Exception e) {
      promise.reject(ERROR_UNABLE_TO_OPEN_DIALOG, "Failed to open share dialog");
    }
  }

  protected void addImagesToIntent(Intent intent, ReadableArray images) {
    ArrayList<Uri> uriList = new ArrayList<>();

    Context context = getReactApplicationContext();
    String fileProviderAuthority = context.getPackageName() + ".fileprovider";

    for (int idx=0; idx < images.size(); idx++) {
      uriList.add(FileProvider.getUriForFile(context, fileProviderAuthority, new File(images.getString(idx))));
    }
    intent.setAction(Intent.ACTION_SEND_MULTIPLE);
    intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uriList);
    intent.setType("image/*");
  }
}
