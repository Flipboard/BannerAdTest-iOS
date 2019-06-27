# BannerAdTest

## Overview

A minimal app that fetches and displays banner ads.  The goal is to test various preloading techniques and debug visibility issues like early auto-play.  The UI is designed to mimic Flipboard.

## CocoaPods

This project uses [Cocoapods](https://guides.cocoapods.org/using/getting-started.html) to import the iOS GoogleMobileAds SDK.  Run the `pod update` command and then open the generated `.xcworkspace` file.

## Functionality

The app has a bottom bar with three buttons:

### Reset

Cancels in-progress fetching/preloading and deletes downloaded ads.


### Fetch/Present

Fetches a new ad with the unit ID selected in Settings. 
 
If "Auto-Present" is off, the "Fetch" button will turn into a "Present" button once the ad finishes fetching/preloading.

### Settings

<dl>
  <dt>Unit ID</dt>
  <dd>The unit ID used for ad fetches.</dd>
</dl>

<dl>
  <dt>Preload</dt>
  <dd>Enables a hack that forces banner ads to preload before they appear.  Banners are attached to the main window behind other views until they finish preloading, or a max time is reached (5 seconds).
	<dl>
	  <dt>Outside Screen Bounds</dt>
	  <dd>Preload the banner outside of the screen's bounds.  Specifically, origin.x is set to the screen width.</dd>
	</dl>
	<dl>
	  <dt>In Detached Parent View</dt>
	  <dd>Preload the banner inside a parent view that's not part of the view hierarchy.</dd>
	</dl>
	<dl>
	  <dt>Wait for Completion Event</dt>
	  <dd>Preload the banner until it sends a completion event to the app.  When disabled the creative will load for a constant amount of time (currently 5 seconds).</dd>
	</dl>
  </dd>
</dl>

<dl>
  <dt>Hide Afterwards</dt>
  <dd>Hide the banner after downloading and preloading finishes, and then unhide when presented.</dd>
</dl>

<dl>
  <dt>Remove From Parent Afterwards</dt>
  <dd>Remove the banner from its parent view after downloading and preloading finishes.</dd>
</dl>

<dl>
  <dt>Inject Visibility Javascript</dt>
  <dd>Inject javascript when the ad is presented to let it know that it's *actually* visible.  Creatives can be modified to delay autoplay until this happens.</dd>
</dl>

<dl>
  <dt>Auto-Present</dt>
  <dd>Automatically display ads when they finish downloading and preloading.  Turn this off to help isolate activity that happens before ads appear.</dd>
</dl>

<dl>
  <dt>Manual Impressions</dt>
  <dd> Manually report impressions rather than letting the SDK do it automatically.</dd>
</dl>
