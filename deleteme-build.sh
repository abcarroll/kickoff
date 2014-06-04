#!/bin/bash

# Copyright (c) 2014 A.B. Carroll <ben@hl9.net>.
# This file is a part of Kickoff.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# ------------------------------------------------------------------------------

# TODO / Roadmap: 
# - Clean up startup -- the intro text is a bit harsh.
# - Unpacking and rm'ing should always occur in a tmp/ dir -- output to a
#   subdirectory, so it will mitigate issues from improper running or bugs in
#   the script.
# - Be able to reuse unzipped bootstrap, bootswatch, etc -- check for existence
#   prior to re-downloading & unpacking
# - Make entire process customizable from a stdin prompt.  Be able to use
#   this script for compiling an intial Kickoff as well as select the target 
#   variant you wish to use (i.e., remove all but one initializr-* file, and
#   the three .js files that would no longer be used, depending on variant)
# - Replace wget calls with a function that can select either wget or curl.
# - More options in regards to git repo's vs plain files (most from Github
#   still, but not git repos).  The Bootswatch repo is rather large, possibly
#   fetch via URL alternatively.
# - Currently fonts and are not being replaced with the 
#   repo's versions.   This is OK because right now they are exactly the same
#   but this might change in the future, especially just-after a new bootstrap
#   release before initializr has a chance to catch up.
# - Options regarding Less.js, Bootstrap, and Bootswatch HEAD vs Stable, etc.
# - Method for selection of jQuery version -- update jQuery, regardless!

url_lessjs=https://raw.github.com/less/less.js/master/dist/less-1.7.0.min.js
url_bootstrap=https://github.com/twbs/bootstrap/archive/v3.1.1.zip
git_bootswatch=https://github.com/thomaspark/bootswatch

# # # # # # # - - # # # # # # #
# You shouldn't need to edit  #
#  anything below this line!  #
# # # # # # # - - # # # # # # #

# The initializr site uses some odd javascript to generate these URLs.  This 
# particularly is "Twitter Bootstrap" + "Minified jQuery" (no dev) + All
# Optionals at the time of this writing:
# IE classes, Old Browser Warning, Google Analytics, .htaccess, Favicon, Apple
# Touch Icons, plugins.js, Robots.txt, Humans.txt, 404 Page, Adobe Cross Domain
# The "HTML 5 Polyfill" Section is handled in the INITIALIZR_VARIANTS loop,
# including the "Respond" checkbox.  You must have a ending '&' on this URL for
# it to work for this reason, as it will append each of the four available
# options [(HTML5/Modernizer)*(Respond/NoRespond)] in the INITIALIZR_VARIANTS
# loop. tl;dr Don't edit this manually, don't copy and paste the URLs directly
# as they will need the polyfill bit removed.

url_initializr_base="http://www.initializr.com/builder?boot-hero&jquerymin&h5bp-iecond&h5bp-chromeframe&h5bp-analytics&h5bp-htaccess&h5bp-favicon&h5bp-appletouchicons&h5bp-scripts&h5bp-robots&h5bp-humans&h5bp-404&h5bp-adobecrossdomain&boot-css&boot-scripts&"

# Which variants to use? Each will be appended to the above URL, downloaded,
# and processed.  To be specific, it will remove any '-'s for the above GET
# parm, while using the name with the '-' for it's index.html 
# (e.x. index.html -> html5shiv-respond.html downloaded from 
# url_initializr_base + 'html5shivrespond'
initializr_variants=(html5shiv html5shiv-respond modernizr modernizr-respond);

# It is possible to tell which are themes with some work, but it's easier just
# to include a static list. Make sure this is up to date!
bootswatch_themes=(amelia cerulean cosmo custom cyborg darkly flatly journal lumen readable simplex slate spacelab superhero united yeti);

# Passes this flag to mkdir, mv, and rm operations.  Can set to blank to make
# it less verbose or set to -v for lots of verbosity
verbose_switch=

# # # #                 # # # #
# ---------  Begin  --------- #
# # # #                 # # # #

if [[ $EUID == 0 ]]; then
  echo "Don't run this as root!"
  exit 1
fi

cwd=$(pwd)
echo --------------------------------------------------------------------------------
echo "This is NOT meant to be ran everytime you initiate a new project!              "
echo --------------------------------------------------------------------------------
echo "In fact, it's not meant to be ran by the end-user, ever. It is ONLY included if"
echo "we stop updating our repository, or if you want a highly customized build.     "
echo "Customization and updating must occur by manually updating this script.        "
echo --------------------------------------------------------------------------------
echo "The Kickoff ./build.sh could potentially overwrite and delete files, destroy   "
echo "working directories with clutter, and knock servers offline not even trying.   "
echo "Think twice, please.  Just delete this file from projects otherwise.           "
echo --------------------------------------------------------------------------------
echo "If you still want to build an entirely new Kickoff from scratch in:            "
pwd
echo "Then type below: 'I am either stupid or brave'.  The directory should be empty."
echo -n " > "
read yn_install

