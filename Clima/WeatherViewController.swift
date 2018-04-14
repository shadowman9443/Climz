//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
class WeatherViewController: UIViewController ,CLLocationManagerDelegate,changeCitydelegate{
   
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDatamodel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate=self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherdata(url:String,parameters:[String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess {
                let weatherData:JSON = JSON(response.result.value!)
                self.updateWeatherData(json:weatherData)
            }else{
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text="Network Connection error"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON) {
        if let tempresult = json["main"]["temp"].double {
            weatherDatamodel.temparatire = Int(tempresult - 273.15)
            weatherDatamodel.city=json["name"].stringValue
            weatherDatamodel.condition=json["weather"][0]["id"].intValue
            weatherDatamodel.weathericonname = weatherDatamodel.updateWeatherIcon(condition: weatherDatamodel.condition)
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather Unavailable"
        }
      
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDatamodel.city
        temperatureLabel.text = "\(weatherDatamodel.temparatire)°"
        weatherIcon.image = UIImage(named: weatherDatamodel.weathericonname)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location=locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("latitude= \(location.coordinate.latitude),latitude= \(location.coordinate.longitude)")
            
            let latitude=String(location.coordinate.latitude)
            let longitude=String(location.coordinate.longitude)
            let param:[String : String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
            getWeatherdata(url:WEATHER_URL,parameters:param)
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text="Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredCity(city: String) {
        let param:[String : String] = ["q" : city  , "appid" : APP_ID]
        getWeatherdata(url:WEATHER_URL,parameters:param)
    }
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVc =  segue.destination as! ChangeCityViewController
            destinationVc.delegate = self
            
        }
    }
    
    
    
    
}


