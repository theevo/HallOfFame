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
    private let contentTypeKey = "Content-Type"
    private let contentTypeValue = "application/json"
    private let likesEndpoint = "likes"
    private let dislikesEndpoint = "dislikes"
    
    
    // MARK: - Post (C)
    
    func postPerson( firstName: String,
                     lastName: String,
                     cohort: String,
                     completion: @escaping (Result<Person, PersonError>) -> Void) {
        // 1) URL
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let personURL = baseURL.appendingPathComponent(personEndpoint)
        print(personURL)
        
        let person = Person(firstName: firstName, lastName: lastName, cohort: cohort, id: nil, likes: nil, dislikes: nil)
        
        var request = URLRequest(url: personURL)
        request.httpMethod = "POST"
        request.setValue(contentTypeValue, forHTTPHeaderField: contentTypeKey)
        request.httpBody = try? JSONEncoder().encode(person)
        
        // 2) DataTask
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // 3) Error Handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
            
            // 4) Check for Data
            guard let data = data else {
                return completion(.failure(.noData))
            }
            
            // 5) Decode
            do {
                let people = try JSONDecoder().decode([Person].self, from: data)
                guard let person = people.first else {
                    return completion(.failure(.noData)) }
                
                // successful POST
                self.people.append(person)
                return completion(.success(person))
                
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
            
        }.resume()
        
    }
    
    func postLike( interestText: String,
                   person: Person,
                   completion: @escaping (Result<Like, PersonError>) -> Void){
        guard let id = person.id,
            let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let likesURL = baseURL.appendingPathComponent(likesEndpoint)
        let personIdURL = likesURL.appendingPathComponent(String(id))
        print(personIdURL)
        
        let interest = InterestPOSTObject(interest: interestText)
        
        var request = URLRequest(url: personIdURL)
        request.httpMethod = "POST"
        request.setValue(contentTypeValue, forHTTPHeaderField: contentTypeKey)
        request.httpBody = try? JSONEncoder().encode(interest)
        
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
                let responseArray = try JSONDecoder().decode([Like].self, from: data)
                guard let like = responseArray.first else {
                    return completion(.failure(.noData)) }
                
                return completion(.success(like))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
        }.resume()
    }
    
    func postDislike( interestText: String,
                   person: Person,
                   completion: @escaping (Result<Dislike, PersonError>) -> Void){
        guard let id = person.id,
            let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let dislikesURL = baseURL.appendingPathComponent(dislikesEndpoint)
        let personIdURL = dislikesURL.appendingPathComponent(String(id))
        print(personIdURL)
        
        let interest = InterestPOSTObject(interest: interestText)
        
        var request = URLRequest(url: personIdURL)
        request.httpMethod = "POST"
        request.setValue(contentTypeValue, forHTTPHeaderField: contentTypeKey)
        request.httpBody = try? JSONEncoder().encode(interest)
        
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
                let responseArray = try JSONDecoder().decode([Dislike].self, from: data)
                guard let dislike = responseArray.first else {
                    return completion(.failure(.noData)) }
                
                return completion(.success(dislike))
            } catch {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
        }.resume()
    }
    
    
    
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
        request.setValue(contentTypeValue, forHTTPHeaderField: contentTypeKey)
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
    
    func getPerson( person: Person, completion: @escaping (Result<Person,PersonError>) -> Void ) {
        
        // 1) URL
        guard let url = baseURL else { return completion(.failure(.invalidURL)) }
        
        // 1.1) components
        let idString = person.id != nil ? "\(person.id!)" : ""
        let personURL = url.appendingPathComponent(personEndpoint).appendingPathComponent(idString)
        
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
    
    func delete(person: Person, completion: @escaping (Result<Person, PersonError>) -> Void) {
        
        guard let id = person.id,
        let baseURL = baseURL else { return
            completion(.failure(.invalidURL)) }
        let personURL = baseURL.appendingPathComponent(personEndpoint)
        let personIdURL = personURL.appendingPathComponent(String(id))
        print(personIdURL)
        
        var request = URLRequest(url: personIdURL)
        request.httpMethod = "DELETE"
        request.setValue(contentTypeValue, forHTTPHeaderField: contentTypeKey)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            // 3) Error handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrown(error)))
            }
            
            // 4) Check for data
            guard let data = data else { return completion(.failure(.noData)) }

            //5) Decode data
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print(responseString)
            
            if responseString == "OK",
                let index = self.people.firstIndex(of: person) {
                
                self.people.remove(at: index)
                return completion(.success(person))
            } else {
                return completion(.failure(.failToDelete))
            }
            
        }.resume()
    }
    
}
