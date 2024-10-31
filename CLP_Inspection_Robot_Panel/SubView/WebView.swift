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
    @EnvironmentObject var station : Station
    @State var refreshView = false
    var cleanUI = false
    var body: some View {
        WebView(ip: "http://\(station.cam_ip):8088/")
            .id(refreshView)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing, content: {
                if !cleanUI{
                    Button(action:{
                        refreshView.toggle()
                            
                    }){
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            .padding()
                            .foregroundStyle(.yellow)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
    //                                .padding()
                    .padding()
                }
            })
            .clipShape(.rect(cornerRadius: 17))
            .padding()
            .background(RoundedRectangle(cornerRadius: 33).fill(.ultraThinMaterial).stroke(cleanUI ? .clear : .white))
            .padding()
            .onChange(of: station.status.camera_status, { oldValue, newValue in
                refreshView.toggle()
            })
            .overlay(content: {
                if !station.connected{
                    ProgressView("Please Wait")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.ultraThinMaterial)
                        )
                }
            })
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
