#tag IOSView
Begin iosView View1
   BackButtonTitle =   ""
   Compatibility   =   ""
   Left            =   0
   NavigationBarVisible=   True
   TabIcon         =   ""
   TabTitle        =   ""
   Title           =   "iOS Example"
   Top             =   0
   Begin iOSButton Button1
      AccessibilityHint=   ""
      AccessibilityLabel=   ""
      AutoLayout      =   Button1, 7, , 0, False, +1.00, 1, 1, 100, 
      AutoLayout      =   Button1, 9, <Parent>, 9, False, +1.00, 1, 1, 0, 
      AutoLayout      =   Button1, 3, , 0, False, +1.00, 1, 1, 124, 
      AutoLayout      =   Button1, 8, , 0, False, +1.00, 1, 1, 30, 
      Caption         =   "Rate in app"
      Enabled         =   True
      Height          =   30.0
      Left            =   110
      LockedInPosition=   False
      Scope           =   0
      TextColor       =   &c007AFF00
      TextFont        =   ""
      TextSize        =   0
      Top             =   124
      Visible         =   True
      Width           =   100.0
   End
   Begin iOSButton Button2
      AccessibilityHint=   ""
      AccessibilityLabel=   ""
      AutoLayout      =   Button2, 7, , 0, False, +1.00, 1, 1, 179, 
      AutoLayout      =   Button2, 9, <Parent>, 9, False, +1.00, 1, 1, 0, 
      AutoLayout      =   Button2, 3, <Parent>, 3, False, +1.00, 1, 1, 198, 
      AutoLayout      =   Button2, 8, , 0, False, +1.00, 1, 1, 30, 
      Caption         =   "Rate on App Store"
      Enabled         =   True
      Height          =   30.0
      Left            =   70
      LockedInPosition=   False
      Scope           =   0
      TextColor       =   &c007AFF00
      TextFont        =   ""
      TextSize        =   0
      Top             =   198
      Visible         =   True
      Width           =   179.0
   End
End
#tag EndIOSView

#tag WindowCode
#tag EndWindowCode

#tag Events Button1
	#tag Event
		Sub Action()
		  
		  
		  If app.iRate.appStoreID = 0 Then
		    
		    MsgBox("iRate is not ready", "Please set the AppStoreID in App.Open event")
		    
		    Return
		  End If
		  
		  App.iRate.promptForRating
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Button2
	#tag Event
		Sub Action()
		  
		  
		  If app.iRate.appStoreID = 0 Then
		    
		    MsgBox("iRate is not ready", "Please set the AppStoreID in App.Open event")
		    
		    Return
		  End If
		  
		  #If DebugBuild
		    
		    MsgBox("Error", "App Store isn't available in the debugger." + &u0A + "Try this button on a real device.")
		    Return
		  #EndIf
		  
		  app.iRate.openRatingsPageInAppStore
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="BackButtonTitle"
		Group="Behavior"
		Type="Text"
		EditorType="MultiLineEditor"
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
		Name="Name"
		Visible=true
		Group="ID"
		Type="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="NavigationBarVisible"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		Type="String"
	#tag EndViewProperty
	#tag ViewProperty
		Name="TabIcon"
		Group="Behavior"
		Type="iOSImage"
	#tag EndViewProperty
	#tag ViewProperty
		Name="TabTitle"
		Group="Behavior"
		Type="Text"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Group="Behavior"
		Type="Text"
		EditorType="MultiLineEditor"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Top"
		Visible=true
		Group="Position"
		InitialValue="0"
		Type="Integer"
	#tag EndViewProperty
#tag EndViewBehavior
