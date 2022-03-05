//
//  ContentView.swift
//  BetterRest
//
//  Created by Anh Le on 28/02/2022.
//

import SwiftUI
import Foundation
import CoreML

struct ContentView: View {
    @State private var amountSleep: Double = 8.0
    @State private var wakeupTime: Date = ContentView.defaultWakeTime
    @State private var amountCoffee = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 4) {
                    Text("How much do you want to sleep?")
                        .font(.headline)
                    Stepper("\(amountSleep.formatted()) hours", value: $amountSleep, in: 0...24, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("What time do you want to wake up")
                        .font(.headline)
                    DatePicker("Please enter you time", selection: $wakeupTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("How much coffee do you drink?")
                        .font(.headline)
                    Stepper(amountCoffee == 1 ? "\(amountCoffee) cup" : "\(amountCoffee) cups", value: $amountCoffee, in: 0...20, step: 1)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate bedtime", action: calculateBedTime)
            }.alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
        
    }
    
    private func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let component = Calendar.current.dateComponents([.hour, .minute], from: wakeupTime)
            let hour =  (component.hour ?? 0) * 60 * 60
            let minute =  (component.minute ?? 0) * 60 * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: amountSleep, coffee: Double(amountCoffee))
            let result = wakeupTime - prediction.actualSleep
            alertTitle = "You should go in bed at..."
            alertMessage = result.formatted(date: .omitted, time: .shortened)
        } catch {
            // Something went wrong!
            print(error.localizedDescription)
            alertTitle = "Error"
            alertMessage = "There was a error calculating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
