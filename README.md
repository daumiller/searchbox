# Safari 13 workaround...

__I used to use this great extension, OmniKey, that lets you search different engines by keyword.
But:__
- Safari 13 disables useful extesions, for mostly useless app extensions
- Safari 13 (or earlier?) also disables customizing the search engine

__So we'll:__
- create a simple redirection server in ruby
- hijack the search.yahoo.com domain locally, because who needs that anyway?
- add a simple search-reload method to live-reload the config json
    - _this should be made into a nice web UI for editing in browser; i'm too lazy for that ATM though_

_NOTE_: Requires a newer-than-system ruby version


_License: BSD 2-Clause_
