import SwiftUI
import CoreData

struct SubscriptionStatsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionModel.name, ascending: true)],
        animation: .default)
    private var subscriptions: FetchedResults<SubscriptionModel>
    @State private var currentTab = 0

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }

    // 총 월간 지출
    var totalMonthly: Int {
        Int(subscriptions.reduce(0) { total, subscription in
            switch subscription.cycle {
            case "월별":
                return total + Double(subscription.price)
            case "분기별":
                return total + Double(subscription.price) / 3
            case "연별":
                return total + Double(subscription.price) / 12
            default:
                return total
            }
        }.rounded())
    }

    // 총 분기별 지출
    var totalQuarterly: Int {
        Int(subscriptions.reduce(0) { total, subscription in
            switch subscription.cycle {
            case "월별":
                return total + Double(subscription.price) * 3
            case "분기별":
                return total + Double(subscription.price)
            case "연별":
                return total + Double(subscription.price) / 4
            default:
                return total
            }
        }.rounded())
    }

    // 총 연별 지출
    var totalYearly: Int {
        Int(subscriptions.reduce(0) { total, subscription in
            switch subscription.cycle {
            case "월별":
                return total + Double(subscription.price) * 12
            case "분기별":
                return total + Double(subscription.price) * 4
            case "연별":
                return total + Double(subscription.price)
            default:
                return total
            }
        }.rounded())
    }

    var body: some View {
        ZStack {
            AppColor.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                TabView(selection: $currentTab) {
                    statsCircle(title: "총 월간 지출", value: totalMonthly).tag(0)
                    statsCircle(title: "총 분기별 지출", value: totalQuarterly).tag(1)
                    statsCircle(title: "총 연별 지출", value: totalYearly).tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 300)
                .overlay(
                    HStack {
                        if currentTab > 0 {
                            Text("<")
                                .font(.title)
                                .foregroundColor(AppColor.primary)
                                .padding()
                                .onTapGesture {
                                    withAnimation {
                                        currentTab -= 1
                                    }
                                }
                        }
                        Spacer()
                        if currentTab < 2 {
                            Text(">")
                                .font(.title)
                                .foregroundColor(AppColor.primary)
                                .padding()
                                .onTapGesture {
                                    withAnimation {
                                        currentTab += 1
                                    }
                                }
                        }
                    }
                )
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatCard(title: "총 구독 수", value: "\(subscriptions.count)")
                    StatCard(title: "가장 비싼 구독", value: "\(currencyFormatter.string(from: NSNumber(value: Int(subscriptions.max(by: { $0.price < $1.price })?.price ?? 0))) ?? "0")원")
                    StatCard(title: "가장 저렴한 구독", value: "\(currencyFormatter.string(from: NSNumber(value: Int(subscriptions.min(by: { $0.price < $1.price })?.price ?? 0))) ?? "0")원")
                    StatCard(title: "평균 구독 비용", value: "\(currencyFormatter.string(from: NSNumber(value: subscriptions.isEmpty ? 0 : totalMonthly / subscriptions.count)) ?? "0")원")
                }
                .padding()
            }
        }
    }

    private func statsCircle(title: String, value: Int) -> some View {
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
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColor.text)
                Text("\(currencyFormatter.string(from: NSNumber(value: value)) ?? "0")원")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColor.primary)
            }
        }
        .frame(height: 250)
        .padding()
    }
}

#Preview {
    SubscriptionStatsView()
}
