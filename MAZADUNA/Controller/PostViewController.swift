//
//  PostViewController.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 13/02/1443 AH.
//

import UIKit
import MBProgressHUD
import DropDown
import UserNotifications

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Start of UI localization
    
    @IBOutlet weak var postAuctionLabel: UILabel!
    @IBOutlet weak var realEstateLabel: UILabel!
    @IBOutlet weak var realEstateSpaceLabel: UILabel!
    @IBOutlet weak var realEstateTypeLabel: UILabel!
    @IBOutlet weak var realEstatePriceLabel: UILabel!
    @IBOutlet weak var realEstateStartDateLabel: UILabel!
    @IBOutlet weak var realEstateEndDateLabel: UILabel!
    @IBOutlet weak var realEstateDescriptionLabel: UILabel!
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var requiredFieldsLabel: UILabel!
    @IBOutlet weak var realEstateLocationPicker: UIButton!
    @IBOutlet weak var realEstateUploadPhoto: UIButton!
    let LocationTitle = NSLocalizedString("AddLocation", comment: "")
    let PhotoTitle = NSLocalizedString("UploadPhoto", comment: "")
    // End of UI localization
    
    @IBOutlet weak var stateNameLabel: UITextField!
    @IBOutlet weak var spaceLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    @IBOutlet weak var typeLabel: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var locationTickImage: UIImageView!
    @IBOutlet weak var photoTickImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var postDescription: UITextView!
    let center = UNUserNotificationCenter.current()

    var newPost: Post = Post(withJson: Dictionary<String, Any>())
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var pickedImage: [UIImage]?
    let startDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120))
    let endDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120))
    var dismissClosure : ((_ post: Post) -> Void)?
    let dropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoTickImage.isHidden = true
        self.locationTickImage.isHidden = true
        self.postButton.layer.cornerRadius=0
        postDescription.layer.cornerRadius=9
        self.hideKeyboardWhenTappedAround()
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.setDatePicker()
        // Do any additional setup after loading the view.
        self.setupDropDown()
        self.setupCollectionView()
        self.spaceLabel.delegate = self
        self.priceLabel.delegate = self
        center.requestAuthorization(options: [.alert,.sound]) { granted, error in
        }
        LocalizeVC()
        
        let realEstateLabelstar: NSAttributedString = realEstateLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        realEstateLabel.attributedText = realEstateLabelstar
        
        let realEstatePriceLabelstar: NSAttributedString = realEstatePriceLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        realEstatePriceLabel.attributedText = realEstatePriceLabelstar
        
        let realEstateTypeLabelstar: NSAttributedString = realEstateTypeLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        realEstateTypeLabel.attributedText = realEstateTypeLabelstar
        
        let realEstateSpaceLabelstar: NSAttributedString = realEstateSpaceLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        realEstateSpaceLabel.attributedText = realEstateSpaceLabelstar
        
        let realEstateStartDateLabelstar: NSAttributedString = realEstateStartDateLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        realEstateStartDateLabel.attributedText = realEstateStartDateLabelstar
        
        let realEstateEndDateLabelstar: NSAttributedString = realEstateEndDateLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        realEstateEndDateLabel.attributedText = realEstateEndDateLabelstar
        
        
        let realEstateDescriptionLabelstar: NSAttributedString = realEstateDescriptionLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        realEstateDescriptionLabel.attributedText = realEstateDescriptionLabelstar
        
        let locationStar: NSAttributedString = (realEstateLocationPicker.titleLabel?.text?.attributedStringWithColor(["*"], color: UIColor.red))!
        realEstateLocationPicker.setAttributedTitle(locationStar, for: UIControl.State.normal)
        let photoStar: NSAttributedString = (realEstateUploadPhoto.titleLabel?.text?.attributedStringWithColor(["*"], color: UIColor.red))!
        realEstateUploadPhoto.setAttributedTitle(photoStar, for: UIControl.State.normal)
        
    }
    
    func LocalizeVC(){
        realEstateLocationPicker.setTitle(LocationTitle, for: .normal)
        postAuctionLabel.text = NSLocalizedString("postAuction", comment: "")
        realEstateLabel.text = NSLocalizedString("realEstateName", comment: "")
        stateNameLabel.placeholder = NSLocalizedString("realEstateNameFeild", comment: "")
        realEstateSpaceLabel.text = NSLocalizedString("realEstateSpace", comment: "")
        spaceLabel.placeholder = NSLocalizedString("realEstateSpaceFeild", comment: "")
        meterLabel.text = NSLocalizedString("realEstateMeter", comment: "")
        realEstateTypeLabel.text = NSLocalizedString("realEstateType", comment: "")
        typeLabel.placeholder = NSLocalizedString("realEstateTypeFeild", comment: "")
        realEstatePriceLabel.text = NSLocalizedString("realEstatePrice", comment: "")
        priceLabel.placeholder = NSLocalizedString("realEstatePriceFeild", comment: "")
        currencyLabel.text = NSLocalizedString("realEstateCurrency", comment: "")
        realEstateStartDateLabel.text = NSLocalizedString("realEstateStartDate", comment: "")
        startDate.placeholder = NSLocalizedString("realEstateStartDateFeild", comment: "")
        realEstateEndDateLabel.text = NSLocalizedString("realEstateEndDate", comment: "")
        endDate.placeholder = NSLocalizedString("realEstateEndDateFeild", comment: "")
        realEstateDescriptionLabel.text = NSLocalizedString("realEstateDescription", comment: "")
        requiredFieldsLabel.text = NSLocalizedString("requiredFieldsSignUp", comment: "")
        postButton.setTitle(NSLocalizedString("Post", comment: ""), for: .normal)
        realEstateLocationPicker.setAttributedTitle(NSAttributedString(string: LocationTitle), for: UIControl.State.normal)
        realEstateUploadPhoto.setAttributedTitle(NSAttributedString(string: PhotoTitle), for: UIControl.State.normal)
        realEstateLocationPicker.setTitleColor(UIColor.white, for: UIControl.State.normal)
        realEstateUploadPhoto.setTitleColor(UIColor.white, for: UIControl.State.normal)

     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.newPost.lat != 0.0 {
            self.locationTickImage.isHidden = false
        }
        if self.newPost.image.count > 0 {
            self.photoTickImage.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.dropDown.width = self.typeLabel.frame.width
        realEstateLocationPicker.setTitle(LocationTitle, for: .normal)
        realEstateUploadPhoto.setTitle(NSLocalizedString("UploadPhoto", comment: ""), for: .normal)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        if textField == priceLabel {
            if(Int(priceLabel.text!)! <= 0){
                let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("priceError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        if textField == spaceLabel{
            if(Int(spaceLabel.text!)! <= 0){
                let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("spaceError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func setupDropDown() {
        
        self.typeLabel.delegate = self
        

        // The view to which the drop down will appear on
        dropDown.anchorView = self.typeLabel // UIView or UIBarButtonItem
        dropDown.direction = .bottom
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = [NSLocalizedString("villa", comment: ""),NSLocalizedString("land", comment: ""),NSLocalizedString("apartment", comment: ""),NSLocalizedString("duplex", comment: ""),NSLocalizedString("builiding", comment: "")]
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            self.dropDown.hide()
            self.typeLabel.text = item
        }

        // Will set a custom width instead of the anchor view width
        dropDown.width = self.typeLabel.frame.width

    }
    
    @IBAction func BackButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }

    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard self.validateFields() else {
            let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("fillAllFieldsError", comment: ""), preferredStyle: .alert)
            let ok = UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.newPost.bidders = ["userID":"price"]
        self.newPost.descriptionForEstate = self.postDescription.text ?? ""
        self.newPost.startPrice = self.priceLabel.text ?? ""
        self.newPost.state = self.stateNameLabel.text ?? ""
        self.newPost.space = self.spaceLabel.text ?? ""
        self.newPost.price = self.priceLabel.text ?? ""
        self.newPost.type = self.typeLabel.text ?? ""
        self.newPost.startDate = self.startDate.text ?? ""
        self.newPost.endDate = self.endDate.text ?? ""
        self.newPost.userID = MZUser.shared.userID
        
        guard let _ = self.pickedImage else {
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("postUploading", comment: "")
        
        self.uploadImages(0) {
            if self.newPost.image.count == 0 {
                hud.hide(animated: true)
                self.showAlert(NSLocalizedString("postFailed", comment: ""))
                return
            }
            var json = self.newPost.json
            let postID = FirebaseManager.shared.ref.childByAutoId().key ?? ""
            json.updateValue(postID, forKey: "postID")
            self.newPost.postID = postID
            hud.label.text = NSLocalizedString("postCreating", comment: "")
            FirebaseManager.shared.addPostToFirebase(json) { (response, error) in
                hud.hide(animated: true)
                if error == nil {
                    AllPosts.shared.addPost(self.newPost)
                    NotificationCenter.default.post(name: Notification.Name.init(rawValue: "PostReload"), object: [self.newPost])
                    self.dismissClosure?(self.newPost)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        //set up notifications
                
                //step 1: Ask for permission
                
                //step 2: Create the notification content
                
                let content = UNMutableNotificationContent()
        
                content.title = NSLocalizedString("auction", comment: "")+newPost.state+NSLocalizedString("ended", comment: "")
                
                content.body = NSLocalizedString("closePrice", comment: "")+" "+newPost.price+" "+NSLocalizedString("realEstateCurrency", comment: "")
                
                //step 3: Create the notification trigger
                
                // get Variables from endDate
                // 20:04:01-05.11.2021
                // HH:mm:ss-dd.MM.yyyy
                print(newPost.endDate.count)
                let hour = newPost.endDate[0...1]
                let minute = newPost.endDate[3...4]
                let second = newPost.endDate[6...7]
                let day = newPost.endDate[9...10]
                let month = newPost.endDate[12...13]
                let year = newPost.endDate[15...18]
                
                var dateComponents = DateComponents()
                dateComponents.hour = Int(hour)
                dateComponents.minute = Int(minute)
                dateComponents.second = Int(second)
                dateComponents.day = Int(day)
                dateComponents.month = Int(month)
                dateComponents.year = Int(year)
                
                
               let trigger =  UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                //step 4: Create the request
                
                let request = UNNotificationRequest(identifier: "end", content: content, trigger: trigger)
                
                //step 5: Register the request
                
                center.add(request) { error in
                    //Handle errors
                    print(error?.localizedDescription)
                }
    }
    
    func uploadImages( _ uploadImageIndex: Int , _ closure: (()-> Void)?) {
        guard let images = self.pickedImage else {
            return
        }
        
        var uploadedImages = uploadImageIndex
        FirebaseManager.shared.uploadImageToFireStore(images[uploadedImages]) { (url, error) in
            if let downloadUrl = url {
                self.newPost.image.append(downloadUrl)
            }
            uploadedImages += 1
            if uploadedImages == images.count {
                closure?()
            } else {
                self.uploadImages( uploadedImages, closure)
            }
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LocationPickViewController") as? LocationPickViewController else { return }
        vc.post = self.newPost
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func pickImageButtonPressed(_ sender: UIButton) {
        guard self.pickedImage?.count ?? 0 < 4 else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photo = UIAlertAction(title: NSLocalizedString("photos", comment: ""), style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let camera = UIAlertAction(title: NSLocalizedString("camera", comment: ""), style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("cancelAlert", comment: ""), style: .destructive) { (action) in
            
        }
        alert.addAction(photo)
        alert.addAction(camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func validateFields() -> Bool {
        return !((self.stateNameLabel.text?.isEmpty ?? true) || (self.spaceLabel.text?.isEmpty ?? true) || (self.postDescription.text?.isEmpty ?? true) || (self.priceLabel.text?.isEmpty ?? true) || (self.typeLabel.text?.isEmpty ?? true) || (self.startDate.text?.isEmpty ?? true) || (self.endDate.text?.isEmpty ?? true) || self.newPost.lat == 0.0 || self.pickedImage == nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        if self.pickedImage == nil {
            self.pickedImage = Array()
        }
        self.photoTickImage.isHidden = false
        self.pickedImage?.append(tempImage)
        picker.dismiss(animated: true, completion: nil)
        self.collectionView.reloadData()
    }
    
    func setDatePicker() {
        //Format Date
        startDatePicker.datePickerMode = .dateAndTime
        endDatePicker.datePickerMode = .dateAndTime
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = Date()
        
        if #available(iOS 13.4, *){
            startDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.preferredDatePickerStyle = .wheels
        }

        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title:NSLocalizedString("done", comment: ""), style: .plain, target: self, action: #selector(doneStartDatePicker(_:)));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancelAlert", comment: ""), style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        //ToolBar
        let toolbar2 = UIToolbar();
        toolbar2.sizeToFit()
        let doneButton2 = UIBarButtonItem(title: NSLocalizedString("done", comment: ""), style: .plain, target: self, action: #selector(doneEndDatePicker(_:)));
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton2 = UIBarButtonItem(title: NSLocalizedString("cancelAlert", comment: ""), style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar2.setItems([doneButton2,spaceButton2,cancelButton2], animated: false)

        startDate.inputAccessoryView = toolbar
        endDate.inputAccessoryView = toolbar2
        startDate.inputView = startDatePicker
        endDate.inputView = endDatePicker
    }

    @objc func doneStartDatePicker(_ sender: UIDatePicker){
        if self.endDate.text?.count ?? 0 == 0 || self.endDatePicker.date > self.startDatePicker.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss-dd.MM.yyyy"
            self.startDate.text = formatter.string(from: self.startDatePicker.date)
            self.view.endEditing(true)
        } else {
            if self.endDatePicker.date <= self.startDatePicker.date {
                self.showAlert(NSLocalizedString("dateError1", comment: ""))
            }
        }
        
    }
    
    @objc func doneEndDatePicker(_ sender: UIDatePicker){
        guard (self.startDate.text?.count ?? 0) > 0 else {
            self.showAlert(NSLocalizedString("dateError2", comment: ""))
            return
        }
        if self.startDatePicker.date < self.endDatePicker.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss-dd.MM.yyyy"
            self.endDate.text = formatter.string(from: self.endDatePicker.date)
            self.view.endEditing(true)
        } else {
            self.showAlert(NSLocalizedString("dateError3", comment: ""))
        }
    }

    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
extension PostViewController: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.typeLabel {
            self.dropDown.show()
            return false
        }
        return true
    }
}

extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        self.collectionView.register(UINib(nibName: "PickedImageCell", bundle: nil), forCellWithReuseIdentifier: "PickedImageCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickedImageCell", for: indexPath) as? PickedImageCell else { return UICollectionViewCell() }
        cell.pickedImage.image = self.pickedImage?[indexPath.item]
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(self.deleteImageButtonPressed(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pickedImage?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @IBAction func deleteImageButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        self.pickedImage?.remove(at: tag)
        self.collectionView.reloadData()
        if self.pickedImage?.count ?? 0 == 0 {
            self.photoTickImage.isHidden = true
        }
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
