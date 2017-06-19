#!/usr/bin/env bash
echo "Creating a basic elm project..."
if [ -z "$1" ]
then
    echo "Please provide a project name"
    echo "syntaxis: elm-project projectname"
    exit 1
fi

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
   npm install -g elm-oracle
   npm install -g elm-format
fi

check1=`which http-server`
if [ "$check1" = "" ]
then
   npm install -g http-server
fi

PROJECT_NAME=$1
mkdir $PROJECT_NAME
cd $PROJECT_NAME
mkdir dist
mkdir src

cat << EOF >dev
#!/usr/bin/env bash
open http://localhost:8000
elm-reactor
EOF
chmod +x dev

cat <<EOF >build
#!/usr/bin/env bash
elm-make src/main.elm --output dist/main.js
cp -f *.css ./dist/
EOF
chmod +x build

cat <<EOF >prod
#!/usr/bin/env bash
build
cd dist
open http://localhost:8080
http-server
cd ..
EOF
chmod +x prod

cat <<EOF >index.html
<!doctype html>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title>IvoNet - elm</title>
    <link rel="stylesheet" href="style.css"/>
</head>
<body>
<script type="text/javascript" src="/_compile/src/main.elm"></script>

<script type="text/javascript">
    runElmProgram();
</script>
</body>
</html>
EOF

cat <<EOF >dist/index.html
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

cat <<EOF >src/main.elm
import Html exposing (text)

main =
    text "hello, world!"
EOF

elm-package install --yes
touch style.css

cat <<EOF
The project has been created here:
  $(pwd)
so first change to that folder...
run options:
  dev   -> to start elm in reactor mode
  build -> build production version in dist
  prod  -> to build and run a dist version
EOF
