//
//  ContentView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 08/10/2024.
//

import SwiftUI

struct CategoriesView: View {
    
    @StateObject private var viewModel: CategoriesViewModel
    
        init() {
              let apiService = HTTPmanager()
              let CategoriesRepository = CategoriesRepository(apiService: apiService)
            _viewModel = StateObject(wrappedValue: CategoriesViewModel(categoriesRepositories: CategoriesRepository))
          }
    
    @State private var selectedInterests: [String] = []
    
    var body: some View {
        
        let categoriesToDiscover: [String] = viewModel.categories?.map{$0.name.raw} ?? []
        
        NavigationView {
           
            VStack {
                
                // Liste comprenant les deux sections
                List {
                    // Première section : Centres d'intérêt sélectionnés
                    Section(header: Text("Organisez vos centres d’intérêt")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                    ) {
                        if selectedInterests.isEmpty {
                            VStack(spacing: 8) {
                                Text("Aucun centre d’intérêt sélectionné")
                                    .bold()
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Text("Votre accueil sera personnalisé en fonction de vos choix.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                                    .background(Color.white)
                                    
                            )
                            .padding()
                        } else {
                            // Affichage des centres d'intérêts sélectionnés
                            ForEach(selectedInterests, id: \.self) { interest in
                                InterestRow(interest: interest, isSelected: true) {
                                    removeFromSelected(interest: interest)
                                }
                            }
                        }
                    }.listRowBackground(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                    
                    // Seconde section : Centres d'intérêt à découvrir
                    Section(header: Text("À découvrir")
                                .font(.headline)
                                .padding(.top, 20)
                                
                    ) {
                        if viewModel.isLoading {
                            ProgressView("Chargement des catégories")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(EdgeInsets(top: 20, leading: 50, bottom: 0, trailing: 0))
                                .background(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                        }
                        if viewModel.isErrorLoading {
                            VStack(spacing: 8) {
                                Text("Erreur lors du chargement des catégories.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                  
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        } else {
                            ForEach(categoriesToDiscover.filter { !selectedInterests.contains($0) }, id: \.self) { interest in
                                InterestRow(interest: interest, isSelected: false) {
                                    toggleInterest(interest: interest)
                                       
                                }.listRowBackground(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                                  
                            }
                        }
                        // Utilisation de .filter pour exclure les éléments déjà sélectionnés
                       
                    }
                }.task {
                    viewModel.fetchCategories()
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarItems(
                leading: Button("Annuler") {
                    selectedInterests.removeAll()
                }.foregroundStyle(.black),
                trailing: Button("Enregistrer") {
                    // Action pour enregistrer
                }.foregroundStyle(.black)
                   
            )
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Centres d’intérêt")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    // Fonction pour ajouter ou retirer un intérêt de la liste sélectionnée
    private func toggleInterest(interest: String) {
        if selectedInterests.contains(interest) {
            // Supprimer de la liste des sélectionnés
            selectedInterests.removeAll { $0 == interest }
        } else {
            // Ajouter à la liste des sélectionnés
            selectedInterests.append(interest)
        }
    }
    
    // Fonction pour retirer un intérêt de la liste des sélectionnés
    private func removeFromSelected(interest: String) {
        selectedInterests.removeAll { $0 == interest }
    }
}

struct InterestRow: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: isSelected ? "minus.circle" : "plus.circle")
                    .foregroundColor(isSelected ? .red : .black)
                    .font(.title3)
            }
            Text(interest)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

struct InterestSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}


#Preview {
    CategoriesView()
}
