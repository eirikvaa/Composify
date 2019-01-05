//
//  OnboardingRootViewController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import UIKit

class OnboardingRootViewController: UIViewController {
    // MARK: @IBOutlets

    @IBOutlet private var skipButton: UIButton! {
        didSet {
            skipButton.setTitle(R.Loc.onboardingSkipButtonTitle, for: .normal)
            skipButton.tintColor = .white
        }
    }

    @IBOutlet private var nextButton: UIButton! {
        didSet {
            nextButton.setTitle(R.Loc.onboardingNextButtonTitleNext, for: .normal)
            nextButton.tintColor = .white
        }
    }

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet private var containerView: UIView! {
        didSet {
            containerView.backgroundColor = R.Colors.cardinalRed
        }
    }

    // MARK: Properties

    private var pagingViewController: UIPageViewController {
        let pagingViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        return pagingViewController
    }

    private lazy var viewControllers = [OnboardingViewController]()

    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configurePageViewController()
        applyAccessibility()
    }

    // As the onboarding is (as of 16th of December) red, we should
    // have a white status bar.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: @IBActions

extension OnboardingRootViewController {
    var currentOnboardingPageIndex: Int {
        guard let currentViewController = pagingViewController.viewControllers?.first as? OnboardingViewController else { return 0 }
        return currentViewController.pageIndex
    }

    @objc func nextOnboardingPage(_: UIButton) {
        guard let currentViewController = pagingViewController.viewControllers?.first as? OnboardingViewController else { return }
        guard currentViewController.pageIndex + 1 < viewControllers.count else {
            dismiss(animated: true) {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: R.UserDefaults.hasSeenOnboarding)
            }
            return
        }
        let nextViewController = viewControllers[currentViewController.pageIndex + 1]

        pagingViewController.setViewControllers(
            [nextViewController],
            direction: .forward,
            animated: true
        )

        updateNextButtonTitleIfNeeded()
    }

    @objc func skipOnboarding(_: UIButton) {
        guard let lastViewController = viewControllers.last else { return }

        pagingViewController.setViewControllers(
            [lastViewController],
            direction: .forward,
            animated: true
        )

        updateNextButtonTitleIfNeeded()
    }
}

private extension OnboardingRootViewController {
    /// Configure the page control
    /// - parameter count: The number of dots corresponding to the number of pages
    func configurePageControl(count: Int) {
        pageControl.currentPage = 0
        pageControl.numberOfPages = count
    }

    /// Configure the user interface
    func configureUI() {
        view.bringSubviewToFront(nextButton)
        nextButton.addTarget(self, action: #selector(nextOnboardingPage), for: .touchUpInside)

        view.bringSubviewToFront(skipButton)
        skipButton.addTarget(self, action: #selector(skipOnboarding), for: .touchUpInside)

        // Color everything the same color as the images that are used
        // because we have to color above and below the safe area layout guides.
        view.backgroundColor = R.Colors.cardinalRed
    }

    /// Generate the view controllers used for pages in the onboarding
    /// - returns: An array of view controllers for the onboarding
    func generateOnboardingViewControllers() -> [OnboardingViewController] {
        var backgroundImages = [
            R.Images.onboarding1,
            R.Images.onboarding2,
            R.Images.onboarding3,
            R.Images.onboarding4,
        ]

        for i in 0 ... 3 {
            let viewController = UIViewController.onboardingPageViewController()
            viewController.backgroundImage = backgroundImages[i]
            viewController.pageIndex = i
            viewControllers.append(viewController)
        }

        return viewControllers
    }

    /// Configure the page view controller
    func configurePageViewController() {
        viewControllers = generateOnboardingViewControllers()

        configurePageControl(count: viewControllers.count)

        pagingViewController.setViewControllers(
            [viewControllers[0]],
            direction: .forward,
            animated: true
        )

        add(pagingViewController)
        pagingViewController.view.pinToEdges(of: containerView)
    }
}

extension OnboardingRootViewController: UIPageViewControllerDelegate {
    /// Update the next button title if needed
    /// It will be updated at the last page as it then will dismiss the onboarding
    func updateNextButtonTitleIfNeeded() {
        // We're at the last onboarding page
        let fontSize = nextButton.titleLabel?.font.pointSize ?? UIFont.systemFontSize
        let transitionedToLastOnboardingPage = currentOnboardingPageIndex == viewControllers.count - 1
        pageControl.currentPage = currentOnboardingPageIndex

        UIView.transition(
            with: nextButton,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                if transitionedToLastOnboardingPage {
                    self.nextButton.setTitle(R.Loc.onboardingNextButtonTitleDismiss, for: .normal)
                    self.nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
                } else {
                    self.nextButton.setTitle(R.Loc.onboardingNextButtonTitleNext, for: .normal)
                    self.nextButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                }
            }
        )
    }

    func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
        // Make sure we actually finished the transition
        guard completed else { return }

        updateNextButtonTitleIfNeeded()
    }
}

extension OnboardingRootViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let boardingVieController = viewController as? OnboardingViewController else { return nil }

        let index = boardingVieController.pageIndex

        guard index - 1 >= 0 else { return nil }

        return viewControllers[index - 1]
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let boardingVieController = viewController as? OnboardingViewController else { return nil }

        let index = boardingVieController.pageIndex

        guard index + 1 < viewControllers.count else { return nil }

        return viewControllers[index + 1]
    }
}

extension OnboardingRootViewController {
    func applyAccessibility() {
        skipButton.isAccessibilityElement = true
        skipButton.accessibilityTraits = .button
        skipButton.accessibilityValue = skipButton.titleLabel?.text
        skipButton.accessibilityLabel = R.Loc.onboardingSkipButtonAccLabel
        skipButton.accessibilityHint = R.Loc.onboardingSkipButtonAccHint

        nextButton.isAccessibilityElement = true
        nextButton.accessibilityTraits = .button
        nextButton.accessibilityValue = nextButton.titleLabel?.text
        nextButton.accessibilityHint = R.Loc.onboardingNextButtonAccHint
        nextButton.accessibilityLabel = R.Loc.onboardingNextButtonAccLabel
    }
}
