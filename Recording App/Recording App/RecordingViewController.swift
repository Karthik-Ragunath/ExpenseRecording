//
//  RecordingViewController.swift
//  Recording App
//
//  Created by Praveen Kumar U on 28/07/18.
//  Copyright © 2018 Praveen Kumar U. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Speech
import MapKit
import CoreLocation

protocol DismissProtocol
{
    func informDismissAction()
}

class RecordingViewController: UIViewController,  CLLocationManagerDelegate, DismissProtocol {
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    let locationManager = CLLocationManager()
    var locationCoordinate = CLLocationCoordinate2D()
    let expenseViewController = ExpenseViewController()
    
    var transcriptionOutputLabel = UILabel()
    var authentication = "901d1895824478ac0d0bfde1be6d6cf7"
    var restaurantId = String()
    var restaurantName = String()
    var proximity = Double()
    
    var location = String()
    var itemName = String()
    var quantity = String()
    var price = String()
    var category = String()
    var amount = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneTapped))
        
        setupTransctiptionOutputLabel()
        
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        SFSpeechRecognizer.requestAuthorization
            {
                [unowned self] (authStatus) in
                switch authStatus
                {
                    
                case .authorized:
                    do {
                        try self.startRecording()
                    } catch let error {
                        print("There was a problem starting recording: \(error.localizedDescription)")
                    }
                case .denied:
                    print("Speech recognition authorization denied")
                case .restricted:
                    print("Not available on this device")
                case .notDetermined:
                    print("Not determined")
                }
        }
    }

    func informDismissAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupTransctiptionOutputLabel()
    {
        transcriptionOutputLabel.translatesAutoresizingMaskIntoConstraints = false
        transcriptionOutputLabel.textAlignment = .center
        transcriptionOutputLabel.layer.borderColor = UIColor.black.cgColor
        transcriptionOutputLabel.layer.borderWidth = 2
        self.view.addSubview(transcriptionOutputLabel)
        
        let viewsDict = ["label": transcriptionOutputLabel]
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-200-[label(200)]", options: [], metrics: nil, views: viewsDict))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: viewsDict))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        locationCoordinate = locValue
    }
    
    @objc func handleDoneTapped()
    {
        stopRecording()
        if let liveString = transcriptionOutputLabel.text
        {
            partsOfSpeech(for: liveString)
        }
    }
    
    func partsOfSpeech(for text: String)
    {
        var numberFormatterCount = 0
        var nounCount = 0
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagScheme.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
        let options: NSLinguisticTagger.Options = [NSLinguisticTagger.Options.omitPunctuation, NSLinguisticTagger.Options.omitWhitespace, .joinNames]
        let range = NSRange(location: 0, length: text.utf16.count)
        tagger.string = text
        if #available(iOS 11.0, *) {
            tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange, _ in
                if let tag = tag {
                    let word = (text as NSString).substring(with: tokenRange)
                    print("\(word): \(tag.rawValue)")
                    if tag.rawValue == "Number"
                    {
                        if let intVal = Int(word)
                        {
                            if numberFormatterCount == 0
                            {
                                self.quantity = String(intVal)
                            }
                            else
                            {
                                self.price = String(intVal)
                            }
                        }
                        else
                        {
                            let numberFormatter = NumberFormatter()
                            numberFormatter.locale = Locale(identifier: "en_US_POSIX")  // if you dont set locale it will use current locale so it wont detect one if the language it is not english at the devices locale
                            numberFormatter.numberStyle = .spellOut
                            let number = numberFormatter.number(from: word)
                            if numberFormatterCount == 0
                            {
                                self.quantity = number?.stringValue ?? "0"
                            }
                            else
                            {
                                self.price = number?.stringValue ?? "0"
                            }
                        }
                        numberFormatterCount += 1
                    }
                    if tag.rawValue == "Noun"
                    {
                        let lowerCasedWord = word.lowercased()
                        if lowerCasedWord != "expense"
                        {
                            if nounCount == 0
                            {
                                self.itemName = lowerCasedWord
                                nounCount += 1
                            }
                        }
                    }
                }
            }
        } else {
            print("Cannot be exexuted on previous versions")
            // Fallback on earlier versions
        }
        if numberFormatterCount <= 1
        {
            let lattitude = "\(self.locationCoordinate.latitude)"
            let longitude = "\(self.locationCoordinate.longitude)"
            getNearbyRestaurants(latitude: lattitude, longitude: longitude)
        }
        else
        {
            self.location = "Shop"
            self.category = "Other Category"
            let intQuantity = Int(self.quantity)
            let intPrice = Int(self.price)
            let intAmount = (intQuantity ?? 0) * (intPrice ?? 0)
            self.amount = "\(intAmount)"
            expenseViewController.price = self.price
            expenseViewController.location = self.location
            expenseViewController.quantity = self.quantity
            expenseViewController.itemName = self.itemName
            expenseViewController.category = self.category
            expenseViewController.amount = self.amount
            expenseViewController.dismissProtocol = self
            let navController = UINavigationController(rootViewController: self.expenseViewController)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    func getNearbyRestaurants(latitude: String, longitude: String)
    {
        let locationLatitude = Double(latitude)
        let locationLongitude = Double(longitude)
        proximity = 100000000
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let urlString = "https://developers.zomato.com/api/v2.1/geocode?lat=" + latitude + "&lon=" + longitude
        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "GET"
        request.setValue(authentication, forHTTPHeaderField: "user-key")
        session.dataTask(with: request as URLRequest)
        { (data, response, error) in
            if let dataResposne = data
            {
                do
                {
                    let json = try JSONSerialization.jsonObject(with: dataResposne, options: JSONSerialization.ReadingOptions.mutableContainers)
                    if let dictionary = json as? NSDictionary
                    {
                        if let nearByRestaurants = dictionary["nearby_restaurants"] as? [NSDictionary]
                        {
                            for nearByRestaurantNow in nearByRestaurants
                            {
                                if let nearByRestaurant = nearByRestaurantNow["restaurant"] as? NSDictionary
                                {
                                    let restaurantNameNow = nearByRestaurant["name"] as! String
                                    let restaurantIdNow = nearByRestaurant["id"] as! String
                                    if let locationDict = nearByRestaurant["location"] as? NSDictionary
                                    {
                                        let latitudeNow = locationDict["latitude"]
                                        let longitudeNow = locationDict["longitude"]
                                        let currentLatitudeDouble = Double(latitudeNow as! String)
                                        let currentLongitudeDouble = Double(longitudeNow as! String)
                                        let proximityNow = locationLatitude! - currentLatitudeDouble! + locationLongitude! - currentLongitudeDouble!
                                        let absoluteProximityNow = abs(proximityNow)
                                        if absoluteProximityNow < self.proximity
                                        {
                                            self.proximity = absoluteProximityNow
                                            self.restaurantId = restaurantIdNow
                                            self.restaurantName = restaurantNameNow
                                        }
                                    }
                                }
                            }
                        }
                    }
//                    print("The restaurant name is \(self.restaurantName)")
//                    print("The restaurant id is \(self.restaurantId)")
                    self.location = self.restaurantName
                    self.category = "Food"
                    let quantityInt = Int(self.quantity)
                    self.price = "40"
                    //With Restaurant Id forward make /dailymenu API to get cost
                    //    https://developers.zomato.com/api/v2.1/dailymenu?res_id=16759908
                    //But this API only works if we become partner of Zomato
                    let amount = (quantityInt ?? 0) * 40
                    self.amount = String(amount)
                }
                catch
                {
                    print("Error occured")
                }
            }
            self.expenseViewController.price = self.price
            self.expenseViewController.location = self.location
            self.expenseViewController.quantity = self.quantity
            self.expenseViewController.itemName = self.itemName
            self.expenseViewController.category = self.category
            self.expenseViewController.amount = self.amount
            self.expenseViewController.dismissProtocol = self
            let navController = UINavigationController(rootViewController: self.expenseViewController)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }.resume()
    }
}

extension RecordingViewController {
    
    fileprivate func startRecording() throws {
        
        self.transcriptionOutputLabel.text = ""
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024,
                        format: recordingFormat) { [unowned self]
                            (buffer, _) in
                            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) {
            [unowned self]
            (result, _) in
            if let transcription = result?.bestTranscription {
                self.transcriptionOutputLabel.text = transcription.formattedString
            }
        }
    }
    
    fileprivate func stopRecording() {
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
}
