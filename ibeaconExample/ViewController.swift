//
//  ViewController.swift
//  ibeaconExample
//
//  Created by 陳仲堯 on 2018/10/11.
//  Copyright © 2018年 陳仲堯. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var beaconInformationLabel: UILabel! {
        didSet {
            beaconInformationLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var stateLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 檢查裝置是否有偵測功能
        locationManager.delegate = self
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        registerBeaconRegionWithUUID(uuidString: "B0702880-A295-A8AB-F734-031A98A512DE", identifier: "test", isMonitor: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func registerBeaconRegionWithUUID(uuidString: String, identifier: String, isMonitor: Bool) {
        
        // 設定偵測的beacon
        let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuidString)!, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        if isMonitor {
            locationManager.startMonitoring(for: region)
        } else {
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            view.backgroundColor = UIColor.white
            beaconInformationLabel.text = "Beacon狀態"
            stateLabel.text = "是否在region內"
        }
    }
    // 這區域可以被偵測的beacon
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        manager.requestState(for: region)
//    }
    
    //檢查是否已在範圍內
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside {
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                stateLabel.text = "已在region中"
                
                notification(message: "inside")
            } else {
                print("不支援ranging")
            }
        } else {
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
            view.backgroundColor = UIColor.white
        }
    }
    /*
     方法一：使用didEnter,didExit來偵測進入時機
     缺點為可靠性不高，因這兩種方法是偵測UUID，而不同區域的UUID是可以相同的
     */
    //進入範圍
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if CLLocationManager.isRangingAvailable() {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        } else {
            print("不支援ranging")
        }
        
        stateLabel.text = "Entering region"
        notification(message: "enter")
    }

    //離開範圍
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        view.backgroundColor = UIColor.white
        stateLabel.text = "Exiting region"
        notification(message: "exit")
    }
    
    /*
     方法二：使用didRangeBeacons，有較精準的範圍偵測
     */
    //顯示beacon距離及訊號強度
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            if let nearstBeacon = beacons.first {
                var proximity = ""
                
                switch nearstBeacon.proximity {
                case CLProximity.immediate:
                    proximity = "Very close"
                    
                case CLProximity.near:
                    proximity = "Near"
                    
                case CLProximity.far:
                    proximity = "far"
                    
                default:
                    proximity = "unknow"
                }
                beaconInformationLabel.text = "Proximity: \(proximity)\n Accuracy: \(nearstBeacon.accuracy)\n RSSI: \(nearstBeacon.rssi)"
                view.backgroundColor = UIColor.red
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Fail: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitor Fail: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Ranging Beacon Fail: \(error.localizedDescription)")
    }
    
    func notification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "IBeacon Test"
        content.body = message
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

