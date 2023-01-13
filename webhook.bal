import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;
import ballerinax/googleapis.gmail;

configurable asgardeo:ListenerConfig config = ?;

configurable string googleClientId = "732184870155-gk8fmodkvhemknm9jfu3b5htss25koli.apps.googleusercontent.com";
configurable string googleClientSecret = "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";
configurable string googleRefreshToken = "1//0gXNii7rE0aT_CgYIARAAGBASNwF-L9IrUPKdGFqSj0Xe7_EMjQblAEu9H3xM0U_iFuwNPc7BrO81xZ_qlY4FtYxykyZ4ygieoms";

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:RegistrationService on webhookListener {
  
    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {
      log:printInfo(event.toJsonString());
    }
    
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {
      log:printInfo(event.toJsonString());
      string receiverName = "shalitha@dk3klkvd.mailosaur.net";
      error? err = sendMail(receiverName);
      if (err is error) {
          log:printInfo(err.message());
      }
     return;
    }
    
    remote function onAcceptUserInvite(asgardeo:GenericEvent event ) returns error? {
      log:printInfo(event.toJsonString());
    }
}

service /ignore on httpListener {}

function sendMail(string recipientEmail) returns error? {
   string emailTemplate = "A user self registered";
   gmail:ConnectionConfig gmailConfig = {
       auth: {
           refreshUrl: gmail:REFRESH_URL,
           refreshToken: googleRefreshToken,
           clientId: googleClientId,
           clientSecret: googleClientSecret
       }
   };
   gmail:Client gmailClient = check trap new (gmailConfig);
   string userId = "me";
   gmail:MessageRequest messageRequest = {
       recipient: recipientEmail,
       subject: "Welcome to fleet.inc",
       messageBody: emailTemplate,
       contentType: gmail:TEXT_HTML,
       sender: "Fleet Inc <shali23shri@gmail.com>"
   };
   gmail:Message m = check gmailClient->sendMessage(messageRequest, userId = userId);
   log:printInfo(m.toJsonString());
}
