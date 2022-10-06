//
//  ContentView.swift
//  Bogi String Game Helper
//
//  Created by Robert Wiebe on 12/2/21.
//

import SwiftUI

struct ContentView: View {
    @State private var solveFrom: Int = 1
    @State private var solveTo: Int = 2
    @State private var showingTutorial: Bool = false
    @State private var showingSolution: Bool = false
    @State private var solutionStep: Int = 0
    @State private var solutionSteps: [String] = []
    var body: some View {
        VStack {
            Text("BOGI string puzzle helper")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)
            HStack {
                Spacer()
                ForEach(1...6, id: \.self) { i in
                    arrowField(number: 7-i)
                    Spacer()
                }
            }
            HStack{
                VStack(alignment: .leading, spacing: 20){
                    VStack(alignment: .leading, spacing:10){
                        Text("Is this your first time\nusing this solver?")
                            .font(.system(size: 30, weight: .regular))
                        Button(action: {
                            self.showingTutorial = true
                        }, label: {Label("View Tutorial ", systemImage: "arrow.forward")
                                .padding(5)
                                .font(.title)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 4))
                                .foregroundColor(.white)
                        })
                            .sheet(isPresented: $showingTutorial) {
                                NavigationView{
                                    TabView{
                                        VStack(spacing: 50){
                                            Text("1 of 3: Notation")
                                                .font(.largeTitle)
                                            Text("Every 'chamber' is given a number with the outside being referred to as 1. With the solver, you can get the solution for moving the string between any two numbers. You can change the start and end points by tapping the numbers and selecting them in the menu.")
                                                .frame(width: 500)
                                                .multilineTextAlignment(.center)
                                            HStack(alignment: .bottom) {
                                                Text("Solve from ")
                                                    .font(.title)
                                                
                                                VStack {
                                                    Image(systemName: "arrow.down")
                                                    Text(String(solveFrom))
                                                }
                                                .font(.title)
                                                .foregroundColor(.red)
                                                Text(" to ")
                                                    .font(.title)
                                                VStack {
                                                    Image(systemName: "arrow.down")
                                                    Text(String(solveTo))
                                                }
                                                .font(.title)
                                                .foregroundColor(.red)
                                                Text(" !")
                                                    .font(.title)
                                            }
                                        }
                                        VStack(spacing: 50) {
                                            Text("2 of 3: Orientation")
                                                .font(.largeTitle)
                                            Text("To undestand the instructions properly, hold the puzzle so that chamber numbers are decreasing away from you on top, as shown in the picture")
                                                .frame(width: 500)
                                                .multilineTextAlignment(.center)
                                            Image("Direction View")
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .padding(.top, -80)
                                        }
                                        Text("Tutorial 3")
                                    }
                                    .tabViewStyle(.page(indexDisplayMode: .always))
                                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                                    .toolbar {
                                        ToolbarItem(placement: .primaryAction) {
                                            Button(action: {
                                                self.showingTutorial = false
                                            }) {
                                                Text("Done").fontWeight(.semibold)
                                            }
                                        }
                                    }
                                    
                                }
                            }
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing:5){
                        Text("Ready?")
                            .font(.title.bold())
                        HStack {
                            Text("Solve from ")
                                .font(.title)
                            Menu(content: {
                                Picker(selection: $solveFrom, label: Text("View")){
                                    ForEach(1...7, id: \.self){ i in
                                        if i != solveTo {
                                            Text(String(i))
                                        }
                                    }
                                }
                            },label: {
                                Text(String(solveFrom))
                                    .font(.title)
                            })
                            Text(" to ")
                                .font(.title)
                            Menu(content: {
                                Picker(selection: $solveTo, label: Text("View")){
                                    ForEach(1...7, id: \.self){ i in
                                        if i != solveFrom {
                                            Text(String(i))
                                        }
                                    }
                                }
                            },label: {
                                Text(String(solveTo))
                                    .font(.title)
                            })
                            Text(" !")
                                .font(.title)
                        }
                        Button(action: {
                                self.showingSolution = true
                            solutionSteps = computeMove(from: solveFrom, to: solveTo)
                        }, label: {
                            Text(" Compute solution ")
                                .padding(5)
                                .font(.title)
                                .foregroundColor(.blue)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 4).foregroundColor(.blue))
                                .padding(.top, 5)
                        })
                    }
                }
                Capsule()
                    .frame(width: 3)
                    .padding(.horizontal)
                ZStack {
                    Image("sideview")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Circle()
                                .frame(width:20, height:20)
                                .foregroundColor(.red)
                                .offset(x:100)
                                .rotationEffect(.degrees(Double(solveTo)*(-45)))
                                .animation(.easeInOut, value: solveTo)
                        )
                        .overlay(
                            Circle()
                                .frame(width:20, height:20)
                                .foregroundColor(.init(hue: 0, saturation: 0.4, brightness: 1))
                                .offset(x:100)
                                .rotationEffect(.degrees(Double(solveFrom)*(-45)))
                                .animation(.easeInOut, value: solveFrom)
                    )
                    ZStack {
                        if solutionSteps.count > 0 {
                            ForEach(((solutionStep > 0 ? solutionStep-1 : 0)...(solutionStep+2 < solutionSteps.count-1 ? solutionStep+2 : solutionSteps.count-1)).reversed(), id: \.self) { i in
                                SolutionCard(text: solutionSteps[i])
                                    .offset(x: i < solutionStep ? -350 : 0, y: i > solutionStep ? CGFloat((i-solutionStep)*20) : 0)
                                    .scaleEffect(i > solutionStep ? getScale(ilol: i, sStep: solutionStep) : 1)
                                    .animation(.easeInOut, value: solutionStep)
                            }
                        }
                    }
                    .mask(Rectangle().padding(-25))
                    .overlay(
                        HStack{
                            Label("Exit ", systemImage: "xmark")
                                .font(.system(size: 25, weight: .semibold))
                                .padding(6)
                                .background(
                                    Capsule().stroke(lineWidth: 4)
                                )
                                .foregroundColor(.red)
                                .onTapGesture {
                                    solutionStep = 0
                                    self.showingSolution = false
                                }
                            Spacer()
                            Label("Next ", systemImage: "arrow.forward")
                                .font(.system(size: 25, weight: .semibold))
                                .padding(6)
                                .background(
                                    Capsule().stroke(lineWidth: 4)
                                )
                                .onTapGesture {
                                    if solutionStep < solutionSteps.count - 1 {
                                        solutionStep += 1
                                    } else {
                                        solutionStep = 0
                                        self.showingSolution = false
                                    }
                                }
                        }.padding(20).shadow(radius: 10)
                    ,alignment: .bottom
                    )
                    .opacity(showingSolution ? 1 : 0)
                    .scaleEffect(showingSolution ? 1 : 0.8)
                    .animation(.easeInOut, value: showingSolution)
                }
            }
            .frame(height: 300)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(Color(white: 0.2))
            )
        }
    }
}

