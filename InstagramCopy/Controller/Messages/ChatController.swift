//
//  ChatController.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 3/29/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


private let reuseIdentifier = "ChatCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var user: User?
    var messages = [Message]()
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    lazy var containerView: MessageInputAccesoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        let containerView = MessageInputAccesoryView(frame: frame)
        containerView.delegate = self
        return containerView
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.keyboardDismissMode = .interactive
        
        configureNavigationBar()
        configureKeyboardObservers()
        
        observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        player?.pause()
        playerLayer?.removeFromSuperlayer()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let messageText = message.messageText {
            height = estimateFrameForText(messageText).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        cell.message = messages[indexPath.item]
        cell.delegate = self
        configureMessage(cell: cell, message: messages[indexPath.item])
        return cell
    }
    
    // MARK: - Handlers
    
    @objc func handleInfoTapped() {
        let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    @objc func handleKeyboardDidShow() {
        scrollToBottom()
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func configureMessage(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if let messageText = message.messageText {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(messageText).width + 32
            cell.frame.size.height = estimateFrameForText(messageText).height + 20
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
            cell.bubbleView.backgroundColor  = UIColor.rgb(red: 0, green: 137, blue: 249)
        } else if let messageImageUrl = message.imageUrl {
            cell.bubbleWidthAnchor?.constant = 200
            cell.messageImageView.loadImage(with: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.textView.isHidden = true
            cell.bubbleView.backgroundColor = .clear
        }
        
        if message.videoUrl != nil {
            guard let videoUrlString = message.videoUrl else { return }
            guard let videoUrl = URL(string: videoUrlString) else { return }
            
            player = AVPlayer(url: videoUrl)
            cell.player = player
            
            playerLayer = AVPlayerLayer(player: player)
            cell.playerLayer = playerLayer
            
            cell.playButton.isHidden = false
        } else {
            cell.playButton.isHidden = true
        }
        
        if message.fromId == currentUid {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
        }
    }
    
    func configureNavigationBar() {
        guard let user = self.user else { return }
        
        navigationItem.title = user.username
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    func configureKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    // MARK: - API
    
    func uploadMessageToServer(withProperties properties: [String: AnyObject]) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // UPDATE: - Safely unwrapped uid to work with Firebase 5
        guard let uid = user.uid else { return }
        
        var values: [String: AnyObject] = ["toId": user.uid as AnyObject, "fromId": currentUid as AnyObject, "creationDate": creationDate as AnyObject, "read": false as AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        let messageRef = MESSAGES_REF.childByAutoId()
        
        // UPDATE: - Safely unwrapped messageKey to work with Firebase 5
        guard let messageKey = messageRef.key else { return }
        
        messageRef.updateChildValues(values) { (err, ref) in
            USER_MESSAGES_REF.child(currentUid).child(uid).updateChildValues([messageKey: 1])
            USER_MESSAGES_REF.child(uid).child(currentUid).updateChildValues([messageKey: 1])
        }
        
        uploadMessageNotification(isImageMessage: false, isVideoMessage: false, isTextMessage: true)
    }
    
    func observeMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerId = self.user?.uid else { return }
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            self.fetchMessage(withMessageId: messageId)
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            })
            self.setMessageToRead(forMessageId: messageId, fromId: message.fromId)
        }
    }
    
    func uploadMessageNotification(isImageMessage: Bool, isVideoMessage: Bool, isTextMessage: Bool) {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = user?.uid else { return }
        var messageText: String!
        
        if isImageMessage {
            messageText = "Sent an image"
        } else if isVideoMessage {
            messageText = "Sent a video"
        } else if isTextMessage{
            messageText = containerView.messageInputTextView.text
        }
        
        let values = ["fromId": fromId,
                      "toId": toId,
                      "messageText": messageText!] as [String : Any]
        
        USER_MESSAGE_NOTIFICATIONS_REF.child(toId).childByAutoId().updateChildValues(values)
    }
    
    func uploadImageToStorage(selectedImage image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let filename = NSUUID().uuidString
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
        
        // UPDATE: - Created constant for ref to work with Firebase 5
        let ref = STORAGE_MESSAGE_IMAGES_REF.child(filename)
        
        ref.putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("DEBUG: Unable to upload image to Firebase Storage")
                return
            }
            
            ref.downloadURL(completion: { (url, error) in
                guard let url = url else { return }
                completion(url.absoluteString)
            })
        }
    }
    
    func sendMessage(withImageUrl imageUrl: String, image: UIImage) {
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width as Any, "imageHeight": image.size.height as Any] as [String: AnyObject]
        
        self.uploadMessageToServer(withProperties: properties)
        self.uploadMessageNotification(isImageMessage: true, isVideoMessage: false, isTextMessage: false)
    }
    
    func uploadVideoToStorage(withUrl url: URL) {
        let filename = NSUUID().uuidString
        
        // UPDATE: - Created constant for ref to work with Firebase 5
        let ref = STORAGE_MESSAGE_VIDEO_REF.child(filename)
        
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print("DEBUG: Failed to upload video to FIRStorage with error: ", error as Any)
                return
            }
            
            ref.downloadURL(completion: { (url, error) in
                guard let url = url else { return }
                guard let thumbnailImage = self.thumbnailImage(forFileUrl: url) else { return }
                let videoUrl = url.absoluteString
                
                self.uploadImageToStorage(selectedImage: thumbnailImage, completion: { (imageUrl) in
                    let properties: [String: AnyObject] = ["imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject, "imageUrl": imageUrl as AnyObject]
                    self.uploadMessageToServer(withProperties: properties)
                    self.uploadMessageNotification(isImageMessage: false, isVideoMessage: true, isTextMessage: false)
                })
            })
        }
    }
    
    func thumbnailImage(forFileUrl fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let time = CMTimeMake(value: 1, timescale: 60)
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print("DEBUG: Exception error: ", error)
        }
        return nil
    }
    
    func setMessageToRead(forMessageId messageId: String, fromId: String) {
        if fromId != Auth.auth().currentUser?.uid {
            MESSAGES_REF.child(messageId).child("read").setValue(true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[.mediaURL] as? URL {
            uploadVideoToStorage(withUrl: videoUrl)
        } else if let selectedImage = info[.editedImage] as? UIImage {
            uploadImageToStorage(selectedImage: selectedImage) { (imageUrl) in
                self.sendMessage(withImageUrl: imageUrl, image: selectedImage)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MessageInputAccesoryViewDelegate

extension ChatController: MessageInputAccesoryViewDelegate {
    
    func handleUploadMessage(message: String) {
        let properties = ["messageText": message] as [String: AnyObject]
        uploadMessageToServer(withProperties: properties)
        
        self.containerView.clearMessageTextView()
    }
    
    func handleSelectImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: - ChatCellDelegate

extension ChatController: ChatCellDelegate {
    
    func handlePlayVideo(for cell: ChatCell) {
        guard let player = self.player else { return }
        guard let playerLayer = self.playerLayer else { return }
        playerLayer.frame = cell.bubbleView.bounds
        cell.bubbleView.layer.addSublayer(playerLayer)
        
        cell.activityIndicatorView.startAnimating()
        player.play()
        cell.playButton.isHidden = true
    }
}

