//
//  NeighbourhoodCommentsViewController.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 03/12/21.
//

import UIKit
import MBProgressHUD
import SwiftUI

class NeighbourhoodCommentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButton: UIButton!
    
    
    var comments: [NeighbourHoodComment] = Array()
    var selectedNeighbour: String = ""
    let placeHolderText = NSLocalizedString("addComment", comment: "")
    let placeHolderColor = UIColor.gray
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupTable()
        self.loadAllComments()
    }
    
    func setupUI() {
        self.viewContainer.layer.cornerRadius = 8
        self.viewContainer.backgroundColor = .systemGray6
        self.viewContainer.layer.shadowColor = UIColor.black.cgColor
        self.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.viewContainer.layer.shadowRadius = 4
        self.viewContainer.layer.shadowOpacity = 0.2
        self.sendCommentButton.addTarget(self, action: #selector(self.sendCommentButtonPressed(_:)), for: .touchUpInside)
        self.sendCommentButton.setTitle("", for: .normal)
        self.sendCommentButton.setTitle("", for: .highlighted)
        self.commentTextView.layer.cornerRadius = 8
        self.commentTextView.clipsToBounds = true
        self.commentTextView.text = self.placeHolderText
        self.commentTextView.textColor = self.placeHolderColor
        self.commentTextView.delegate = self
        
        self.plusButton.isHidden = FirebaseManager.shared.isAnonymouse
        self.plusButton.layer.cornerRadius = self.plusButton.frame.height / 2
        self.plusButton.backgroundColor = #colorLiteral(red: 0.5218120813, green: 0.6480953097, blue: 0.6156229377, alpha: 1)
        self.plusButton.setTitle("", for: .normal)
        self.plusButton.setTitle("", for: .highlighted)
        self.plusButton.setImage(UIImage(named: "plusIcon"), for: .normal)
        self.plusButton.setImage(UIImage(named: "plusIcon"), for: .highlighted)
        self.plusButton.addTarget(self, action: #selector(self.plusButtonPressed(_:)), for: .touchUpInside)
    }
    
    func loadAllComments() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading.."
        hud.show(animated: true)
        FirebaseManager.shared.loadComments(neighbour: self.selectedNeighbour) { comments, error in
            hud.hide(animated: true)
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            self.comments = comments
            self.tableView.reloadData()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func setupTable() {
        self.tableView.layer.cornerRadius = 8
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: NeighbourCommentTableCell.reuseableID, bundle: nil), forCellReuseIdentifier: NeighbourCommentTableCell.reuseableID)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func sendCommentButtonPressed(_ sender: UIButton) {
        let commentText = self.commentTextView.text ?? ""
        guard commentText.trimmingCharacters(in: .whitespacesAndNewlines).count > 0, commentText != self.placeHolderText else { return }
        let comment = NeighbourHoodComment(with: [String:Any]())
        comment.comment = commentText
        comment.neighbourHood = self.selectedNeighbour
        comment.addToFirebase()
        if self.comments.count > 0 {
            self.comments.insert(comment, at: 0)
        } else {
            self.comments.append(comment)
        }
        
        self.tableView.reloadSections([0], with: .automatic)
        self.commentTextView.text = ""
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        self.commentView.isHidden = false
        self.commentViewHeightConstraint.constant = 100
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension NeighbourhoodCommentsViewController: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NeighbourCommentTableCell.reuseableID, for: indexPath) as? NeighbourCommentTableCell else { return UITableViewCell() }
        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonPressed(_:)), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.row
        cell.comment = self.comments[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 60))
        view.backgroundColor = .systemGray6
        return FirebaseManager.shared.isAnonymouse ? nil : view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FirebaseManager.shared.isAnonymouse ? 0 : 60
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let comment = self.comments[sender.tag]
        comment.deleteComment()
        self.comments.remove(at: sender.tag)
        self.tableView.reloadData()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !self.commentTextView.text.isEmpty && self.commentTextView.text == self.placeHolderText {
            self.commentTextView.text = ""
            self.commentTextView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if self.commentTextView.text.isEmpty {
            self.commentTextView.text = self.placeHolderText
            self.commentTextView.textColor = self.placeHolderColor
        }
    }
}

extension NeighbourhoodCommentsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            self.viewContainer.transform = .identity
        } else {
            self.viewContainer.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -100 {
            self.dismiss(animated: true, completion:  nil)
        }
    }
}
