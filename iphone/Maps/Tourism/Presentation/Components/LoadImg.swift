import SwiftUI
import SDWebImageSwiftUI

struct LoadImageView: View {
  let url: String?
  
  @State var isError = false
  
  var body: some View {
    if let urlString = url {
      ZStack(alignment: .center) {
        WebImage(url: URL(string: urlString))
          .onSuccess(perform: { Image, data, cache in
            self.isError = false
          })
          .onFailure(perform: { isError in
            self.isError = true
          })
          .resizable()
          .indicator(.activity)
          .scaledToFill()
          .transition(.fade(duration: 0.2))
        if(isError) {
          Image(systemName: "exclamationmark.circle")
            .font(.system(size: 30))
            .background(SwiftUI.Color.clear)
            .foregroundColor(Color.hint)
            .clipShape(Circle())
        }
      }
    } else {
      Text(L("no_image"))
        .foregroundColor(Color.hint)
    }
  }
}

struct LoadImageView_Previews: PreviewProvider {
  static var previews: some View {
    LoadImageView(url: Constants.imageUrlExample)
  }
}
