package com.jarvan.fluwxexample.wxapi;

import android.os.Bundle;
import android.view.WindowManager;

import com.jarvan.fluwx.wxapi.FluwxWXEntryActivity;

public class WXPayEntryActivity extends FluwxWXEntryActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
    }
}
