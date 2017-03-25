//
//  LocationGameEngine.swift
//  Location Pairs
//
//  Created by Joshua Areogun on 25/03/2017.
//  Copyright © 2017 Joshua Areogun. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationGameEngine: NSObject {

    var dispatchGroup = DispatchGroup()
    var placesClient:GMSPlacesClient!
    var listOfRestaurants:[GMSPlace] = []
    var gameImagesArray:[UIImage] = []
    var arrayOfPhotos:[UIImage] = []

    func initGameDataWithArrayOfPhotos() -> [UIImage]{

        linkUpWithLocationServices()

        dispatchGroup.notify(queue: .main, execute: {
            self.gameImagesArray = self.arrayOfPhotos
        })

        if (gameImagesArray.isEmpty == false) {
             return self.randomizeItemsInArray(sourceArray: self.createDoublesForItemsInArray(photosArray: gameImagesArray))
        } else {
            // if something goes wrong, provide default images to keep the game working.
            gameImagesArray = [#imageLiteral(resourceName: "Akuma"),#imageLiteral(resourceName: "Albert_Wesker"), #imageLiteral(resourceName: "Amaterasu"), #imageLiteral(resourceName: "Arthur"), #imageLiteral(resourceName: "Captain_America"), #imageLiteral(resourceName: "Chun-Li"), #imageLiteral(resourceName: "Doctor_Strange"), #imageLiteral(resourceName: "Dormammu")]
            return randomizeItemsInArray(sourceArray: createDoublesForItemsInArray(photosArray: gameImagesArray))
        }
    }

    func linkUpWithLocationServices() {
        placesClient = GMSPlacesClient.shared()
        arrayOfPhotos = []
        dispatchGroup.enter()
        placesClient.currentPlace(callback: {(placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Error picking place:\(error.localizedDescription)")
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let topRestaurants = placeLikelihoodList.likelihoods.prefix(8)
                for likelihood in topRestaurants
                {
                    if(self.performRestaurantCheckOnPlace(place: likelihood.place)) {
                        self.listOfRestaurants.append(likelihood.place)
                        self.sortOutPhotosForPlaces(place: likelihood.place)
                    }
                }
                self.dispatchGroup.leave()
            }
        })
    }

    func createDoublesForItemsInArray(photosArray:[UIImage]) -> [UIImage] {
        let duplicateArray = photosArray

        let duplicatedArray = photosArray + duplicateArray

        return duplicatedArray
    }

    func randomizeItemsInArray(sourceArray:[UIImage]) -> [UIImage] {
        var randomArray = sourceArray

        // Utilizes the The Fisher-Yates / Knuth shuffle algorithm to randomize the array's elements..
        for i in stride(from: sourceArray.count - 1, through: 1, by: -1) {

            let j = Int(arc4random_uniform(UInt32(i+1)))
            if i != j {
                swap(&randomArray[i], &randomArray[j])
            }
        }
        return randomArray
    }

    func checkIfImagesAreTheSame(imageOne:UIImage, imageTwo:UIImage) -> Bool {
        var areImagesEqual:Bool

        if imageOne.isEqual(imageTwo)
        {
            areImagesEqual = true
        } else {
            areImagesEqual = false
        }

        return areImagesEqual
    }

    func deleteItemAndInsertBlankSpaceAtItsIndex(index:Int, givenArray:[UIImage]) -> [UIImage] {
        var newArray:[UIImage] = givenArray
        let blankImage:UIImage = UIImage(named: "white.png")!

        newArray.remove(at: index)
        newArray.insert(blankImage, at: index)
        return newArray
    }

    func sortOutPhotosForPlaces (place:GMSPlace){
        getPhotoFromPlace(place: place)
    }

    func performRestaurantCheckOnPlace(place:GMSPlace) -> Bool {
        // some places still use deprecated type, food.
        if (place.types.contains("food")) {
            return true
        } else {
            return false
        }
    }

    func getPhotoFromPlace(place:GMSPlace) {
        placesClient.lookUpPhotos(forPlaceID: place.placeID, callback: {(photos, error) -> Void in
            if let error = error {
                print("Something went wrong:\(error.localizedDescription)")
            } else {
                print("we did it")
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }

        })

    }
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata){

        var actualPhoto:UIImage!

        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                print("we did it")
                actualPhoto = photo;
                self.arrayOfPhotos.append(actualPhoto)
            }
        })
    }
}
