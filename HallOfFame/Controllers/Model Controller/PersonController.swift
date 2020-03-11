//
//  PersonController.swift
//  HallOfFame
//
//  Created by theevo on 3/11/20.
//  Copyright © 2020 theevo. All rights reserved.
//

import Foundation

class PersonController {
    
    // MARK: - Shared Instance and Source of Truth
    
    static let shared = PersonController()
    var people: [Person] = []
    
    
    // MARK: - Private Properties
    
    private let baseURL = URL(string: "https://ios-api.devmountain.com/api/")
    private let peopleEndpoint = "people"
    private let offsetQueryItemName = "offset"
    private let personEndpoint = "person"
    
    
    // MARK: - Post (C)
    
    
    
    // MARK: - Get (R)
    
    func getPeople( page: Int, completion: @escaping (Result<[Person], PersonError>) -> Void ) {
        
        // 1) URL
        guard let url = baseURL else { return completion(.failure(.invalidURL)) }
        
        let peopleURL = url.appendingPathComponent(peopleEndpoint)
        
        // 1.1) components
        var urlComponents = URLComponents(url: peopleURL, resolvingAgainstBaseURL: true)
        
        let offset = String(page * 50)
        
        urlComponents?.queryItems = [URLQueryItem(name: offsetQueryItemName, value: offset)]
        
        guard let finalURL = urlComponents?.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        
        // 1.2) request
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.httpMethod = "GET" // GET by default. if you want to change the HTTP verb, you must change it yourself.
        
        // 2) Data Task
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // 3) Error handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
            
            // 4) Check for data
            guard let data = data else { return completion(.failure(.noData)) }
            
            //5) Decode data
            do {
                let people = try JSONDecoder().decode([Person].self, from: data)
                self.people = people
                return completion(.success(people))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
            
        }.resume()
    }
    
    func getPerson( id: Int, completion: @escaping (Result<Person,PersonError>) -> Void ) {
        
        // 1) URL
        guard let url = baseURL else { return completion(.failure(.invalidURL)) }
        
        // 1.1) components
        let personURL = url.appendingPathComponent(peopleEndpoint).appendingPathComponent(String(id))
        
        let urlComponents = URLComponents(url: personURL, resolvingAgainstBaseURL: true)
        
        guard let finalURL = urlComponents?.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        
        // 1.2) request
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2) Data Task
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // 3) Error handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
            
            // 4) Check for data
            guard let data = data else { return completion(.failure(.noData)) }
            
            //5) Decode data
            do {
                let personArray = try JSONDecoder().decode([Person].self, from: data)
                guard let person = personArray.first else { return completion(.failure(.noData)) }
                return completion(.success(person))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
        }.resume()
        
    }
    
    
    // MARK: - Put/Patch (U)
    
    
    
    // MARK: - Delete (D)
    
    
    
}
