<cfcomponent extends="CFIDE.websocket.ChannelListener" output="false">
	<cffunction name="allowSubscribe" access="public" returnType="boolean">
		<cfargument name="subscriberInfo">

		<cfreturn createObject("component","login").wsSubscribeToken(subscriberInfo.channelName)>
	</cffunction>

	<cffunction name="afterUnsubscribe">
		<cfargument name="subscriberInfo">

	</cffunction>

	<cffunction name="canSendMessage" access="public" returnType="boolean">
		<cfargument name="message">
		<cfargument name="subscriberInfo">
		<cfargument name="publisherInfo">

		<!--- 
			Coldfusion envía el message al subcanal destino (publisherInfo.channelName) 
			y a todos los supercanales correspondientes (subscriberInfo)
			Esta verificación permite enviarlos únicamente al subcanal destino (subscriberInfo = publisherInfo)
		--->
		<cfreturn (subscriberInfo.channelName EQ publisherInfo.channelName)>
	</cffunction>
</cfcomponent>

