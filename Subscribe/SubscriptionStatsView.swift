import SwiftUI
import CoreData

// 4. 구독 통계 화면 (CoreData 적용)
struct SubscriptionStatsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionModel.name, ascending: true)],
        animation: .default)
    private var subscriptions: FetchedResults<SubscriptionModel>

    // NumberFormatter 인스턴스 생성
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }

    // 총 월간 지출
    var totalMonthly: Double {
        subscriptions.reduce(0) { $0 + Double($1.price) }
    }
    
    // 가장 비싼 구독
    var mostExpensiveSubscriptionPrice: Double {
        Double(subscriptions.max(by: { $0.price < $1.price })?.price ?? 0)
    }
    
    // 가장 저렴한 구독
    var leastExpensiveSubscriptionPrice: Double {
        Double(subscriptions.min(by: { $0.price < $1.price })?.price ?? 0)
    }
    
    // 평균 구독 비용 (정수로 표현)
    var averageSubscriptionCost: Int {
        if subscriptions.isEmpty {
            return 0
        } else {
            return Int(totalMonthly / Double(subscriptions.count))
        }
    }

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(AppColor.secondary)
                    
                    Circle()
                        .trim(from: 0.0, to: 0.75)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(AppColor.primary)
                        .rotationEffect(Angle(degrees: 270.0))
                    VStack {
                        Text("총 월간 지출")
                            .font(.headline)
                            .foregroundColor(AppColor.text)
                        Text("\(currencyFormatter.string(from: NSNumber(value: totalMonthly)) ?? "0")원")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColor.primary)
                    }
                }
                .frame(height: 250)
                .padding()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatCard(title: "총 구독 수", value: "\(subscriptions.count)")
                    
                    StatCard(title: "가장 비싼 구독", value: "\(currencyFormatter.string(from: NSNumber(value: mostExpensiveSubscriptionPrice)) ?? "0")원")
                    
                    StatCard(title: "가장 저렴한 구독", value: "\(currencyFormatter.string(from: NSNumber(value: leastExpensiveSubscriptionPrice)) ?? "0")원")
                    
                    StatCard(title: "평균 구독 비용", value: "\(currencyFormatter.string(from: NSNumber(value: averageSubscriptionCost)) ?? "0")원")
                }
                .padding()
            }
        }
    }
}
