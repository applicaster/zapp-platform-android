package com.applicaster.ui.interfaces;

import androidx.appcompat.app.AppCompatActivity;

/*
Base activity class for UILayer implementations to host in
 */
public abstract class HostActivityBase extends AppCompatActivity {

    abstract public void releaseOrientation();

    public abstract void setAppOrientation(int orientation);

}
