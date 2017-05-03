#tag Class
Protected Class jly_iRate
	#tag Method, Flags = &h1
		Protected Sub connectionSucceeded()
		  
		  if self.CheckingForAppStoreID then
		    
		    //no longer checking
		    self.checkingForPrompt = False
		    self.checkingForAppStoreID = False
		    
		    //Open app store
		    openRatingsPageInAppStore()
		    
		  Elseif self.checkingForPrompt then
		    
		    //no longer checking
		    self.checkingForPrompt = False
		    
		    //Confirm with delegate
		    if shouldPromptForRating <> nil and not shouldPromptForRating.Invoke() then
		      
		      if self.verboseLogging then
		        xojo.System.DebugLog("iRate did not display the rating prompt because the iRateShouldPromptForRating delegate method returned NO")
		        
		      end if
		      Return
		    end if
		    
		    self.promptForRating()
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function declinedAnyVersion() As Boolean
		  
		  
		  Dim txt As Text = StandardUserDefaultsTextForKey(kDeclinedVersionKey)
		  Return txt.Length <> 0
		  'Return Foundation.NSUserDefaults.StandardUserDefaults.TextForKey(kDeclinedVersionKey).Length <> 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub declineThisVersion()
		  
		  self.declinedThisVersion = True
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub incrementEventCount()
		  
		  self.eventCount = self.eventCount + 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub incrementUseCount()
		  
		  self.usesCount = self.usesCount + 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub init()
		  
		  declare function NSClassFromString lib "Foundation.framework" (clsName as CFStringRef) as ptr
		  declare function mainBundle lib "Foundation.framework" selector "mainBundle" (clsRef as ptr) as ptr
		  declare function objectForInfoDictionaryKey lib "Foundation.framework" selector "objectForInfoDictionaryKey:" _
		  (obj_id as ptr, key as CFStringRef) as CFStringRef
		  
		  Declare Function getbundleIdentifier lib "Foundation.framework" selector "bundleIdentifier" (id as ptr) as CFStringRef
		  
		  
		  self.appStoreCountry = xojo.core.locale.Current.Identifier
		  
		  
		  
		  //application version (use short version preferentially)
		  self.applicationVersion = objectForInfoDictionaryKey(mainBundle(NSClassFromString("NSBundle")), "CFBundleShortVersionString")
		  if self.applicationVersion.Empty then
		    self.applicationVersion = objectForInfoDictionaryKey(mainBundle(NSClassFromString("NSBundle")), "CFBundleVersionKey")
		  end if
		  
		  //Application name
		  self.applicationName = objectForInfoDictionaryKey(mainBundle(NSClassFromString("NSBundle")), "CFBundleDisplayName")
		  if self.applicationName.Empty then
		    self.applicationName = objectForInfoDictionaryKey(mainBundle(NSClassFromString("NSBundle")), "CFBundleName")
		  end if
		  
		  
		  //bundle id
		  self.applicationBundleID = getbundleIdentifier(mainBundle(NSClassFromString("NSBundle")))
		  
		  
		  //default settings
		  'self.useAllAvailableLanguages = True
		  self.promptForNewVersionIfUserRated = True
		  self.onlyPromptIfLatestVersion = True
		  self.onlyPromptIfMainWindowIsAvailable = True
		  self.promptAtLaunch = False
		  self.usesUntilPrompt = 10
		  self.eventsUntilPrompt = 10
		  self.daysUntilPrompt = 10.0
		  self.usesPerWeekForPrompt = 0.0
		  self.remindPeriod = 1.0
		  self.verboseLogging = False
		  self.previewMode = False
		  
		  #if DebugBuild
		    self.verboseLogging = True
		    xojo.System.DebugLog("iRate verbose logging enabled.")
		  #endif
		  
		  
		  'Dim defaults As Foundation.NSUserDefaults = Foundation.NSUserDefaults.StandardUserDefaults
		  'Dim defaults As ptr = StandardUserDefaults()
		  'Dim lastUsedVersion As Text = defaults.TextForKey(kLastVersionUsedKey)
		  
		  Dim lastUsedVersion As Text = StandardUSerDefaultsTextForKey(kLastVersionUsedKey)
		  
		  if firstUsed is nil or lastUsedVersion <> self.applicationVersion then
		    
		    'defaults.SetTextForKey(self.applicationVersion, kLastVersionUsedKey)
		    StandardUserDefaultsSetTextForKey(self.applicationVersion, kLastVersionUsedKey)
		    
		    if firstUsed is nil or ratedAnyVersion then
		      
		      //Reset defaults
		      firstUsed = xojo.core.date.Now
		      usesCount = 0
		      eventCount = 0
		      lastReminded = nil
		      
		      
		    end if
		    
		    
		  end if
		  
		  self.incrementUseCount()
		  if self.promptAtLaunch then
		    self.promptifAllCriteriaMet()
		  end if
		End Sub
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h0
		Delegate Function iRateShouldPromptForRating() As Boolean
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h0
		Sub logEvent(deferPrompt As Boolean = False)
		  
		  self.incrementEventCount()
		  if not deferPrompt then
		    self.promptIfAllCriteriaMet()
		  end if
		End Sub
	#tag EndMethod

	#tag ExternalMethod, Flags = &h0
		Declare Function NSClassFromString Lib "Foundation.framework" (clsName as CFStringRef) As Ptr
	#tag EndExternalMethod

	#tag Method, Flags = &h0, Description = 4F70656E732074686520526174696E6773207061676520696E204170702053746F7265
		Sub openRatingsPageInAppStore()
		  
		  if self.verboseLogging then
		    
		    xojo.System.DebugLog("iRate will open the App Store ratings page using the following URL: " + self.ratingsURL)
		    
		  end if
		  
		  Declare Function NSClassFromString Lib "Foundation" (name As CFStringRef) As Ptr
		  Declare Function sharedApplication Lib "UIKit" Selector "sharedApplication" (obj As Ptr) As Ptr
		  Dim sharedApp As Ptr = sharedApplication(NSClassFromString("UIApplication"))
		  
		  // https://developer.apple.com/library/mac/documentation/UIKit/Reference/Foundation/Classes/NSURL_Class/#//apple_ref/occ/clm/NSURL/URLWithString:
		  Declare Function URLWithString Lib "Foundation" Selector "URLWithString:" ( id As Ptr, URLString As CFStringRef ) As Ptr
		  Dim nsURL As Ptr = URLWithString(NSClassFromString("NSURL"), self.ratingsURL)
		  
		  // https://developer.apple.com/Library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/occ/instm/UIApplication/openURL:
		  Declare Function openURL Lib "UIKit" Selector "openURL:" (id As Ptr, nsurl As Ptr) As Boolean
		  
		  if not openURL(sharedApp, nsURL) then
		    
		    Dim message As Text
		    message = "iRate was unable to open the specified ratings URL: " + self.ratingsURL
		    
		    #if DebugBuild
		      message = "iRate could not open the ratings page because the App Store is not available on the iOS simulator"
		    #endif
		    
		    xojo.System.DebugLog(message)
		    
		    
		  Else
		    
		    //consider that if user opened the rating page, he rated the app
		    self.ratedThisVersion = True
		    
		  end if
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub promptButtonAction(msgbox As iOSMessageBox, buttonIndex As Integer)
		  
		  #Pragma Unused msgbox
		  
		  RemoveHandler visibleAlert.ButtonAction, WeakAddressOf promptButtonAction
		  
		  
		  if buttonIndex = 0 then
		    
		    self.declineThisVersion()
		    
		  Elseif buttonIndex = 1 then
		    
		    self.rate()
		    
		  Elseif buttonIndex = 2 then
		    
		    self.remindLater()
		    
		  end if
		  
		  
		  //Release alert
		  self.visibleAlert = nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub promptForRating()
		  
		  if self.visibleAlert is nil then
		    
		    
		    #if TargetIOS
		      
		      
		      declare function currentDevice_ lib "UIKit.framework" selector "currentDevice" (clsRef as ptr) as ptr
		      declare function systemversion_ lib "UIKit.framework" selector "systemVersion" (obj_id as ptr) as CFStringRef
		      Dim device as Ptr = currentDevice_(NSClassFromString("UIDevice"))
		      Dim systemVersion As Text = systemversion_(device)
		      Dim sSystemVersion As Double
		      
		      try
		        sSystemVersion = Double.FromText(systemVersion)
		      Catch
		      end try
		      
		      //Use new API
		      if sSystemVersion >= 10.3 and not defaultOldRatingSystem then
		        
		        
		        declare function NSClassFromString lib "Foundation.framework" (clsName as CFStringRef) as ptr
		        declare sub requestReview_ lib "StoreKit.framework" selector "requestReview" (obj_id as ptr)
		        
		        requestReview_(NSClassFromString("SKStoreReviewController"))
		        
		        
		        if self.verboseLogging then xojo.System.DebugLog("iRate presented new Rating API (SKStoreReviewController)")
		        
		        //consider that user rated the App as there is no response to requestReview
		        self.ratedThisVersion = True
		        Return
		      End if
		      
		      
		      
		      Dim message As Text = self.message
		      
		      Dim msgbox as new iOSMessageBox
		      
		      msgbox = new iOSMessageBox
		      msgbox.Buttons = Array(self.LabelcancelButton, self.LabelrateButton, self.LabelRemindButton)
		      msgbox.Title = messageTitle
		      msgbox.Message = message
		      
		      AddHandler msgbox.ButtonAction, WeakAddressOf promptButtonAction
		      
		      
		      self.visibleAlert = msgbox
		      msgbox.Show
		      
		      if self.verboseLogging then xojo.System.DebugLog("iRate presented Msgbox")
		      
		      
		    #else
		      Break
		      
		    #endif
		    
		  end if
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub promptIfAllCriteriaMet()
		  
		  if self.shouldPromptForRating then
		    
		    self.promptIfNetworkAvailable()
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub promptIfNetworkAvailable()
		  
		  //Available if iOSKit is used
		  'Dim www As new Extensions.Reachability
		  'if www.isNotReachable then
		  'Return
		  'end if
		  
		  promptForRating()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub rate()
		  
		  
		  
		  self.openRatingsPageInAppStore()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ratedAnyVersion() As Boolean
		  
		  Dim txt As Text = StandardUserDefaultsTextForKey(kRatedVersionKey)
		  Return txt.Length <> 0
		  'Return Foundation.NSUserDefaults.StandardUserDefaults.TextForKey(kRatedVersionKey).Length <> 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub remindLater()
		  
		  self.lastReminded = xojo.core.date.Now
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function sharedInstance() As jly_iRate
		  
		  Static sharedInstance as jly_iRate
		  
		  if sharedInstance is nil then
		    sharedInstance = new jly_iRate
		  end if
		  
		  Return sharedInstance
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function shouldPromptForRating() As Boolean
		  
		  If Self.previewMode Then
		    
		    xojo.System.DebugLog("iRate preview mode is enabled - make sure you disable this for release")
		    Return True
		    
		    
		    //Check if we've rated this version
		  Elseif Self.ratedThisVersion Then
		    
		    If Self.verboseLogging Then
		      xojo.System.DebugLog("iRate did not prompt for rating because the user has already rated this version")
		      
		    End If
		    Return False
		    
		    
		    //Check if we've rated any version
		  Elseif (self.ratedAnyVersion and not self.promptForNewVersionIfUserRated) then
		    
		    If Self.verboseLogging Then
		      xojo.System.DebugLog("iRate did not prompt for rating because the user has already rated this app, and promptForNewVersionIfUserRated is disabled")
		      
		    End If
		    Return False
		    
		    //Check if we've declined to rate the app
		  Elseif Self.declinedAnyVersion Then
		    
		    If Self.verboseLogging Then
		      xojo.System.DebugLog "iRate did not prompt for rating because the user has declined to rate the app"
		      
		    End If
		    Return False
		    
		    //check how long we've been using this version
		  elseif (xojo.core.date.now.SecondsFrom1970 - self.firstUsed.SecondsFrom1970) < (self.daysUntilPrompt * SECONDS_IN_A_DAY) then
		    
		    If Self.verboseLogging Then
		      Dim txt as Text = "iRate did not prompt for rating because the app was first used %g days ago"
		      Dim days As Integer = (xojo.core.date.now.SecondsFrom1970 - self.firstUsed.SecondsFrom1970) / SECONDS_IN_A_DAY
		      txt = txt.Replace("%g", days.ToText(xojo.core.locale.Current, "#"))
		      
		      xojo.System.DebugLog txt
		      
		    End If
		    Return False
		    
		    
		    //Check how many times we've used it and the number of significant events
		  Elseif (Self.usesCount < Self.usesUntilPrompt And Self.eventCount < Self.eventsUntilPrompt) Then
		    
		    If Self.verboseLogging Then
		      Dim txt As Text = "iRate did not prompt for rating because the app has only been used %@ times and only %@ events have been logged"
		      txt = txt.Replace("%@", Self.usesCount.ToText)
		      txt = txt.Replace("%@", Self.eventCount.ToText)
		      
		      xojo.System.DebugLog txt
		      
		    End If
		    Return False
		    
		    //Check if usage frequency is high enough
		  Elseif (Self.usesPerWeek < Self.usesPerWeekForPrompt) Then
		    
		    If Self.verboseLogging Then
		      Dim txt As Text = "iRate did not prompt for rating because the app has only been used %g times per week on average since it was installed"
		      txt = txt.Replace("%g", Self.usesPerWeek.ToText(xojo.core.locale.Current, "##.00"))
		      
		      xojo.System.DebugLog txt
		      
		    End If
		    Return False
		    
		    //Check within the reminder period
		  Elseif (Self.lastReminded <> Nil And _
		    (xojo.core.date.Now.SecondsFrom1970 - Self.lastReminded.SecondsFrom1970) < Self.remindPeriod * SECONDS_IN_A_DAY) Then
		    
		    If Self.verboseLogging Then
		      Dim txt As Text = "iRate did not prompt for rating because the user last asked to be reminded less than %g days ago (%d)"
		      txt = txt.Replace("%g", Self.remindPeriod.ToText(xojo.core.locale.Current, "##.00"))
		      
		      Dim d As Double = (xojo.core.date.Now.SecondsFrom1970 - Self.lastReminded.SecondsFrom1970) / SECONDS_IN_A_DAY
		      txt = txt.Replace("%d", d.ToText(xojo.core.locale.Current, "##.00"))
		      
		      xojo.System.DebugLog txt
		      
		    End If
		    Return False
		    
		    
		    
		  End If
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StandardUserDefaults() As ptr
		  
		  
		  declare function standardUserDefaults_ lib "Foundation.framework" selector "standardUserDefaults" (clsRef as ptr) as ptr
		  static ClassRef as ptr = NSClassFromString("NSUserDefaults")
		  declare function alloc lib "Foundation.framework" selector "alloc" (clsRef as ptr) as ptr
		  
		  declare function initWithSuiteName_ lib "Foundation.framework" selector "initWithSuiteName:" (obj_id as ptr, suitename as CFStringRef) as ptr
		  'Dim defaults as ptr = initWithSuiteName_(alloc(ClassRef), standardUserDefaults_(ClassRef)) )
		  Static defaults As ptr = standardUserDefaults_(ClassRef)
		  
		  
		  
		  Return defaults
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StandardUserDefaultsIntegerForKey(defaultName As Text) As Integer
		  Dim defaults As ptr = StandardUserDefaults()
		  
		  
		  declare function integerForKey_ lib "Foundation.framework" selector "integerForKey:" (obj_id as ptr, defaultName as CFStringRef) as Integer
		  Return integerForKey_(defaults, defaultName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StandardUserDefaultsRemoveObjectForKey(defaultName As Text)
		  Dim defaults As ptr = StandardUserDefaults()
		  
		  declare sub removeObjectForKey_ lib "Foundation.framework" selector "removeObjectForKey:" (obj_id as ptr, defaultName as CFStringRef)
		  removeObjectForKey_(defaults, defaultName)
		  
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StandardUserDefaultsSetIntegerForKey(value As Integer, defaultName As Text)
		  Dim defaults As ptr = StandardUserDefaults()
		  
		  
		  declare sub setInteger_ lib "Foundation.framework" selector "setInteger:forKey:" (obj_id as ptr, value as Integer, defaultName as CFStringRef)
		  setInteger_(defaults, value, defaultName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StandardUserDefaultsSetTextForKey(value as Text, defaultName As CFStringRef)
		  Dim defaults As ptr = StandardUserDefaults()
		  
		  
		  declare function stringWithString lib "Foundation.framework" selector "stringWithString:" ( cls as Ptr, value as CFStringRef ) as Ptr
		  
		  
		  Dim s As ptr = stringWithString( NSClassFromString("NSString"), value)
		  
		  declare sub setObject_ lib "Foundation.framework" selector "setObject:forKey:" (obj_id as ptr, value as ptr, defaultName as CFStringRef)
		  setObject_(defaults, s, defaultName)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StandardUserDefaultsSynchronize()
		  
		  
		  declare function synchronize_ lib "Foundation.framework" selector "synchronize" (obj_id as ptr) as Boolean
		  call synchronize_(StandardUserDefaults)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StandardUserDefaultsTextForKey(defaultName As Text) As CFStringRef
		  Dim defaults As ptr = StandardUserDefaults()
		  
		  
		  declare function stringForKey_ lib "Foundation.framework" selector "stringForKey:" (obj_id as ptr, defaultName as CFStringRef) as CFStringRef
		  Return stringForKey_(defaults, defaultName)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function usesPerWeek() As Double
		  Const SECONDS_IN_A_WEEK = 604800.0
		  
		  if self.firstUsed is nil then
		    Return 0.0
		  end if
		  
		  Dim today As xojo.Core.Date = xojo.Core.Date.Now
		  Dim first As xojo.core.Date = self.firstUsed
		  
		  return self.usesCount / (today.SecondsFrom1970-first.SecondsFrom1970) / SECONDS_IN_A_WEEK
		End Function
	#tag EndMethod


	#tag Note, Name = About
		
		
		TODO:
		
		
		handle appstore connectionSucceeded
		handle app Restore from home
	#tag EndNote

	#tag Note, Name = Licence.MD
		
		iRate https://github.com/nicklockwood/iRate
		
		Version 1.11.6, August 4th, 2016
		
		Copyright (C) 2011 Charcoal Design
		
		This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
		
		Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
		
		The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
		
		Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
		
		This notice may not be removed or altered from any source distribution.
	#tag EndNote


	#tag Property, Flags = &h0
		applicationBundleID As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		applicationName As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		applicationVersion As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		appStoreCountry As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		appStoreGenreID As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mappStoreID
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mappStoreID = value
			End Set
		#tag EndSetter
		appStoreID As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		AppStoreIDKey As Text = "iRateAppStoreIDKey"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private checkingForAppStoreID As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private checkingForPrompt As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		daysUntilPrompt As Single
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  Dim txt As Text = StandardUserDefaultsTextForKey(kDeclinedVersionKey)
			  Dim value As Boolean = (txt = self.applicationVersion)
			  
			  'Dim value as boolean = (Foundation.NSUserDefaults.StandardUserDefaults.TextForKey(kDeclinedVersionKey) = self.applicationVersion)
			  
			  Return value
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  if value then
			    StandardUserDefaultsSetTextForKey(self.applicationVersion, kDeclinedVersionKey)
			    'Foundation.NSUserDefaults.StandardUserDefaults.SetTextForKey(self.applicationVersion, kDeclinedVersionKey)
			    
			  else
			    StandardUserDefaultsRemoveObjectForKey(kDeclinedVersionKey)
			    'Foundation.NSUserDefaults.StandardUserDefaults.RemoveObjectForKey(kDeclinedVersionKey)
			    
			  end if
			  
			  StandardUserDefaultsSynchronize()
			  
			  'call Foundation.NSUserDefaults.StandardUserDefaults.Synchronize()
			End Set
		#tag EndSetter
		declinedThisVersion As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 57696C6C206E657665722075736520534B53746F7265526576696577436F6E74726F6C6C657220666F722074686520726174696E67206D657373616765
		#tag Getter
			Get
			  return mdefaultOldRatingSystem
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mdefaultOldRatingSystem = value
			  
			  If Self.verboseLogging Then
			    Dim txt As Text = "iRate will never use SKStoreReviewController on iOS 10.3 and further. Apple may remove applications that do not use SKStoreReviewController for their rating system"
			    
			    xojo.System.DebugLog txt
			    
			  End If
			End Set
		#tag EndSetter
		defaultOldRatingSystem As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  Dim cnt As Integer = StandardUserDefaultsIntegerForKey(kEventCountKey)
			  'Dim cnt As integer = Foundation.NSUserDefaults.StandardUserDefaults.IntegerForKey(kEventCountKey)
			  
			  Return cnt
			  
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  StandardUserDefaultsSetIntegerForKey(value, kEventCountKey)
			  StandardUserDefaultsSynchronize()
			  
			  'Foundation.NSUserDefaults.StandardUserDefaults.SetIntegerForKey(value, kEventCountKey)
			  'call Foundation.NSUserDefaults.StandardUserDefaults.Synchronize()
			End Set
		#tag EndSetter
		eventCount As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		eventsUntilPrompt As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  'Dim txt As text = Foundation.NSUserDefaults.StandardUserDefaults.TextForKey(kFirstUsedKey)
			  Dim txt As text = StandardUserDefaultsTextForKey(kFirstUsedKey)
			  if txt.Empty then
			    Return nil
			  end if
			  
			  Dim d As xojo.core.date = xojo.core.Date.FromText(txt)
			  Return d
			  
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  Dim txt As text = value.ToText()
			  
			  StandardUserDefaultsSetTextForKey(txt, kFirstUsedKey)
			  StandardUserDefaultsSynchronize()
			  
			  'Foundation.NSUserDefaults.StandardUserDefaults.SetTextForKey(txt, kFirstUsedKey)
			  'call Foundation.NSUserDefaults.StandardUserDefaults.Synchronize()
			End Set
		#tag EndSetter
		firstUsed As Xojo.core.date
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  'Dim txt As text = Foundation.NSUserDefaults.StandardUserDefaults.TextForKey(kLastRemindedKey)
			  Dim txt As text = StandardUserDefaultsTextForKey(kLastRemindedKey)
			  if txt.Empty then
			    Return nil
			  end if
			  
			  Dim d As xojo.core.date = xojo.core.Date.FromText(txt)
			  Return d
			  
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  Dim txt As text
			  
			  if value is nil then
			    txt = "2001-01-01"
			  else
			    txt = value.ToText()
			  end if
			  
			  StandardUserDefaultsSetTextForKey(txt, kLastRemindedKey)
			  StandardUserDefaultsSynchronize()
			  
			  'Foundation.NSUserDefaults.StandardUserDefaults.SetTextForKey(txt, kLastRemindedKey)
			  'call Foundation.NSUserDefaults.StandardUserDefaults.Synchronize()
			End Set
		#tag EndSetter
		lastReminded As Xojo.core.date
	#tag EndComputedProperty

	#tag Property, Flags = &h21, Description = 54686973206973206F6E6C79206E656564656420696620796F75722062756E646C65204944206973206E6F7420756E69717565206265747765656E20694F5320616E64204D6163206170702073746F726573
		Private mappStoreID As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mdefaultOldRatingSystem As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  if self.appStoreGenreID = kAppStoreGameGenreID then
			    
			    Return LabelGameMessage.ReplaceAll("%@", applicationName) 'self.applicationName)
			    
			  Else
			    
			    Return LabelAppMessage.ReplaceAll("%@", applicationName) 'self.applicationName)
			    
			  end if
			End Get
		#tag EndGetter
		message As Text
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return LabelMessageTitle.Replace("%@", applicationName) 'self.applicationName)
			End Get
		#tag EndGetter
		messageTitle As Text
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mmessage As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mmessageTitle As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mratingsURL As Text
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			//TODO 
		#tag EndNote
		Protected onlyPromptIfLatestVersion As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		onlyPromptIfMainWindowIsAvailable As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		previewMode As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		promptAtLaunch As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		promptForNewVersionIfUserRated As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  Dim txt As Text = StandardUserDefaultsTextForKey(kRatedVersionKey)
			  Dim value As Boolean = (txt = self.applicationVersion)
			  
			  'Dim value as boolean = (Foundation.NSUserDefaults.StandardUserDefaults.TextForKey(kRatedVersionKey) = applicationVersion)
			  
			  Return value
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  
			  if value then
			    StandardUserDefaultsSetTextForKey(self.applicationVersion, kRatedVersionKey)
			    'Foundation.NSUserDefaults.StandardUserDefaults.SetTextForKey(self.applicationVersion, kRatedVersionKey)
			    
			  Else
			    StandardUserDefaultsRemoveObjectForKey(kRatedVersionKey)
			    'Foundation.NSUserDefaults.StandardUserDefaults.RemoveObjectForKey(kRatedVersionKey)
			    
			  end if
			  StandardUserDefaultsSynchronize()
			  'call Foundation.NSUserDefaults.StandardUserDefaults.Synchronize()
			End Set
		#tag EndSetter
		ratedThisVersion As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if not mratingsURL.Empty then
			    return mratingsURL
			  end if
			  
			  if self.appStoreID.ToText.empty and self.verboseLogging then
			    xojo.System.DebugLog("iRate could not find the App Store ID for this application. If the application is not intended for App Store release then you must specify a custom ratingsURL.")
			    
			  end if
			  
			  Dim URLString As Text
			  
			  #if TargetIOS
			    
			    URLString = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%APPID%&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
			    'URLString = iRateiOS7AppStoreURLFormat
			    
			  #elseif TargetDesktop
			    
			    'URLString = iRateMacAppStoreURLFormat
			    
			  #endif
			  
			  Return URLString.Replace("%APPID%", appStoreID.ToText)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mratingsURL = value
			End Set
		#tag EndSetter
		ratingsURL As Text
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		remindPeriod As Single
	#tag EndProperty

	#tag Property, Flags = &h0
		shouldPromptForRating As iRateShouldPromptForRating
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			//not implemented
		#tag EndNote
		Attributes( hidden ) Private useAllAvailableLanguages As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  
			  Dim cnt As Integer = StandardUserDefaultsIntegerForKey(kUseCountKey)
			  
			  'Dim cnt As integer = Foundation.NSUserDefaults.StandardUserDefaults.IntegerForKey(kUseCountKey)
			  
			  Return cnt
			  
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  
			  StandardUserDefaultsSetIntegerForKey(value, kUseCountKey)
			  StandardUserDefaultsSynchronize()
			  
			  'Foundation.NSUserDefaults.StandardUserDefaults.SetIntegerForKey(value, kUseCountKey)
			  'call Foundation.NSUserDefaults.StandardUserDefaults.Synchronize()
			End Set
		#tag EndSetter
		usesCount As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		usesPerWeekForPrompt As Single
	#tag EndProperty

	#tag Property, Flags = &h0
		usesUntilPrompt As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		verboseLogging As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected visibleAlert As iOSMessageBox
	#tag EndProperty


	#tag Constant, Name = iRateVersionNumber, Type = Text, Dynamic = False, Default = \"1.0.1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kAppStoreGameGenreID, Type = Double, Dynamic = False, Default = \"6014", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDeclinedVersionKey, Type = Text, Dynamic = False, Default = \"iRateDeclinedVersion", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEventCountKey, Type = Text, Dynamic = False, Default = \"iRateEventCount", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFirstUsedKey, Type = Text, Dynamic = False, Default = \"iRateFirstUsed", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLastRemindedKey, Type = Text, Dynamic = False, Default = \"iRateLastReminded", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLastVersionUsedKey, Type = Text, Dynamic = False, Default = \"iRateLastVersionUsed", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRatedVersionKey, Type = Text, Dynamic = False, Default = \"RatedVersionChecked", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kUseCountKey, Type = Text, Dynamic = False, Default = \"iRateUseCount", Scope = Private
	#tag EndConstant

	#tag Constant, Name = LabelAppMessage, Type = Text, Dynamic = True, Default = \"If you enjoy using %@\x2C would you mind taking a moment to rate it\? It won\xE2\x80\x99t take more than a minute. Thanks for your support!", Scope = Public
		#Tag Instance, Platform = Any, Language = fr, Definition  = \"Si vous aimez utiliser %@\x2C n\'oubliez pas de donner votre avis sur l\'App Store. Cela ne prend qu\'une minute. Merci d\'avance pour votre soutien !"
		#Tag Instance, Platform = Any, Language = en, Definition  = \"If you enjoy using %@\x2C would you mind taking a moment to rate it\? It won\xE2\x80\x99t take more than a minute. Thanks for your support!"
		#Tag Instance, Platform = Any, Language = zh_CN, Definition  = \"\xE5\xA6\x82\xE6\x9E\x9C\xE6\x82\xA8\xE8\xA7\x89\xE5\xBE\x97\xE2\x80\x9C%@\xE2\x80\x9D\xE5\xBE\x88\xE5\xA5\xBD\xE7\x94\xA8\xEF\xBC\x8C\xE5\x8F\xAF\xE5\x90\xA6\xE4\xB8\xBA\xE5\x85\xB6\xE8\xAF\x84\xE4\xB8\x80\xE4\xB8\xAA\xE5\x88\x86\xE6\x95\xB0\xEF\xBC\x9F\xE8\xAF\x84\xE5\x88\x86\xE8\xBF\x87\xE7\xA8\x8B\xE5\x8F\xAA\xE9\x9C\x80\xE8\x8A\xB1\xE8\xB4\xB9\xE5\xBE\x88\xE5\xB0\x91\xE7\x9A\x84\xE6\x97\xB6\xE9\x97\xB4\xE3\x80\x82\xE6\x84\x9F\xE8\xB0\xA2\xE6\x82\xA8\xE7\x9A\x84\xE6\x94\xAF\xE6\x8C\x81\xEF\xBC\x81"
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Wenn dir %@ gef\xC3\xA4llt\x2C w\xC3\xBCrdest Du es bitte bewerten\? Dies wird nicht l\xC3\xA4nger als eine Minute dauern. Danke f\xC3\xBCr die Unterst\xC3\xBCtzung!"
	#tag EndConstant

	#tag Constant, Name = LabelCancelButton, Type = Text, Dynamic = True, Default = \"No\x2C Thanks", Scope = Public
		#Tag Instance, Platform = Any, Language = fr, Definition  = \"Non\x2C merci"
		#Tag Instance, Platform = Any, Language = en, Definition  = \"No\x2C Thanks"
		#Tag Instance, Platform = Any, Language = zh_CN, Definition  = \"\xE4\xB8\x8D\xE4\xBA\x86\xEF\xBC\x8C\xE8\xB0\xA2\xE8\xB0\xA2"
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Nein\x2C danke"
	#tag EndConstant

	#tag Constant, Name = LabelGameMessage, Type = Text, Dynamic = True, Default = \"If you enjoy playing %@\x2C would you mind taking a moment to rate it\? It won\xE2\x80\x99t take more than a minute. Thanks for your support!", Scope = Public
		#Tag Instance, Platform = Any, Language = fr, Definition  = \"Si vous aimez jouer \xC3\xA0 %@\x2C n\'oubliez pas de donner votre avis sur l\'App Store. Cela ne prend qu\'une minute. Merci d\'avance pour votre soutien !"
		#Tag Instance, Platform = Any, Language = en, Definition  = \"If you enjoy playing %@\x2C would you mind taking a moment to rate it\? It won\xE2\x80\x99t take more than a minute. Thanks for your support!"
		#Tag Instance, Platform = Any, Language = zh_CN, Definition  = \"\xE5\xA6\x82\xE6\x9E\x9C\xE6\x82\xA8\xE8\xA7\x89\xE5\xBE\x97\xE2\x80\x9C%@\xE2\x80\x9D\xE5\xBE\x88\xE5\xA5\xBD\xE7\x8E\xA9\xEF\xBC\x8C\xE5\x8F\xAF\xE5\x90\xA6\xE4\xB8\xBA\xE5\x85\xB6\xE8\xAF\x84\xE4\xB8\x80\xE4\xB8\xAA\xE5\x88\x86\xE6\x95\xB0\xEF\xBC\x9F\xE8\xAF\x84\xE5\x88\x86\xE8\xBF\x87\xE7\xA8\x8B\xE5\x8F\xAA\xE9\x9C\x80\xE8\x8A\xB1\xE8\xB4\xB9\xE5\xBE\x88\xE5\xB0\x91\xE7\x9A\x84\xE6\x97\xB6\xE9\x97\xB4\xE3\x80\x82\xE6\x84\x9F\xE8\xB0\xA2\xE6\x82\xA8\xE7\x9A\x84\xE6\x94\xAF\xE6\x8C\x81\xEF\xBC\x81"
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Wenn dir %@ gef\xC3\xA4llt\x2C w\xC3\xBCrdest Du es bitte bewerten\? Dies wird nicht l\xC3\xA4nger als eine Minute dauern. Danke f\xC3\xBCr die Unterst\xC3\xBCtzung!"
	#tag EndConstant

	#tag Constant, Name = LabelMessageTitle, Type = Text, Dynamic = True, Default = \"Rate %@", Scope = Public
		#Tag Instance, Platform = Any, Language = en, Definition  = \"Rate %@"
		#Tag Instance, Platform = Any, Language = fr, Definition  = \"Notez %@"
		#Tag Instance, Platform = Any, Language = zh_CN, Definition  = \"\xE4\xB8\xBA\xE2\x80\x9C%@\xE2\x80\x9D\xE8\xAF\x84\xE5\x88\x86"
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Bewerte %@"
	#tag EndConstant

	#tag Constant, Name = LabelRateButton, Type = Text, Dynamic = True, Default = \"Rate It Now", Scope = Public
		#Tag Instance, Platform = Any, Language = en, Definition  = \"Rate It Now"
		#Tag Instance, Platform = Any, Language = fr, Definition  = \"Noter maintenant"
		#Tag Instance, Platform = Any, Language = zh_CN, Definition  = \"\xE7\x8E\xB0\xE5\x9C\xA8\xE5\x8E\xBB\xE8\xAF\x84\xE5\x88\x86"
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Jetzt bewerten"
	#tag EndConstant

	#tag Constant, Name = LabelRemindButton, Type = Text, Dynamic = True, Default = \"Remind Me Later", Scope = Public
		#Tag Instance, Platform = Any, Language = fr, Definition  = \"Me le rappeler ult\xC3\xA9rieurement"
		#Tag Instance, Platform = Any, Language = en, Definition  = \"Remind Me Later"
		#Tag Instance, Platform = Any, Language = zh_CN, Definition  = \"\xE7\xA8\x8D\xE5\x90\x8E\xE5\x86\x8D\xE8\xAF\xB4"
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Sp\xC3\xA4ter erinnern"
	#tag EndConstant

	#tag Constant, Name = SECONDS_IN_A_DAY, Type = Double, Dynamic = False, Default = \"86400", Scope = Private
	#tag EndConstant


	#tag Enum, Name = ErrorCodes, Type = Integer, Flags = &h0
		ErrorBundleIdDoesNotMatchAppStore = 1
		  ErrorApplicationNotFoundOnAppStore
		  ErrorApplicationIsNotLatestVersion
		ErrorCouldNotOpenRatingPageURL
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="applicationBundleID"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="applicationName"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="applicationVersion"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="appStoreCountry"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="appStoreGenreID"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="appStoreID"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AppStoreIDKey"
			Group="Behavior"
			InitialValue="iRateAppStoreIDKey"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="daysUntilPrompt"
			Group="Behavior"
			Type="Single"
		#tag EndViewProperty
		#tag ViewProperty
			Name="declinedThisVersion"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="defaultOldRatingSystem"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="eventCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="eventsUntilPrompt"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="message"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="messageTitle"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="onlyPromptIfMainWindowIsAvailable"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="previewMode"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="promptAtLaunch"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="promptForNewVersionIfUserRated"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ratedThisVersion"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ratingsURL"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="remindPeriod"
			Group="Behavior"
			Type="Single"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="usesCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="usesPerWeekForPrompt"
			Group="Behavior"
			Type="Single"
		#tag EndViewProperty
		#tag ViewProperty
			Name="usesUntilPrompt"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="verboseLogging"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
