import SwiftUI

struct HomeView: View {
    // Bu o'zgaruvchi yon menyuning ochiq/yopiqligini boshqaradi
    @Binding var isSideMenuShowing: Bool
    // Bu o'zgaruvchi navbat olish oynasining ochiq/yopiqligini boshqaradi
    @State private var isBookingSheetShowing: Bool = false
    
    var body: some View {
        ZStack {
            // Orqa fon
            Color.theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. Yuqori qism (Top Bar)
                    topBar
                    
                    // 2. Sartarosh ma'lumotlari
                    barberInfoSection
                    
                    // 3. Statistikalar
                    statsSection
                    
                    // 4. Soch turmaklari galereyasi
                    gallerySection(title: "Soch Kesimlari Galereyasi", images: ["haircut1", "haircut2", "haircut3", "haircut4"])
                    
                    // 5. Sartaroshxona rasmlari galereyasi
                    gallerySection(title: "Sartaroshxona", images: ["shop1", "shop2", "shop3"])
                    
                    // 6. Manzil va ish vaqti
                    locationSection
                    
                    Spacer()
                }
            }
            
            // Pastki qismdagi "Book Now" tugmasi
            VStack {
                Spacer()
                bookNowButton
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isBookingSheetShowing) {
            // BookingView'ni modal oyna sifatida chaqiramiz
            BookingView()
        }
    }
}


// MARK: - View Components (Kod tozaligi uchun)
private extension HomeView {
    
    var topBar: some View {
        HStack {
            // Hamburger menyu tugmasi
            Button {
                withAnimation(.spring()) {
                    isSideMenuShowing.toggle()
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title)
                    .foregroundColor(.theme.primaryText)
            }
            
            Spacer()
            
            Text("ZAFAR Barber")
                .font(.headline.bold())
                .foregroundColor(.theme.primaryText)
            
            Spacer()
            
            // Notifikatsiya tugmasi
            Button {
                // Notifikatsiya ekrani ochiladi
            } label: {
                Image(systemName: "bell.badge.fill")
                    .font(.title2)
                    .foregroundColor(.theme.primaryText)
            }
        }
        .padding()
    }
    
    var barberInfoSection: some View {
        HStack(spacing: 16) {
            Image("barber-photo") // Assets'ga "barber-photo" nomli rasm qo'shing
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                // Ramka rangini to'q kulrang qilamiz
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nate Black")
                    .font(.title.bold())
                    .foregroundColor(.theme.primaryText)
                Text("Tashkent, Uzbekistan")
                    .font(.subheadline)
                    .foregroundColor(.theme.secondaryText)
            }
        }
        .padding(.horizontal)
    }
    
    var statsSection: some View {
        HStack {
            StatView(value: "4.6/5", label: "(123)", icon: "star.fill")
            Spacer()
            StatView(value: "92%", label: "Tavsiya", icon: "hand.thumbsup.fill")
            Spacer()
            StatView(value: "512", label: "Mijozlar", icon: "checkmark.seal.fill")
        }
        .padding()
        // Orqa fonni oq (yoki juda och kulrang) qilamiz
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    func gallerySection(title: String, images: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.theme.primaryText)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(images, id: \.self) { imageName in
                        Image(imageName) // Assets'ga rasm qo'shing
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 180)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Manzil & Ish Vaqti")
                .font(.title2.bold())
                .foregroundColor(.theme.primaryText)
            
            Text("Dushanba - Shanba: 9:00 - 19:00")
                .font(.subheadline)
                .foregroundColor(.theme.secondaryText)
            Text("Manzil: Toshkent sh., Olmazor tumani, 12-uy")
                .font(.subheadline)
                .foregroundColor(.theme.secondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    var bookNowButton: some View {
        Button {
            isBookingSheetShowing.toggle()
        } label: {
            Text("Book Now")
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.theme.accent)
                .cornerRadius(15)
                .shadow(color: Color.theme.accent.opacity(0.5), radius: 10, y: 5)
        }
        .padding(.horizontal, 40)
        .padding(.bottom)
    }
}


// MARK: - Yordamchi View'lar
struct StatView: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.theme.accent)
                Text(value)
                    .font(.headline.bold())
                    .foregroundColor(.theme.primaryText)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.theme.secondaryText)
        }
    }
}


// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(isSideMenuShowing: .constant(false))
            .environmentObject(ThemeViewModel())
    }
} 