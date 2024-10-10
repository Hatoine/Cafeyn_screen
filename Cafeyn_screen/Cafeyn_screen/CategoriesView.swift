//
//  ContentView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 08/10/2024.
//

import SwiftUI

struct CategoriesView: View {
    
    @StateObject private var viewModel: CategoriesViewModel
    @State private var selectedInterests: [String] = []
    @State private var isEditing = false // État pour gérer le mode édition
    
    init() {
        let apiService = HTTPmanager()
        let categoriesRepository = CategoriesRepository(apiService: apiService)
        _viewModel = StateObject(wrappedValue: CategoriesViewModel(categoriesRepositories: categoriesRepository))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Première section : Centres d'intérêt sélectionnés (provenant des UserDefaults)
                    Section(
                        header: HStack { // Personnalisation du header avec un HStack
                            Text("Organisez vos centres d’intérêt")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: {
                                isEditing.toggle()
                            }) {
                                if isEditing {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
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
                            // Affichage des centres d'intérêts sélectionnés (provenant des UserDefaults)
                            ForEach(selectedInterests, id: \.self) { interest in
                                InterestRow(interest: interest, isSelected: true) {
                                    removeFromSelected(interest: interest) // Retirer l'intérêt
                                }.transition(.move(edge: .trailing))
                            }
                            .onMove { from, to in
                                selectedInterests.move(fromOffsets: from, toOffset: to)
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
                            // Affichage des catégories et sous-catégories
                            ForEach(viewModel.categories?.filter { !selectedInterests.contains($0) } ?? [], id: \.self) { interest in
                                InterestRow(interest: interest, isSelected: false) {
                                    toggleInterest(interest: interest) // Ajouter ou retirer l'intérêt
                                }.listRowBackground(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                            }
                        }
                    }.task {
                        viewModel.fetchCategories()
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationBarItems(
                    leading: Button("Annuler") {
                        clearSelectedInterests() // Effacer tout
                    }.foregroundStyle(.black),
                    trailing: Button("Enregistrer") {
                        saveSelectedInterests() // Sauvegarder
                    }.foregroundStyle(.black)
                )
                .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive)) // Gérer l'état d'édition
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Centres d’intérêt")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                loadSelectedInterests() // Charger les centres d'intérêts depuis UserDefaults quand la vue apparaît
            }
        }
    }
    
    // Fonction pour charger les centres d'intérêt depuis les UserDefaults
    private func loadSelectedInterests() {
        if let savedInterests = UserDefaults.standard.array(forKey: "selectedInterests") as? [String] {
            selectedInterests = savedInterests
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
        saveSelectedInterests() // Sauvegarder les changements après modification
    }
    
    // Fonction pour retirer un intérêt de la liste des sélectionnés
    private func removeFromSelected(interest: String) {
        // Retirer de la liste des centres d'intérêt sélectionnés
        selectedInterests.removeAll { $0 == interest }
        saveSelectedInterests() // Mettre à jour UserDefaults immédiatement
    }
    
    // Fonction pour sauvegarder les centres d'intérêts dans les UserDefaults
    private func saveSelectedInterests() {
        UserDefaults.standard.set(selectedInterests, forKey: "selectedInterests")
    }
    
    // Fonction pour effacer la liste des centres d'intérêt et les UserDefaults
    private func clearSelectedInterests() {
        selectedInterests.removeAll() // Vider la liste des centres d'intérêt
        UserDefaults.standard.removeObject(forKey: "selectedInterests") // Supprimer des UserDefaults
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

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
