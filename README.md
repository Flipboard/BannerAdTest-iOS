# CeltraTest

## Overview

A minimal app that fetches and displays banner ads.  The goal is to test various pre-loading techniques and debug visibility issues like early auto-play. 

## CocoaPods

This project uses [Cocoapods](https://guides.cocoapods.org/using/getting-started.html) to import the iOS GoogleMobileAds SDK.  Run the `pod update` command and then open the generated `.xcworkspace` file.

## Functionality

The app uses most of the screen to display ads, with the exception of a bottom bar, just like Flipboard.  The bottom bar contains three buttons:

**Reset**

Cancels in-progress fetching/preloading and deletes downloaded ads.


**Fetch/Present**

Fetches a new ad with the unit ID selected in Settings. 
 
If "Auto-Present" is off, the "Fetch" button will turn into a "Present" button once the ad finishes downloading/preloading.

**Settings**

* *Unit ID -* The unit ID used for ad fetches.

* *Preload -* Enables a hack that forces Celtra ads to preload before they appear.  Banners are attached to the main window behind other views for 5 seconds.

* *Preload > Outside Screen Bounds -* Preload the banner outside of the screen's bounds.  Specifically, origin.x is set to the screen width.

* *Preload > In Detached Parent View -* Preload the banner inside a parent view that's not part of the view hierarchy.

* *Preload > Wait for Completion Event -* Preload the banner until it sends a completion event to the app.  When disabled the creative will load for a constant amount of time (currently 5s).

* *Preload > Hide Afterwards -* Hide the banner after preloading finishes, and then unhide when presented.

* *Inject Visibility Javascript -* Inject javascript when the ad is presented to let it know that it's *actually* visible.  Creatives can be modified to delay autoplay until this happens.

* *Auto-Present -* Automatically display ads when they finish downloading/preloading.  Turn this off to help isolate activity that happens before ads appear.

* *Manual Impressions -* Manually report impressions rather than letting the SDK do it automatically.
