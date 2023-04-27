//
//  FolderViewController.swift
//  FileManager
//
//  Created by Beliy.Bear on 24.04.2023.
//

import UIKit
import FMPhotoPicker
import MobileCoreServices

class FolderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FMPhotoPickerViewControllerDelegate {
    
    var folderURL: URL!
    private let tableView = UITableView()
    private var documents: [URL] = []
    var currentLetter: Character = "a"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = folderURL.lastPathComponent
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotoTapped))
        setupTableView()
        loadDocuments()
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: .settingsDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .settingsDidChange, object: nil)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func loadDocuments() {
        let fileManager = FileManager.default
        let fileURLs = try! fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        documents = fileURLs
        updateSettings()
    }

    @objc private func addPhotoTapped() {
        var config = FMPhotoPickerConfig()
        config.selectMode = .single
        config.mediaTypes = [.image]
        let picker = FMPhotoPickerViewController(config: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func updateSettings() {
        let showSize = UserDefaults.standard.bool(forKey: "Показывать размер фотографии")
        let sortByName = UserDefaults.standard.bool(forKey: "Сортировка")
        if sortByName {
            documents.sort { $0.lastPathComponent < $1.lastPathComponent }
        } else {
            documents.sort { $0.lastPathComponent > $1.lastPathComponent }
        }
        if showSize {
            tableView.reloadData()
        }
    }

    @objc private func settingsDidChange() {
        loadDocuments()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let document = documents[indexPath.row]
        let showSize = UserDefaults.standard.bool(forKey: "Показывать размер фотографии")
        
        // Determine the file type and set the appropriate icon
        let fileExtension = document.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeRetainedValue() {
            if UTTypeConformsTo(uti, kUTTypeImage) {
                cell.imageView?.image = UIImage(systemName: "photo")
            } else if UTTypeConformsTo(uti, kUTTypeFolder) {
                cell.imageView?.image = UIImage(systemName: "folder")
            } else {
                cell.imageView?.image = UIImage(systemName: "doc")
            }
        }
        
        if showSize {
            if let fileSize = try? document.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
                cell.textLabel?.text = document.lastPathComponent + " (\(fileSizeString))"
            } else {
                cell.textLabel?.text = document.lastPathComponent
            }
        } else {
            cell.textLabel?.text = document.lastPathComponent
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedURL = documents[indexPath.row]
        let isDirectory = (try? selectedURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false

        if isDirectory {
            let folderVC = FolderViewController()
            folderVC.folderURL = selectedURL
            navigationController?.pushViewController(folderVC, animated: true)
        } else if let imageData = try? Data(contentsOf: selectedURL), let image = UIImage(data: imageData) {
            let imageVC = ImageViewController()
            imageVC.image = image
            navigationController?.pushViewController(imageVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: documents[indexPath.row])
                documents.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        guard let image = photos.first else { return }
        let imageName = getNextImageName(in: folderURL)
        let imagePath = folderURL.appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        documents.append(imagePath)
        tableView.reloadData()
        dismiss(animated: true)
    }
    
    func getRandomString(length: Int) -> String {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        let randomString = String((0..<length).map { _ in alphabet.randomElement()! })
        return randomString
    }

    func getNextImageName(in folderURL: URL) -> String {
        let imageName = "\(getRandomString(length: 6)).jpg"
        return imageName
    }
    
    private func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
}
