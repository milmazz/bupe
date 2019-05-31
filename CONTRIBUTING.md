# CONTRIBUTING

First off, thank you for considering contributing to this project.

All members of our community must follow our [Code of Conduct][code-of-conduct].
Please make sure you are welcoming and friendly in all of our spaces. Please
report any unacceptable behavior to [me@milmazz.uno](mailto:me@milmazz.uno).

You can contribute to this project doing the following:

* Writing tutorials or blog posts
* Improving the documentation
* Helping us tackle existing issues
* [Submitting bug reports][new-issue]

The list of GitHub issues may give you some ideas on how to contribute, please
keep every Pull Request as focused as possible, do not try to cover too much
stuff in one Pull Request.

For proposing new features, please start a discussion first, remember that it
is your job to explain why a feature is useful for us and how this change will
impact the codebase. Be nice!

Below are the guidelines for working on Pull Requests:

## Workflow

1. [Fork it!](https://github.com/milmazz/bupe)
2. Clone your fork: `git clone https://github.com/<username>/bupe`
3. Create your feature branch: `git checkout -b new-feature`
4. Commit your changes: `git commit -am 'New cool feature'`
5. Push your branch: `git push origin new-feature`
6. [Create new Pull Request][send-pull-request]

## Documentation

* Should be easy to read
* Keep the first paragraph of the documentation as succinct as possible, usually one line.
* No spelling mistakes
* No orthographic mistakes
* No Markdown syntax errors
* Try to follow Elixir's [Writing Documentation][writing-documentation] guidelines
* Verify the documentation results after processing with [ExDoc][]

## New features or bug fixes

* Please follow the [Elixir Style Guide][elixir-style-guide]
* The codebase is not perfect at this moment, but we expect that you do not introduce new code style violations.
* Unit tests must pass
* Please verify your changes. It is highly recommended to include new tests to the test suite with every new feature or fix that you introduce.

[new-issue]: https://github.com/milmazz/bupe/issues/
[send-pull-request]: https://help.github.com/articles/about-pull-requests/
[elixir-style-guide]: https://github.com/lexmag/elixir-style-guide/
[ExDoc]: https://github.com/elixir-lang/ex_doc/
[writing-documentation]: https://hexdocs.pm/elixir/writing-documentation.html#content
[code-of-conduct]: https://github.com/milmazz/bupe/blob/master/CODE_OF_CONDUCT.md
