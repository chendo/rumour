# Rumour - A simple Mumble/Murmur channel viewer.

I didn't like the look of the existing perl and php examples so I had a shot at writing my own.

## Notes

The styling is non-existant at the moment, but pull requests welcome!

## Requirements

* Murmur with a working DBUS setup (look at the murmur docs on how to get this working)
* Ruby 1.9.2 (may work on other versions)

## Usage

    $ bundle
    $ bundle exec thin start -d
    # Go to http://<ip>:3000/

## License

Copyright (C) 2012 Jack Chen (chendo)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
