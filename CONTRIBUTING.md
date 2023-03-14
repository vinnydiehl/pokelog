# Contributing to PokéLog

Thank you for considering contributing to PokéLog! We are always looking 
for new contributors to help us improve the project. Please give this
document a read before you get started, it will help you get dependencies set
up, and we can talk about best practices.

## Rails

PokéLog is a Ruby on Rails app. If you're just getting started with Rails,
welcome! They have
[excellent documentation](https://guides.rubyonrails.org/getting_started.html).
I would recommend playing around with a basic app as they describe to get the
hang of how Rails works. Once you get the feel for it, you can dive into some
of our dependencies:

### Preprocessors

PokéLog uses some software to pretty up the front-end code:

#### HAML

HAML formats HTML/ERB in a minimalist, indentation-driven syntax; see
[their docs](https://haml.info) for more info.

#### SCSS

[SCSS](https://sass-lang.com/guide) makes CSS about 30% less of a pain by allowing
nice things such as nesting, variables, mixins, and more.

### Database

PokéLog uses PostgreSQL. Setup will vary depending on your environment but
there is plenty of documentation on getting it running anywhere. Once your
database server is running and you have created the `pokelog_dev` database, you
should be able to `bin/rake db:migrate` and run the app.

### Google Sign In

In order to log into the app in development you will need to create an OAuth2
client ID in the
[Google Cloud API Console](https://console.developers.google.com/apis/credentials):

1. In the projects menu at the top of the page, create a new one and select it.
2. In the left-side navigation menu, choose APIs & Services → Credentials.
3. Click the button near the top labeled "Create Credentials". In the menu that appears,
   choose to create an OAuth client ID.
4. When prompted to select an application type, select "Web application".
5. Enter a name you would like to refer to the credential by, e.g. `pokelog-oauth2`.
6. Under "Authorized JavaScript origins", press the "Add URI" button and enter
   `http://localhost`.
7. Add another JavaScript Origin URI for `http://localhost:3000`.
8. Under "Authorized redirect URIs", add `http://localhost:3000/login/submit`.
9. Click the button labeled “Create.” You’ll be presented with a client ID and client
   secret. 
10. Add these lines to your `~/.bashrc`, pasting in the values that the API Console
    gives you:

    ```bash
    export GOOGLE_OAUTH2_ID='client id here'
    export GOOGLE_OAUTH2_SECRET='client secret here'
    ```

These environment variables will be loaded by the Rails server on boot up and
you should be able to use the Google Sign In button in development with your
own Google account. Make sure you `source ~/.bashrc` before running the server
if you are just getting this set up.

### Testing

Testing is absolutely critical for the continued maintenance of any software.
As PokéLog becomes increasingly complex it is important that we do not break
existing behavior while making bugfixes and improvements. As such, any time you
make a change that introduces a new behavior to (or removes an undesired
behavior from) the application, you should write a test to go along with it.
Make sure all tests are green before you open a pull request; that's why they're
there!

PokéLog uses RSpec and Capybara with the Selenium Chrome driver. You will need
the appropriate version of Chrome installed for the driver version you are
running; for the purposes of active development of this project, that will be
the latest version of Chrome.

You will need to create a PostgreSQL database named `pokelog_test`, then run
`bin/rake db:migrate RAILS_ENV=test` to set it up for the first time. The
database is automatically wiped in between each test, so each test is
essentially acting on a freshly installed version of the app.

The test suite bypasses Google sign in by patching the GSI gem
[here](/https://github.com/vinnydiehl/pokelog/blob/trunk/spec/support/gsi_patch.rb);
no internet connection or Google account is required to pass.

For more information, see the docs for [RSpec](https://rspec.info/documentation/)
and [Capybara](https://rubydoc.info/github/jnicklas/capybara#using-capybara-with-rspec).

### PokéAPI

The `poke-api-v2` gem
([GitHub](https://github.com/rdavid1099/poke-api-v2#poke-api-v2))
is included in the development dependencies as it is an incredibly useful tool
to use in the console for data management and debugging. See the [PokéAPI
website](https://pokeapi.co/) for more information on this amazing service.

## Best Practices

### Code Style

Readability and consistency above all else. The
[Ruby Style Guide](https://rubystyle.guide/) is a good start, but liberties may
be taken so long as the code makes sense. Try to keep lines under 80
characters, but this isn't always feasible. In views especially, 90-character
lines are okay.

I'm not a fan of having parens everywhere, but if there's ever a question about
what is nested in what, use them. Whether to use `foo bar(baz)` or `foo(bar baz)`
depends entirely on the context. `foo(bar(baz))` is generally frowned upon.

Use `"` for quotes universally. Only exceptions are when nesting gets weird and
it would increase readability, such as `"foo #{bar ? 'baz' : 'bat'}"`.

### Release Model

PokéLog uses a trunk-based release model. This means that work is done directly
on the `trunk` branch and this branch is frequently merged with the
`production` branch, the HEAD of which is live; the current live commit is
displayed on [the about page](https://www.pokelog.net/about).

With each release will be a version number and a tag, the version number in the
format of `major.minor.patch`. The patch is bumped for bugfixes, cosmetic changes,
and the like, the minor is bumped for new features and large changes to
functionality, and the major version is for large site overhauls. At some
point, when I feel that the website is sufficiently polished, it will bump to
major version 1.0. Each version will be accompanied by an entry in
[`CHANGELOG.md`](https://github.com/vinnydiehl/pokelog/blob/trunk/CHANGELOG.md).

Working directly on `trunk` is permitted. All commits/merges to `trunk` must have
passing tests, and new tests for any functionality changes introduced in the
commit. For work that will require multiple commits, start a branch.

When starting a new branch, create a new branch off of `trunk` with a name that
describes the feature you're working on, prepended with `feature/` or `bugfix/`,
like `feature/really-cool-thing`.

Make your changes on this branch, committing them as you go. Once you're 
finished, open a pull request to merge your feature branch into `trunk`.

Here's an example of how you might add a new feature to PokéLog:

1. Check out the `trunk` branch if you're not already on it: `git checkout trunk`
2. Create a new branch for your feature: `git checkout -b feature/really-cool-thing`
3. Make your changes, write tests, and commit them: `git commit -am "Add awesome feature"`
4. Make sure all tests pass: `bin/rspec`
4. Push your branch to GitHub: `git push origin feature/really-cool-thing`
5. Open a pull request to merge your feature branch into `trunk`

If your commits are neat and tidy, they'll be preserved; otherwise, they'll be
squashed before merge. Please write nice commit messages; the first line should
be limited to 50 characters and succinctly describe what the commit does in the
form of a command; "Add this" or "Fix that", rather than "Added this" or "Fixed
that". The commit body should be thought out and describe the reasoning for the
changes and any caveats or concerns surrounding your implementation.
