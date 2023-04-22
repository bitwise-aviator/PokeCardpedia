//
//  CollectionLockView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/13/23.
//

import SwiftUI

struct CollectionLockView: View {
    @ObservedObject var lock = Padlock.lock
    @ViewBuilder
    var body: some View {
        let lockBinding = Binding(
            get: { lock.isLocked },
            set: {
                lock.setLock(to: $0)
                print(lock.isLocked)
            }
        )
        HStack {
            Image(systemName: lock.isLocked ? "lock.fill" : "lock.open.fill")
                .resizable().scaledToFit().frame(width: 50, height: 50)
            Toggle(isOn: !lockBinding) {
                Text(lock.isLocked ? "Locked" : "Unlocked")
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }.tint(.red).foregroundColor(lock.isLocked ? .green : .red)
        }
    }
}

struct CollectionLockView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionLockView()
    }
}
