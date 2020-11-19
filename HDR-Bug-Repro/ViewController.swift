//
//  ViewController.swift
//  HDR-Bug-Repro
//
//  Created by Josh Pyles on 11/18/20.
//

import UIKit
import PhotosUI
import AVKit

class ViewController: UITableViewController {
    
    @IBOutlet var addItem: UIBarButtonItem?
    @IBOutlet var loadingItem: UIBarButtonItem?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    
    let presetName: String = AVAssetExportPreset960x540
    
    var player: AVPlayer?
    
    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    var files: [URL] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                activityIndicatorView?.startAnimating()
                navigationItem.rightBarButtonItem = loadingItem
            } else {
                navigationItem.rightBarButtonItem = addItem
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        loadFiles()
    }
    
    @IBAction func addTapped() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .videos
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = files[indexPath.row]
        print("Selected \(file.relativePath)")
        let player = AVPlayer(url: file.absoluteURL)
        self.player = player
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true, completion: nil)
        player.play()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let file = files[indexPath.row]
        cell.textLabel?.text = file.lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            self.deleteItem(at: indexPath, completion: completion)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func deleteItem(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let file = files[indexPath.row]
        do {
            try FileManager.default.removeItem(at: file)
            loadFiles()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    func loadFiles() {
        if let documentsDirectory = directory {
            let files = try? FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: [.creationDateKey], options: [])
            let sortedFiles = files?.sorted { a, b -> Bool in
                let aCreatedAt = try? FileManager.default.attributesOfItem(atPath: a.relativePath)[.creationDate] as? Date
                let bCreatedAt = try? FileManager.default.attributesOfItem(atPath: b.relativePath)[.creationDate] as? Date
                return aCreatedAt ?? .distantPast > bCreatedAt ?? .distantPast
            }
            self.files = sortedFiles ?? []
        }
    }
    
    func didSelectAsset(withIdentifier identifier: String) {
        guard let directory = directory else { return }
        let filename = Exporter.sharedInstance.filename()
        let url = directory.appendingPathComponent(filename)
        isLoading = true
        Exporter.sharedInstance.export(assetIdentifier: identifier, to: url) {
            self.isLoading = false
            self.loadFiles()
        }
    }

}

extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        if let assetIdentifier = results.compactMap(\.assetIdentifier).first {
            didSelectAsset(withIdentifier: assetIdentifier)
        }
    }
    
}

