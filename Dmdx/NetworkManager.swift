//
//  NetworkManager.swift
//  Dmdx
//
//  Created by Oleksandr Stepanov on 20.11.2021.
//

import Foundation
import Combine

class NetworkingManager {
    
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badURLResponse(url: let url): return "[🔥] Bad response from URL: \(url)"
            case .unknown: return "[⚠️] Unknown error occured"
            }
        }
    }
    
    static func download(url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ try handleURLResponse(output: $0, url: url) })
            .retry(3)
            .eraseToAnyPublisher()
    }
    
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        return output.data
    }
    
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
}

class CoinDataService: ObservableObject {
    
    @Published var allCoins: [Article] = []
    
    var coinSubscription: AnyCancellable?
    
    init() {
        getCoins()
    }
    
    func getCoins() {
        
        print(#function)
        guard let url = URL(string: "http://127.0.0.1:8000/api/tasks") else { return }
        print(#function, "------------TRUE---------")
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: ArticleModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins.tasks
                print(returnedCoins.tasks)
                self?.coinSubscription?.cancel()
            })
    }
    
}

struct ArticleModel: Codable, Hashable {
    let tasks: [Article]
}

struct Article: Codable, Hashable, Identifiable {
    let title: String
    let task: String
    let id: String
}
