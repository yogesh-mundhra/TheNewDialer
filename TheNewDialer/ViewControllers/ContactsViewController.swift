//
//  ViewController.swift
//  TheNewDialer
//
//  Created by Chaoqun Ding on 2019-10-25.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {
    @IBOutlet weak var contactsTableView: UITableView!
    var contacts = [CNContact]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authorizationStatus == .notDetermined {
            store.requestAccess(for: .contacts) { [weak self] didAuthorize, error in
                if didAuthorize {
                    self?.retrieveContacts(from: store)
                }
            }
        } else if authorizationStatus == .authorized {
            retrieveContacts(from: store)
        } //else if authorizationStatus == .denied {
        //}
      }
    
    func retrieveContacts(from store: CNContactStore) {
        let containerId = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        // 4
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataAvailableKey as
                           CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]

//        let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
//        print(contacts)
//        do {
//            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
//            print(contacts)
//        } catch {
//            // something went wrong
//            print(error) // there always is a "free" error variable inside of a catch block
//        }
        contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        DispatchQueue.main.async { [weak self] in // keep contacts up to date
          self?.contactsTableView.reloadData()
        }
        print(contacts)
    }
}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        let contact = contacts[indexPath.row]

        cell.fullNameLabel.text = "\(contact.givenName) \(contact.familyName)"
        let phoneNumber = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
        let phoneNumberFirst3digits = phoneNumber.prefix(3)
        let phoneNumberLast4digits = phoneNumber.suffix(4)
        let phoneNumberMiddle3digits = phoneNumber.dropFirst(3).dropLast(4)

        cell.phoneNumberLabel.text = "\(phoneNumberFirst3digits)-\(phoneNumberMiddle3digits)-\(phoneNumberLast4digits)"

        if contact.imageDataAvailable == true, let imageData = contact.imageData {
            cell.avatarImageView.image = UIImage(data: imageData)
        }

        return cell
    }
}
extension ContactsViewController: UITableViewDelegate {
  // extension implementation
}

    

