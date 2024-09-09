import SwiftUI
import CoreData


// 2. 구독 목록 화면 (CoreData 적용)
struct SubscriptionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionModel.name, ascending: true)],
        animation: .default)
    private var subscriptions: FetchedResults<SubscriptionModel>
    @State private var refreshID = UUID()
    @State private var selectedCategory = "전체"
    @State private var categories: [String] = ["전체"]
    
    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                CategorySortView(selectedCategory: $selectedCategory, categories: categories)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredSubscriptions) { subscription in
                            NavigationLink(destination: EditSubscriptionView(subscription: subscription, refreshID: $refreshID)) {
                                SubscriptionCard(subscription: subscription)
                            }
                        }
                        .onDelete(perform: deleteSubscription)
                    }
                    .padding()
                }
            }
            .id(refreshID)
        }
        .onAppear(perform: loadCategories)
    }

    private var filteredSubscriptions: [SubscriptionModel] {
        if selectedCategory == "전체" {
            return Array(subscriptions)
        } else {
            return subscriptions.filter { $0.wrappedCategory == selectedCategory }
        }
    }
    
    private func loadCategories() {
        var uniqueCategories = Set(subscriptions.map { $0.wrappedCategory })
        uniqueCategories.insert("전체")
        categories = Array(uniqueCategories).sorted()
    }

    private func deleteSubscription(at offsets: IndexSet) {
        offsets.map { subscriptions[$0] }.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// 카테고리 정렬 뷰
struct CategorySortView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Namespace private var animation
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(category: category, isSelected: selectedCategory == category, namespace: animation)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedCategory = category
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(AppColor.cardBackground)
        .cornerRadius(15)
        .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct CategoryButton: View {
    let category: String
    let isSelected: Bool
    let namespace: Namespace.ID
    
    var body: some View {
        Text(category)
            .fontWeight(isSelected ? .bold : .regular)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColor.primary)
                            .matchedGeometryEffect(id: "background", in: namespace)
                    }
                }
            )
            .foregroundColor(isSelected ? AppColor.cardBackground : AppColor.text)
    }
}

// 구독 카드 뷰 (CoreData 적용)
struct SubscriptionCard: View {
    let subscription: SubscriptionModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(subscription.wrappedColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(subscription.wrappedName.prefix(1).uppercased())
                        .font(.title2.bold())
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(subscription.wrappedName)
                    .font(.headline)
                    .foregroundColor(AppColor.text)
                Text(subscription.wrappedCategory)
                    .font(.subheadline)
                    .foregroundColor(AppColor.text.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(subscription.price)원")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.primary)
                Text(subscription.wrappedCycle)
                    .font(.caption)
                    .foregroundColor(AppColor.text.opacity(0.7))
            }
        }
        .padding()
        .background(AppColor.cardBackground)
        .cornerRadius(15)
        .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

#Preview {
    SubscriptionListView()
}