if [[ "I am either stupid or brave" != "$yn_install" ]]; then
  echo "Smart man (or woman)."
  echo "Exiting."
  exit 1
fi

# Initializr Handling -------------
echo "Downloading initializr zips and merging them..."
for iname in "${initializr_variants[@]}"; do
  urlname=$(echo "$iname" | sed 's/-//g')
  echo "Getting initializr variant '$iname'"
  wget "$url_initializr_base$urlname" -O "initializr-$iname.zip"
  echo "Unpacking..."
  unzip "initializr-$iname.zip"
  rm $verbose_switch "initializr-$iname.zip"
  echo "Merging..."
  mv $verbose_switch initializr/index.html ./initializr-$iname.html
  rsync -rlh $verbose_switch initializr/ ./
  rm -rf $verbose_switch initializr/
done

# Less.js Handling -------------------------------

echo "Downloading less.js ..."
wget "$url_lessjs" -O js/vendor/less.min.js

# Bootstrap Handling -----------------------------

echo "Downloading bootstrap source..."
wget "$url_bootstrap" -O bootstrap.zip

echo "Unpacking bootstrap..."
unzip bootstrap.zip

echo "Removing Archive"
rm $verbose_switch bootstrap.zip

echo "Moving bootstrap's less files into css/bootstrap/"
mv $verbose_switch bootstrap-*/less/*.* css/bootstrap/

echo "Making sure bootstrap's .js is up-to-date"
mv $verbose_switch bootstrap-*/dist/js/*.js js/vendor/

echo "Moving examples into a different directory structure."
mkdir $verbose_switch examples/
mv $verbose_switch bootstrap-*/docs/assets/js/docs.min.js examples/
mv $verbose_switch bootstrap-*/docs/assets/js/vendor/holder.js examples/
for example_dir in bootstrap-*/docs/examples/*/; do
  exname=$(basename "$example_dir")
	if [ -f "$example_dir/index.html" ]; then
	  mv $verbose_switch "$example_dir/index.html" "examples/$exname.html"
		if [ -f "$example_dir/$exname.css" ]; then
		  mv $verbose_switch "$example_dir/$exname.css" examples/
		fi
		if [ -f "$example_dir/$exname.js" ]; then
		  mv $verbose_switch "$example_dir/$exname.js" examples/
		fi
	fi
done

echo "Removing bootstrap stuff - we got what we wanted!"
rm -rf $verbose_switch bootstrap-*/

# Bootswatch Handling ----------------------------

echo "Getting bootswatch from github..."
git clone "$git_bootswatch"

echo "Moving variables.less + bootswatch.less into css/bootswatch/ for all themes..."
mkdir $verbose_switch css/bootswatch/
# Make sure this theme list is up to date!
for theme in "${bootswatch_themes[@]}"; do
	mkdir $verbose_switch "css/bootswatch/$theme";
	mv $verbose_switch "bootswatch/$theme/variables.less" "css/bootswatch/$theme/variables.less";
	mv $verbose_switch "bootswatch/$theme/bootswatch.less" "css/bootswatch/$theme/bootswatch.less";
done

echo "Removing bootswatch repository - we got what we wanted!"
rm -rf $verbose_switch bootswatch/


# Conversion Handling ----------------------------
# Converts the regular css-based initializr-* files
# and Bootstrap examples to use our style.less and the less.js
# compiler

echo "Converting initializr html files to use less.js..."
for working_file in initializr-*.html; do
  # Updates stylesheets to proper less.js sheet	
  perl -p -i'' -e 's#(\s+)<link rel="stylesheet" href="css/bootstrap\.min\.css">(\r?\n)#$1<link rel="stylesheet/less" type="text/css" href="css/style.less">$2$1<script src="js/vendor/less.min.js"></script>$2$2#' "$working_file"
  # Removes some junk lines no longer needed  
  perl -p -i'' -e 's#\s+<link rel="stylesheet" href="css/main\.css">\r?\n|\s+<link rel="stylesheet" href="css/bootstrap-theme.min.css">\r?\n##' "$working_file"
  # Changes 'Project Name' to 'Kickoff'
  perl -p -i'' -e "s#Project name#AB's Kickoff#" "$working_file"
  # And links the large button to "examples"
  perl -p -i'' -e 's#<a class="btn btn-primary btn-lg" role="button">Learn more &raquo;</a>#<a class="btn btn-primary btn-lg" role="button" href="./examples/index.html">View More Bootstrap Examples &raquo;</a>#' "$working_file"
done

