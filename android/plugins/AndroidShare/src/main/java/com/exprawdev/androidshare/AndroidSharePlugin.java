
package com.exprawdev.androidshare;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.webkit.MimeTypeMap;

import androidx.core.content.FileProvider;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.UsedByGodot;

import java.io.File;

public class AndroidSharePlugin extends GodotPlugin {

    public AndroidSharePlugin(Godot godot) {
        super(godot);
    }

    @Override
    public String getPluginName() {
        return "AndroidShare";
    }

    @UsedByGodot
    public void share_file(
            String filePath,
            String mimeType,
            String chooserTitle
    ) {
        Activity activity = getActivity();

        if (activity == null) {
            return;
        }

        File photoFile = new File(filePath);

        if (!photoFile.exists() || !photoFile.isFile()) {
            return;
        }

        activity.runOnUiThread(() -> {
            try {
                String authority =
                    activity.getPackageName() + ".fileprovider";

                Uri photoUri = FileProvider.getUriForFile(
                    activity,
                    authority,
                    photoFile
                );

                Intent shareIntent = new Intent(
                    Intent.ACTION_SEND
                );

                shareIntent.setType(
                    mimeType == null || mimeType.isEmpty()
                        ? "image/*"
                        : mimeType
                );

                shareIntent.putExtra(
                    Intent.EXTRA_STREAM,
                    photoUri
                );

                shareIntent.addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                );

                Intent chooser = Intent.createChooser(
                    shareIntent,
                    chooserTitle == null
                        ? "Share photo"
                        : chooserTitle
                );

                activity.startActivity(chooser);

            } catch (Exception exception) {
                exception.printStackTrace();
            }
        });
    }
}
