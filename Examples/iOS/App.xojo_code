#tag Class
Protected Class App
Inherits IOSApplication
	#tag CompatibilityFlags = TargetIOS
	#tag Event
		Sub Open()
		  //Make sure to correctly set the appStoreID
		  
		  
		  //iRate system
		  iRate = jly_iRate.sharedInstance
		  iRate.init
		  iRate.previewMode = False //Set to True to preview the message
		  iRate.daysUntilPrompt = 5.0 //Don't prompt on first day
		  iRate.eventsUntilPrompt = 20
		  iRate.appStoreID = 1208312901 //Very important to set this value
		  iRate.promptAtLaunch = False
		  iRate.remindPeriod = 50.0 //User will be reminded every 50 days
		End Sub
	#tag EndEvent


	#tag Property, Flags = &h0
		iRate As jly_iRate
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
