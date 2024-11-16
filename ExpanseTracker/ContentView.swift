//
//  ContentView.swift
//  ExpanseTracker
//
//  Created by Ricky Primayuda Putra on 16/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("isFirstTime") private var isFirstTime: Bool = true
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    @AppStorage("lockWhenAppGoesBackground") private var lockWhenAppGoesBackground: Bool = false
    
    @State private var activeTab: Tab = .recents
    
    var body: some View {
        LockView(lockType: .both, lockPin: "3536", isEnabled: isAppLockEnabled, lockWhenAppGoesBackground: lockWhenAppGoesBackground) {
            TabView(selection: $activeTab){
                Recents()
                    .tag(Tab.recents)
                    .tabItem{Tab.recents.tabContent}
                
                Search()
                    .tag(Tab.search)
                    .tabItem{Tab.search.tabContent}
                
                Graph()
                    .tag(Tab.charts)
                    .tabItem{Tab.charts.tabContent}
                
                Settings()
                    .tag(Tab.settings)
                    .tabItem{Tab.settings.tabContent}
            }
            .tint(appTint)
            .sheet(isPresented: $isFirstTime, content: {
                IntroScreenView()
                    .interactiveDismissDisabled()
            })
        }
    }
}

#Preview {
    ContentView()
}
