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

class RecordingViewController: UIViewController,  CLLocationManagerDelegate {
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    let locationManager = CLLocationManager()
    var locationCoordinate = CLLocationCoordinate2D()
    
    var transcriptionOutputLabel = UILabel()
    var authentication = "901d1895824478ac0d0bfde1be6d6cf7"

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
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationCoordinate = locValue
    }
    
    @objc func handleDoneTapped()
    {
        stopRecording()
        if let liveString = transcriptionOutputLabel.text
        {
            let strArr = liveString.split(separator: " ")
            for item in strArr
            {
                let components = item.components(separatedBy: CharacterSet.decimalDigits.inverted)
                let part = components.joined()
                if let intVal = Int(part)
                {
                    print("This is a number \(intVal)")
                }
                else
                {
                    let lowerCased = item.lowercased()
                    switch lowerCased
                    {
                    case "zero":
                        print("0")
                    case "one":
                        print("1")
                    case "two":
                        print("2")
                    case "three":
                        print("3")
                    case "four":
                        print("4")
                    case "five":
                        print("5")
                    case "six":
                        print("6")
                    case "seven":
                        print("7")
                    case "eight":
                        print("8")
                    case "nine":
                        print("9")
                    default:
                        print("default")
                    }
                }
            }
            partsOfSpeech(for: liveString)
        }
//        dismiss(animated: true, completion: .none)
    }
    
    func partsOfSpeech(for text: String)
    {
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
                            print("This is a number in method: \(intVal)")
                        }
                        else
                        {
                            let numberFormatter = NumberFormatter()
                            numberFormatter.locale = Locale(identifier: "en_US_POSIX")  // if you dont set locale it will use current locale so it wont detect one if the language it is not english at the devices locale
                            numberFormatter.numberStyle = .spellOut
                            let number = numberFormatter.number(from: word)
                            print("The number is \(number ?? 0)")
                        }
                    }
                    if tag.rawValue == "Noun"
                    {
                        let lowerCasedWord = word.lowercased()
                        if lowerCasedWord != "expense"
                        {
                            print("The noun is \(lowerCasedWord)")
                        }
                    }
                }
            }
        } else {
            print("Cannot be exexuted on previous versions")
            // Fallback on earlier versions
        }
        let lattitude = "\(self.locationCoordinate.latitude)"
        let longitude = "\(self.locationCoordinate.longitude)"
        getNearbyRestaurants(latitude: lattitude, longitude: longitude)
    }
    
    func getNearbyRestaurants(latitude: String, longitude: String)
    {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let urlString = "https://developers.zomato.com/api/v2.1/geocode?lat=" + latitude + "&lon=" + longitude
        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.httpMethod = "GET"
        request.setValue(authentication, forHTTPHeaderField: "user-key")
        session.dataTask(with: request as URLRequest)
        { (data, response, error) in
            if let responseValue = response
            {
                print("The response is: ")
                print(responseValue)
            }
            if let dataResposne = data
            {
                do
                {
                    var json = try JSONSerialization.jsonObject(with: dataResposne, options: JSONSerialization.ReadingOptions.mutableContainers)
                    if let dictionary = json as? NSDictionary
                    {
                        print(dictionary)
                    }
                }
                catch
                {
                    print("Error occured")
                }
            }
            self.dismiss(animated: true, completion: .none)
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
