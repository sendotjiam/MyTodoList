//
//  TodoRepository.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 06/04/22.
//

import Foundation
import UIKit

class BaseRepository {
     
    func setObject<Object>(_ object: Object, forKey: String) where Object: Encodable {
        do {
            let data = try JSONEncoder().encode(object)
            UserDefaults.standard.set(data, forKey: forKey)
            UserDefaults.standard.synchronize()
        } catch let encodeErr {
            print("Failed to encode object:", encodeErr)
        }
    }
        
    func getObject<Object>(forKey: String, castTo type: Object.Type) -> Object? where Object: Decodable {
        guard let data = UserDefaults.standard.data(forKey: forKey) else { return nil }
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch let decodeError{
            print("Failed to decode object:" , decodeError)
            return nil
        }
    }
}
