//
//  PostMediaView.swift
//  XClone
//
//  Created by Stephan Dowless on 2/26/25.
//

import AVKit
import Kingfisher
import SwiftUI

struct PostMediaView: View {
    @State private var player = AVPlayer()
    
    let post: Post

    var body: some View {
        Group {
            if let imageUrl = post.imageURL {
                KFImage(URL(string: imageUrl))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 10))
                    .contentShape(.rect)
            } else if let videoURL = post.videoURL {
                VideoPlayer(player: player)
                    .scaledToFill()
                    .background(Color(.systemBackground))
                    .clipShape(.rect(cornerRadius: 10))
                    .contentShape(.rect)
            }
        }
        .onAppear {
            if let videoURL = post.videoURL, let url = URL(string: videoURL) {
                player = AVPlayer(url: url)
                player.play()
            }
        }
        .onDisappear {
            if let videoURL = post.videoURL {
                print("DEBUG: Pausing now..")
                player.pause()
            }
        }
    }
}

#Preview {
    PostMediaView(post: MockData.post)
}
