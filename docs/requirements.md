# Perf Check CI Requirements

Perf Check CI is a web application to manage jobs that measure and compare performance on another web application.

## Creating a job

* As a user, I want to compare relative performance of my branch against master to make sure I'm not shipping code that will slow things down.
* As a user, I want to have a quick idea how performance on my branch looks, without caring about comparisons against master.
* As a user, I want to create a job to compare the performance of two branches across multiple request paths.
* As a user, I know the request I'm working on takes a long time (10-60 seconds), so just want a very rough comparison that takes a smaller amount of time to complete so I can get back to work.
* As a user, I care about getting a final and accurate-as-possible comparison across two branches.
* As a user, I want verify that my performance improvements on a branch did not change the response body of the branch.

## Reporting

* As a user, I want to know if the branch performance of each URL is better, about the same, or worse than the reference measurement.
* As a user, I want to understand how the branch performance thresholds for better/worse are calculated and be able to verify and double check the calculation.
* As a user, I want to know if URL(s) on my branch still have problematic performance in an absolute way, such as too many database queries, are too long for an acceptable web request, or eats up too much memory.

## Workflow & CI

* As a user, I want to easily start a job from a Github PR without many steps beyond knowing which URL(s) to test.
* As a user, I want to have a small set of URLs that can be tested against master on most (but not all) of my team's PRs.
* As a code reviewer, I want to see iterative history that performance was later improved on a PR that initially had poor performance.

## Social Proof

* As a user, I want my GitHub PR to display an up-to-date concise summary of performance status that links to details of the latest Perf Check job for the branch.
* As a user, I'd like to share my results summary with someone in slack.

## Error Handling

* As a user, I want to know if everything on Perf Check CI is actually working right now.
* As a Perf Check developer, I want to know if all specific components of the Perf Check CI system are functioning properly (db online, db last updated, queue status, target app bootable).
* As the product owner, I want to communicate clearly to a user when a job failure or error was the result of problems with their branch or user supplied Job settings.
* As a user, I want to know if the target application did not boot on my branch, but did boot on master.
* As a user, I want to know if the URL 404'd or 500'd on the target app, see the error in a format I'm used to, and receive guidance on whether that was a result of my branch's changes or if master had the same problem.
* As a user, I'd like to know when the error was the result of bugs/issues with the Perf Check CI stack that it's communicated to the Perf Check developers.

## Measurements and statistics

* As a product owner, I want to present very limited and clear "headline" guidance to users so they attend to and optimize "big picture" performance instead of being distracted by Perf Check implementation details.
* As a Perf Check developer, I want to store all measurements from a Perf Check run so can process them later.
* As a Perf Check developer, I want to compute summary statistics over measurements so I can use them for reporting.
* As a user, I want to see a detailed breakdown of each request made.
* As a user, I want to know variance of a group of requests and know how "normal" that variance is, so I feel comfortable trusting the summarized results and knowing whether the request profile is changed or unchanged.
* As a user, I want to gain intuition about request performance variance via a visual representation of where the reference and branch requests fall on a shared timeline.

## Additional Performance Guidance

* As a user, I might not know which data facet (e.g. company) has lots of a given type of data, and would like to explore the data shape to help inform a good URL to choose.
* As a user, I might not know if the URL I chose for a job has a small, medium or large data shape, and would like to be presented with the data shape.
* As a user, I want to understand how relative performance on a Job compares with real-world production performance either generally on Perf Check or specifically for an URL (e.g. via an APM integration).
* As a product owner, I want to provide general guidance that results are relatively comparable with each other but not absolutely comparable to other environments, even ones with the same data shape such as production.

## Deployment and Target App Integration

* As a product owner, I want a stable and sustainable way to automate server booting, request issuing and error handling that isn't necessarily coupled with the Perf Check CLI on localhost.
* As a Perf Check developer, I want to fire requests as any user of the target application.
