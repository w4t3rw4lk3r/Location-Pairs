//
//  LocationGameGridCollectionViewController.swift
//  Location Pairs
//
//  Created by Joshua Areogun on 25/03/2017.
//  Copyright © 2017 Joshua Areogun. All rights reserved.
//

import UIKit

class LocationGameGridCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var gameEngine = LocationGameEngine()
    var arrayOfImages:[UIImage]!

    var revealedCards:[UIImage] = []
    var revealedCardIndexArray:[IndexPath] = []
    var cardsRevealedTracker:Int = 0

    var numberOfAttempts:Int = 0
    var numberOfCardsLeft:Int = 0

    @IBOutlet weak var gameGridCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameGrid()
        self.arrayOfImages = self.gameEngine.initGameDataWithArrayOfPhotos()
        self.gameGridCollectionView.reloadData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupGameGrid() {
        self.title = "\(numberOfAttempts)"

        numberOfCardsLeft = GlobalConstants.kTotalNumberOfImagesInGame

        gameGridCollectionView.register(UINib(nibName:"LocationCard", bundle:nil), forCellWithReuseIdentifier:"cardCell")
        gameGridCollectionView.delegate = self
        gameGridCollectionView.dataSource = self
    }

    func gameOver() {
        //Display alert with number of attempts.
        //segue to LeaderBoard

        let gameOverAlert = UIAlertController(title: "Game Over", message: "You finished the game with \(numberOfAttempts) attempts", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (result:UIAlertAction) in
                self.performSegue(withIdentifier: "leaderboardSegue", sender: self)

        }
        gameOverAlert.addAction(okAction)
        self.present(gameOverAlert, animated: true, completion: nil)


    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if((arrayOfImages) != nil) {
            return arrayOfImages.count
        }
        else
        {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = gameGridCollectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! LocationCardView

        cell.locationImageView.image = arrayOfImages[indexPath.row]
        
        return cell

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardsRevealedTracker += 1

        let cell = gameGridCollectionView.cellForItem(at: indexPath) as! LocationCardView
        cell.coverView.isHidden = true

        //store the image and its cell's indexpath.
        revealedCards.append(cell.locationImageView.image!)
        revealedCardIndexArray.append(indexPath)

        if cardsRevealedTracker == 2 {
            // Both cards have been chosen now, we log an attempt.
            keepScore()

            // we are 100% certain there's a first card saved, this is safe to do.
             let firstCellTapped = self.gameGridCollectionView.cellForItem(at: self.revealedCardIndexArray[0]) as! LocationCardView
            //fetch images
            let firstImage = revealedCards[0]
            let secondImage = revealedCards[1]

            // check for similarity.
            if gameEngine.checkIfImagesAreTheSame(imageOne: firstImage, imageTwo: secondImage)
            {
                print("The images are the same...proceeding...")
                revealedCards = []

                // remove similar images from game board & insert a blank space.
                arrayOfImages = gameEngine.deleteItemAndInsertBlankSpaceAtItsIndex(index: arrayOfImages.index(of: firstImage)!, givenArray: arrayOfImages)
                arrayOfImages = gameEngine.deleteItemAndInsertBlankSpaceAtItsIndex(index: arrayOfImages.index(of: secondImage)!, givenArray: arrayOfImages)
                numberOfCardsLeft -= 2

                // Remove similar images from the collectionview.
                gameGridCollectionView.performBatchUpdates({
                    self.gameGridCollectionView.deleteItems(at: self.revealedCardIndexArray)
                    self.gameGridCollectionView.insertItems(at: self.revealedCardIndexArray)
                }, completion: {(success:Bool) in
                    if self.numberOfCardsLeft == 0 {
                        self.checkScores()
                        }
                    })
                self.revealedCardIndexArray = []

            } else {
                //images aren't the same, reset and proceed.
                print("The images aren't the same...not proceeding...")
                print("count this: \(revealedCardIndexArray[0])")
                revealedCards = []

                //To avoid the card's reveal not animating, we delay by a second.
                let delayInSeconds = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delayInSeconds) {
                    cell.coverView.isHidden = false
                    firstCellTapped.coverView.isHidden = false
                }
                self.revealedCardIndexArray = []
            }

            cardsRevealedTracker = 0
        }
    }

    func keepScore() {
        numberOfAttempts += 1
        self.title = "\(numberOfAttempts)"
    }

    func checkScores() {
        let defaults = UserDefaults.standard
        var scoreboard = defaults.array(forKey: "scoreboardKey") as! [[String:Any]]

        for item in scoreboard {
            if (item["score"] as! Int) > numberOfAttempts {
                //present, entry, save scores & exit
                let entryAlert = UIAlertController(title: "New High Score", message: "You finished the game with \(numberOfAttempts) attempts", preferredStyle: .alert)
                entryAlert.addTextField{(textfield: UITextField) -> Void in
                    textfield.placeholder = "Enter your name"
                }
                let okAction = UIAlertAction(title: "Ok", style: .default){ (result:UIAlertAction) -> Void in
                    scoreboard.append(["name":entryAlert.textFields?.first?.text as Any, "score":self.numberOfAttempts])
                    let defaults = UserDefaults.standard
                    defaults.set(scoreboard, forKey:"scoreboardKey")
                    self.performSegue(withIdentifier: "leaderboardSegue", sender: self)
                }
            entryAlert.addAction(okAction)
            self.present(entryAlert, animated: true, completion: nil)
            return
            }
        }
        self.gameOver()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 50, height: 50)
    }

}
