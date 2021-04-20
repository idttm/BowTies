//
//  ViewController.swift
//  BowTies
//
//  Created by Andrew Cheberyako on 20.04.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    var currentBowTie: BowTie!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var wearButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        managedContext = appDelegate?.persistentContainer.viewContext
 
        insertSampleData()
        
        let request: NSFetchRequest<BowTie> = BowTie.fetchRequest()
        let firstTitle = segmentedControl.titleForSegment(at: 0) ?? ""
        request.predicate = NSPredicate(
            format: "%K = %@",
            argumentArray: [#keyPath(BowTie.searchKey), firstTitle])
        
        do {
            let results = try managedContext.fetch(request)
            if let tie = results.first {
                currentBowTie = tie
                populate(bowtie: tie)
                }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
  
    func insertSampleData() {
        
        let fetch: NSFetchRequest<BowTie> = BowTie.fetchRequest()
        fetch.predicate = NSPredicate(format: "searchKey != nil")
       
        let tieCount = (try? managedContext.count(for: fetch)) ?? 0
        
        if tieCount > 0 {
            // SampleData.plist data already in Core Data
            return
        }
        
        let path = Bundle.main.path(forResource: "SampleData",
                                    ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(
                forEntityName: "BowTie",
                in: managedContext)!
            let bowtie = BowTie(entity: entity,
                                insertInto: managedContext)
            let btDict = dict as! [String: Any]
            
            //        bowtie.id = UUID(uuidString: btDict["id"] as! String)
            bowtie.name = btDict["name"] as? String
            bowtie.searchKey = btDict["searchKey"] as? String
            bowtie.rating = btDict["rating"] as! Double
            let colorDict = btDict["tintColor"] as! [String: Any]
            bowtie.tintColor = UIColor.color(dict: colorDict)
            
            let imageName = btDict["imageName"] as? String
            let image = UIImage(named: imageName!)
            bowtie.photoData = image?.pngData()
            bowtie.lastWorn = btDict["lastWorn"] as? Date

            let timesNumber = btDict["timesWorn"] as! NSNumber
            bowtie.timesWorn = timesNumber.int32Value
            bowtie.isFavorite = btDict["isFavorite"] as! Bool
            //        bowtie.url = URL(string: btDict["url"] as! String)
        }
        try? managedContext.save()
    }
    
    func populate(bowtie: BowTie) {
        
      guard let imageData = bowtie.photoData as Data?,
        let lastWorn = bowtie.lastWorn as Date?,
        let tintColor = bowtie.tintColor else {
          return
      }
      
      imageView.image = UIImage(data: imageData)
      nameLabel.text = bowtie.name
      ratingLabel.text = "Rating: \(bowtie.rating)/5"
      
      timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .short
      dateFormatter.timeStyle = .none
      
      lastWornLabel.text = "Last worn: " + dateFormatter.string(from: lastWorn)
      
      favoriteLabel.isHidden = !bowtie.isFavorite
      view.tintColor = tintColor
    }
   
    func update(rating: String?) {

        guard let ratingString = rating,
              let rating = Double(ratingString) else {
            return
        }
        do {
            currentBowTie.rating = rating
            try managedContext.save()
            populate(bowtie: currentBowTie)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        guard let selectedValue = sender.titleForSegment(
            at: sender.selectedSegmentIndex) else {
              return
          }

          let request: NSFetchRequest<BowTie> = BowTie.fetchRequest()
          request.predicate = NSPredicate(
            format: "%K = %@",
            argumentArray: [#keyPath(BowTie.searchKey), selectedValue])

          do {
            let results = try managedContext.fetch(request)
            currentBowTie = results.first
            populate(bowtie: currentBowTie)
            print(currentBowTie)
          } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
          }
        
    }
    
    @IBAction func wear(_ sender: UIButton) {
        
        currentBowTie.timesWorn += 1
        currentBowTie.lastWorn = Date()
        
        do {
            try managedContext.save()
            populate(bowtie: currentBowTie)
            print(currentBowTie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    @IBAction func rate(_ sender: UIButton) {
        let alert = UIAlertController(title: "New Rating",
                                      message: "Rate this bow tie",
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        let saveAction = UIAlertAction(
            title: "Save",
            style: .default
        ) { [unowned self] _ in
            if let textField = alert.textFields?.first {
                self.update(rating: textField.text)
            }
        }
        print(currentBowTie)
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
}
private extension UIColor {
    
    static func color(dict: [String: Any]) -> UIColor? {
        guard
            let red = dict["red"] as? NSNumber,
            let green = dict["green"] as? NSNumber,
            let blue = dict["blue"] as? NSNumber else {
            return nil
        }
        
        return UIColor(
            red: CGFloat(truncating: red) / 255.0,
            green: CGFloat(truncating: green) / 255.0,
            blue: CGFloat(truncating: blue) / 255.0,
            alpha: 1)
    }
}

