//
//  CounterpartyService.swift
//  Dmdx
//
//  Created by admin on 06.04.2022.
//

import Foundation

protocol CounterpartyServiceable {
    func getMyCounterparties(type: CounterpartyType) async -> Result<[Counterparty], RequestError>
//    func getCounterpartyPersons(type: CounterpartyType, counterpartyId: String) async -> Result<Movie, RequestError>
}

struct CounterpartyService: HTTPClient, CounterpartyServiceable {
    func getMyCounterparties(type: CounterpartyType) async -> Result<[Counterparty], RequestError> {
        return await sendRequest(endpoint: CounterpartyEndpoint.getMyCounterparties(type: type))
    }
    
    
}
