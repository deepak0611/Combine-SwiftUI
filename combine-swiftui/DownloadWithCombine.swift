//
//  DownloadWithCombine.swift
//  combine-swiftui
//
//  Created by Deepak Kumar1 on 07/01/25.
//

import SwiftUI
import Combine

struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
    
}

class DownloadWithCombineViewModel: ObservableObject {
    
    @Published var posts: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return
        }
        //combine discussions
        /*
        // 1. sign up for monthly subscription for package to be delievered
        // 2. the company would make the package behind the scene
        // 3. receive the package at the front door
        // 4. make sure the box isn't damaged
        // 5. open and make sure that the item isn't damaged
        // 6. use the item!!
        // 7. cancellable at any time
        
        // 1. create the publisher
        // 2. subscribe publisher on the background thread
        // 3. receive on the main thread
        // 4. tryMap (check that the data is good)
        // 5. decode (data into post models)
        // 6. sink (put the item into the app)
        // 7. store (cancel subscription if needed)
        */
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
//            .tryMap { (data, response) -> Data in
//                guard
//                    let response = response as? HTTPURLResponse,
//                    response.statusCode >= 200 && response.statusCode < 300 else {
//                    throw URLError(.badServerResponse)
//                }
//                return data
//            }
            .decode(type: [PostModel].self, decoder: JSONDecoder())
            .sink { completion in
                print("copletion: \(completion)")
            } receiveValue: { [weak self] (returnedPosts) in
                self?.posts = returnedPosts
            }
            .store(in: &cancellables)
        
    }
    
    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return output.data
    }
    
}

struct DownloadWithCombine: View {
    
    @StateObject var vm = DownloadWithCombineViewModel()
    
    var body: some View {
        ZStack {
            Color.red
            List {
                ForEach(vm.posts) { post in
                    VStack {
                        Text(post.title)
                            .font(.headline)
                        Text(post.body)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    DownloadWithCombine()
}
