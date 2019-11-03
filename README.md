Safari 13 workaround...

I used to use this great extension, OmniKey, that lets you search different engines by keyword.
But:
- Safari 13 disables useful extesions, for mostly useless app extensions
- Safari 13 (or earlier?) also disables customizing the search engine

So we'll:
- create a simple redirection server in ruby
- hijack the search.yahoo.com domain, because who needs that anyway?
- add a simple search-reload method to live-reload the config json
    - this should be made into a nice web UI for editing in browser; i'm to lazy for that ATM though

License: BSD 2-Clause
