//
//  SettingsViewController.swift
//  HDR-Bug-Repro
//
//  Created by Josh Pyles on 11/19/20.
//

import UIKit
import Photos
import AVFoundation

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var fileFormatSegmentedControl: UISegmentedControl?
    @IBOutlet weak var deliveryModeSegmentedControl: UISegmentedControl?
    @IBOutlet weak var optimizeForNetworkToggle: UISwitch?
    @IBOutlet weak var presetPicker: UIPickerView?
    
    let fileFormats: [AVFileType] = [.mov, .mp4, .m4v]
    
    let deliveryModes: [PHVideoRequestOptionsDeliveryMode] = [.automatic, .highQualityFormat, .mediumQualityFormat, .fastFormat]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentFormat = Exporter.sharedInstance.outputFileType
        let currentDeliveryMode = Exporter.sharedInstance.deliveryMode
        fileFormatSegmentedControl?.selectedSegmentIndex = fileFormats.firstIndex(of: currentFormat) ?? 0
        deliveryModeSegmentedControl?.selectedSegmentIndex = deliveryModes.firstIndex(of: currentDeliveryMode) ?? 0
        optimizeForNetworkToggle?.isOn = Exporter.sharedInstance.shouldOptimizeForNetworkUse
        if let presetIndex = Exporter.allPresets.firstIndex(of: Exporter.sharedInstance.exportPreset) {
            presetPicker?.selectRow(presetIndex, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func fileFormatToggled(sender: UISegmentedControl) {
        let format = fileFormats[sender.selectedSegmentIndex]
        Exporter.sharedInstance.outputFileType = format
    }
    
    @IBAction func deliveryModeToggled(sender: UISegmentedControl) {
        let deliveryMode = deliveryModes[sender.selectedSegmentIndex]
        Exporter.sharedInstance.deliveryMode = deliveryMode
    }
    
    @IBAction func optimizeForNetworkToggled(sender: UISwitch) {
        Exporter.sharedInstance.shouldOptimizeForNetworkUse = sender.isOn
    }
    
}

extension SettingsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Exporter.allPresets.count
    }
    
}

extension SettingsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Exporter.name(forPreset: Exporter.allPresets[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Exporter.sharedInstance.exportPreset = Exporter.allPresets[row]
    }
    
}
