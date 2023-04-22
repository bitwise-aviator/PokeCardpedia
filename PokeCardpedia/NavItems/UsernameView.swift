//
//  UsernameView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/13/23.
//

import SwiftUI

struct UsernameView: View {
    @Binding var userNameSelectionActive: Bool    
    var body: some View {
        HStack {
            Image(systemName: "person.fill").resizable().scaledToFit().frame(width: 50, height: 50)
            Text(!CoreSettings.settings.trainerName.isEmpty ? CoreSettings.settings.trainerName : "User")
                .font(.system(.title3, design: .rounded))
                .bold()
        }.onTapGesture {
            userNameSelectionActive = true
        }
    }
}

struct UsernameView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameView(userNameSelectionActive: .constant(false))
    }
}
