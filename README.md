# AB's Kickoff 
Yet another Bootstrap Bootstrap .

Kickoff is an amalgamation between: 

* Verekia's Initializr: HTML5BoilerPlate + HTML5Shiv, Modernizr, jQuery, Respond.js (some optional). [http://www.initializr.com/]
* Twitter Bootstrap: LESS version + Example Set with Modifications to work with Less.js [http://getbootstrap.com/]
* Bootswatch: A number of Bootstrap Themes, LESS Files [http://bootswatch.com/]
* Less.js: LESS Javascript Compiler for browsers [http://lesscss.org/]
* My own 'style.less' and methodology, and also a bash build tool.

##What is this stuff?

* Initializr is an mix of HTML5 Boilerplate and other very well known web development libraries such as jQuery, and some other misc. techniques, such as their 'boilerplate .htaccess', which I don't think comes with H5BP.  It also optionally comes with HTML5Shiv or Modernizer, and each of those options with or without Respond.js.  The most basic is HTML5Shiv without Respond.js.
* The Initializr's Twitter Bootstrap took the H5BP and applied it to a Twitter Bootstrap example to get both working together.
* Bootswatch is a collection of themes (and also, a way to manage themes, but that is not included here) for
  Twitter Bootstrap.  I've included them all here so you can quickly sift through them and get a base look for later customization.
* Less.js Javascript LESS compiler.  So, Bootstrap, your Bootswatch theme you'd like to use (if any), and your custom LESS/CSS can be ran directly from their LESS source from your browser during development.  When you are ready to distribute the project to browsers, proceed to compile the LESS into minified CSS for a final product.
* Twitter Examples are also included, which I feel are a nice way to get a feel for a Bootswatch theme, and what your front-end might look like very early on in the development process.  The Twitter example will pull from your master ''style.less''.
  
## How to use
Just clone this repository and probably delete our `.git/` directory and re-run `git init` to get a fresh repository.  The way Kickoff is built, with basic knowledge it should be easy to manually update components over a long term project.

After cloning the project just take a look around the repository.  You'll probably want to delete `./build.sh` after removing our `.git` directory.  After you select *which* Initializr `index-*.html` file you want to use, simply delete the other three and the corresponding three unused javascript files.  For example, if you want to use HTML5Shiv alone (most basic), rename the file `index-html5shiv.html` to `index.html` (or whatever you wish), and delete the other three corresponding `initializer-*.html` files, and the three corresponding javascript files, if you wish.

Once you've got that, you'll probably want to take a look at `css/style.less` which is the "core" of Kickoff, and is unique to Kickoff.  From here you can change and try different Bootswatch themes and see how things are laid out.  Included is a blank `variables.less` and `custom.less` file in the `css/` directory where custom modifications should go.  This will make updating Bootstrap and Bootswatch themes a snap.  Finally, you could peek in `examples/` at the same time you are looking and changing bootswatch themes to get a better feel for each theme and example file.

Also included is `./build.sh` which I used to automate the entire process from start to finish.  `./build.sh` is very powerful if used properly.  Just read the script -- it's not overly complicated.  It is, however, dangerous if you are careless, therefore it is advised to **delete it** if you aren't going to building your own custom version.  

**It's not necessary unless (a) You are building your own custom build, or (b) I stopped updating Kickoff and you wish to continue using it after everything is badly out of date.**  In the latter, you could use `./build.sh` to re-generate from the sources, after some minor manual updates/modifications to the script, and continue using Kickoff for long term projects even if I abandon it.  As a third possibility, (c) is you simply wish to understand how Kickoff works and how it is built.

**Note: ./build.sh is actually named ./deleteme-build.sh to bring more attention that this can normally be deleted.**

##Credit Due
* Bootstrap LESS + Javascript.  MIT License.  
* Bootstrap `examples/`: From Bootstrap Docs, and is probably licensed separately under the CC BY 3.0 License.  The .html files under examples/ *are modified* to use Less.js instead of a stock bootstrap.min.css.  Also included is `examples/holder.js` which is (C) 2012-2014 Ivan Malopinsky.
* Some files distributed by, and possibly modified and/or compiled by Initializr.  No license stated.
* HTML5Boilerplate.  MIT License. [http://html5boilerplate.com/]
* jQuery. MIT License. [http://jquery.org]
* HTML5Shiv. Dual licensed under the MIT or GPL Version 2.
* Modernizr.  MIT License. [http://lesscss.org].
* Respond.js.  MIT License, by Scott Jehl.
* Bootswatch. MIT License, by Thomas Park. [http://www.bootswatch.com]
* Less.js.  Apache License.  One single file, for development purposes only.  
* `./build.sh` is my code, and released under the MIT License.

## To Do, Planned Features, Known Issues
 * There is a To Do list in the top of `./build.sh` that explains some larger to-do items.
 * Feedback from users!
