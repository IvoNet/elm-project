#!/usr/bin/env bash
echo "Creating a basic elm project..."
if [ -z "$1" ]
then
    echo "Please provide a project name"
    echo "syntaxis: elm-project projectname"
    exit 1
fi

echo "Checking if required tools are available..."
nodecheck=`which node`
if [ "$nodecheck" = "" ]
then
  echo "Node.js does not seem to be installed."
  echo "Please do that first :-)"
  exit 1
fi

elmcheck=`which elm`
if [ "$elmcheck" = "" ]
then
   npm install -g elm
fi
elmcheck=`which elm-oracle`
if [ "$elmcheck" = "" ]
then
   npm install -g elm-oracle
fi
elmcheck=`which elm-format`
if [ "$elmcheck" = "" ]
then
   npm install -g elm-format
fi
elmcheck=`which elm-css`
if [ "$elmcheck" = "" ]
then
   npm install -g elm-css
fi

httpserver=`which http-server`
if [ "$httpserver" = "" ]
then
   npm install -g http-server
fi

echo "Creating folder structure..."
PROJECT_NAME=$1
mkdir $PROJECT_NAME
cd $PROJECT_NAME
mkdir resources
mkdir src

echo "Creating shell scripts..."
cat << EOF >dev
#!/usr/bin/env bash
open http://localhost:8000
elm-reactor
EOF
chmod +x dev

cat <<EOF >build
#!/usr/bin/env bash
mkdir target
elm-make src/main.elm --output target/main.js
cp -f resources/* ./target/
EOF
chmod +x build

cat <<EOF >prod
#!/usr/bin/env bash
build
cd target
open http://localhost:8080
http-server
cd ..
EOF
chmod +x prod

cat <<EOF >clean
#!/usr/bin/env bash
rm -rf target
EOF
chmod +x clean

echo "Creating html wrapper files..."
cat <<EOF >index.html
<!doctype html>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title>IvoNet - elm - reactor</title>
    <link rel="stylesheet" href="resources/style.css"/>
</head>
<body>
<script type="text/javascript" src="/_compile/src/main.elm"></script>

<script type="text/javascript">
    runElmProgram();
</script>
</body>
</html>
EOF

cat <<EOF >resources/index.html
<!doctype html>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title>IvoNet - elm</title>
    <link rel="stylesheet" href="style.css"/>
</head>
<body>
<div id="my-app"></div>
<script type="text/javascript" src="main.js"></script>

<script type="text/javascript">
    var node = document.getElementById('my-app');
    var app = Elm.Main.embed(node);
</script>
</body>
</html>
EOF

cat <<EOF > ./.gitignore
### IntelliJ
.idea

### macOS
*.DS_Store
.AppleDouble
.LSOverride

### elm
elm-stuff
target
EOF

echo "Creating hello world elm file..."
cat <<EOF >src/main.elm
import Html exposing (text)

main =
    text "hello, world!"
EOF

echo "Packaging..."
elm-package install --yes
touch resources/style.css

cat <<EOF
The project has been created here:
  $(pwd)
so first change to that folder...
run options:
  dev   -> to start elm in reactor mode
  build -> build production version in target
  prod  -> to build and run a target version
EOF
echo "Finished..."