echo "Converting twitter bootstrap examples to use less.js and fixing favicons.."
for working_file in examples/*.html; do
  # Updates stylesheets to proper less.js sheet
  perl -p -i'' -e 's#(\s+)<link href="../../dist/css/bootstrap\.min\.css" rel="stylesheet">(\r?\n)#$1<link rel="stylesheet/less" type="text/css" href="../css/style.less">$2$1<script src="../js/vendor/less.min.js"></script>$2$2#' "$working_file"
  # Updates Bootstrap's Javascript Properly
  perl -p -i'' -e 's#<script src="\.\./\.\./dist/js/bootstrap\.min\.js"></script>#<script src="../js/vendor/bootstrap.min.js"></script>#' "$working_file"  
  # Fix Favicon
  perl -p -i'' -e 's#<link rel="shortcut icon" href="../../assets/ico/favicon.ico">#<link rel="shortcut icon" href="../favicon.ico">#' "$working_file"
  # Removes this, who the hell uses IE8 to test their software?  We aren't including this .js ...
  perl -p -i'' -e 's#\s+<!-- Just for debugging purposes\. Don.t actually copy this line! -->\r?\n|\s+<!--\[if lt IE 9\]><script src="\.\./\.\./assets/js/ie8-responsive-file-warning\.js"></script><!\[endif\]-->\r?\n##' "$working_file"
  # We don't need to load this from a CDN, we already have this locally:
  perl -p -i'' -e 's#<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>#<script src="../js/vendor/jquery-1.11.0.min.js"></script>#' "$working_file"
  perl -p -i'' -e 's#<script src="../../assets/js/docs.min.js"></script>#<script src="./docs.min.js"></script>#' "$working_file"
  # Changes 'Project Name' to 'Kickoff' (same as above)
  perl -p -i'' -e "s#Project name#AB's Kickoff#" "$working_file"
done

# Static File Handling ---------------------------
# Write out some static files for the sake of keeping the entire system contained
# within one file.

echo "Writing out css/style.less..."

echo "// Kickoff - the magic happens here

// Include bootstrap base.  This will also include a base variables.less
@import \"bootstrap/bootstrap.less\";

// Include the bootswatch theme's variables.less and bootswatch.less
// bootswatch.less is equiv. to it's own "custom.css" which includes
// customizations not possible with variables alone.
// The default here is 'cosmo', out of the stock Bootswatch themes of:
// amelia cerulean cosmo custom cyborg darkly flatly journal lumen
// readable simplex slate spacelab superhero united yeti
// You might also be interested in the Bootswatchlet, available near
// the bottom of this URL: http://bootswatch.com/help/
@import \"bootswatch/cosmo/variables.less\";
@import \"bootswatch/cosmo/bootswatch.less\";

// These are your own files to modify and update as you see fit.  Note if
// you generate a FULL variables.less from Twitter's online generator, it
// WILL overwrite Bootswatch's.  Instead, pick and choose individual
// customizations if this is an issue.
@import \"variables.less\";
@import \"custom.less\";

// Do not remove it unless you are sure.
// See this URL for further reading on why this is re-included.
// http://coding.smashingmagazine.com/2013/03/12/customizing-bootstrap/
@import \"bootstrap/utilities.less\";

// Remember this file is meant for development and demos only!  You should
// use a real less compiler against this file and generate a compiled and
// minimized version of your CSS before deployment." > css/style.less

echo "Creating blank variables.less and custom.less"
echo '// YOUR CUSTOM VARIABLES GO HERE' > css/variables.less
echo '// YOUR CUSTOM CSS/LESS GOES HERE' > css/custom.less

echo "Cleaning up old CSS files to prevent confusion"
rm $verbose_switch css/*.css css/*.css.map;

# TODO tree is pretty nonstandard, make sure it exists
echo "Generating HTML Index Files with 'tree' utility..."
echo "(It's OK if this fails, just use autoindexing or equiv.)"

# Build index.html
tree -H "." --prune -P "*.html|README.md|/style.less" -T "AB's Kickoff (Index)" | perl -p -0777 -E 's#(\s+)<style type="text/css">.*?</style>#$1<link rel="stylesheet/less" type="text/css" href="css/style.less">$1<script src="js/vendor/less.min.js"></script>$1<style>body{margin:1em;}.VERSION{font-size:9pt;}</style>#ism' | perl -p -E 's#(\s+)(<p class="VERSION">)(\s+)#$1$2$3$1<strong>Directory Index Generated By:</strong><br>$3#'  > index.html

# Build examples/index.html
tree -H "." --prune -P "*.html" -T "Twitter Bootstrap Examples (Index)" examples/ | perl -p -0777 -E 's#(\s+)<style type="text/css">.*?</style>#$1<link rel="stylesheet/less" type="text/css" href="../css/style.less">$1<script src="../js/vendor/less.min.js"></script>$1<style>body{margin:1em;}.VERSION{font-size:9pt;}</style>#ism' | perl -p -E 's#(\s+)(<p class="VERSION">)(\s+)#$1$2$3$1<strong>Directory Index Generated By:</strong><br>$3#' > examples/index.html

# This .htaccess can cause 500 Errors on servers without AllowOverride All
mv .htaccess demo.htaccess

echo "Complete!"
