#tag Module
Protected Module Helper
	#tag Method, Flags = &h0
		Sub MsgBox(title as Text, message as text = "")
		  dim msg as new iOSMessageBox
		  msg.Buttons = Array("Ok")
		  msg.Title = title
		  msg.Message = message
		  msg.Show
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShowURL(url As Text) As Boolean
		  // NSString* launchUrl = @"http://www.xojo.com/";
		  // [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
		  
		  Declare Function NSClassFromString Lib "Foundation" (name As CFStringRef) As Ptr
		  Declare Function sharedApplication Lib "UIKit" Selector "sharedApplication" (obj As Ptr) As Ptr
		  Dim sharedApp As Ptr = sharedApplication(NSClassFromString("UIApplication"))
		  
		  // https://developer.apple.com/library/mac/documentation/UIKit/Reference/Foundation/Classes/NSURL_Class/#//apple_ref/occ/clm/NSURL/URLWithString:
		  Declare Function URLWithString Lib "Foundation" Selector "URLWithString:" ( id As Ptr, URLString As CFStringRef ) As Ptr
		  Dim nsURL As Ptr = URLWithString(NSClassFromString("NSURL"), url)
		  
		  // https://developer.apple.com/Library/ios/documentation/UIKit/Reference/UIApplication_Class/index.html#//apple_ref/occ/instm/UIApplication/openURL:
		  Declare Function openURL Lib "UIKit" Selector "openURL:" (id As Ptr, nsurl As Ptr) As Boolean
		  Return openURL(sharedApp, nsURL)
		  
		End Function
	#tag EndMethod


	#tag ViewBehavior
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
	#tag EndViewBehavior
End Module
#tag EndModule
