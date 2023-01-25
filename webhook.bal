import ballerinax/trigger.asgardeo;
import ballerina/log;
import ballerina/http;
import ballerinax/googleapis.gmail;

configurable asgardeo:ListenerConfig config = ?;

configurable string googleClientId = ?;
configurable string googleClientSecret = ?;
configurable string googleRefreshToken = ?;
configurable string receiverName = ?;

listener http:Listener httpListener = new(8090);
listener asgardeo:Listener webhookListener =  new(config,httpListener);

service asgardeo:RegistrationService on webhookListener {
  
    remote function onAddUser(asgardeo:AddUserEvent event ) returns error? {
      log:printInfo(event.toJsonString());
      error? err = sendMail(receiverName);
      if (err is error) {
          log:printInfo(err.message());
      }
     return;
    }
    
    remote function onConfirmSelfSignup(asgardeo:GenericEvent event ) returns error? {
      log:printInfo(event.toJsonString());
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
