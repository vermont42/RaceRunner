//
//  Weather.swift
//  RaceRunner
//
//  Created by Josh Adams on 10/19/22.
//  Copyright © 2022 Josh Adams. All rights reserved.
//

import CoreLocation

enum WeatherRequester {
  static func currentWeatherAndTemperature(location: CLLocation) async -> CurrentWeatherAndTemperature? {
    do {
      guard let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&exclude=minutely,hourly,daily,alerts&units=metric&appid=\(Config.openWeatherKey)") else {
        return nil
      }

      let (data, _) = try await URLSession.shared.data(from: url)
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let response = try decoder.decode(Response.self, from: data)
      let current = response.current

      guard !current.weather.isEmpty else {
        return nil
      }

      return CurrentWeatherAndTemperature(weather: current.weather[0].description, temperature: current.temp)
    } catch {
      return nil
    }
  }
}

struct CurrentWeatherAndTemperature {
  let weather: String
  let temperature: Double
}

private struct Response: Decodable {
  let current: Current
}

private struct Current: Decodable {
  let temp: Double
  let weather: [Weather]
}

private struct Weather: Decodable {
  let description: String
}
