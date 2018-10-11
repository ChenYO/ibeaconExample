//
//  ViewController.swift
//  ibeaconExample
//
//  Created by 陳仲堯 on 2018/10/11.
//  Copyright © 2018年 陳仲堯. All rights reserved.
//

import UIKit
import CoreLocation

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
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside {
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                stateLabel.text = "已在region中"
            } else {
                print("不支援ranging")
            }
        } else {
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
            view.backgroundColor = UIColor.white
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if CLLocationManager.isRangingAvailable() {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        } else {
            print("不支援ranging")
        }
        
        stateLabel.text = "Entering region"
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        view.backgroundColor = UIColor.white
        stateLabel.text = "Exiting region"
    }
    
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
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error.localizedDescription)
    }
}

