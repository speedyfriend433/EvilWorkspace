//
//  ContentView.swift
//  CantStopMe
//
//  Created by fridakitten on 03.05.25.
//

//
//  ContentView.swift
//  EnhancedEvilApp
//
//  Created by fridakitten & Enhanced AI on [Current Date]
//

import SwiftUI

struct ContentView: View {
    // Use AppStorage to persist the state across launches
    @AppStorage("isEvil") var isEvil: Bool = false

    // State to disable buttons while service is unavailable
    @State private var isServiceAvailable: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Evil")
                    .foregroundColor(.red)
                Text("Workspace")
                    .foregroundColor(.white)
            }
            .font(.system(size: 40, weight: .bold))

            Spacer()

            if !isServiceAvailable {
                Text("⚠️ Private API access failed.\nExploit functionality disabled.")
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button {
                // Toggle the evil state
                isEvil.toggle()
                if isEvil {
                    // Start the persistence loop when toggled ON
                    EvilPersistenceManager.manageEvilProcess(mode: .stayAlive, isEvil: $isEvil)
                }
                // The loop will stop itself when isEvil becomes false
            } label: {
                Text(isEvil ? "😈 Stop Being Evil" : "😇 Be Evil")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(isEvil ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!isServiceAvailable) // Disable if service failed

            Button {
                // Trigger an immediate restart attempt
                EvilPersistenceManager.manageEvilProcess(mode: .restartNow, isEvil: $isEvil)
            } label: {
                 Text("☢️ Attempt Restart")
                 .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isEvil || !isServiceAvailable) // Disable if evil mode is on OR service failed

            Spacer()

            VStack {
                 Text("PID: \(String(getpid()))")
                 Text("Status: \(isEvil ? "EVIL ACTIVE" : "Idle") \(isServiceAvailable ? "✅" : "❌")")
                 Text("Discovered by SeanIsTethered")
            }
            .font(.caption)
            .foregroundColor(.gray)

        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            // Check service availability on appear
            if EvilWorkspaceService.shared != nil {
                isServiceAvailable = true
                // If returning to the app and isEvil is true, ensure the loop restarts
                if isEvil {
                    EvilPersistenceManager.manageEvilProcess(mode: .stayAlive, isEvil: $isEvil)
                }
            } else {
                isServiceAvailable = false
                isEvil = false // Force evil off if service is unavailable
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
