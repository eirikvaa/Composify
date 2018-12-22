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

    @IBOutlet private var containerView: UIView!

    // MARK: Properties

    private var pagingViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    private lazy var viewControllers = [OnboardingViewController]()

    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configurePageViewController()
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
    func configureUI() {
        view.bringSubviewToFront(nextButton)
        nextButton.addTarget(self, action: #selector(nextOnboardingPage), for: .touchUpInside)

        view.bringSubviewToFront(skipButton)
        skipButton.addTarget(self, action: #selector(skipOnboarding), for: .touchUpInside)
    }

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

    func configurePageViewController() {
        viewControllers = generateOnboardingViewControllers()

        pagingViewController.setViewControllers(
            [viewControllers[0]],
            direction: .forward,
            animated: true
        )

        pagingViewController.dataSource = self
        pagingViewController.delegate = self

        add(pagingViewController)
        containerView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
    }
}

extension OnboardingRootViewController: UIPageViewControllerDelegate {
    func updateNextButtonTitleIfNeeded() {
        // We're at the last onboarding page
        let fontSize = nextButton.titleLabel?.font.pointSize ?? UIFont.systemFontSize
        let transitionedToLastOnboardingPage = currentOnboardingPageIndex == viewControllers.count - 1

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