struct arrowField: View {
    @State var active: Bool = true
    @State var orientation: Bool = false
    var number: Int
    var body: some View {
        HStack {
            Text(String(number))
            Image(systemName: "arrow.up")
            .rotationEffect(orientation ? .degrees(180) : .degrees(0))
            .foregroundColor(active ? (orientation ? .blue : .yellow) : .gray)
        }
        .font(.system(size: 80, weight: .regular))
        .offset(y: active ? 0 : -25)
        .onTapGesture(count: 1) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.825, blendDuration: 0)) {
                self.orientation.toggle()
            }
        }
        .onLongPressGesture(perform: {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.825, blendDuration: 0)) {
                self.active.toggle()
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
.previewInterfaceOrientation(.landscapeLeft)
    }
}

struct SolutionCard: View {
    var text: String
    var body: some View {
        RoundedRectangle(cornerRadius: 40)
            .aspectRatio(1, contentMode: .fit)
            .foregroundColor(.init(white: 0.3))
            .shadow(radius: 10)
            .overlay(Text(text).font(.title2).padding())
    }
}

func move(over: Int, isDown: Bool, isInside: Bool) -> [String] {
    var temp: [String] = []
    if isDown {
        if isInside {
            if over == 1 {
                temp.append("Slide string down along 1 through 2")
            } else {
                temp.append("Slide string along \(over) until you reach \(over-1)")
                temp += move(over: over-1, isDown: true, isInside: false)
                temp += move(over: over-1, isDown: false, isInside: true)
                temp.append("Pull string through \(over+1)")
            }
        } else {
            if over == 1 {
                temp.append("Move string below 1 and pull it back until it reaches the ends of 2")
            } else {
                temp.append("Slide string along \(over) until you reach \(over-1)")
                temp += move(over: over-1, isDown: true, isInside: false)
                temp += move(over: over-1, isDown: false, isInside: true)
            }
        }
    } else {
        if isInside {
            if over == 1 {
                temp.append("Slide string up along 1, through 2, and all the way until the other side of 1")
            } else {
                temp.append("Slide string up along \(over), through \(over+1), until you reach \(over-1)")
                temp += move(over: over-1, isDown: true, isInside: true)
                temp += move(over: over-1, isDown: false, isInside: false)
            }
        } else {
            if over == 1 {
                temp.append("Move the string end out and above 1")
            } else {
                temp += move(over: over-1, isDown: true, isInside: true)
                temp += move(over: over-1, isDown: false, isInside: false)
            }
        }
    }
    return temp
}

func computeMove(from: Int, to: Int) -> [String]{
    var temp: [String] = []
    if to > from {
        for i in from...(to-1) {
            temp += move(over: i, isDown: false, isInside: true)
        }
    } else {
        for i in (from-1)...to {
            temp += move(over: i, isDown: true, isInside: true)
        }
    }
    return temp
}

func getScale(ilol: Int, sStep: Int) -> CGFloat {
    return CGFloat(truncating: NSDecimalNumber(decimal:pow(0.95, (ilol-sStep))))
}
