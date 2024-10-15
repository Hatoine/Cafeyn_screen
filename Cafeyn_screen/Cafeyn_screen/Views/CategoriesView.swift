//
//  ContentView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 08/10/2024.
//

import SwiftUI

//Main app view
struct CategoriesView: View {
    
    //StateObject to create a reference type inside the view
    @StateObject private var viewModel: CategoriesViewModel
    
    //State properties
    @State private var selectedInterests: [Name] = []
    @State private var isEditing = false
    
    //Pencil image name
    let imageReorderingName = "square.and.pencil"
    
    //Hard coded strings to localize
    let interests = "Organisez vos centres d’intérêt"
    let placeHolderInterestsText = "Aucun centre d’intérêt sélectionné"
    let secondPlaceHolderInterestsText = "Votre accueil sera personnalisé en fonction de vos choix."
    let sectionOneHeaderText = "À découvrir"
    let progressViewText = "Chargement des catégories"
    let emptyListText = "Aucune catégorie disponible"
    let toolbarText = "Centres d’intérêt"
    let cancelButtonText = "Annuler"
    let saveButtonText = "Enregistrer"
    
    
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
                    //List first section to display interests
                    Section(
                        header: HStack {
                            //Text for section 0 header
                            SectionZeroHeaderText(text: interests)
                            
                            //Button to allow reordering interests
                            Button(action: {
                                isEditing.toggle()
                            }) {
                                Image(systemName: imageReorderingName)
                                    .font(.system(size: 20))
                                    .foregroundColor(isEditing ? .red : .black)
                            }
                        }
                    ) {
                        //Check if interests list is empty. If the interests list is empty, a placeholder view is display
                        if selectedInterests.isEmpty {
                            //Placeholder view if interests list is empty
                            InterestsPlaceHolderView(mainText: placeHolderInterestsText, subText: secondPlaceHolderInterestsText)
                        } else {
                            //Display interests rows
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
                    
                    //List second section to display catagories
                    Section(header: SectionOneHeaderText(headerText: sectionOneHeaderText)
                    ) {
                        //Progressview when data is loading
                        if viewModel.isLoading {
                            ProgressView(progressViewText)
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(EdgeInsets(top: 20, leading: 50, bottom: 0, trailing: 0))
                                .background(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                        }
                        //Check if an error occurs in data loading or categories list is empty. Display a placeholder view in this case.
                        if viewModel.isErrorLoading || viewModel.isEmptyList == true {
                            //Placeholder view
                            NoCategoriesView(noCategoriesText:emptyListText )
                        } else {
                            //Filter elements to exclude categories already selected by user
                            ForEach(viewModel.categories ?? [], id: \.self) { topic in
                                //Display categories list
                                if !selectedInterests.contains(topic.name) {
                                    InterestRow(interest: topic.name.raw, isSelected: false) {
                                        toggleInterest(interest: topic.name)
                                    }
                                    .listRowBackground(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                                }
                                
                                //Display sub categories list
                                ForEach(topic.subTopics?.filter { !selectedInterests.contains($0.name) } ?? [], id: \.self) { subTopic in
                                    InterestRow(interest: subTopic.name.raw, isSelected: false) {
                                        toggleInterest(interest: subTopic.name)
                                    }
                                    .listRowBackground(Color(red: 1, green: 0.9918245673, blue: 0.974753201))
                                }
                            }
                        }
                    }.task {
                        //Load interests in list first section
                        loadSelectedInterests()
                        //Load categories from webservice
                        viewModel.fetchCategories()
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationBarItems(
                    leading:
                        //Cancel button to cancel interests and clear userdefaults  and interests list
                    Button(cancelButtonText) {
                        clearSelectedInterests() // Efface tous les UserDefaults
                    }.foregroundStyle(.black),
                    trailing:
                        //Save button to save interests in userdefaults list. If not clicked by the user, interests won't be store in userdefaults and data won't persist in the interests list. If the user delete all (or partially) interests manually, a click on the save button is necessary to clear userdefaults, otherwise interests data will persist in userdefaults
                    Button(saveButtonText) {
                        saveSelectedInterests()
                    }.foregroundStyle(.black)
                )
                .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        //Toolbar text
                        ToolBarTextView(toolbarText: toolbarText)
                    }
                }
            }
        }
    }
    
    //Load interests stored in userdefaults from repository
    private func loadSelectedInterests() {
        selectedInterests = interestsRepository.loadSelectedInterests()
    }
    
    //Add or remove an interest from the interests list, not store or remove data from userdefaults
    private func toggleInterest(interest: Name) {
        withAnimation {
            if selectedInterests.contains(interest) {
                selectedInterests.removeAll { $0 == interest }
            } else {
                selectedInterests.append(interest)
            }
        }
    }
    
    //Remove interest from interests list, not remove data from userdefaults
    private func removeFromSelected(interest: Name) {
        withAnimation {
            selectedInterests.removeAll { $0 == interest }
            // Ne sauvegarde pas encore dans UserDefaults
        }
    }
    
    //Save interests in userdefaults when user click the save button
    private func saveSelectedInterests() {
        interestsRepository.saveSelectedInterests(selectedInterests)
        interestsRepository.idsToSave = self.selectedInterests.map { $0.key.replacingOccurrences(of: "topic.", with: "")}
        viewModel.saveSelectedCategories(ids: interestsRepository.idsToSave)
    }
    
    
    //Clear interests list and remove data from userdefaults
    private func clearSelectedInterests() {
        selectedInterests.removeAll() // Vider la liste des centres d'intérêt
        interestsRepository.clearSelectedInterests() // Supprimer des UserDefaults
        interestsRepository.idsToSave.removeAll()
        viewModel.saveSelectedCategories(ids: interestsRepository.idsToSave)
    }
}

//Interest row to display categories and interests in lists
struct InterestRow: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void
    let imageRemoveName = "minus.circle"
    let imageAddName = "plus.circle"
    
    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: isSelected ? imageRemoveName : imageAddName)
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

