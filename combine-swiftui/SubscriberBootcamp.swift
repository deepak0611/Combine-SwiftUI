//
//  SubscriberBootcamp.swift
//  combine-swiftui
//
//  Created by Deepak Kumar1 on 02/01/25.
//

import Foundation
import SwiftUI
import Combine

class SubscriberViewModel: ObservableObject {
    @Published var count = 0
    var cancellables = Set<AnyCancellable>()
    
    @Published var textFieldText: String = ""
    @Published var textIsValid: Bool = false
    
    @Published var showButton: Bool = false
    
    init() {
        setupTimer()
        addTextFieldSubscriber()
        addButtonSubscriber()
    }
    
    func addTextFieldSubscriber() {
        $textFieldText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // debounce is used to put a cooldown period after data has been publised, after 0.5 second when data has been published these map and sink functions will be called. this is mostly used in textfield search feature where we need to make any db/network call in the sink function, to reduce to db/network calls
            .map { (text) -> Bool in // this is the feature of combine, we can apply high level functions over the published data recieved, before providing it to the sink method.
                if text.count > 3 {
                    return true
                } else {
                    return false
                }
            }
            //.assign(to: \.textIsValid, on: self) // we can't make self weak in this case, so it is better to use sink method
            .sink(receiveValue: { [weak self] (isValid) in // this is the method where we get the published value
                self?.textIsValid = isValid
            })
            .store(in: &cancellables)
    }
    
    func setupTimer() {
        Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in // sink method receives the data that is published, timer publishes date value, that why we are receiving date value in the sink method
                guard let self = self else { return }
                self.count += 1
            }
            .store(in: &cancellables) // we need to store the reference of the publisher so that it can be cancelled when not required, else it will be giving compilation error
        
    }
    
    func addButtonSubscriber() {
        $textIsValid
            .combineLatest($count)
            .sink { [weak self] (isValid, count) in
                guard let self = self else { return }
                if isValid && count >= 10 {
                    self.showButton = true
                } else {
                    self.showButton = false
                }
            }
            .store(in: &cancellables)
    }
}

struct SubscriberBootcamp: View {
    
    @StateObject var vm = SubscriberViewModel()
    
    var body: some View {
        VStack {
            Text("\(vm.count)")
                .font(.largeTitle)
            
            Text("\(vm.textIsValid.description)")
            
            TextField("type something here...", text: $vm.textFieldText)
                .padding(.leading)
                .frame(height: 55)
                .font(.headline)
                .background(Color.teal)
                .cornerRadius(10)
                .overlay (
                    ZStack {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.red)
                            .opacity(vm.textFieldText.isEmpty ? 0.0 : vm.textIsValid ? 0.0 : 1.0)
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.green)
                            .opacity(vm.textIsValid ? 1.0 : 0.0)
                    }
                        .font(.title)
                        .padding(.trailing)
                    , alignment: .trailing
                )
            
            Button(action: {}, label: {
                Text("Submit".uppercased())
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .opacity(vm.showButton ? 1.0 : 0.5)
            })
            .disabled(!vm.showButton)
        }
        .padding()
    }
}

#Preview {
    SubscriberBootcamp()
}
