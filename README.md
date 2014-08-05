# Skin Makefile

This is a generic Makefile for fetching front end resources and compiling them.
It uses some custom extensions `.curl`, `.concat`, `.ugly`, `.min.dev.less`,
`.css.less` to avoid the need to edit/customize the Makefile for individual
projects.  Resources are found using curl, component, and bower.  The Makefile
will do an `include` for any files with the `.skin.mk` extension.

## Installing

The Makefile requires the following commands to be available:
curl glue lessc optipng uglifyjs cleancss component bower autoprefixer md5sum jq verify_version_spec stripmq

*See the install.sh*

## Using

Place this `Makefile` in a directory that has a 'static' directory and run::

  $ make

If you desire to not include compiled resources in version control then use the
`development` and `production` targets that make use of a MANIFEST file. So,
after done developing do a `make development` and include the MANIFEST in
version control.  On the production side: `make production` which will fail if
the checksums don't match.

### Using curl to get files

All files with the `.curl` extension are used as the config passed to curl.
The output is saved to the file name without the `.curl` extension. Example
`placeholder-700x400.png.curl`:: 

  url = http://placehold.it/700x400

### Combining files

A file with the extension `.concat` will be read line by line with each line
being a path to a file. These files will be combined into one and saved to the
filename without the `.concat` extension.  Example `abc.txt.concat`::

  path/to/a.txt
  path/to/some-other/b.txt
  2b.txt
  another-c.txt

### Minifying javascript files

Uses the [Uglify](https://github.com/mishoo/UglifyJS2) command.  Each file with
the `.ugly` extension should contain file paths that will be uglified. The name
of the uglified file is the ugly file without the `.ugly` extension.  How
pretty.  *Note: options can be passed in by adding them to the end of the ugly
file.* Example `path/to/example.min.js.ugly`::

  libs/widget-b.js
  libs/widget-a/dist/widget-example.js
  --comments
  --beautify ascii-only 


### CSS pre-processing with LESS

Each file with the extension `.min.dev.less` creates two css files; a minified
`.min.css` version and non-minified development `.dev.css`.  Also, the
extension `.css.less` can be used to not create a minified version and will be
saved to the filename without the `.less` extension.

The [lessc](http://lesscss.org/) command is used with the --depends option to
parse for all files that each less file depends on.  The command
[autoprefixer](https://github.com/ai/autoprefixer) is ran afterwards which adds
any browser specific prefixes to the css.

For example to create a `static/css/site.min.css` and `static/css/site.dev.css` from the
source file `static/css/site.min.dev.less` which imports `style-a.less` and
`vendor/style-b.less`::

  // static/css/site.min.dev.less
  @import "style-a";
  @import "vendor/style-b";

  .example-style {
    color: black;
  }

The minified css is done by [clean-css](https://www.npmjs.org/package/clean-css).

Use `.css.less` to only create a `.css` file. Example would be
`static/css/example.css` from `static/css/example.css.less`. These are not automatically
processed by the autoprefixer.

### Sprites generating with glue

This is a rather opinionated bit on how to do a setup for generating image
sprites with [glue](https://github.com/jorgebastida/glue/). The glue target
depends on any files that match `static/css/img/sprites/*.png` and`sprite.conf` within
the `static/css/img/sprites` directory. It will also use the `optipng` command to
compress the generated sprites file.  In the future this may be moved to it's
own `extra/glue.skin.mk`.

### Package management

If a `bower.json` is found in the current working directory then it will run
the `bower install` command.

If a `component.json` is found in the current working directory then the
`component install` and `component build` command will be run.
[Component](https://github.com/component/component) builds HTML, CSS and JS
files among other things.

### Verifying resources and commands

When first running the Makefile it will check for the availability of the
required commands and if the versions of them meet a certain specificiation.
All commands used can be changed like so::

  $ make CURL=/path/to/alternate-curl

The MANIFEST file is to make sure that the compiled resources like minified css
and js are the same.  It's created/updated when doing a `make development` and
is verified when doing `make production`. The `md5sum` command is used to
create checksums of all the generated files and outputs these to the MANIFEST
file.

### Extending the Makefile

The Makefile will do an `include` for any files with the `.skin.mk` extension.
See the extras directory.
