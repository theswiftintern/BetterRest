//
//  ContentView.swift
//  BetterRest
//
//  Created by RJ Tedoco on 8/9/22.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var bedTimeResult = "12:00AM"
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    HStack {
                        Text("Estimated time")
                        Spacer()
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: wakeUp) { _ in
                                calculateBedtime()
                            }
                    }
                } header: {
                    Text("When do you want to wake up?")
                        .font(.subheadline.bold())
                }
                
                Section() {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        .onChange(of: sleepAmount) { _ in
                            calculateBedtime()
                        }
                } header: {
                    Text("Desired amount of sleep")
                        .font(.subheadline.bold())
                }
                
                Section() {
                    Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { numberOfCups in
                            Text(numberOfCups == 1 ? "\(numberOfCups) cup" : "\(numberOfCups) cups")
                        }
                    }
                    .onChange(of: coffeeAmount) { _ in
                        calculateBedtime()
                    }
                } header: {
                    Text("Daily coffee intake")
                        .font(.subheadline.bold())
                }
                
                Section() {
                    Text(bedTimeResult)
                } header: {
                    Text("Recommended Bedtime")
                }
                .headerProminence(.increased)
            }
            .navigationTitle("BetterRest")
           
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minuteInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hourInSeconds + minuteInSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            bedTimeResult = sleepTime.formatted(date: .omitted, time: .shortened);
            
        } catch {
            bedTimeResult = "Sorry, there was a problem calculating your bedtime."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
