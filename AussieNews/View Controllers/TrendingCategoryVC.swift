//
//  TrendingCategoryVCViewController.swift
//  AussieNews
//
//  Created by Alexander Thompson on 23/3/2022.
//

import UIKit

class TrendingCategoryVC: UIViewController {
    
    //MARK: - Variables & Constants
    
    
    // TODO: make articles random order. 
    
    let progressStack       = UIStackView()
    let trendingView        = TrendingView()
    let trendingButtonView  = TrendingButtonView()
    var newsArticles: [Article] = []
    var topic: String = ""
    var progressStatus: Int = -1
    var timer               = Timer()
    var progressViewArray: [UIProgressView] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getArticles(params: .topic)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureProgressStack()
        layoutUI()
        setupGestures()
        configureTrendingButtons()
    }
    
    //create in customvc
    func getArticles(params: NewsManager.networkParams) {
        NewsManager.Shared.topic = topic
        NewsManager.Shared.getNews(params:params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let newsArticles):
                DispatchQueue.main.async {
                    self.newsArticles.append(contentsOf: newsArticles.articles)
                    self.trendingView.set(self.newsArticles[0])
                    self.animateProgressViews(startingNum: 0)
                }
                
            case.failure(let error): print(error.rawValue)
            }
        }
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
    }
   
    
    private func configureProgressStack() {
        for _ in 0...4 {
            let progressView = UIProgressView(progressViewStyle: .bar)
            progressView.translatesAutoresizingMaskIntoConstraints = false
            progressView.backgroundColor   = .systemGray3
            progressView.progressTintColor = .orange
            progressView.layer.cornerRadius = 5
            progressView.layer.masksToBounds = true
            progressViewArray.append(progressView)
        }
        
        progressStack.translatesAutoresizingMaskIntoConstraints = false
        for view in progressViewArray {
            progressStack.addArrangedSubview(view)
        }
        progressStack.alignment = .fill
        progressStack.spacing = 10
        progressStack.distribution = .fillEqually
        progressStack.axis = .horizontal
        
    }
    
    func configureTrendingButtons() {
        trendingButtonView.shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
    }
    
    
    @objc func shareButtonPressed() {
        
        // TODO: remove share and save. just have open
        let article = newsArticles[progressStatus + 1]
        
        if let urlString = NSURL(string: (article.link)!) {
            let activityItems = [urlString]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.isModalInPresentation = true
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    private func layoutUI() {
       
        view.addSubviews(progressStack, trendingView, trendingButtonView)
       
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            progressStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            progressStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            progressStack.heightAnchor.constraint(equalToConstant: 7),
            
            trendingView.topAnchor.constraint(equalTo: progressStack.bottomAnchor, constant: padding),
            trendingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            trendingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            trendingView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            trendingButtonView.topAnchor.constraint(equalTo: trendingView.bottomAnchor, constant: 5),
            trendingButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            trendingButtonView.widthAnchor.constraint(equalTo: trendingView.widthAnchor),
            trendingButtonView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(gesturePressed))
        trendingView.addGestureRecognizer(tap)
        trendingView.isUserInteractionEnabled = true
    }
    
    
    private func setupButtons() {
        
        
    }
    
    
    func animate(num: Int, duration: Double) {

        UIView.animate(withDuration: duration, delay: 0) {
            let progress: Float = 1.0
            self.progressViewArray[num].setProgress(progress, animated: true)
        } completion: { _ in
            let article = self.newsArticles[num]
            self.trendingView.set(article)
        }

    }
    
    func progressReset() {
        
        for (index, view) in progressViewArray.enumerated() {
            if index < progressStatus {
                view.setProgress(1.0, animated: false)
            } else {
              view.progress = 0.0
        }
        }
    }
    
    func animateProgressViews(startingNum: Int) {
        
        var num = startingNum
        let duration = 3.0
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { timer in
            self.animate(num: num, duration: duration)
            num += 1
            self.progressStatus += 1
            print(self.progressStatus)
            if num == 5 {
                timer.invalidate()
            }
        }
    }
    
  
    
    @objc func gesturePressed(_ tap: UITapGestureRecognizer) {
        timer.invalidate()
        let point = tap.location(in: trendingView)
        let leftArea = CGRect(x: 0, y: 0, width: trendingView.frame.width / 2, height: trendingView.frame.height)
        if leftArea.contains(point) {
            if progressStatus >= 1 {
           progressStatus -= 1
            }
        } else {
            if progressStatus <= 3 {
            progressStatus += 1
            }
        }
        progressReset()
        let article = self.newsArticles[progressStatus]
        self.trendingView.set(article)
        animateProgressViews(startingNum: progressStatus)
    }
    
}
