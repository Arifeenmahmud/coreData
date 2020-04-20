
import UIKit

class MainViewController: UIViewController {
	@IBOutlet private weak var collectionView:UICollectionView!
	
	private var friends = [Friend]()
	private var filtered = [Friend]()
	private var isFiltered = false
	private var friendPets = [String:[String]]()
	private var selected:IndexPath!
	private var picker = UIImagePickerController()
	private var images = [String:UIImage]()
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	override func viewDidLoad() {
		super.viewDidLoad()
		picker.delegate = self
	}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            friends = try context.fetch(Friend.fetchRequest())
        } catch let error as NSError {
            print("could not fetch. \(error), \(error.userInfo)")
        }
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK:- Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "petSegue" {
			if let index = sender as? IndexPath {
				let pvc = segue.destination as! PetsViewController
				let friend = friends[index.row]
                if let pets = friendPets[friend.name!] {
					pvc.pets = pets
				}
				pvc.petAdded = {
                    self.friendPets[friend.name!] = pvc.pets
				}
			}
		}
	}

	// MARK:- Actions
	@IBAction func addFriend() {
	let data = FriendData()
        let friend = Friend(entity: Friend.entity(), insertInto: context)
        friend.name = data.name
        appDelegate.saveContext()
        friends.append(friend)
        let index = IndexPath(row: friends.count - 1, section: 0)
        collectionView?.insertItems(at: [index])
        
	}
	
	// MARK:- Private Methods
	private func showEditButton() {
		if friends.count > 0 {
			navigationItem.leftBarButtonItem = editButtonItem
		}
	}
}

// Collection View Delegates
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let width  = (view.frame.size.width - 10) / 2
           return CGSize(width: width, height: width)
       }
    
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let count = isFiltered ? filtered.count : friends.count
		return count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as! FriendCell
		let friend = isFiltered ? filtered[indexPath.row] : friends[indexPath.row]
        cell.nameLabel.text = friend.name!
        if let image = images[friend.name!] {
			cell.pictureImageView.image = image
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if isEditing {
			selected = indexPath
			self.navigationController?.present(picker, animated: true, completion: nil)
		} else {
			performSegue(withIdentifier: "petSegue", sender: indexPath)
		}
	}
}

// Search Bar Delegate
extension MainViewController:UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let query = searchBar.text else {
			return
		}
		isFiltered = true
		filtered = friends.filter({(friend) -> Bool in
            return friend.name!.contains(query)
		})
		searchBar.resignFirstResponder()
		collectionView.reloadData()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		isFiltered = false
		filtered.removeAll()
		searchBar.text = nil
		searchBar.resignFirstResponder()
		collectionView.reloadData()
	}
}

// Image Picker Delegates
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

		let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
		let friend = isFiltered ? filtered[selected.row] : friends[selected.row]
        images[friend.name!] = image
		collectionView?.reloadItems(at: [selected])
		picker.dismiss(animated: true, completion: nil)
	}
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}