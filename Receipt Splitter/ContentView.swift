//  ContentView.swift
//  Receipt Splitter
//
//  Created by Brian Liu on 12/25/23.
//
import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false
    @State private var receiptImage: UIImage?
    @State private var receiptItems: [ReceiptItem] = []
    @State private var isProcessing = false
    @State private var userName: String = ""
    @State private var showUserSelection = false
    @State private var userCount: Int = 1
    
    let ocrManager = OCRManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                if isProcessing {
                    ProgressView("Processing...")
                } else if showUserSelection {
                    // Pass the userCount and selectedItems to UserSelectionView
                    UserSelectionView(items: $receiptItems, selectedItems: $selectedItems, userCount: $userCount)
                } else {
                    // Show NameEntryView when not processing or showing selection
                    NameEntryView(userName: $userName, userCount: $userCount, showUserSelection: $showUserSelection)
                }

                Button("Scan Receipt") {
                    showingCamera = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(showUserSelection) // Disable while showing user selection
            }
            .navigationTitle("WeSplit")
        }
        .sheet(isPresented: $showingCamera, onDismiss: processImage) {
            CameraView(isShown: $showingCamera, image: $receiptImage)
        }
    }

    func processImage() {
        guard let imageToProcess = receiptImage else {
            print("No image available for processing")
            return
        }
        print("Starting image processing...")
        isProcessing = true

        ocrManager.processImage(imageToProcess) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success(let items):
                    print("Image processed successfully with \(items.count) items.")
                    self.receiptItems = items
                    self.showUserSelection = true // Show selection after processing
                case .failure(let error):
                    print("Image processing failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct NameEntryView: View {
    @Binding var userName: String
    @Binding var userCount: Int
    @Binding var showUserSelection: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("User #\(userCount): Enter your name")
                .font(.headline)

            TextField("Name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Next") {
                self.showUserSelection = true // Trigger showing UserSelectionView
                self.userName = "" // Reset name for the next user
            }
            .disabled(userName.isEmpty)
            .padding()
            .background(userName.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
