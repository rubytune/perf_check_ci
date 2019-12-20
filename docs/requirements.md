# Perf Check CI Requirements

Perf Check CI is a web application to manage jobs that measure and compare performance on another web application.

## Creating a Job

* As a user, I want to compare relative performance of my branch against master (or the default reference branch deployed in production) on a production-like shaped database to make sure I'm not shipping code that will slow things down.
* As a user, I want to compare the performance of my branch against an arbitrary reference branch across request paths.
* As a user, I already ran a Job against a reference branch, made some code changes and now want to quickly get a rough idea how performance on my branch is trending.
* As a user, I know the request path I'm working on takes a long time (10-60 seconds), so I want a quick and dirty sanity check comparison against the reference branch so I can get back to work.
* As a user, I've ran several quick Jobs while I've improved performance on my branch and now care about getting accurate-as-possible final comparison against the reference branch.
* As a user, I want verify that my performance improvements on a branch did not change the response body of the branch.

## Reporting

* As a user, I want to know if the branch performance of each request path is better, about the same, or worse than the reference measurement.
* As a user, I want to know if the request path(s) on my branch still have problematic performance in an absolute way, such as too many database queries, are too long for an acceptable web request, or eats up too much memory.

## Social Proof

* As a user, I want to share the results from my Job with my teammates so I can be transparent, ask for help, and celebrate performance improvements.
* As a user, I want my GitHub PR to display an up-to-date concise summary of performance status that links to details of the latest Job for the branch.
* As a user, I'd like to share my results summary with someone in slack.

## Workflow & CI

* As a user, I want to easily start a job from a Github PR without many steps beyond knowing which request path(s) to test.
* As a user, I want to have a small set of request path(s) that can be tested against the reference branch on most (but not all) of my team's GitHub PRs.
* As a code reviewer, I saw that a Job on a GitHub PR I'm reviewing had poor results, asked the author to improve them, and want their iteration towards an improved result documented and easily accessible.

## Error Handling

* As a user, I want to know if the application stack is working right now, as I would like to run a successful Job and have historically run into various unclear problems with the service.
* As a user, I want to know when the error was the result of bugs/issues with the application stack that it has been communicated to the Perf Check developers.
* As a Perf Check developer, I want to know if all specific components of the application's deployment are functioning properly (db online, db last updated, queue status, target app bootable).
* As the product owner, I want to communicate clearly to a user when a Job failure or error results from common problems on their branch or incorrectly supplied Job settings, to encourage users to fix their own failed Jobs vs. reporting it as an application issue.
* As a user, I want to know if the target application did not boot on my branch, but did boot on the reference branch.
* As a user, I want to know if any request path 404'd or 500'd on the target app, see the error in a format I'm used to, and receive guidance on whether that was a result of my branch's changes or if the reference branch had the same problem.

## Measurements and statistics

* As a product owner, I want to present very limited and clear "headline" guidance to users so they attend to and optimize "big picture" performance instead of being distracted by Perf Check implementation details.
* As a Perf Check developer, I want to store all measurements from a Perf Check run so can process them later.
* As a Perf Check developer, I want to compute summary statistics over measurements so I can use them for reporting.
* As a user, I want to see a detailed breakdown of each request made, like I'm used to seeing in Perf Check CLI, so I pick out any anomalies and understand how stable a request path is.
* As a user, I want to understand how performance thresholds for better/worse are implemented and what is considered "normal" so I can trust and understand the application's interpretation of a Job's results.

## Additional Performance Guidance

* As a user, I might not know which data facet (e.g. company) has lots of a given type of data, and would like to explore the data shape to help inform a good request path to select.
* As a user, I might not know if the request path I chose for a job has a small, medium or large data shape, and would like to be presented with the data shape.
* As a user, I want to understand how performance on a request path in a Job compares  generally with other request paths tested on Perf Check or and for the specific request path in production (e.g. via an APM integration).
* As a product owner, I want to provide general guidance that results are relatively comparable with each other but not absolutely comparable to other environments, even ones with the same data shape (such as production).

## Deployment and Target App Integration

* As a product owner, I want a stable and sustainable way to automate server booting, request issuing and error handling that isn't necessarily coupled with the Perf Check CLI on localhost.
* As a Perf Check developer, I want to fire requests as any user of the target application.
