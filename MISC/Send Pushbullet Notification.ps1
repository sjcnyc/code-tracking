#####################################################################################
#Script Created by Phillip Marshall													#
#Creation Date 6/5/14																#
#Revision 2																			#
#Revisions Changes - Added Commenting.												#
#																					#
#Description - This Script will create a pushbullet notification and send to all	#
#devices for a given API key.														#
#																					#
#####################################################################################

# specify the pushbullet api key(s)
$pushbulletApiKeys = @('')
$message = "2nd test"
# function to pushbullet notifications
function sendPushBulletNotification($apiKey, $message) {
    # convert api key into PSCredential object
    $credentials = New-Object System.Management.Automation.PSCredential ($apiKey, (ConvertTo-SecureString $apiKey -AsPlainText -Force))
    # get list of registered devices
    $pushDevices = Invoke-RestMethod -Uri 'https://api.pushbullet.com/api/devices' -Method Get -Credential $credentials
    # loop through devices and send notification
    foreach ($device in $pushDevices.devices) {
         # build the notification
         $notification = @{
            device_iden = $device.iden
            type = 'note'
            title = 'Labtech Alert'
            body = $message
        }
         # push the notification
        Invoke-RestMethod -Uri 'https://api.pushbullet.com/api/pushes' -Body $notification -Method Post -Credential $credentials
    }
}
# send the notification(s)
foreach ($apiKey in $pushbulletApiKeys) {
    sendPushBulletNotification $apiKey $message
}
