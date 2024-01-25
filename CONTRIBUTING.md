Contributing to the Daily Dozen for iOS
=======================================

We would love for you to contribute to our source code and to help make the Daily Dozen for iOS even better!  Here are the guidelines we would like you to follow:

 - [Code of Conduct](#coc)
 - [Question or Problem?](#question)
 - [Issues and Bugs](#issue)
 - [Feature Requests](#feature)
 - [Submission Guidelines](#submit)
 - [Commit Message Guidelines](#commit)

<a name="coc"></a> Code of Conduct
----------------------------------

Help us to keep the [Daily Dozen for iOS][daily-dozen-ios] open and inclusive.  Please read and follow our [Code of Conduct][coc]

<a name="question"></a> Have a Question or Problem?
---------------------------------------------------

If you have a question or issue with how to use the [Daily Dozen for iOS][daily-dozen-ios] app or for other support-related questions, please contact us by visiting the [NutritionFacts.org Help Desk on Zendesk][zendesk].

<a name="issue"></a> Found an Issue?
------------------------------------

If you find a bug in the source code, a mistake in the documentation, you can help by submitting it in [the issues][issues].

**Please Note:** This repository is *only* for issues within the [Daily Dozen iOS][daily-dozen-ios] source code. Issues in other app components or the [Daily Dozen Android][daily-dozen-android] version should be reported in their respective repositories. Issues related to the Daily Dozen language translations would be submitted to the [daily-dozen-localization repository](https://github.com/nutritionfactsorg/daily-dozen-localization).

**Please see our [Submission Guidelines](#submit) below for more information**

<a name="feature"></a> Want a Feature?
--------------------------------------

You can request a new feature by submitting [an issue][issue] with a description of the proposed feature.

Changes that you wish to contribute to the project should be proposed and discussed first via the issue so we can better coordinate our efforts, prevent duplication of work, and help you to craft the change so that it is successfully accepted into the project.  This is especially useful when dealing with large UI changes within the application that may require approval of mockups and screen workflows to stay consistent within our brand.

<a name="submit"></a> Submission Guidelines
-------------------------------------------

### Submitting an Issue

Before you submit your issue, please search the repository.  Your issue may have already been addressed.

If your issue appears to be a bug, and it hasn't been reported, open a [new Issue Ticket][issue]. Please help us to optimize the effort we can spend fixing issues and adding new features by not reporting duplicate issues.

When submitting an issue, providing the following information will increase the chances of your request being dealt with quickly:

* **Overview of the Issue** - if an error is being thrown, a stack trace or log helps (if available)
* **Motivation for or Use Case** - explain why this is a bug for you and what was expected
* **iOS Version(s)** - current iOS version
* **Device Model** - is it a problem with all devices or only a specific model?
* **Stock or Customized System** - provide details on system customization, if customized
* **Daily Dozen App Version:** - current app version
* **Steps to Reproduce the Issue** - provide an unambiguous set of steps with screenshots (if possible)
* **Related Issues** - has a similar issue been reported before?
* **Suggest a Fix** - perhaps you can point to what might be causing the problem (line of code or commit)

### Submitting a Pull Request

Before you create and submit a Pull Request, please create an [Issue Ticket][issue] which describes the envisioned contribution. An Issue Ticket will allow for discussion of how a fix or enhancement aligns with project history, impact, and roadmap. This step should also clarify approach, timeline, and naturally lead to a go/no-go/defer action plan from a core team member.

If an Issue Ticket proceeds to a "go" plan, then you will be pointed to which branch to use at that time.

**Getting Up To Speed**

We want to foster a community of participation and learning, especially for people interested in committing to FOSS projects. Kent C. Dodds provides a great set of tutorials covering [How to Contribute to an Open Source Project on GitHub][contribute-os] geared toward submitting your first Pull Request.  Check it out and start contributing!  

**Before you submit your Pull Request consider the following guidelines:**

* Search any open and closed [Issue Ticket][issue] related to what you would like to contribute. Someone may already be preparing to create a pull reqest.

* Search for an open or closed [Pull Request][pr] that relates to your submission.  You don't want to duplicate effort.

* Please submit all pull requests to the [nutritionfactsorg/daily-dozen-ios][daily-dozen-ios] repository in the branch designated by a core team member for the related Issue Ticket.

If you don't have a feature in mind, but would like to contribute back to the project, check out the [open issues][issues] and see if there are any you can tackle. 

The outreach [labels](https://github.com/nutritionfactsorg/daily-dozen-ios/issues/labels) ("beginner, "good first issue" and "help wanted") indicate which issues are looking for community participation to do the related Pull Request.

| | |
|--------|---------------------|
| ![][lbl-beginner]    | Indicates an issue which is easier or less complicated to resolve. |
| ![][lbl-good-first]  | Indicates a good issue for new contributors. |
| ![][lbl-help-wanted] | Indicates that a maintainer wants help on an issue or pull request. |

<a name="commit"></a> Git Commit Guidelines
-------------------------------------------

### Commit Message Format

#### Single Line Commit

Not every commit requires a subject, body, and footer. Sometimes a single line is fine, especially when the change is so simple that no further context is necessary. For example:

```
Fix typo in README.md
```

#### Subject and Body Commit

When a commit merits a bit of explanation and context, you need to write a **body** in addition to the **subject**, separated by a ```<BLANK LINE>```:

```
<subject>
<BLANK LINE>
<body>
```

#### Full-size Commit (Subject, Body, and Footer)

When a commit **closes an issue**, this should be referenced in the **footer**.

A full commit with a **subject**, a **body** and a **footer** should also have each part separated by a ```<BLANK LINE>```:

```
<subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

### Subject

* **Limit the Subject Line to 50 Characters** - Keeping subject lines at this length ensures that they are readable, and forces you to think for a moment about the most concise way to explain what's going on.  If you're having a hard time summarizing, you might be committing too many changes at once.

* **Capitalize the Subject Line**

* **Do Not End the Subject Line with a Period** - Trailing punctuation is unnecessary in subject lines. Space is precious when you're trying to keep them to 50 characters or less.

* **Use the Imperative Mood in the Subject Line** - Imperative mood means "spoken or written as if giving a command or instruction." When you write your commit messages in the imperative, you're following git's own built-in conventions. For example:

	* Update getting started documentation
	* Release version 1.0.0

	A properly formed git commit subject line should always be able to complete the following sentence:
	
	If applied, this commit will *your subject line here*
	
	For example:
	
	* If applied, this commit will *update getting started documentation*
	* If applied, this commit will *release version 1.0.0*

	**Referencing a Revert in the Subject**
	
	If the commit reverts a previous commit, it should begin with `Revert: `, followed by the header of the reverted commit. In 	the body it should say: `This reverts commit <hash>.`, where the hash is the SHA of the commit being reverted.

### Body

**Wrap the Body at 72 Characters**

**Use the Body to Explain What and Why** - Leave out details about *how* a change has been made. Code is generally self-explanatory in this regard and can be viewed in the diff. Focus on the reasons you made the change in the first place, the way things worked before the change (and what was wrong with that), the way they work now, and why you decided to solve it the way you did.

### Footer
The footer should reference GitHub issues that this commit **Closes**.

[daily-dozen-android]: https://github.com/nutritionfactsorg/daily-dozen-android "Daily Dozen for Android"
[daily-dozen-ios]: https://github.com/nutritionfactsorg/daily-dozen-ios "Daily Dozen for iOS"
[nutritionfacts.org]: http://nutritionfacts.org "NutritionFacts.org - The Latest in Nutrition Research"
[coc]: https://github.com/nutritionfactsorg/daily-dozen-ios/blob/master/CODE_OF_CONDUCT.md "Code of Conduct"
[zendesk]: http://nutritionfacts.zendesk.com "NutritionFacts.org Help Desk"
[slack-dev]: https://nutritionfacts.slack.com/messages/development/ "#Development on Slack"
[issues]: https://github.com/nutritionfactsorg/daily-dozen-ios/issues "Daily Dozen for iOS Issues"
[issue]: https://github.com/nutritionfactsorg/daily-dozen-ios/issues/new "Create an Issue"
[pr]: https://github.com/nutritionfactsorg/daily-dozen-ios/pulls "Pull Requests"
[contribute-os]: https://egghead.io/courses/how-to-contribute-to-an-open-source-project-on-github "How to Contribute to an Open Source Project on GitHub"
[cremail]: mailto:christi@nutritionfacts.org?subject=Slack%20#Development%20Invitation


<!-- LABELS -->

[lbl-beginner]:CONTRIBUTING_files/lbl-beginner.svg
[src-beginner]:https://labl.es/svg?text=beginner&bgcolor=128a0c

[lbl-good-first]:CONTRIBUTING_files/lbl-good-first.svg
[src-good-first]:https://labl.es/svg?text=good%20first%20issue&bgcolor=128a0c

[lbl-help-wanted]:CONTRIBUTING_files/lbl-help-wanted.svg
[src-help-wanted]:https://labl.es/svg?text=help%20wanted&bgcolor=128a0c