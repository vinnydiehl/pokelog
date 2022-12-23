# PokéLog

EV tracker for hardcore enthusaists. Under construction. Sparse developer
documentation incoming.

# Database

PokéLog uses PostgreSQL. Setup will vary depending on your environment but
there is plenty of documentation on getting it running anywhere. Once your
database server is running, you should be able to `bin/rake db:migrate` and run
the app.

# OAuth2

You will need to set up an OAuth2 Client ID in the Google API Console. PokéLog
uses the `google_sign_in` gem to handle logins; see
[their README](https://github.com/basecamp/google_sign_in#configuration) for
detailed instructions on setting up your development environment. Once you have
credentials created, add the lines to your `~/.bashrc`, pasting in the values
that the API Console gives you:

```bash
export GOOGLE_OAUTH2_ID='client id here'
export GOOGLE_OAUTH2_SECRET='client secret here'
```

# PokéAPI

The `poke-api-v2` gem
([GitHub](https://github.com/rdavid1099/poke-api-v2#poke-api-v2))
is included in the development dependencies as it is an incredibly useful tool
to use in the console for data management and debugging. See the [PokéAPI
website](https://pokeapi.co/) for more information on this amazing service.
