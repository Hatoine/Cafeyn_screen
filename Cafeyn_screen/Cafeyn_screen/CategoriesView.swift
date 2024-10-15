//
//  ContentView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 08/10/2024.
//

import SwiftUI

struct CategoriesView: View {
    
    @StateObject private var viewModel: CategoriesViewModel
    @State private var selectedInterests: [Name] = []
    @State private var isEditing = false
    
    private var interestsRepository: InterestsRepository
    
    init() {
        interestsRepository = InterestsRepository(apiService: HTTPmanager())
        let apiService = HTTPmanager()
        let categoriesRepository = CategoriesRepository(apiService: apiService)
        let interests = InterestsRepository(apiService: apiService)
        _viewModel = StateObject(wrappedValue: CategoriesViewModel(categoriesRepositories: categoriesRepository, interestsRepositories: interests))
         // Initialiser le repository des centres d'intérêt
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Première section : Centres d'intérêt sélectionnés
                    Section(
                        header: HStack {
                            Text("Organisez vos centres d’intérêt")
                                .font(.headline)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(action: {
                                isEditing.toggle()
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 20))
                                    .foregroundColor(isEditing ? .red : .black)
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
                            // Affichage des centres d'intérêts sélectionnés
                            ForEach(selectedInterests, id: \.self) { interest in
                                InterestRow(interest: interest.raw, isSelected: true) {
                                    removeFromSelected(interest: interest)
                                }
                                .transition(.scale)
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
                        if viewModel.isErrorLoading || viewModel.isEmptyList == true {
                            VStack(spacing: 8) {
                                Text("Aucune catégorie disponible")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            ).padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 0))
                        } else {
                            // Filtrer les éléments pour exclure ceux déjà sélectionnés
                            ForEach(viewModel.categories ?? [], id: \.self) { topic in
                                // Affichage du sujet principal
                                if !selectedInterests.contains(topic.name) {
                                    InterestRow(interest: topic.name.raw, isSelected: false) {
                                        toggleInterest(interest: topic.name)
                                    }
                                    .listRowBackground(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                                }
                                
                                // Affichage des sous-catégories
                                ForEach(topic.subTopics?.filter { !selectedInterests.contains($0.name) } ?? [], id: \.self) { subTopic in
                                    InterestRow(interest: subTopic.name.raw, isSelected: false) {
                                        toggleInterest(interest: subTopic.name)
                                    }
                                    .listRowBackground(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                                }
                            }
                        }
                    }.task {
                        viewModel.fetchCategories()
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationBarItems(
                    leading: Button("Annuler") {
                        clearSelectedInterests() // Efface tous les UserDefaults
                    }.foregroundStyle(.black),
                    trailing: Button("Enregistrer") {
                        saveSelectedInterests() // Sauvegarde des sélections
                    }.foregroundStyle(.black)
                )
                .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
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
    
    // Charger les centres d'intérêt depuis UserDefaults en utilisant le repository
    private func loadSelectedInterests() {
        selectedInterests = interestsRepository.loadSelectedInterests()
    }
    
    // Ajouter ou retirer un intérêt de la liste sélectionnée
    private func toggleInterest(interest: Name) {
        withAnimation {
            if selectedInterests.contains(interest) {
                selectedInterests.removeAll { $0 == interest }
            } else {
                selectedInterests.append(interest)
            }
            // Ne sauvegarde pas encore dans UserDefaults
        }
    }
    
    // Retirer un intérêt de la liste des sélectionnés
    private func removeFromSelected(interest: Name) {
        withAnimation {
            selectedInterests.removeAll { $0 == interest }
            // Ne sauvegarde pas encore dans UserDefaults
        }
    }
    
    // Sauvegarder les centres d'intérêts dans UserDefaults uniquement lorsque le bouton "Enregistrer" est appuyé
    private func saveSelectedInterests() {
        interestsRepository.saveSelectedInterests(selectedInterests)
        interestsRepository.idsToSave = self.selectedInterests.map { $0.key.replacingOccurrences(of: "topic.", with: "")}
        viewModel.saveSelectedCategories(ids: interestsRepository.idsToSave)
    }
    
    
    // Effacer la liste des centres d'intérêt et les UserDefaults
    private func clearSelectedInterests() {
        selectedInterests.removeAll() // Vider la liste des centres d'intérêt
        interestsRepository.clearSelectedInterests() // Supprimer des UserDefaults
        interestsRepository.idsToSave.removeAll()
        viewModel.saveSelectedCategories(ids: interestsRepository.idsToSave)
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
