import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var query: String = ""

    var body: some View {
        VStack {
            TextField("Search Parameter", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Search") {
                viewModel.search(byParameter: query)
            }

            List(viewModel.results, id: \.id) { experiment in
                Text(experiment.name)
            }
        }
        .padding()
    }
}
