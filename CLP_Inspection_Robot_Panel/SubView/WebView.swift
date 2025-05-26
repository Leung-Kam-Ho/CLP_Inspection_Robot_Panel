//
//  WebView.swift
//  CLP_Inspection_Robot_Panel
//
//  Created by Kam Ho Leung on 20/9/2024.
//

import SwiftUI
import WebKit
import os
import SwiftUI



struct Camera_WebView : View {
    @EnvironmentObject var settings : SettingsHandler
    @State var refreshView = false
    var cleanUI = false
    var body: some View {
        WebView(ip: "http://\(settings.cam_ip)")
            .disabled(true)
            .id(refreshView)
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing, content: {
                if !cleanUI{
                    VStack{
                        Section{
                            Button(action:{
                                refreshView.toggle()
                                    
                            }){
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                    .padding()
                                    .foregroundStyle(.yellow)
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                        }
                        .buttonStyle(.plain)
                        .padding()
                    }
                }
            })
            .clipShape(.rect(cornerRadius: 33))
            .padding()
            .background(RoundedRectangle(cornerRadius: 49).fill(.ultraThinMaterial).stroke(cleanUI ? .clear : .white))
            .padding()
//            .onChange(of: station.status.camera_status, { oldValue, newValue in
//                refreshView.toggle()
//            })
    }
}

struct WebView: UIViewRepresentable {
    let ip : String
    let webView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Constants.notBlack)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        loadURL()
    }
    
    func loadURL(){
        webView.load(URLRequest(url: URL(string: ip)!))
    }
    
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
    }
        
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("WebView started loading")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed with error: \(error)")
            self.parent.loadURL()
        }
    }
    
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        Camera_WebView()
            .environmentObject(Station())
    }
}
