// ErrorView.swift
// Created by José Duarte on 11/06/2023
// Copyright (c) 2023

import SwiftUI

struct ErrorView: View {
    let errorWrapper: ErrorWrapper
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("An error has occurred!")
                .font(.title)
                .padding(.bottom)
            Text(errorWrapper.error.localizedDescription)
                .font(.headline)
            Spacer()
            Text(errorWrapper.guidance)
                .font(.caption)
                .padding(.top)
                .multilineTextAlignment(.center)
        }
        .padding()
        .cornerRadius(16)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    enum SampleError: Error {
        case errorRequired
    }

    static var wrapper: ErrorWrapper {
        ErrorWrapper(error: SampleError.errorRequired, guidance: "You can safely ignore this error")
    }

    static var previews: some View {
        ErrorView(errorWrapper: wrapper)
    }
}
