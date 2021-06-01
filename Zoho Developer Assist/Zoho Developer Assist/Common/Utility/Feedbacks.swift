//
//  Feedbacks.swift
//  Zoho Developer Assist
//
//  Created by Tharun P on 01/06/21.
//

import AVFoundation
import UserNotifications

func completedSound()
{
    var filePath: String?
    filePath = Bundle.main.path(forResource: "CompletedSound", ofType: "aiff")          // AlertSound
    let fileURL = URL(fileURLWithPath: filePath!)
    var soundID:SystemSoundID = 0
    AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
    AudioServicesPlaySystemSound(soundID)
}

func showLocalNotification(title: String, subtitle: String)
{
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("All set!")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    content.sound = UNNotificationSound.default

    // show this notification five seconds from now
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

    // choose a random identifier
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    // add our notification request
    UNUserNotificationCenter.current().add(request)
    
}
